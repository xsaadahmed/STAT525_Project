# Saad: run from the project root: Rscript R/01_energy_consumption.R
# Analysis needs base R only; Rmd rendering needs knitr, rmarkdown and Pandoc.
# No shared data, preparation scripts or teammate files are written.
run_energy_analysis <- function(out = 'outputs/saad_energy_consumption') {
  source('R/validate_cleaned_data.R', local=TRUE)
  county <- readRDS('data/cleaned_data.rds')
  vars <- c('res_elec_mwh_pc','res_gas_mcf_pc','gasoline_gal_pc')
  labels <- c('Residential electricity (MWh/person)',
              'Residential natural gas (Mcf/person)', 'On-road gasoline (gallons/person)')
  stopifnot(nrow(county)==3142L, ncol(county)==19L,
    all(vapply(county[vars],is.numeric,logical(1))), !anyNA(county[vars]),
    all(is.finite(as.matrix(county[vars]))), all(county$res_gas_mcf_pc>=0),
    all(county$gasoline_gal_pc>0))
  d <- county # All counties retained; no imputation, weighting or winsorization.
  d$log_gasoline <- log(d$gasoline_gal_pc)
  d$log1p_gas <- log1p(d$res_gas_mcf_pc) # Preserves nine genuine zeros.
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  csv <- function(x,nm) write.csv(x,file.path(out,paste0(nm,'.csv')),row.names=FALSE,na='')
  descriptives <- do.call(rbind,lapply(seq_along(vars),function(j) {
    x <- d[[vars[j]]]
    data.frame(variable=vars[j],units=labels[j],n=length(x),missing=sum(is.na(x)),
      zeros=sum(x==0),mean=mean(x),median=median(x),sd=sd(x),min=min(x),
      q1=unname(quantile(x,.25)),q3=unname(quantile(x,.75)),iqr=IQR(x),max=max(x),
      skewness=mean((x-mean(x))^3)/mean((x-mean(x))^2)^1.5)
  }))
  csv(descriptives,'descriptive_statistics')
  correlations <- do.call(rbind,lapply(list(c(1,2),c(1,3),c(2,3)),function(z) {
    data.frame(variable1=vars[z[1]],variable2=vars[z[2]],
      pearson=cor(d[[vars[z[1]]]],d[[vars[z[2]]]]),
      spearman=cor(d[[vars[z[1]]]],d[[vars[z[2]]]],method='spearman'))
  }))
  csv(correlations,'correlations')
  # Limited alternatives: compress gasoline's tail, then allow the curvature
  # visible in the natural-gas scatterplot. Response remains in original MWh/person units.
  models <- list(
    gas_simple=lm(res_elec_mwh_pc~res_gas_mcf_pc,d),
    gasoline_simple=lm(res_elec_mwh_pc~gasoline_gal_pc,d),
    raw_multiple=lm(res_elec_mwh_pc~res_gas_mcf_pc+gasoline_gal_pc,d),
    log_gasoline_multiple=lm(res_elec_mwh_pc~res_gas_mcf_pc+log_gasoline,d),
    quadratic_gas_log_gasoline=lm(res_elec_mwh_pc~res_gas_mcf_pc+I(res_gas_mcf_pc^2)+log_gasoline,d))
  # HC3 inference is a variance sensitivity check, not a remedy for spatial
  # dependence, confounding or incorrect functional form.
  coefficient_table <- function(m,nm) {
    a <- coef(summary(m)); ci <- confint(m); X <- model.matrix(m)
    inv <- solve(crossprod(X)); w <- residuals(m)^2/(1-hatvalues(m))^2
    se <- sqrt(diag(inv %*% crossprod(X,X*w) %*% inv))
    crit <- qt(.975,df.residual(m))
    data.frame(model=nm,term=rownames(a),estimate=a[,1],std_error=a[,2],t=a[,3],
      p_value=a[,4],ci_low=ci[,1],ci_high=ci[,2],hc3_se=se,
      hc3_ci_low=a[,1]-crit*se,hc3_ci_high=a[,1]+crit*se,
      hc3_p_value=2*pt(-abs(a[,1]/se),df.residual(m)),row.names=NULL)
  }
  coefficients <- do.call(rbind,Map(coefficient_table,models,names(models)))
  csv(coefficients,'model_coefficients')
  # Same response/folds: comparable original-scale RMSE. Random folds measure
  # interpolation, not performance in geographically independent regions.
  set.seed(525); folds <- sample(rep(1:10,length.out=nrow(d)))
  comparison <- do.call(rbind,lapply(names(models),function(nm) {
    m <- models[[nm]]; s <- summary(m); pred <- rep(NA_real_,nrow(d))
    for(k in 1:10) {
      fit <- lm(formula(m),d[folds!=k,])
      pred[folds==k] <- predict(fit,newdata=d[folds==k,])
    }
    data.frame(model=nm,n=nobs(m),r_squared=s$r.squared,
      adjusted_r_squared=s$adj.r.squared,residual_se=s$sigma,
      cv_rmse=sqrt(mean((d$res_elec_mwh_pc-pred)^2)),
      max_leverage=max(hatvalues(m)),max_cook=max(cooks.distance(m)))
  }))
  csv(comparison,'model_comparison')
  vif <- do.call(rbind,lapply(names(models)[3:5],function(nm) {
    X <- model.matrix(models[[nm]])[,-1,drop=FALSE]
    values <- vapply(seq_len(ncol(X)),function(j) {
      1/(1-summary(lm(X[,j]~X[,-j,drop=FALSE]))$r.squared)
    },numeric(1))
    data.frame(model=nm,term=colnames(X),vif=values)
  }))
  csv(vif,'vif')
  diagnostics <- do.call(rbind,lapply(names(models),function(nm) {
    m <- models[[nm]]; n <- nobs(m); p <- length(coef(m))
    # BP-style n*R2 auxiliary check using fitted values, one degree of freedom.
    aux <- lm(I(residuals(m)^2)~fitted(m)); stat <- n*summary(aux)$r.squared
    data.frame(model=nm,bp_statistic=stat,bp_p_value=pchisq(stat,1,lower.tail=FALSE),
      abs_resid_fitted_spearman=cor(abs(residuals(m)),fitted(m),method='spearman'),
      residual_skewness=mean(residuals(m)^3)/mean(residuals(m)^2)^1.5,
      n_high_leverage=sum(hatvalues(m)>2*p/n),
      n_cook_screen=sum(cooks.distance(m)>4/n),
      n_studentized_over3=sum(abs(rstudent(m))>3))
  }))
  csv(diagnostics,'diagnostic_summary')
  extremes <- do.call(rbind,lapply(seq_along(vars),function(j) {
    x <- d[[vars[j]]]; q <- quantile(x,c(.25,.75))
    i <- which(x<q[1]-1.5*IQR(x) | x>q[2]+1.5*IQR(x))
    data.frame(variable=vars[j],d[i,c('county_fips','county_state_name','population')],value=x[i],row.names=NULL)
  }))
  csv(extremes,'exploratory_extremes')
  csv(d[d$res_gas_mcf_pc==0,c('county_fips','county_state_name',vars)],'natural_gas_zeros')
  influence <- do.call(rbind,lapply(names(models),function(nm) {
    m <- models[[nm]]; n <- nobs(m); p <- length(coef(m))
    data.frame(model=nm,d[c('county_fips','county_state_name','population',vars)],
      leverage=hatvalues(m),studentized_residual=rstudent(m),cook=cooks.distance(m),
      high_leverage=hatvalues(m)>2*p/n,cook_screen=cooks.distance(m)>4/n,row.names=NULL)
  }))
  csv(influence[influence$high_leverage | influence$cook_screen |
    abs(influence$studentized_residual)>3,],'flagged_counties')
  # Diagnostic exclusions only; primary models always retain all counties.
  sensitivity <- do.call(rbind,lapply(names(models),function(nm) {
    m <- models[[nm]]
    sets <- list(all_counties=rep(TRUE,nrow(d)),without_loving=d$county_fips!='48301',
      without_most_influential=seq_len(nrow(d))!=which.max(cooks.distance(m)),
      without_cook_screen=cooks.distance(m)<=4/nrow(d))
    do.call(rbind,lapply(names(sets),function(scenario) {
      keep <- sets[[scenario]]; fit <- lm(formula(m),d[keep,])
      cbind(scenario=scenario,n=sum(keep),removed=sum(!keep),coefficient_table(fit,nm),
        adjusted_r_squared=summary(fit)$adj.r.squared)
    }))
  }))
  csv(sensitivity,'sensitivity_coefficients')
  partial_r2 <- do.call(rbind,lapply(names(models)[3:5],function(nm) {
    m <- models[[nm]]; terms <- attr(terms(m),'term.labels')
    do.call(rbind,lapply(terms,function(term) {
      reduced <- lm(reformulate(setdiff(terms,term),response='res_elec_mwh_pc'),d)
      data.frame(model=nm,term=term,
        partial_r_squared=(deviance(reduced)-deviance(m))/deviance(reduced))
    }))
  }))
  csv(partial_r2,'partial_r_squared')
  png_plot <- function(nm,width=1800,height=1200) {
    png(file.path(out,paste0(nm,'.png')),width=width,height=height,res=180)
    par(mar=c(4.3,4.5,3,1),mgp=c(2.8,.7,0),las=1,
      col.axis='#334155',col.lab='#172554',col.main='#172554')
  }
  blue <- adjustcolor('#2563A6',alpha.f=.3)
  png_plot('01_distributions',1800,1500); par(mfrow=c(3,2))
  for(j in seq_along(vars)) {
    hist(d[[vars[j]]],breaks=40,col='#8BBAD9',border='white',main=labels[j],xlab=labels[j])
    boxplot(d[[vars[j]]],horizontal=TRUE,col='#8BBAD9',main='Full-range boxplot',xlab=labels[j])
  }; dev.off()
  png_plot('02_relationships',1800,1350); par(mfrow=c(2,2))
  for(j in 2:3) {
    x <- d[[vars[j]]]; y <- d$res_elec_mwh_pc
    plot(x,y,pch=16,cex=.5,col=blue,xlab=labels[j],ylab=labels[1],main='All counties: original scale')
    abline(models[[j-1]],col='#B91C1C',lwd=2); lines(lowess(x,y),col='#047857',lwd=2)
    legend('topright',c('OLS','LOWESS'),col=c('#B91C1C','#047857'),lty=1,bty='n',cex=.8)
    plot(x,y,pch=16,cex=.5,col=blue,xlab=labels[j],ylab=labels[1],
      xlim=quantile(x,c(0,.99)),main='Zoom: X <= 99th percentile')
    abline(models[[j-1]],col='#B91C1C',lwd=2); lines(lowess(x,y),col='#047857',lwd=2)
    mtext(sprintf('%d counties outside view; fits use all',sum(x>quantile(x,.99))),side=3,cex=.65,line=.2)
  }; dev.off()
  png_plot('03_transformed_relationships',1800,800); par(mfrow=c(1,2))
  for(xnm in c('log1p_gas','log_gasoline')) {
    x <- d[[xnm]]; y <- d$res_elec_mwh_pc
    plot(x,y,pch=16,cex=.5,col=blue,
      xlab=if(xnm=='log1p_gas') 'ln(1 + gas in Mcf/person)' else 'ln(gasoline in gallons/person)',
      ylab=labels[1],main='All counties: transformed predictor')
    abline(lm(y~x),col='#B91C1C',lwd=2); lines(lowess(x,y),col='#047857',lwd=2)
    legend('topright',c('Simple OLS','LOWESS'),col=c('#B91C1C','#047857'),lty=1,bty='n',cex=.8)
  }; dev.off()
  for(nm in names(models)) {
    png_plot(paste0('diagnostics_',nm)); par(mfrow=c(2,2))
    plot(models[[nm]],which=c(1,2,3,5),id.n=3,cex=.45,labels.id=d$county_fips)
    dev.off()
  }
  png_plot('04_influence',1800,850); par(mfrow=c(1,2))
  for(nm in c('raw_multiple','quadratic_gas_log_gasoline')) {
    cook <- cooks.distance(models[[nm]])
    plot(cook,type='h',xlab='County row (original order)',ylab="Cook's distance",main=nm,col='#2563A6')
    abline(h=4/nrow(d),lty=2,col='#B91C1C'); i <- head(order(cook,decreasing=TRUE),3)
    text(i,cook[i],labels=d$county_fips[i],pos=ifelse(i>nrow(d)/2,2,4),cex=.7)
  }; dev.off()
  png_plot('05_preliminary_model',1800,850); par(mfrow=c(1,2))
  m <- models$quadratic_gas_log_gasoline
  baseline <- d
  baseline$log_gasoline <- median(d$log_gasoline)
  adjusted_y <- residuals(m) + predict(m,newdata=baseline)
  plot(d$res_gas_mcf_pc,adjusted_y,pch=16,cex=.5,col=blue,
    xlab=labels[2],ylab='Adjusted electricity (MWh/person)',main='Gas curve: gasoline held at median')
  grid <- seq(min(d$res_gas_mcf_pc),max(d$res_gas_mcf_pc),length.out=300)
  lines(grid,predict(m,newdata=data.frame(res_gas_mcf_pc=grid,
    log_gasoline=median(d$log_gasoline))),col='#B91C1C',lwd=2)
  baseline <- d; baseline$res_gas_mcf_pc <- median(d$res_gas_mcf_pc)
  adjusted_y <- residuals(m)+predict(m,newdata=baseline)
  plot(d$log_gasoline,adjusted_y,pch=16,cex=.5,col=blue,
    xlab='ln(gasoline in gallons/person)',ylab='Adjusted electricity (MWh/person)',
    main='Gasoline: natural gas held at median')
  grid <- seq(min(d$log_gasoline),max(d$log_gasoline),length.out=300)
  lines(grid,predict(m,newdata=data.frame(res_gas_mcf_pc=median(d$res_gas_mcf_pc),
    log_gasoline=grid)),col='#B91C1C',lwd=2)
  dev.off()
  png_plot('01b_gasoline_log_distribution',1200,700)
  hist(d$log_gasoline,breaks=40,col='#8BBAD9',border='white',
    main='On-road gasoline: full distribution on log scale',
    xlab='ln(gasoline in gallons/person)')
  dev.off()
  written <- read.csv(file.path(out,'model_coefficients.csv'))
  stopifnot(isTRUE(all.equal(written$estimate,coefficients$estimate,tolerance=1e-12)),
    all(vapply(models,nobs,numeric(1))==3142),all(is.finite(d$log1p_gas)),
    sum(d$log1p_gas==0)==9L,identical(county,readRDS('data/cleaned_data.rds')))
  writeLines(c('All 3142 counties retained in primary models; no missing analysis values.',
    'Original RDS and CSV validated by unchanged R/validate_cleaned_data.R.',
    'Exported coefficient estimates verified against fitted model objects.',
    'Nine genuine gas zeros preserved; log1p finite; gasoline strictly positive.',
    'Sensitivity exclusions are diagnostic alternatives, not cleaned datasets.',
    capture.output(sessionInfo())),file.path(out,'execution_validation.txt'))
  invisible(list(data=d,descriptives=descriptives,correlations=correlations,models=models,
    coefficients=coefficients,comparison=comparison,vif=vif,diagnostics=diagnostics,
    influence=influence,extremes=extremes,sensitivity=sensitivity,partial_r2=partial_r2))
}
energy_results <- run_energy_analysis()
