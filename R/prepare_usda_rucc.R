# Prepare the user-supplied USDA 2013 RUCC CSV from the project root (base R).
# Keep the original upload at this ignored path; no network download is performed.
input <- 'data/external/downloads/usda_rucc_2013.csv'
x <- read.csv(input,colClasses='character',na.strings=c('','NA'),check.names=FALSE)
stopifnot(all(c('FIPS','RUCC_2013') %in% names(x)))
blank <- apply(x,1,function(row) all(is.na(row) | trimws(row)==''))
x <- x[!blank,]
fips <- trimws(x$FIPS); raw <- trimws(x$RUCC_2013)
stopifnot(!anyNA(fips),all(grepl('^[0-9]{5}$',fips)),!anyDuplicated(fips),
          all(is.na(raw) | raw %in% as.character(1:9)))
y <- data.frame(county_fips=fips,rucc_2013=as.integer(raw))
write.csv(y,'data/external/usda_rucc_2013.csv',row.names=FALSE,na='')
cat('Removed',sum(blank),'entirely blank rows; retained',nrow(y),'unique FIPS;',sum(is.na(y$rucc_2013)),'missing codes.\n')
