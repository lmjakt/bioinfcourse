## numbers of papers and sequenced published per year since 1980.

pubs <- read.table("../publication_trends.txt", sep="\t", stringsAsFactors=FALSE, header=TRUE)

pdf("article_counts.pdf", width=7, height=7)
plot(pubs[,'Year'], pubs[,'PubMed'], type='b', xlab='Year', ylab='No. Published', main="Articles")
dev.off()

pdf("nucleotide_counts.pdf", width=7, height=7)
plot(pubs[,'Year'], pubs[,'Nucleotide'], type='b', xlab='Year', ylab='No. Published', main="Sequences")
dev.off()
