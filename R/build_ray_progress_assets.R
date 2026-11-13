# Rebuild Ray's static shared-report assets from accepted data, base R only.
# Does not write baseline data or the full individual analysis outputs.
b <- readRDS('data/cleaned_data.rds')
x <- read.csv('data/external/usda_rucc_2013.csv',colClasses=c('character','integer'))
stopifnot(!anyDuplicated(x$county_fips))
b$rucc_2013 <- factor(x$rucc_2013[match(b$county_fips,x$county_fips)],levels=1:9)
d <- b[!is.na(b$rucc_2013),]
stopifnot(nrow(b)==3142,nrow(d)==3140)
fits <- list(
 co2_raw=lm(res_elec_price_usd_mwh~elec_co2e_tons_per_mwh,b),
 rucc_raw=lm(res_elec_price_usd_mwh~rucc_2013,d),
 joint_raw=lm(res_elec_price_usd_mwh~elec_co2e_tons_per_mwh+rucc_2013,d),
 co2_log=lm(log(res_elec_price_usd_mwh)~elec_co2e_tons_per_mwh,b),
 rucc_log=lm(log(res_elec_price_usd_mwh)~rucc_2013,d),
 joint_log=lm(log(res_elec_price_usd_mwh)~elec_co2e_tons_per_mwh+rucc_2013,d))
reference <- read.csv('outputs/ray_electricity_prices/coefficients.csv')
for(nm in names(fits)) stopifnot(isTRUE(all.equal(unname(coef(fits[[nm]])),
 reference$estimate[reference$model==nm],tolerance=1e-10)))
out <- 'reports/progress_assets/ray';dir.create(out,recursive=TRUE,showWarnings=FALSE)
f <- function(x,k=4) formatC(x,format='f',digits=k)
labels <- c('Emissions','RUCC categories','Emissions + RUCC','Emissions','RUCC categories','Emissions + RUCC')
rows <- vapply(seq_along(fits),function(i) {
 m <- fits[[i]];s <- summary(m)
 paste0(if(i<=3) 'USD/MWh' else '$\\ln$(USD/MWh)',' & ',labels[i],' & ',nobs(m),' & ',
 f(s$r.squared),' & ',f(s$adj.r.squared),' & ',f(s$sigma),' \\\\')
},character(1))
writeLines(c('\\begin{tabular}{llrrrr}','\\toprule',
 'Response scale & Predictors & $n$ & $R^2$ & Adjusted $R^2$ & RSE \\\\','\\midrule',
 rows,'\\bottomrule','\\end{tabular}'),file.path(out,'comparison.tex'))
png(file.path(out,'exploration.png'),width=1800,height=1000,res=180)
layout(rbind(c(1,1,2,2,3,3),c(4,4,4,5,5,5)))
par(mar=c(4,4,2.4,1),mgp=c(2.5,.65,0),las=1,cex=1.1)
hist(b$res_elec_price_usd_mwh,breaks=35,col='#9FC7DE',border='white',
 main='Electricity expenditure',xlab='USD/MWh',ylab='Counties')
hist(b$elec_co2e_tons_per_mwh,breaks=25,col='#9FC7DE',border='white',
 main='Emissions intensity',xlab='Metric tons CO2e/MWh',ylab='Counties')
barplot(table(d$rucc_2013),cex.names=.8,col='#9FC7DE',border='white',main='RUCC 2013',
 xlab='Code (1-3 metro; 4-9 nonmetro)',ylab='Counties')
plot(b$elec_co2e_tons_per_mwh,b$res_elec_price_usd_mwh,pch=16,cex=.45,
 col=adjustcolor('#2563A6',.3),main='Expenditure versus emissions',
 xlab='Metric tons CO2e/MWh',ylab='Expenditure (USD/MWh)')
abline(fits$co2_raw,col='firebrick',lwd=2)
legend('topright','Simple OLS',col='firebrick',lty=1,bty='n',cex=.8)
boxplot(res_elec_price_usd_mwh~rucc_2013,d,col='#9FC7DE',
 main='Expenditure by RUCC',xlab='Unordered county categories',ylab='Expenditure (USD/MWh)')
dev.off()
cat('PASS: six refits agree with audited coefficients; Ray report assets generated.\n')
