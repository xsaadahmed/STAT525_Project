# Independent audit, run after R/03_electricity_prices.R from project root.
source('R/validate_cleaned_data.R')
b <- readRDS('data/cleaned_data.rds')
x <- read.csv('data/external/usda_rucc_2013.csv',colClasses=c('character','integer'))
stopifnot(nrow(x)==3234,!anyDuplicated(x$county_fips),all(grepl('^[0-9]{5}$',x$county_fips)),
          sum(is.na(x$rucc_2013))==2,all(na.omit(x$rucc_2013) %in% 1:9))
b$rucc_2013 <- factor(x$rucc_2013[match(b$county_fips,x$county_fips)],levels=1:9)
d <- b[!is.na(b$rucc_2013),]
stopifnot(nrow(d)==3140,setequal(b$county_fips[is.na(b$rucc_2013)],c('02158','46102')))
out <- 'outputs/ray_electricity_prices'
a <- read.csv(file.path(out,'coefficients.csv')); cmp <- read.csv(file.path(out,'model_comparison.csv'))
same <- function(x,y) stopifnot(isTRUE(all.equal(as.numeric(x),as.numeric(y),tolerance=1e-10)))
for(scale in c('raw','log')) for(type in c('co2','rucc','joint')) {
  rows <- if(type=='co2') b else d
  y <- if(scale=='raw') rows$res_elec_price_usd_mwh else log(rows$res_elec_price_usd_mwh)
  emission <- rows$elec_co2e_tons_per_mwh; category <- rows$rucc_2013
  fit <- switch(type,co2=lm(y~emission),rucc=lm(y~category),joint=lm(y~emission+category))
  name <- paste(type,scale,sep='_'); tab <- a[a$model==name,]; c <- cmp[cmp$model==name,]
  same(tab$estimate,coef(fit));same(tab$se,coef(summary(fit))[,2]);same(tab$p_ols,coef(summary(fit))[,4])
  same(tab$ci_low,confint(fit)[,1]);same(tab$ci_high,confint(fit)[,2])
  same(c$n,nobs(fit));same(c$r_squared,summary(fit)$r.squared)
  if(type!='co2') stopifnot(ncol(model.matrix(fit))==if(type=='joint') 10 else 9)
  # Independent cluster meat as a sum of cluster-specific score outer products.
  X <- model.matrix(fit); bread <- chol2inv(chol(crossprod(X))); meat <- matrix(0,ncol(X),ncol(X))
  for(group in unique(rows$egrid_subregion)) {
    i <- which(rows$egrid_subregion==group)
    score <- crossprod(X[i,,drop=FALSE],resid(fit)[i]);meat <- meat+tcrossprod(score)
  }
  G <- length(unique(rows$egrid_subregion)); n <- nrow(rows); p <- ncol(X)
  se <- sqrt(diag(bread %*% meat %*% bread)*G/(G-1)*(n-1)/(n-p))
  same(tab$cluster_se,se);same(tab$cluster_p,2*pt(-abs(coef(fit)/se),G-1))
  same(tab$cluster_ci_low,coef(fit)-qt(.975,G-1)*se)
  same(tab$cluster_ci_high,coef(fit)+qt(.975,G-1)*se)
}
cat('PASS: canonical keys/coverage; six independently fitted factor models; OLS and eGRID-cluster inference.\n')
# Audit the three influence refits separately from the production script.
sens <- read.csv(file.path(out,'joint_log_sensitivity.csv'))
fit <- lm(log(res_elec_price_usd_mwh)~elec_co2e_tons_per_mwh+rucc_2013,d)
for(scenario in unique(sens$scenario)) {
 keep <- switch(scenario,all_complete=rep(TRUE,nrow(d)),
   without_max_cook=seq_len(nrow(d))!=which.max(cooks.distance(fit)),
   without_cook_screen=cooks.distance(fit)<=4/nrow(d))
 m <- lm(formula(fit),d[keep,]); rows <- sens[sens$scenario==scenario,]
 same(rows$estimate,coef(m));stopifnot(all(rows$n==sum(keep)))
}
cat('PASS: all three influence sensitivity fits; no primary deletions.\n')
