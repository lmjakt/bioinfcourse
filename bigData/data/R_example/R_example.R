## code to implement R examples we went through on Friday 11-11-16

## try the code in last year's experiment yourself. Modify it and see what
## happens.

## load expression data and sample data:
exp.data <- read.table("exp_data.txt", header=TRUE, sep="\t", stringsAsFactors=FALSE)
sample.data <- read.table("sample_data.txt", header=TRUE, sep="\t", stringsAsFactors=FALSE)

### note that Shotaroy may need to use 'sep=" "' rather than \t due to some weirdness in
### text representation

## it is often easier to deal with matrices rather than dataframes:
exp <- as.matrix(exp.data)

## and for expression data log space often makes more sense than
## linear space.
exp.l <- log(exp)

## when we have some data that we've loaded from files, or elsewhere
## it is often useful to use the following functions to initially
## explore the data

## for a basic summary (though somewhat long for big tables)
summary(exp.data)
summary(exp)
summary(sample.data)

## note that summary() does different things depending on the type of object
## it is passed as its argument.

## to get the sizes of matrices and data.frames
dim(exp.data)
dim(sample.data)

## to get the range of values
range(exp)
range(exp.l)
range(exp.data) 

## to get the distributions of the full data set..
hist( exp.data )  ## DOES NOT WORK, because a data.frame
hist( exp )
hist( exp.l )

## here we see that it's more reasonable to use log-transformed
## data.

## assign the return value of hist() to an object
a.h <- hist( exp.l, breaks=60 )
## here we have also specified the approximate size of breaks

## look at what a.h is
typeof( a.h )
class( a.h )
length( a.h )
names( a.h )

## to see the full data set, simply do
a.h

## Use apply to obtain a histogram for each column of exp.l
## here we specify the breaks to be the same as we obtained
## when running hist() on the full data set

## column histograms
c.h <- apply( exp.l, 2, hist, breaks=a.h$breaks, plot=FALSE )
## note the plot=FALSE as well. Look at ?hist to see what this
## does

## look at what you get
length( c.h )
names( c.h )
c.h[[1]]

## to visualise we can use image: but first we must extract the counts
## into a matrix. For this we can use sapply(). sapply() stands for simple
## lapply() and is used to run a function over all elements of a list.
## lapply() always returns a list; sapply() will try to simplify this to
## a vector or matrix if possible.

## here we define a simple function that simply returns the $counts vector

c.h.counts <- sapply( c.h, function(x){ x$counts } )
## you should understand this.

## look at what you got
dim(c.h.counts)
length(c.h.counts)  ### what does this do? Understand this!
rownames(c.h.counts)
colnames(c.h.counts)


## run image(). Specify a set of colours from blue to red using rgb() and seq()
image( c.h.counts, col=rgb( seq(0,1,length.out=255), 0, seq(1,0,length.out=255) ) )

## I tend to prefer it the other way around (though this really doesn't matter.
image( t(c.h.counts), col=rgb( seq(0,1,length.out=255), 0, seq(1,0,length.out=255) ) )

## we can also try log transform the counts. But since we have some 0 counts we have to
## adjust the values. We can simply do:
image( t(log(c.h.counts + 0.1)), col=rgb( seq(0,1,length.out=255), 0, seq(1,0,length.out=255) ) )

## we can also use hsv() to specify the colours:
image( t(log(c.h.counts + 0.1)), col=hsv(seq(0,1,length.out=756), 1, 1) )
## but thats a bit ugly, try:
image( t(c.h.counts), col=hsv(seq(0,1,length.out=1000), 1, 1) )
## which is a bit nicer
## compare to:
image( t(c.h.counts), col=hsv(seq(0.25,1,length.out=1000), 1, 1) )
image( t(c.h.counts), col=hsv(seq(0.1,1,length.out=1000), 1, 1) )
## to get an idea of what the hsv function does.

## we can also plot as a line plot: Try to understand the following.
plot(1,1, type='n', xlab='level', ylab='count', ylim=range( c.h.counts ), xlim=c(1, ncol(c.h.counts) ) )
## here we loop rather than use apply as it allows us to specify colours easily
## use the samples table and as colours
col <- as.numeric( as.factor( sample.data[,'tissue'] ))
for(i in 1:ncol( c.h.counts )){
    lines( 1:nrow(c.h.counts), c.h.counts[,i], col=col[i] )
}
## in many ways this gives a much clearer picture of the distributions and outliers. However, it is not
## so easy to idenfity which sample is the outlier.

#### PCA
#### Principal components analysis
#### Use the prcomp() function. After transposing the data.
####

p.l1 <- prcomp( t(exp.l), scale=TRUE )

## You _should_ understand what scale does. If you are unsure, read the man-pages (?prcomp and ?scale).
## and then play around a bit, eg...
x <- rnorm( 20, mean=10, sd=4 )
x.s <- scale( x )
plot( x.s, x )
plot( x.s, (x - mean(x)) / sd(x) )
## guess what mean() and sd() do.

## have a look at wnat prcomp returned:
typeof(p.l1)
class(p.l1)
length(p.l1)
names(p.l1)

length( p.l1$sdev )
dim( p.l1$x )
dim( p.l1$rotation )
colnames( p.l1$rotation )
colnames( p.l1$x )
rownames( p.l1$x )

## what happens if we run plot on p.l1
plot(p.l1)

## note that the rows of p.l1$x correspond to the samples, and
## the columns to the principal components:
plot( p.l1$x[,1], p.l1$x[,2], col=as.factor( sample.data[,'tissue'] ))
## try with a different plot character (pch)
plot( p.l1$x[,1], p.l1$x[,2], col=as.factor( sample.data[,'tissue'] ), pch=19)

## we can also try to make a set of colours for all replicates. We can then add some points to the plot
col.n <- as.numeric( as.factor( paste( sample.data[,1], sample.data[,2], sample.data[,3] ) ))
## convert to something useful using hsv..
col.l <- hsv( col.n / max(col.n), 1, 0.7 )
## and then add small circles to the plot:
points( p.l1$x[,1], p.l1$x[,2], pch=1, cex=1.2, col=col.l, lwd=2.5 )

## to get an idea of what colour is what you can simply do:
cbind( sample.data, col.n )
## to see the actual colours, you can use legend(), but it won't fit very well here.

#### The PCA is a matrix factorisation; that means that we should be able to undo the pca by
#### multiplying the resulting matrices ($rotation and $x):
####
p.l1.rec <- p.l1$x %*% t(p.l1$rotation)
dim(p.l1.rec)
## 54 rows, so rows represent samples, and columns are genes. So to plot the first gene against itself we can
## simply do..
plot( exp.l[1,], p.l1.rec[,1] )
## note the actual values.

## we can then unscale the data using the $center and $scale vectors
## note that we now have to transpose the recovered values to make sure that the
## operation does the correct thing:

p.l1.rec.us <- t(p.l1.rec) * p.l1$scale + p.l1$center
plot( exp.l[1,], p.l1.rec.us[1,] )
## and magically everything is the same. But note
range( p.l1.rec.us - exp.l )
## the values are not exactly the same due to rounding errors


#### The PCA is also a (matrix) rotation of the initial N (15923) dimensional space into
#### m (54) dimensions. This means that we should be able to simulate the PCA by multiplying
#### the initial data (after scaling) by the rotation matrix:

## we transpose the data and then scale it as scale works on columns rather than rows
p.l1.sim <- scale( t(exp.l) ) %*% p.l1$rotation
dim(p.l1.sim)

## this now has the same dimensions as p.l1$x so to check that they are the same we can simply
## plot them against each other
plot(p.l1$x, p.l1.sim)

## which works nicely.
