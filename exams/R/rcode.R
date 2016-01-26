## some code used to generate plots for the exam.

## distributions

x <- rnorm(1000)
xe <- exp(rnorm(1000))

pdf("log_norm.pdf", width=14, height=7)
par(mfrow=c(1,2))
hist(x, main="A", xlab='value')
hist(xe, main="B", xlab='value')
dev.off()

mean(x)
sum( abs(x) > 2 ) / length(x)

## lets have a look at a hypergeometric distribution...
## though we don't care too much about it..

hg <- rhyper(100000, 15, 85, 30)
pdf("hyper.pdf", width=7, height=7)
hg.h <- hist(hg, breaks=seq(-0.5, 30, by=1), main='X', xlab='value')
dev.off()

## let's look at the t-statistic and difference distibutions

a1 <- rnorm(10000, 10, 1)
b1 <- rnorm(10000, 13, 1)

a2 <- c(rnorm(8000, 10, 1), rnorm(2000, 13, 1))
b2 <- c(rnorm(5000, 10, 1), rnorm(5000, 13, 1))

h1 <- hist( c(a1,b1) )
h2 <- hist( c(a2,b2) )

ha1 <- hist( a1, breaks=h1$breaks)
hb1 <- hist( b1, breaks=h1$breaks)

ha2 <- hist( a2, breaks=h2$breaks)
hb2 <- hist( b2, breaks=h2$breaks)

pdf("binorm.pdf", width=14, height=7)
par(mfrow=c(1,2))
plot(h1$mids, ha1$count, type='b', col='red', xlab='value', ylab='count', main='normal')
points(h1$mids, hb1$count, type='b', col='blue')
legend('topright', legend=c('A', 'B'), pch=1, col=c('red', 'blue'))

plot(h2$mids, ha2$count, type='b', col='red', xlab='value', ylab='count', main='bi-normal')
points(h2$mids, hb2$count, type='b', col='blue')
legend('topright', legend=c('A', 'B'), pch=1, col=c('red', 'blue'))
dev.off()

h.sample <- apply( log(exp.data), 1, function(x){
    hist(x, breaks=h.all$breaks) })

a <- vector(mode='numeric', length=1000)
b <- vector(mode='numeric', length=length(a))
for(i in 1:length(a)){
    a[i] <- rnorm(1, 10, 2)
    b[i] <- a[i] * rnorm(1, 2, 0.25) + rnorm(1, 3, 1)
}
plot(a, b, pch=1, col='red', xlab='a', ylab='b')


phrases <- c("hello there stranger", "what's up doc")
words <- strsplit(phrases, " ")
words <- unlist(words)
sort(words)

## code for a question dealing with subsetting
a <- matrix(1:9, ncol=3, byrow=TRUE)
b <- t(a)
c <- rbind(a, b)
d <- c[ rowSums(c) > 10, 2:3]
e <- a + b[1,]


9 + 11 + 9 + 13 + 6 + 9 + 12 + 16
##
## I've written 85 questions.
##
## the exam is usally 4 hours. So for a total of a 100 points we should
## give at least 2.4 minutes per point.

## section one, we have:
4 + 4 + 2 + 4 + 2 + 3 + 3 + 3 + 2 = 27 points

## section two
10 + 10 + 3 + 2 + 4 + 3 + 4 + 2 + 4 + 2 + 4 = 48 points

## section three
3 + 3 + 3 + 3 + 3 + 2 + 2 + 1 + 4 = 24 points

## section four (pairwise alignment)
10 + 4 + 4 + 2 + 3 + 4 + 4 + 3 + 3 + 3 + 4 + 2 + 4 = 50 points

## section five (multiple alignment)
4 + 3 + 3 + 4 + 3 + 3 = 20 points

## section six (Perl)
3 + 4 + 4 + 4 + 5 + 2 + 2 + 2 + 2 = 28 points

## database sequence searches
3 + 4 + 2 + 3 + 1 + 4 + 3 + 5 + 4 + 3 + 3 = 35 points

## section seven (numbers, big data and R)
3 + 3 + 3 + 4 + 4 + 2 + 4 + 2 + 2 + 4 + 4 + 4 + 4 + 3 + 2 + 1 = 49 points.

## in total we have:
27 + 48 + 24 + 50 + 20 + 28 + 35 + 49 = 281 points.
