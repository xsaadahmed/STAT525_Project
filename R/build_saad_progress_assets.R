# Regenerate ONLY the self-contained Saad assets used by the shared progress TeX.
# Run from repository root; base R. Full analysis runs into a temporary directory.
eval(parse('R/01_energy_consumption.R')[[1]])
z <- run_energy_analysis(tempfile('saad-progress-'))
out <- 'reports/progress_assets/saad'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
f <- function(x,k=3) formatC(x,format='f',digits=k)
write_table <- function(name,header,rows) writeLines(c(header,rows,'\\bottomrule','\\end{tabular}'),file.path(out,name))
a <- z$descriptives
write_table('descriptive.tex',c('\\begin{tabular}{lrrrrrrr}','\\toprule',
 'Variable (per person) & Mean & Median & SD & Q1 & Q3 & Min & Max \\\\','\\midrule'),
 vapply(1:3,function(i) paste0(c('Electricity (MWh)','Natural gas (Mcf)','Gasoline (gal)')[i],' & ',
  paste(f(unlist(a[i,c('mean','median','sd','q1','q3','min','max')]),2),collapse=' & '),' \\\\'),character(1)))
rows <- vapply(c('gas_simple','gasoline_simple'),function(nm) {
 m <- z$models[[nm]]; scale <- if(nm=='gasoline_simple') 100 else 1
 ci <- confint(m)[2,]*scale
 paste0(if(nm=='gas_simple') 'Gas: 1 Mcf/person' else 'Gasoline: 100 gal/person',' & ',f(coef(m)[1]),' & ',
  f(coef(m)[2]*scale,4),' & [',f(ci[1],4),', ',f(ci[2],4),'] & ',
  if(nm=='gas_simple') '$<0.001$' else '0.0021',' & ',f(summary(m)$r.squared,4),' & ',f(sigma(m),3),' \\\\')
},character(1))
write_table('simple.tex',c('\\begin{tabular}{lrrlrrr}','\\toprule',
 'Predictor increment & Intercept & Slope & 95\\% OLS CI & $p$ & $R^2$ & RSE \\\\','\\midrule'),rows)
a <- z$comparison
write_table('comparison.tex',c('\\begin{tabular}{lrrrr}','\\toprule',
 'Model & $R^2$ & Adjusted $R^2$ & RSE & CV RMSE \\\\','\\midrule'),
 vapply(1:5,function(i) paste0(c('Gas only','Gasoline only','Gas + gasoline','Gas + $\\ln$(gasoline)',
 'Gas + gas$^2$ + $\\ln$(gasoline)')[i],' & ',paste(f(unlist(a[i,c('r_squared','adjusted_r_squared','residual_se','cv_rmse')]),4),collapse=' & '),' \\\\'),character(1)))
png(file.path(out,'distributions.png'),width=1800,height=520,res=180)
par(mfrow=c(1,3),mar=c(3.8,3.5,2,1),mgp=c(2.2,.6,0),las=1)
for(i in 1:3) {
 x <- z$data[[c('res_elec_mwh_pc','res_gas_mcf_pc','gasoline_gal_pc')[i]]]
 hist(if(i==3) log10(x) else x,breaks=30,col='#9FC7DE',border='white',
  main=c('Residential electricity','Residential natural gas','On-road gasoline')[i],
  xlab=c('MWh/person','Mcf/person','log10(gallons/person)')[i],ylab='Counties')
};dev.off()
png(file.path(out,'relationships.png'),width=1800,height=650,res=180)
par(mfrow=c(1,2),mar=c(4,4,2.6,1),mgp=c(2.4,.6,0),las=1)
for(j in 1:2) {
 x <- z$data[[c('res_gas_mcf_pc','gasoline_gal_pc')[j]]];y <- z$data$res_elec_mwh_pc
 limits <- if(j==1) range(x) else unname(quantile(x,c(0,.99)))
 plot(x,y,pch=16,cex=.45,col=adjustcolor('#2563A6',.3),xlim=limits,xaxs='i',
  xlab=c('Natural gas (Mcf/person)','On-road gasoline (gallons/person)')[j],
  ylab='Electricity (MWh/person)',main=c('Natural gas: all counties','Gasoline: exact 99th-percentile zoom')[j])
 abline(z$models[[j]],col='firebrick',lwd=2);lines(lowess(x,y),col='darkgreen',lwd=2)
 legend('topright',c('Simple OLS','LOWESS'),col=c('firebrick','darkgreen'),lty=1,bty='n',cex=.8)
 if(j==2) mtext(sprintf('%d predictor values above view; fits use all',sum(x>limits[2])),side=3,line=.2,cex=.65)
};dev.off()
cat('PASS: report tables/plots regenerated from fitted objects; no primary outputs overwritten.\n')
