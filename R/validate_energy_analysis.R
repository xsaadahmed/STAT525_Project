# Independent output audit; run from project root after the analysis.
# Base R only. Stops on mismatch rather than silently refreshing results.
source('R/validate_cleaned_data.R')
d <- readRDS('data/cleaned_data.rds')
out <- 'outputs/saad_energy_consumption'
read_output <- function(nm) read.csv(file.path(out,paste0(nm,'.csv')),check.names=FALSE)
a <- read_output('model_coefficients'); cmp <- read_output('model_comparison')
forms <- list(
  gas_simple=res_elec_mwh_pc~res_gas_mcf_pc,
  gasoline_simple=res_elec_mwh_pc~gasoline_gal_pc,
  raw_multiple=res_elec_mwh_pc~res_gas_mcf_pc+gasoline_gal_pc,
  log_gasoline_multiple=res_elec_mwh_pc~res_gas_mcf_pc+log(gasoline_gal_pc),
  quadratic_gas_log_gasoline=res_elec_mwh_pc~res_gas_mcf_pc+I(res_gas_mcf_pc^2)+log(gasoline_gal_pc))
same <- function(x,y) stopifnot(isTRUE(all.equal(as.numeric(x),as.numeric(y),tolerance=1e-10)))
for(nm in names(forms)) {
  m <- lm(forms[[nm]],d); tab <- a[a$model==nm,]; c <- cmp[cmp$model==nm,]
  # Coefficient ordering is intercept, gas (and square if present), gasoline.
  same(tab$estimate,coef(m)); same(tab$std_error,coef(summary(m))[,2])
  same(tab$p_value,coef(summary(m))[,4]); same(tab$ci_low,confint(m)[,1])
  same(tab$ci_high,confint(m)[,2]); same(c$r_squared,summary(m)$r.squared)
  same(c$adjusted_r_squared,summary(m)$adj.r.squared); same(c$residual_se,sigma(m))
  stopifnot(c$n==3142L,nobs(m)==3142L)
  # HC3 via weighted design and QR inverse, independently of script's crossprod inverse.
  X <- model.matrix(m); qr_inv <- chol2inv(qr.R(qr(X)))
  U <- X*as.vector(residuals(m)/(1-hatvalues(m)))
  robust_se <- sqrt(diag(qr_inv %*% crossprod(U) %*% qr_inv))
  same(tab$hc3_se,robust_se)
}
s <- read_output('descriptive_statistics')
for(v in s$variable) {
  row <- s[s$variable==v,]; x <- d[[v]]
  same(row$mean,mean(x)); same(row$sd,sd(x)); same(row$median,median(x))
  same(row$min,min(x)); same(row$max,max(x)); same(row$iqr,IQR(x))
  stopifnot(row$n==3142,row$missing==0,row$zeros==sum(x==0))
}
stopifnot(sum(log1p(d$res_gas_mcf_pc)==0)==9,
  all(is.finite(log1p(d$res_gas_mcf_pc))),all(is.finite(log(d$gasoline_gal_pc))))
# Validate every sensitivity sample size and slope from its explicit rule.
sens <- read_output('sensitivity_coefficients')
for(nm in names(forms)) {
  m <- lm(forms[[nm]],d)
  keep <- list(all_counties=rep(TRUE,nrow(d)),without_loving=d$county_fips!='48301',
    without_most_influential=seq_len(nrow(d))!=which.max(cooks.distance(m)),
    without_cook_screen=cooks.distance(m)<=4/nrow(d))
  for(scenario in names(keep)) {
    rows <- sens[sens$model==nm & sens$scenario==scenario,]
    fit <- lm(forms[[nm]],d[keep[[scenario]],])
    same(rows$estimate,coef(fit)); stopifnot(all(rows$n==sum(keep[[scenario]])),
      all(rows$removed==sum(!keep[[scenario]])))
  }
}
cat('PASS: five independently refitted model tables, OLS inference, HC3 SEs,\n')
cat('descriptive summaries, all 20 sensitivity fits, sample sizes and zero handling.\n')
# Focused audit corrections: independently reconstruct from baseline, not script objects.
expected_r2 <- c(.116349261385061,.00301015368581285,.117689959658247,
                 .136394901399443,.186268455476854)
same(cmp$r_squared,expected_r2)
raw_gasoline <- subset(a,model=='raw_multiple' & term=='gasoline_gal_pc')
stopifnot(abs(raw_gasoline$p_value-.0290367815176457)<1e-10,
          abs(raw_gasoline$hc3_p_value-.115852902081477)<1e-10)
# Also verify the HC3 residual-df t reference, not merely its standard errors.
for(nm in names(forms)) {
  fit <- lm(forms[[nm]],d); rows <- a[a$model==nm,]
  crit <- qt(.975,df.residual(fit))
  same(rows$hc3_ci_low,coef(fit)-crit*rows$hc3_se)
  same(rows$hc3_ci_high,coef(fit)+crit*rows$hc3_se)
  same(rows$hc3_p_value,2*pt(-abs(coef(fit)/rows$hc3_se),df.residual(fit)))
}
# Rebuild balanced seeded folds and count each test prediction explicitly.
set.seed(525)
fold <- sample(rep(seq_len(10),length.out=nrow(d)))
stopifnot(max(tabulate(fold))-min(tabulate(fold))<=1L)
cv_rmse <- numeric(length(forms)); names(cv_rmse) <- names(forms)
for(nm in names(forms)) {
  prediction <- rep(NA_real_,nrow(d)); visits <- integer(nrow(d))
  for(k in seq_len(10)) {
    test <- which(fold==k); train <- which(fold!=k)
    stopifnot(length(intersect(train,test))==0L)
    fit <- lm(forms[[nm]],data=d[train,])
    prediction[test] <- predict(fit,newdata=d[test,])
    visits[test] <- visits[test]+1L
  }
  stopifnot(all(visits==1L),all(is.finite(prediction)))
  cv_rmse[nm] <- sqrt(sum((d$res_elec_mwh_pc-prediction)^2)/nrow(d))
  same(cmp$cv_rmse[cmp$model==nm],cv_rmse[nm])
}
cat('PASS: common seeded folds; exactly one OOF prediction per county per model. RMSE:\n')
print(cv_rmse,digits=10)
# Check both R2 denominators for each existing term, retaining polynomial caveat.
part <- read_output('partial_r_squared')
d$log_gasoline <- log(d$gasoline_gal_pc)
for(nm in names(forms)[3:5]) {
  form <- switch(nm,
    raw_multiple=res_elec_mwh_pc~res_gas_mcf_pc+gasoline_gal_pc,
    log_gasoline_multiple=res_elec_mwh_pc~res_gas_mcf_pc+log_gasoline,
    quadratic_gas_log_gasoline=res_elec_mwh_pc~res_gas_mcf_pc+I(res_gas_mcf_pc^2)+log_gasoline)
  full <- lm(form,d); terms <- attr(terms(full),'term.labels')
  for(term in terms) {
    reduced <- lm(reformulate(setdiff(terms,term),response='res_elec_mwh_pc'),d)
    # Direct squared residual sums provide a separate SSE computation.
    ss0 <- sum(resid(reduced)^2); ss1 <- sum(resid(full)^2)
    total <- sum((d$res_elec_mwh_pc-mean(d$res_elec_mwh_pc))^2)
    partial <- (ss0-ss1)/ss0; delta <- (ss0-ss1)/total
    row <- part[part$model==nm & part$term==term,]
    same(row$partial_r_squared,partial); same(row$delta_r_squared,delta)
    same(delta,(1-summary(reduced)$r.squared)*partial)
  }
}
cat('PASS: delta R2 and partial R2 denominators and identity for all terms.\n')
# Full-data tail and a separate geographic refit using the direct log formula.
geo <- read_output('geographic_sensitivity'); states <- read_output('gas_upturn_tail_by_state')
full <- lm(forms$quadratic_gas_log_gasoline,d)
b <- coef(full); turning <- -b[2]/(2*b[3]); tail <- d[d$res_gas_mcf_pc>turning,]
stopifnot(nrow(tail)==60L,sum(tail$state_abbr=='NE')==36L,sum(tail$state_abbr=='IL')==13L)
stopifnot(setequal(states$state_abbr,unique(tail$state_abbr)))
for(state in states$state_abbr) {
  same(states$count_above_full_minimum[states$state_abbr==state],sum(tail$state_abbr==state))
}
same(states$full_minimum_mcf_pc,rep(unname(turning),nrow(states)))
for(scenario in c('all_counties','without_NE_IL')) {
  sample <- if(scenario=='all_counties') d else d[!d$state_abbr %in% c('NE','IL'),]
  fit <- lm(forms$quadratic_gas_log_gasoline,sample); b <- coef(fit)
  observed <- range(sample$res_gas_mcf_pc); slopes <- b[2]+2*b[3]*observed
  minimum <- -b[2]/(2*b[3]); row <- geo[geo$scenario==scenario,]
  stopifnot(row$n==nrow(sample)); same(row$gas_linear,b[2]); same(row$gas_squared,b[3])
  same(c(row$gas_min,row$gas_max),observed); same(row$implied_minimum,minimum)
  same(c(row$derivative_at_min,row$derivative_at_max),slopes)
  stopifnot(row$minimum_within_range==(minimum>=observed[1] && minimum<=observed[2]),
    row$observed_rising_limb==(b[3]>0 && slopes[1]<0 && slopes[2]>0))
  if(scenario=='all_counties') stopifnot(slopes[1]<0,slopes[2]>0) else {
    stopifnot(nrow(sample)==2947L,all(slopes<0),minimum>max(sample$res_gas_mcf_pc))
  }
}
cat('PASS: 60 tail counties (NE 36, IL 13); full/excluded derivatives and observed ranges.\n')
print(geo,digits=10,row.names=FALSE)
# Compare recorded actual production viewport with independently computed limits.
# Also draw an independent exact viewport on a temporary device to check R behavior.
zoom <- read_output('relationship_zoom_bounds')
device_path <- tempfile(fileext='.pdf'); pdf(device_path)
for(v in c('res_gas_mcf_pc','gasoline_gal_pc')) {
  x <- d[[v]]; limits <- c(min(x),as.numeric(quantile(x,.99,type=7)))
  plot(x,d$res_elec_mwh_pc,xlim=limits,xaxs='i')
  same(par('usr')[1:2],limits)
  row <- zoom[zoom$variable==v,]
  same(c(row$lower,row$upper),limits); same(c(row$usr_lower,row$usr_upper),limits)
  stopifnot(row$count_above_upper==sum(x>limits[2]),sum(x>limits[2])==32L)
}
dev.off(); unlink(device_path)
cat('PASS: exact minimum/99th-percentile viewport and 32 strict exceedances per predictor.\n')
