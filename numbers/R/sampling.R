for(i in 1:10){
    print( mean( sample(1:10, 10, replace=TRUE) ))
}

for(i in 1:10){
    print( mean( runif( 10, min=1, max=10 ) ) )
}

n <- 100 ## the number of average numbers
k <- 10  ## the size of each set of numbers
## something to store the numbers in
m <- vector(mode='numeric', length=n) 
## the range from which we sample 
minV <- 0
maxV <- 10 
## loop to obtain mean values
for(i in 1:n){
    m[i] <- mean( sample(minV:maxV, k, replace=TRUE) )
}
plot(m)

pdf("averages1.pdf", width=7, height=7)
plot(meanValues(), main='n=100 k=10 minV=0 maxV=10', ylim=c(minV, maxV))
dev.off()

pdf("averages2.pdf", width=8, height=8)
par(mfrow=c(3,3))
par(mar=c(3, 4, 4, 2))
for(i in 1:9){
    plot(meanValues(k=(i^2)), main=paste('k=', i^2, sep=""),
         ylim=c(minV, maxV), ylab='mean', xlab='')
}
dev.off()

pdf("medians1.pdf", width=8, height=8)
par(mfrow=c(3,3))
par(mar=c(3, 4, 4, 2))
for(i in 1:9){
    plot(avgValues(k=(i^2), sumFunc=median), main=paste('k=', i^2, sep=""),
         ylim=c(minV, maxV), ylab='mean', xlab='')
}
dev.off()

pdf("geoMeans1.pdf", width=8, height=8)
par(mfrow=c(3,3))
par(mar=c(3, 4, 4, 2))
for(i in 1:9){
    plot(avgValues(k=(i^2), sumFunc=geoMean, minV=1), main=paste('k=', i^2, sep=""),
         ylim=c(0, maxV), ylab='mean', xlab='')
}
dev.off()

pdf("dist1.pdf", width=7, height=8)
m <- meanValues( n=10000, k=10, minV=0, maxV=10 ) 
hist( m, main=paste('mean=', sprintf('%.2f', mean(m)), ' standard deviation=',
             sprintf('%.2f', sd(m)),
             sep=''), xlab='mean', breaks=100 )

dev.off()



m <- meanValues2( n=10000, k=10, minV=0, maxV=10 ) 
mh <- hist( m, breaks=seq(0, 10, by=0.25))
m.norm <- dnorm( mh$mids, mean=mean(m), sd=sd(m) )
pdf("dist2.pdf", width=7, height=7)
m.bp <- barplot( mh$density/sum(mh$density),
                main=paste('mean=', sprintf('%.2f', mean(m)),
                    ' standard deviation=', sprintf('%.2f', sd(m)), sep=''),
                ylim=c(0,0.12))
lines(m.bp, m.norm/sum(m.norm), type='b', col='red')
dev.off()

pdf("dist3.pdf", width=8, height=8)
par(mfrow=c(3,3))
par(mar=c(3, 4, 4, 2))
for(i in 1:9){
    m <- meanValues(n=10000, k=(i^2))
    m.h <- hist(m, breaks=seq(0, 10, by=0.25), plot=FALSE)
    m.sd <- sd(m)
    m.m <- mean(m)
    m.norm <- dnorm( m.h$mids, mean=m.m, sd=m.sd )
    mx <- ifelse( max(m.norm) > max( m.h$density ), max(m.norm), max(m.h$density) )
    m.bp <- barplot(m.h$density/sum(mh$density),
                    main=paste('k=', i^2, ' mean=', sprintf('%.2f', m.m),
                        ' sd=', sprintf('%.2f', m.sd), sep=''),
                    ylim=c(0,1.1*mx/sum(m.norm)))
    lines(m.bp, m.norm/sum(m.norm), type='b', col='red')
}
dev.off()

m <- meanValues2( n=10000, k=10, minV=0, maxV=10 ) 
mh <- hist( m, breaks=seq(0, 10, by=0.25))
m.norm <- dnorm( mh$mids, mean=mean(m), sd=sd(m) )
pdf("dist4.pdf", width=7, height=7)
m.bp <- barplot( mh$density/sum(mh$density),
                main=paste('mean=', sprintf('%.2f', mean(m)),
                    ' standard deviation=', sprintf('%.2f', sd(m)), sep=''),
                ylim=c(0,0.12))
lines(m.bp, m.norm/sum(m.norm), type='b', col='red')
m.m <- mean(m)
m.sd <- sd(m)
mh.b <- abs(mh$mids - m.m) <= (2 * m.sd)
mh.i <- which(mh.i)
l <- length(mh.i)
polygon( c(m.bp[mh.i[1]], m.bp[mh.i], m.bp[mh.i[l]]),
         c(0, mh$density[mh.i]/sum(mh$density), 0), col=rgb(0,0,0.5,0.4) )
dev.off()

## differences of means which have been sampled from the same distributions...
## use a mean of 0, and a standard deviation of 1
n <- 10000
sd <- 1
m <- 0
## k is equivalen to the number of replicates we might have
## for each sample class
k <- 10
## two vectors for storing the means in
X <- vector(mode='numeric', length=n)
Y <- vector(mode='numeric', length=n)
for(i in 1:n){
    X[i] <- mean( rnorm(k, mean=0, sd=1) )
    Y[i] <- mean( rnorm(k, mean=0, sd=1) )
}
## look at the distribution of the differences:
pdf("differences1.pdf", width=7, height=7)
plot(X - Y, ylab="difference", main="mean=0, sd=1")
dev.off()
pdf("diffDist.pdf", width=7, height=7)
h <- hist( X - Y, breaks=40 )
dev.off()

## to get the t distribution for degrees of freedom = 18
N <- 10000 ## the number of samples of t
k <- 10    ## number of replicates (n) for each group
s <- 4     ## the standard deviation of the distributions
t <- vector(mode='numeric', length=N)
for(i in 1:N){
    X <- rnorm(n=k, mean=0, sd=4)
    Y <- rnorm(n=k, mean=0, sd=3)
    x.v <- var(X)
    y.v <- var(Y)
    x.m <- mean(X)
    y.m <- mean(Y)
    t[i] <- (x.m - y.m) / (sqrt(x.v + y.v) * sqrt(1/k))
}
pdf("tdist1.pdf", width=7, height=7)
h <- hist(t)
dev.off()

pdf("tdist2.pdf", width=7, height=7)
plot(h$mids, h$density, type='b', col='black')
points(h$mids, dt(h$mids, df=(2*k-2)), type='b', col='red')
dev.off()





                
## but better to define a function so we can easily vary
## the variables...
meanValues <- function( n=100, k=10, minV=0, maxV=10 ){
    m <- vector(mode='numeric', length=n)
    for(i in 1:n){
        m[i] <- mean( sample(minV:maxV, k, replace=TRUE) )
    }
    m
}

meanValues2 <- function( n=100, k=10, minV=0, maxV=10 ){
    m <- vector(mode='numeric', length=n)
    for(i in 1:n){
        m[i] <- mean( runif(k, min=minV, max=maxV) )
    }
    m
}


## 
## A generalised function that can do medians, or whatever
avgValues <- function( n=100, k=10, minV=0, maxV=10, sumFunc=mean ){
    m <- vector(mode='numeric', length=n)
    for(i in 1:n){
        m[i] <- sumFunc( sample(minV:maxV, k, replace=TRUE) )
    }
    m
}

geoMean <- function(x){
##    p <- x[1]
##    for(i in 2:length(x)){
##        p <- p * x[i]
##    }
##    p^(1/length(x))
    ## the above code follows the simple definition of
    ## the geometric mean, but, is not very useful as it
    ## will overflow. It can also be written more concisely
    ## using prod()

    ## instead we do:
    exp( mean(log(x)) )
    ## and hope that x does not contain any negative or 0 numbers.
}
