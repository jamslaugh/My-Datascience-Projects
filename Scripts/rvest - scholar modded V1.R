# Note: much of the code in this script (the tags) has been written following SelectorGadget.
# With SelectorGadget it is possible to choose the part of the webpage and obtain the 
# CSS tag associated with.
# Probable insertion of read_html() to get to the website and make a virtual click...?
# Source for this script is: https://www.r-bloggers.com/google-scholar-scraping-with-rvest-package/ mixed with 
# scholar package function. Making this way, the scraping process can be quite simple.
#
# Plans for the future (to be completed): 
# 
# 1) I'd like to keep track of authors' id by making a virtual search over the internet
# 
# 2) I'd like to implement more API inside the search
#
# 3) The prompt id will be substituted by a prompt like: "tell me who you are looking for"
#
# 4) Some issues occour using C++ implementations like sprintf, but they are like python string formatting
#
# 5) @Professor Aria, it is my opinion that the work can be started from here.

library(rvest)
library(ggplot2)
library(RCurl)
library(XML)
library(httr)
library(stringr)
library(dplyr)
library(scholar)

get_schol_bib <- function ( cstart = 0, pagesize = 100, flush = FALSE,...) 
{
  #NOTE: we need to check for wether the full name has more than three letters.
  full_name = readline(prompt="Please, insert first name and Last Name of the scholar you are looking for: ")
  url_search_tmp1 <- "https://scholar.google.it/citations?view_op=search_authors&mauthors=%s+%s%s"
  url_search_tmp2 <- "&hl=it&oi=ao"
  # From here we first unlist the scholar and then we add a + sign in order to get the search result
  splitting <- strsplit(full_name, split = " ")
  splitted <- unlist(splitting)
  search_url <- sprintf(url_search_tmp1,splitted[1],splitted[2],url_search_tmp2)
  srch_page <- GET(search_url, handle=getOption("scholar_handle")) %>% htmlParse()
  links<-xpathSApply(srch_page,path = "//a",xmlGetAttr,"href")
  
  id = links[18]
  url_template <- "http://scholar.google.com%s&cstart=%d&pagesize=%d"
  url <- sprintf(url_template, id, cstart, pagesize)
  page <- GET(url, handle = getOption("scholar_handle")) %>% 
    read_html()
  cites <- page %>% html_nodes(xpath = "//tr[@class='gsc_a_tr']")
  title <- cites %>% html_nodes(".gsc_a_at") %>% html_text()
  pubid <- cites %>% html_nodes(".gsc_a_at") %>% html_attr("href") %>% str_extract(":.*$") %>% str_sub(start = 2)
  doc_id <- cites %>% html_nodes(".gsc_a_ac") %>% html_attr("href") %>% 
    str_extract("cites=.*$") %>% str_sub(start = 7)
  cited_by <- suppressWarnings(cites %>% html_nodes(".gsc_a_ac") %>% 
                                 html_text() %>% as.numeric(.) %>% replace(is.na(.), 
                                                                           0))
  year <- cites %>% html_nodes(".gsc_a_y") %>% html_text() %>% 
    as.numeric()
  authors <- cites %>% html_nodes("td .gs_gray") %>% html_text() %>% 
    as.data.frame(stringsAsFactors = FALSE) %>% filter(row_number()%%2 == 
                                                         1) %>% .[[1]]
  details <- cites %>% html_nodes("td .gs_gray") %>% html_text() %>% 
    as.data.frame(stringsAsFactors = FALSE) %>% filter(row_number()%%2 == 
                                                         0) %>% .[[1]]
  first_digit <- as.numeric(regexpr("[\\\\[\\\\(]?\\\\d", details)) - 
    1
  journal <- str_trim(str_sub(details, end = first_digit)) %>% 
    str_replace(",$", "")
  numbers <- str_sub(details, start = first_digit) %>% 
    str_trim() %>% str_sub(end = -5) %>% str_trim() %>% 
    str_replace(",$", "")
  data <- data.frame(title = title, author = authors, journal = journal, 
                     number = numbers, cites = cited_by, year = year, 
                     cid = doc_id, pubid = pubid)
  if (nrow(data) > 0 && nrow(data) == pagesize) {
    data <- rbind(data, get_publications(id, cstart = cstart + 
                                           pagesize, pagesize = pagesize))
  }
  results <<- data
} 