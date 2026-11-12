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
