scores <- as.matrix(read.table('SM_scores'))
ptrs <- as.matrix(read.table('SM_pointers'))

## to draw them first set up a set of positions

x <- as.integer( 0:(length(ptrs)-1) / nrow(ptrs) )
y <- ( 0:(length(ptrs)-1) %% nrow(ptrs) )
y <- max(y) - y

pdf("SM_drawing.pdf", width=21, height=7)
par(mfrow=c(1,3))
plot( 1, xlim=c(-1, max(x)+1), ylim=c(-1, max(y)+1),
     type='n', xlab='', ylab='', main='scores', cex.main=2 )
text(x, y, labels=as.numeric(scores), cex=2)
    
plot( 1, xlim=c(-1, max(x)+1), ylim=c(-1, max(y)+1),
     type='n', xlab='', ylab='', main='pointers', cex.main=2 )
text(x, y, labels=as.numeric(ptrs), cex=2)

plot( 1, xlim=c(-1, max(x)+1), ylim=c(-1, max(y)+1),
     type='n', xlab='', ylab='', main='arrows',cex.main=2 )
up.b <- as.logical(bitwAnd(1, ptrs))
left.b <- as.logical(bitwAnd(2, ptrs))
diag.b <- as.logical(bitwAnd(4, ptrs))
arrows( x[up.b], y[up.b]+0.25, x[up.b], y[up.b] + 0.75, length=0.1 )
arrows( x[left.b]-0.25, y[left.b], x[left.b] -0.75, y[left.b], length=0.1 )
arrows( x[diag.b]-0.25, y[diag.b]+0.25, x[diag.b] -0.75 , y[diag.b] + 0.75, length=0.1 )
dev.off()
