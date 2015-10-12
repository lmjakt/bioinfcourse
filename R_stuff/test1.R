
str <- "ABCDEF"

## to get the numbers in the bytes, simply do:
charToRaw(str)

## Å is 142, Æ is even higher. To see if it gives
## us non signed characters.
str2 <- "ÅÆØ"

charToRaw(str2)

## to actually make use of the data we need to do
readBin( charToRaw(str), "integer", size=1, length=nchar(str), signed=FALSE)

## note that this is done here using UTF8 rather than ASCII, this shouldn't
## cause any trouble for lower values, but does give us something we can use.


