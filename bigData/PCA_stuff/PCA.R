## a demonstration of a PCA as means to discover linear models
## within data.

## first create a data set which can be explained as a combination of
## a small number of factors and noise:

## an input experimental factor, something like concentration of
## a chemical.

## start with a very simple structure, 1 variable treatment, with
## one sample type
f1 <- c(rep(0, 3), rep(2, 3), rep(3, 3))

## then we have a set of genes. Each gene has a base level of expression,
## a response to the factor and some level of noise.
## that is, a gene expression at any level can be described by the expression:
##
## e = b + f1 * r1 + n
## where 
## e = the resulting expression level
## b = base level of expression
## f1 = the value of the continuous factor f1
## r1 = the response of the gene to the factor (here we are using a simple
## linear relationship, but this could also be categorical)
## n = noise

## to make things simple we will assign values from normal distibutions
## but this isn't very realistic. What we might expect is that the response
## variable comes from a bimodal distribution, but that doesn't matter
## so much.

## N is the number of genes
N <- 1000;
## b is the baselevel of expression...;
b <- rnorm(N, sd=10)
## r is the response vector
r <- rnorm(N, sd=1)
## m is the number of samples; here simply the
## length of f1
m <- length(f1)
## n is the noise and needs to calculated for
## every gene and measurement
n <- matrix(rnorm(N * m, 0.1), nrow=N)

## then we should be able to calculate the gene expression as
## a matrix multiplication, though since I don't quite know how
## I will do this the stupid way. 
e <- matrix(nrow=N, ncol=m, data=0)
for(i in 1:length(f1)){
  e[,i] <- b + (f1[i] * r) + n[,i]
}

## then lets make a scaled data set
e.rowMeans <- rowMeans(e)
e.sd <- apply(e, 1, sd)

e.n <- e - e.rowMeans
e.n <- e.n / e.sd

## then perform a pca on this. Normally we would center and scale it, but
## here we don't really need to do that since we have a very simple structure

## e.n is already normalised, so no need to scale or center
e.p <- prcomp(t(e), center=TRUE, scale=TRUE)

## then we can look at the rotation matrix and plot this against
## our response variable.

## but first let's look at out PCA
plot(e.p)
## and we see that almost all the variance is associated with the
## first dimension. As it ought to be in simple case like this.
plot(e.p$x[,1], e.p$x[,2], col=(2+f1), pch=19)

## then plot component 1 vs factor 1
plot(e.p$x[,1], f1)
## the PCA nicely disovers the experimental factor

## we see a simple line.
## then let's look at the rotation matrix and the response rates...
plot(r, e.p$rotation[,1])
## this naturally doesn't work since we have set the sd to be 1 for
## everything. Scaling here of the data doesn't work at all...
## if we don't set the variance to 1, then
## the PCA will nicely discover the response factors as well...
## or we can try to:
plot(r, e.p$rotation[,1] * e.sd)
## and we regain the relationship nicely.

## then can we find the noise as well?
## The assumption here is that everything that is not explained by the
## first factor is noise. So we can simply say;
## e.m (the model)

## the full PCA model should recover everything :
e.m <- e.p$rotation %*% e.p$x
## because of the centering
## but here we have used normalised data e.n, so no need to 
## undo the centering
e.m <- e.m * e.sd
e.m <- e.m + e.rowMeans

plot(e, e.m, cex=0.1)
abline(0, 1, col='red')
## WARNING: that should give a perfect fit, but it doesn't
## Not sure why not

## what we want to do here to use only the first component
## we can do that by
rot <- e.p$rotation
p.x <- e.p$x
rot[,-1] <- 0
p.x[,-1] <- 0
e.m.1 <- rot %*% p.x 
e.m.1 <- e.m.1 * e.sd
e.m.1 <- e.m.1 + e.rowMeans

plot(e.m.1, e, cex=0.1)
abline(0, 1, col='red')

## that gives a pretty good fit. No lets plot the errors vs the noise
plot(n, (e - e.m.1), cex=0.1)
abline(0,1, col='red')
## not perfect, but not that far off.

## Here we have used a matrix multiplication expression to obtain the
## model. We can also express this in a simpler algebraic way:

e.m.2 <- matrix(0, nrow=nrow(e.p$rotation), ncol=ncol(e.p$rotation))
for(i in 1:ncol(e.m.2)){
  e.m.2[,i] <- e.p$rotation[,1] * e.p$x[i,1]
}

## recover the variance and the means
e.m.2 <- e.m.2 * e.sd
e.m.2 <- e.m.2 + e.rowMeans
plot(e.m.1, e.m.2)
plot(e, e.m.2)

## note that using the matrix multiplication and the algebraic form
## do not give exactly the same results. This suggests we may be running
## into rounding errors. I have to rerun this code on Linux and see what happens.

### This should be combined with an introduction to matrix multiplication
### given at this point. Note that means that we should not express the
### model above as a matrix multiplication, but rather to first show it
### algorithmically through a loop.
### Then explain the relationship between a matrix and simultaneous equations,
### and how the PCA solves such a set of equations in a constrained manner.

### Further exercises:
## add an unintentional variable. Assume that each series of replicates was done
## on a separate occassion and this introduced some sort of deviation. Again, 
## you will need to set some set of response variables. In this case these can be
## categorical; how can you do this?

## To add another variable to the data set, it is easiest if we consider
## something that could arise during a specific experiment.
## 
## Example 1.
## In the above data we have three replicates for each experimental condition;
## It is possible that these would have been carried out on different times and
## that for example we may have had some buffer that was going off. Alternatively
## we can postulate that the measurements were all carried out on the same day, but
## that the sample treatments had been carried out at different times. In this case
## the samples would have been stored for different times. How this affects the gene
## expression is unknown, and indeed, we cannot say that a gene will be affected
## in a linear manner. Hence we now have to update our equation to say

## e = b + f1*r1 + f2*r2 + n
##
## another linear equation.

## however, here, f2 is categorical, and actually have a seperate response vector for 
## each level of f2 (1,2,3), so the equation should really read something like:
##
## e = b + f1*r1 + f2_ri + n
## or something

f2 <- rep(1:3, 3)
f2r <- matrix(nrow=N, ncol=3)
f2.response <- rnorm(N, sd=0.5)
f2.levels <- sample(1:10, 3)
for(i in 1:ncol(f2r)){
  f2r[,i] <- f2.response *  f2.levels[i] ## noise is at 0.1, so this is a bit weak
}
e2 <- e
for(i in 1:length(f2)){
  e2[,i] <- e[,i] + f2r[ f2[i]]
}

e2.sd <- apply(e2, 1, sd)
e2.rowMeans <- rowMeans(e2)

e2.p <- prcomp(t(e2), scale=TRUE, center=TRUE)
plot(e2.p)
## weak effect in the second component
plot(e2.p$x[,1], e2.p$x[,2], col=f2, pch=19)

## and then
plot(e2.p$x[,1], f1)
plot(e2.p$x[,2], f2)
plot(e2.p$x[,2], f2.levels[f2])

## and again we can see that the experimental and incidental factors are
## recovered from the transformation.
## to get the response levels for individual genes we can do the same as before;

plot(e2.sd * e2.p$rotation[,1], r)
plot(e2.sd * e2.p$rotation[,2], f2.response)
## here we fail completely to get something from f2.response
