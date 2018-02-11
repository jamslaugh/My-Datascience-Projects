library(NLP)
library(RColorBrewer)
library(tm)
library(wordcloud)
set.seed(8)

files <- list.files(pattern = '.pdf$')

Rpdf <- readPDF(control = list(text = '-layout'))(elem=list(uri = files[1]),language = 'en')

text_raw <- Rpdf$content

text_corpus <- Corpus(VectorSource(text_raw))

corpus_clean <- tm_map(text_corpus,stripWhitespace)
corpus_clean <- tm_map(text_corpus,removeNumbers)
corpus_clean <- tm_map(text_corpus,content_transformer(tolower))
corpus_clean <- tm_map(text_corpus,removePunctuation)

corpus_clean <- tm_map(corpus_clean,removeWords,stopwords('english'))

wordcloud(corpus_clean,max.words=Inf,random.order=F,scale=c(3,0.1),colors=brewer.pal(8,'Dark2'))
