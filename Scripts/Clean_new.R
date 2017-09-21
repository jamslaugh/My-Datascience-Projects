######################## FUNZIONE RANDOM CODE
ERString <- function(n=1, lenght=12, inside=c(0:9, letters, LETTERS))
{
  randomString <- c(1:n)                  # initialize vector  
  for (i in 1:n)
  {
    randomString[i] <- paste(sample(inside,
                                    lenght, replace=TRUE),
                             collapse="")
  }
  return(randomString)
}
# ERString(lenght=5,inside=c(LETTERS))

####################### CREAZIONE FILES

files <- list.files(path="./sources", pattern="*.csv", full.names=T, recursive=FALSE)
for (inum in 1:length(files)){  
  fileName <- files[inum]  
  df_giacomo <- read.csv2(fileName, sep=",")
  
  if(names(df_giacomo)[2]=='X'){
    header <- vector()
    sapply(df_giacomo[1,], function(x){header <<- c(header,as.character(x) );})
    header <- header[-1]
  }else{
    header <- gsub("X","",names(df_giacomo))
    header <- header[-1]
  }
  
  names <- as.character(gsub("^\\s+|\\s+$", "",df_giacomo[,1]))
  names <- names[-1]
  df_giacomo <- df_giacomo[c(-1,-26),-1]
  row.names(df_giacomo)<-NULL
  randomNames <- vector()
  realNames <- vector()
  sourceFiles <- vector()
  timeInsert <- vector()
  DFcheck <- data.frame()
  for(g in 1:dim(df_giacomo)[1]){ 
    output <- df_giacomo[g,]
    names(output) <- as.character(header)
    gname <- gsub(",|:|;", " ",names[g])    
    realNames[g] <- gname
    randomNames[g] <- ERString(lenght=5,inside=c(LETTERS))
    timeInsert[g] <- format(Sys.time(), format="%Y-%M-%d %H:%M")
    while(randomNames[g] %in% DFcheck$randomNames){
      randomNames[g] <- ERString(lenght=5,inside=c(LETTERS))
    }
    sourceFiles[g] <- fileName
    write.table(output, file = paste0("./files/IT-",randomNames[g],".csv"),append = FALSE, quote = TRUE, sep = ",",qmethod = "double", row.names=F)
#     if(g==2) break;
  }
  DFcheck <- data.frame(sourceFiles,randomNames,realNames, timeInsert)
  DFtime <- format(Sys.Date(), format="%Y-%m-%d")
  DFfname <- gsub("^\\..+/+|.csv$", "",fileName)    
  write.table(DFcheck, file = paste0("./files/","Files&codes-",DFfname,"-",DFtime,".csv"),append = FALSE, quote = TRUE, sep = ",",qmethod = "double", row.names=F)
}