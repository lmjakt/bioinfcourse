## quick look at some data for the students to have a look at

## I downloaded GDS3850_full.soft from NCBI GEO. This is data
## from a load of different tissues and treatments in rat.
## also with different phenotype.

## the soft file can be read in with GEOquery
## which I installed from Bioconductor.
##
## following instructions on:
## http://www2.warwick.ac.uk/fac/sci/moac/people/students/peter_cock/r/geo/#GEOquery
library(Biobase)
library(GEOquery)

gds <- getGEO(filename="GDS3850_full.soft")

## to get the metdata data use the Meta slot
## this returns a named list. So we can do something
## like:

names(Meta(gds))

## to get the names.
## the more interesting parts can be found in:

Meta(gds)$sample_id
Meta(gds)$description

## the sample ids are in a list which seems to correspond to
## the description list excluding the first data point. Each sample_id
## is represented many times I suppose indicating whether the sample
## should be classified in that sense.

description <- Meta(gds)$description[-1]
sample.id.group <- strsplit(Meta(gds)$sample_id, ',')
sample.ids <- unique(unlist(sample.id.group))

## from the description we have
## 1, 2 : genotype
## 3..5 : tissue
## 6:10 : drug treatment

samples <- matrix(nrow=length(sample.ids), ncol=3)
rownames(samples) <- sample.ids
colnames(samples) <- c('genotype', 'tissue', 'drug')

for(i in 1:2){
    samples[ rownames(samples) %in% sample.id.group[[i]], 'genotype' ] <- description[i]
}

for(i in 3:5){
    samples[ rownames(samples) %in% sample.id.group[[i]], 'tissue' ] <- description[i]
}

for(i in 6:10){
    samples[ rownames(samples) %in% sample.id.group[[i]], 'drug' ] <- description[i]
}

## to get the actual expression levels we use Table

data <- Table(gds)
## that has 76 columns, The first column is the ID ref. Other columns
## contain the feature annotation. The table is relatively small, only
## 15923 rows. That's probably good...

## columns with expression data have colnames with GSM in them so we can
## split this easily enough..

exp.data <- as.matrix(data[ , grepl('GSM', colnames(data))])
feat.data <- data[ , !grepl('GSM', colnames(data))]

## that splits up pretty nicely, now to reorder the sample descriptions

all(rownames(samples) %in% colnames(exp.data)) ## --> true good

samples <- samples[ match(rownames(samples), colnames(exp.data)), ]
## and then to confirm:
all(rownames(samples) == colnames(exp.data))

### and now we have some data. I don't know anything about it, so first..
range(exp.data)
## bugger, the data is all character, so we can do..
tmp <- matrix(ncol=ncol(exp.data), data=as.numeric(exp.data))
colnames(tmp) <- colnames(exp.data)
rownames(tmp) <- rownames(exp.data)
exp.data <- tmp
rm(tmp)

## better, but we still have two NAs in the data. Do..
range(exp.data[ !is.na(exp.data) ])
## range is 0.1 --> 114450
## so the data is not log transformed. That's nice..

## for convenience lets do..
exp.data[ is.na(exp.data) ] <- 0.05
## 0 is probably more real, but this way we can log transform.

pdf("all_hist.pdf", width=14, height=7)
par(mfrow=c(1,2))
hist(exp.data, main="linear")
h.all <- hist(log(exp.data), main="log")
dev.off()

## then lets get individial histograms
h.sample <- apply( log(exp.data), 2, function(x){ hist(x, breaks=h.all$breaks) })

## and lets get the count data from all of these ..
h.sample.c <- sapply( h.sample, function(x){ x$counts } )
## to which we can then do a heatmap and see if there is something that we would like to do
## to the data..
rownames(h.sample.c) <- h.all$mids
## this is not pretty, but,, 
heatmap(h.sample.c, Rowv=NA, Colv=NA, scale='none', col=rainbow(255, s=1, v=0.8),
        )

## with column colours. But this is troublesome
colColor <- rep('grey', ncol(h.sample.c))
colColor[ samples[,'tissue'] == 'skeletal muscle (gastrocnemius)' ] <- 'red'
colColor[ samples[,'tissue'] == 'liver' ] <- 'blue'
colColor[ samples[,'tissue'] == 'adipose tissue (epididymal)' ] <- 'green'

pdf("distributionHeatMap.pdf", width=10, height=7)
heatmap(h.sample.c, Rowv=NA, Colv=NA, scale='none', col=rainbow(255, s=1, v=0.8),
        ColSideColors=colColor )
dev.off()
### From which we can see that adipose tissues are distinct from the others
### for this we ought to be a little bit careful.

### there are also some other outliers. There are other things which we can
### do here, but in general this is not so bad a situation. We can do more..

## but first to get an overall idea of the data we can simply do a PCA.
## for this, I think we will do it on the log transformed data and scale it

pca.l1 <- prcomp( t(log(exp.data)), scale=TRUE )
## and then let us consider how we can plot this.
## I can here simply use as.factor to get colors

pdf("pca1.pdf", width=7, height=7)
plot(pca.l1)  ## this is superb. Everything is here. This needs to be explained.
              ## however, it is probably almost all from tissue type
              ## of which we have three... hence a triangle needed.
dev.off()
pdf("pca2.pdf", width=7, height=7)
plot(pca.l1$x[,1], pca.l1$x[,2], col=as.factor(samples[,'tissue']), pch=19)
## lets highlight the controls
ctl.b <- samples[,'drug'] == 'control'
points(pca.l1$x[ctl.b,1], pca.l1$x[ctl.b,2], col='purple', lwd=2, pch=1, cex=1.5)
dev.off()
###

### lets look at correlations
sample.cor <- cor(log(exp.data))
pdf("sample_correlation.pdf", width=10, height=10)
heatmap(sample.cor, scale='none', col=rainbow(255, v=0.8))
dev.off()


### lets get some interesting data. Get the f-stats for a simple grouping..
source("~/R/general_functions.R")
sample.mf <- mulFactor(samples, c('genotype', 'tissue', 'drug'))

## and then we can get some fstats, to see what pops up..
fstats.a <- fStats(log(exp.data), sample.mf$f)

## lets make a reasonable sample order...
sample.o <- order(samples[,'tissue'], samples[,'genotype'], samples[,'drug'])
samples[sample.o,]
## ahah, now I understand the experimental design...

fstat.a.o <- order(fstats.a$f, decreasing=TRUE)
plotExp(fstat.a.o[1:10])

pdf("fstatAll.pdf", width=9, height=9)
par(mfrow=c(3,3))
plotExp(fstat.a.o[1:9], interactive=FALSE)
dev.off()

for(i in 1:10){
    j <- fstat.a.o[i]
    mx <- max(exp.data[j,])
    mn <- min(exp.data[j,])
    plot(1:length(sample.o), exp.data[j, sample.o],
         type='n', col=as.factor(samples[sample.o,'drug']), pch=19,
         ylim=c( mn - (mx-mn)*0.05, mx ),
         main=paste(feat.data[fstats.d.o[i],'Gene symbol']), ylab='Expression', xlab='Sample')
    usr <- par("usr")
    ## set up some rectangles to indicate the tissue type.
    rect((1:length(sample.o))-0.5, usr[3], (1:length(sample.o))+0.5, usr[4],
          col=hsvScale(as.numeric(as.factor(samples[sample.o,'tissue'])), sat=0.5, alpha=0.5),
         border=NA)
    ## and to indicate the genotype
    rect((1:length(sample.o))-0.5, usr[3], (1:length(sample.o))+0.5, usr[3] + (mx-mn)*0.05,
         col=hsvScale(as.numeric(as.factor(samples[sample.o,'genotype'])), sat=c(0.5), alpha=0.6),
         border=NA)
    
    points(1:length(sample.o), exp.data[j, sample.o], type='b',
           pch=19, col=as.factor(samples[sample.o,'drug']) )
inp <- readline(paste(feat.data[fstats.d.o[i],'Gene symbol'], ":"))
}


## then let's do the same for the drug treatment to see if we can anything.
## this is unlikely to work very well, but we can try.
fstats.d <- fStats(log(exp.data), as.numeric(as.factor(samples[,'drug'])))
fstats.d.o <- order(fstats.d$f, decreasing=TRUE)
plotExp(fstats.d.o[1:10])

## indeed, that doesn't really work very well as one might expect. One would prefer
## to normalise by tissue type. But I don't have time to do that right now. So, will
## have to do the more simple thing and just look in the liver
liver.b <- samples[,'tissue'] == 'liver'

fstats.dl <- fStats(log(exp.data[,liver.b]), as.numeric(as.factor(samples[liver.b,'drug'])))
fstats.dl.o <- order(fstats.dl$f, decreasing=TRUE)

plotExp(fstats.dl.o[1:30])

pdf("fstatsDrugLiver.pdf", width=12, height=9)
par(mfrow=c(3,4))
plotExp(fstats.dl.o[1:12], interactive=FALSE)
dev.off()

## get some genes by similarity of expression:
cr <- cor(scale(exp.data[fstats.dl.o[1],]), scale(t(exp.data)))
cr.o <- order(cr, decreasing=TRUE)
## make matrix of the top 10
exp.cr <- exp.data[ cr.o[1:10], ]

pdf("expression.pdf", width=14, height=7)
par(mfrow=c(1,2))

plot(1, 1, xlim=c(1,ncol(exp.cr)), ylim=range(exp.cr), type='n', xlab='sample', ylab='expression', main="Raw values")
apply(exp.cr, 1, function(x){ lines(1:length(x), x, col='grey')})
lines(1:ncol(exp.cr), colMeans(exp.cr), lwd=3)

exp.cr <- t( scale(t(exp.cr)) )
plot(1, 1, xlim=c(1,ncol(exp.cr)), ylim=range(exp.cr), type='n', xlab='sample', ylab='expression', main="Normalised values")
apply(exp.cr, 1, function(x){ lines(1:length(x), x, col='grey')})
lines(1:ncol(exp.cr), colMeans(exp.cr), lwd=3)
dev.off()

## this function makes use of global variables. These can't be modified,
## but can still result in unexpected behaviour
plotExp <- function(ind, interactive=TRUE){
    for(j in ind){
        #j <- ind[i]
        mx <- max(exp.data[j,])
        mn <- min(exp.data[j,])
        plot(1:length(sample.o), exp.data[j, sample.o],
             type='n', col=as.factor(samples[sample.o,'drug']), pch=19,
             ylim=c( mn - (mx-mn)*0.05, mx ),
             main=paste(feat.data[j,'Gene symbol']), ylab='Expression', xlab='Sample')
        usr <- par("usr")
        ## set up some rectangles to indicate the tissue type.
        rect((1:length(sample.o))-0.5, usr[3], (1:length(sample.o))+0.5, usr[4],
             col=hsvScale(as.numeric(as.factor(samples[sample.o,'tissue'])), sat=0.5, alpha=0.5),
             border=NA)
        ## and to indicate the genotype
        rect((1:length(sample.o))-0.5, usr[3], (1:length(sample.o))+0.5, usr[3] + (mx-mn)*0.05,
             col=hsvScale(as.numeric(as.factor(samples[sample.o,'genotype'])), sat=c(0.5), alpha=0.6),
             border=NA)
        
        points(1:length(sample.o), exp.data[j, sample.o], type='b',
               pch=19, col=as.factor(samples[sample.o,'drug']) )
        if(interactive)
            inp <- readline(paste(feat.data[j,'Gene symbol'], ":"))
    }
}

## lets have a look at GDS4805
##
gds4 <- getGEO(filename=GDS4805)
gds4.samples <- unique(unlist(strsplit(Meta(gds4)$sample_id, ",")))
sample.treat <- vector(mode='character', length=length(gds4.samples))
names(sample.treat) <- gds4.samples
tmp.ids <- strsplit(Meta(gds4)$sample_id, ",")
gds4.description <- (Meta(gds4)$description[-1])
for(i in 1:length(tmp.ids)){
    sample.treat[ names(sample.treat) %in% tmp.ids[[i]] ] <- gds4.description[i]
}

gds4.data <- Table(gds4)
gds4.exp <- as.matrix(gds4.data[ , grep("GSM", colnames(gds4.data)) ])
colnames( gds4.exp ) <- colnames(gds4.data)[ grep("GSM", colnames(gds4.data)) ]
rownames( gds4.exp ) <- gds4.data[,'ID_REF']
gds4.exp <- matrix(ncol=ncol(gds4.exp), data=as.numeric(gds4.exp) )
## and they are ordered ok, so we can simply do
treat.f <- c(rep(1,3), rep(2,3), rep(3,3), rep(4,3))
gds4.pca <- prcomp(t(log(gds4.exp)))
plot(gds4.pca$x[,1], gds4.pca$x[,2], col=treat.f )

## and they are very nicely arranged.
## lets get some overall fstats...
gds4.f <- fStats(log(gds4.exp), as.numeric(as.factor(sample.treat)))
gds4.fo <- order(gds4.f$f, decreasing=T)

gds4.t <- apply(gds4.exp, 1, function(x){ t.test(x[treat.f==1], x[treat.f!=1] )$statistic })
gds4.to <- order(gds4.t, decreasing=TRUE)
#for(i in gds4.fo[1:100]){
for(i in gds4.to[1:100]){
##for(i in 1:100){
                                        #    plot(1:ncol(gds4.exp), gds4.exp[i,], col=treat.f, pch=19,
#         ylim=c(0,max(gds4.exp[i,])))
    plot(1:ncol(gds4.exp), gds4.exp[i,], col=hsvScale(treat.f), pch=19,
         ylim=c(0,max(gds4.exp[i,])))
    inp <- readline(do.call(paste, gds4.data[i,c('ID_REF', 'Gene symbol')] ))
}
