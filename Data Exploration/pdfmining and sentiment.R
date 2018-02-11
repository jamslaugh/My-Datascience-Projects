# First approach: tm package 
# 
# # Trial info on http://data.library.virginia.edu/reading-pdf-files-into-r-for-text-mining/
# 
# Second Approach: textreadr package

library(stringr)
library(textreadr)

el = list.files(pattern = "*.pdf$")

for(i in (1:length(el))){
  tmp = read_pdf(el[i], remove.empty = T)
  assign(paste("data_",i,sep=''),tmp)
}

dfs <- ls()[sapply(mget(ls(), .GlobalEnv), is.data.frame)]

for(i in 1:length(dfs)){

tmp_data <- str_extract(get(dfs[i])$text,'\\(.+\\)')
assign(paste(dfs[i],"cit",sep='_'),tmp_data)

}


# NLP Approaches:

# 1) split each word inside each row of the dataset
# 2) tokenize by regular expression
# 3) See Datacamp for any other approach

# Third Approach: Tesseract OCR Engine.