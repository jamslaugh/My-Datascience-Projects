# strategy to extract info from desc_oper in df @ work.

stri <- c()

for(i in c(1:nrow(string_data))){
  stri <- c(stri,str_split(string_data[[i,1]],pattern=" |-"))
}

for(i in 1:length(stri)){
  stri[[i]][length(stri[[i]])+1] <- paste(stri[[i]][4:length(stri[[i]])],collapse = " ")
  stri[[i]] <- stri[[i]][c(1,2,3,length(stri[[i]]))]
}

string_data[,c("Gen","COD","SP","P1")] <- transpose(stri)
