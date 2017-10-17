library(rvest)
library(ggplot2)
library(RCurl)
library(XML)
library(httr)
library(stringr)
library(dplyr)
library(scholar)
library(stringr)

get_schol_id <- function(){
  full_name = readline(prompt="Please, insert first name and Last Name of the scholar you are looking for: ")
  url_search_tmp1 <- "https://scholar.google.it/citations?view_op=search_authors&mauthors=%s+%s%s"
  url_search_tmp2 <- "&hl=it&oi=ao"
  # From here we first unlist the scholar and then we add a + sign in order to get the search result
  splitting <- strsplit(full_name, split = " ")
  splitted <- unlist(splitting)
  search_url <- sprintf(url_search_tmp1,splitted[1],splitted[2],url_search_tmp2)
  srch_page <- GET(search_url, handle=getOption("scholar_handle")) %>% htmlParse()
  links<-xpathSApply(srch_page,path = "//a",xmlGetAttr,"href")
  id_tmp <- str_extract(links,"[A-Za-z0-9]{12}")
  id_tmp <- id_tmp[!is.na(id_tmp)]
  if(length(id_tmp) > 1){
    if(nchar(id_tmp[1])!= 12){
      warning("Seems like the author you have searched is not on scholar. You might have misspelled it")
    }else{
    return(id_tmp[1])
    }
  }else{
    if(nchar(id_tmp) != 12){
      warning("Seems like the author you have searched is not on scholar. You might have misspelled it")
    }else{
      return(id_tmp)
     }
   }
}
