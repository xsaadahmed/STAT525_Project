# Ray: electricity expenditure per MWh versus emissions intensity and USDA RUCC.
# Run from project root: Rscript R/03_electricity_prices.R. Base R only.
# Estimates are observational; no shared baseline or teammate files are written.
source('R/validate_cleaned_data.R')
source('R/00_merge_external_data.R')
county <- readRDS('data/cleaned_data.rds')
rucc <- read_canonical_external('data/external/usda_rucc_2013.csv','rucc_2013')
idx <- match(county$county_fips,rucc$county_fips)
county$rucc_2013 <- factor(rucc$rucc_2013[idx],levels=1:9,ordered=FALSE)
stopifnot(nrow(county)==3142L,!anyDuplicated(county$county_fips),
          all(county$res_elec_price_usd_mwh>0))
out <- 'outputs/ray_electricity_prices'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
export <- function(x,name) write.csv(x,file.path(out,paste0(name,'.csv')),row.names=FALSE,na='')
export(data.frame(county_fips=county$county_fips[is.na(county$rucc_2013)],
  county=county$county_state_name[is.na(county$rucc_2013)]),'missing_rucc')
d <- county[complete.cases(county[c('res_elec_price_usd_mwh','elec_co2e_tons_per_mwh','rucc_2013')]),]
# Emissions-only models use all counties; combined and RUCC models use complete RUCC.
models <- list(
  co2_raw=lm(res_elec_price_usd_mwh~elec_co2e_tons_per_mwh,county),
  rucc_raw=lm(res_elec_price_usd_mwh~rucc_2013,d),
  joint_raw=lm(res_elec_price_usd_mwh~elec_co2e_tons_per_mwh+rucc_2013,d),
  co2_log=lm(log(res_elec_price_usd_mwh)~elec_co2e_tons_per_mwh,county),
  rucc_log=lm(log(res_elec_price_usd_mwh)~rucc_2013,d),
  joint_log=lm(log(res_elec_price_usd_mwh)~elec_co2e_tons_per_mwh+rucc_2013,d))
# Sensitivity to shared eGRID regions: cluster sandwich CR1 with G-1 t reference.
# Only 26 groups; this does not resolve spatial correlation across regions,
# confounding, or bias in modeled source estimates. Classical inference is exploratory.
coefficient_table <- function(m,name,rows) {
  a <- coef(summary(m)); ci <- confint(m); X <- model.matrix(m)
  group <- rows$egrid_subregion; G <- length(unique(group)); n <- nobs(m); p <- ncol(X)
  scores <- rowsum(X*as.vector(resid(m)),group,reorder=FALSE)
  inv <- solve(crossprod(X))
  cov <- G/(G-1)*(n-1)/(n-p)*inv %*% crossprod(scores) %*% inv
  se <- sqrt(diag(cov)); crit <- qt(.975,G-1)
  data.frame(model=name,term=rownames(a),estimate=a[,1],se=a[,2],p_ols=a[,4],
    ci_low=ci[,1],ci_high=ci[,2],egrid_groups=G,cluster_se=se,
    cluster_ci_low=a[,1]-crit*se,cluster_ci_high=a[,1]+crit*se,
    cluster_p=2*pt(-abs(a[,1]/se),G-1),row.names=NULL)
}
coefficients <- do.call(rbind,lapply(names(models),function(name) {
  rows <- if(grepl('^co2_',name)) county else d
  coefficient_table(models[[name]],name,rows)
}))
export(coefficients,'coefficients')
comparison <- do.call(rbind,lapply(names(models),function(name) {
  m <- models[[name]]; s <- summary(m)
  aux <- lm(I(resid(m)^2)~fitted(m)); bp <- nobs(m)*summary(aux)$r.squared
  data.frame(model=name,n=nobs(m),response_scale=if(grepl('_log$',name)) 'ln(USD/MWh)' else 'USD/MWh',
    r_squared=s$r.squared,adjusted_r_squared=s$adj.r.squared,residual_se=s$sigma,
    bp_style_p=pchisq(bp,1,lower.tail=FALSE),max_cook=max(cooks.distance(m)),
    cook_flags=sum(cooks.distance(m)>4/nobs(m)),studentized_over3=sum(abs(rstudent(m))>3))
}))
export(comparison,'model_comparison')
# Correct omnibus tests for a nine-level factor, rather than a numeric trend t-test.
full <- models$joint_log
rucc_test <- anova(lm(log(res_elec_price_usd_mwh)~elec_co2e_tons_per_mwh,d),full)
co2_test <- anova(models$rucc_log,full)
export(data.frame(term=c('rucc_2013 (8 df)','elec_co2e_tons_per_mwh (1 df)'),
  F=c(rucc_test$F[2],co2_test$F[2]),p_ols=c(rucc_test$`Pr(>F)`[2],co2_test$`Pr(>F)`[2])),
  'joint_log_omnibus')
group_summary <- do.call(rbind,lapply(levels(d$rucc_2013),function(level) {
  x <- d$res_elec_price_usd_mwh[d$rucc_2013==level]
  data.frame(rucc_2013=level,n=length(x),mean_usd_mwh=mean(x),median_usd_mwh=median(x),sd_usd_mwh=sd(x))
}))
export(group_summary,'rucc_summary')
influence <- data.frame(d[c('county_fips','county_state_name','res_elec_price_usd_mwh','rucc_2013','egrid_subregion')],
  leverage=hatvalues(full),studentized=rstudent(full),cook=cooks.distance(full))
export(influence[influence$cook>4/nrow(d) | abs(influence$studentized)>3 | influence$leverage>2*length(coef(full))/nrow(d),],
       'joint_log_flagged_counties')
# Sensitivity is not a deletion recommendation; primary fits keep valid observations.
sensitivity <- do.call(rbind,lapply(c('all_complete','without_max_cook','without_cook_screen'),function(scenario) {
  keep <- switch(scenario,all_complete=rep(TRUE,nrow(d)),
    without_max_cook=seq_len(nrow(d))!=which.max(cooks.distance(full)),
    without_cook_screen=cooks.distance(full)<=4/nrow(d))
  m <- lm(formula(full),d[keep,]); data.frame(scenario=scenario,n=nobs(m),term=names(coef(m)),estimate=coef(m),row.names=NULL)
}))
export(sensitivity,'joint_log_sensitivity')
# Association of a continuous predictor with factor categories: no Pearson r on RUCC codes.
export(data.frame(measure=c('price_emissions_Pearson','price_emissions_Spearman','emissions_variance_explained_by_RUCC'),
  value=c(cor(county$res_elec_price_usd_mwh,county$elec_co2e_tons_per_mwh),
    cor(county$res_elec_price_usd_mwh,county$elec_co2e_tons_per_mwh,method='spearman'),
    summary(lm(elec_co2e_tons_per_mwh~rucc_2013,d))$r.squared)),'associations')
figure <- function(name,w=1600,h=1000) {
  png(file.path(out,paste0(name,'.png')),width=w,height=h,res=160)
  par(mar=c(4.5,4.5,3,2),las=1)
}
figure('distributions',1800,700);par(mfrow=c(1,3))
hist(county$res_elec_price_usd_mwh,breaks=35,col='lightblue',main='Residential electricity expenditure',xlab='USD/MWh')
hist(county$elec_co2e_tons_per_mwh,breaks=25,col='lightblue',main='Electricity emissions intensity',xlab='Metric tons CO2e/MWh')
barplot(table(d$rucc_2013),col='lightblue',main='USDA RUCC 2013 (categorical)',xlab='Code (1-3 metro; 4-9 nonmetro)',ylab='Counties')
dev.off()
figure('relationships',1700,800);par(mfrow=c(1,2))
plot(county$elec_co2e_tons_per_mwh,county$res_elec_price_usd_mwh,pch=16,col=adjustcolor('steelblue',.3),
  xlab='Metric tons CO2e/MWh',ylab='Residential expenditure (USD/MWh)',main='Price versus emissions intensity')
abline(models$co2_raw,col='firebrick',lwd=2)
boxplot(res_elec_price_usd_mwh~rucc_2013,d,col='lightblue',xlab='RUCC 2013 (unordered categories)',
  ylab='Residential expenditure (USD/MWh)',main='Price by county classification')
dev.off()
for(name in names(models)) {
  rows <- if(grepl('^co2_',name)) county else d
  figure(paste0('diagnostics_',name));par(mfrow=c(2,2))
  plot(models[[name]],which=c(1,2,3,5),labels.id=rows$county_fips,id.n=3,cex=.4)
  dev.off()
}
writeLines(c(sprintf('Baseline n=3142; complete RUCC n=%d; excluded from RUCC/joint models=%d.',nrow(d),3142-nrow(d)),
  'Baseline remains unchanged. RUCC reference category=1; unordered levels=1:9.',
  'Log outcomes require strictly positive observed expenditure per MWh.',
  'Q-Q plots assess residuals, not normality of predictors.',
  'Model comparison across raw/log response scales is not a direct ranking of R2 or residual SE.',
  trimws(capture.output(sessionInfo()),which='right')),file.path(out,'execution.txt'))
