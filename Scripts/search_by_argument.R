get_arg <- function(chunk_start = 0, chunk_end = 30,...){  
    
    arg_srch = readline(prompt="Please, insert the argument you are looking for: ")
    
    ## SPLITTING
    ############
    
    splitting <- strsplit(arg_srch, split = " ")
    splitted <- unlist(splitting)
    
    ## URL Area
    ############ 
    
    
    url_search_tmp1 <- "https://scholar.google.com/scholar?hl=en&as_sdt=0%2C5&q="
    url_search_tmp2 <- "&btnG="
    url_search_tmp <- paste(url_search_tmp1,sprintf("%s",paste(splitted,collapse="+")),url_search_tmp2,sep="")
    
    ## Parsing
    ############
    
    sleep_times <- seq(0.1, 3, length.out = 6)
    
    srch_page_parse <- GET(url_search_tmp, handle=getOption("scholar_handle")) %>% htmlParse()
    srch_page <- GET(url_search_tmp, handle=getOption("scholar_handle")) %>% read_html()
    papers <- srch_page %>% html_nodes(".gs_rt") %>% html_text() %>% as.character()
    kind <- str_extract(papers,"\\[(.*?)\\]")
    papers <- gsub("\\[(.*?)\\]\\s","",papers)
    abstract <- srch_page %>% html_nodes(".gs_rs") %>% html_text() %>% as.character()
    authors <- srch_page %>% html_nodes(".gs_a") %>% html_text() %>% as.character()
    cited <- srch_page %>% html_nodes(".gs_or_cit+ a") %>% html_text() %>% as.character()
    cited <- as.integer(str_extract(cited,'\\d{1,200}'))
    # !!!!! N.B. : Authors has to be cleaned 
    # Citations: .gs_or_cit+ a
    
    year <- as.integer(str_extract(authors,"\\d{4}"))
    journal <- sub(".*?-(.*?)\\s*","",authors)
    real_auth <- str_extract(authors,".*?-(.*?)\\s*")
    real_auth <- gsub("\\s-","",real_auth)
    
    # Authors c'è un problema: quei ... vengono letti in quanto tali dal programma. Va migliorata questa cosa.
    
    # Anche nel caso dei giornali, il titolo rischia di essere incompleto...
    
    # Nota che questa pagina: "https://scholar.google.it/scholar?start=%d&q=Data+Science&hl=it&oe=ASCII&as_sdt=0,5" con %d pari a zero
    # ci da i risultati della prima pagina.
    
    # NOVITA' del 23/10: i ... vengono indicati in quanto tali dal parsing della pagina, quindi c'è poco da fare in merito.
    # Un'alternativa potrebbe essere quella di considerare di prendere dalle singole pagine i ... <-.->
    
    # Per i bibtex... Ci sono alcuni problemi nella definizione. Un approccio veloce consisterebbe nell'effettuare una ricerca 
    # in base al titolo del singolo paper per poi andare a prendere le info più dettagliate. I bibtex di scholar si sono dimostrati errati.
    
    # Il sito per il javascript scraping è il seguente: https://www.r-bloggers.com/web-scraping-javascript-rendered-sites/ o anche
    # questo approccio è da provare: https://stackoverflow.com/questions/30195092/scraping-a-web-with-javascript-links
    
    ## Links Extraction
    ############
    
    links<-xpathSApply(srch_page_parse,path = "//a",xmlGetAttr,"href")
    
    # 21/10 Problema: il pattern che utilizza links è il seguente: "/scholar?start=%d&q=Data+Science&hl=it&oe=ASCII&as_sdt=0,5"  
    # dove %d è un numero. Purtroppo da href prima pagina si arriva al massimo a 90 risultati. Google 
    # visualizza almeno le prime 100 pagine! Continuo con scraping autori.
    
    url_pg1 <- "/scholar?start="
    url_spec <- gsub("(.*?)start=\\d{2}","%d",links[grepl("/\\w{7}\\?start=\\d{2}",links,perl=T)][1])
    
    # Next step: try to get the pages one after the other and all the info needed. The main idea is to get each page
    #############
   
    pages <- seq(from = chunk_start, to = chunk_end ,by = 10)
   
    url_pg_srch <- paste(url_pg1,url_spec,sep="")
    
    AU <- authors
    AB <- abstract
    PA <- papers
    YY <- year
    JO <- journal
    KI <- kind
    CI <- cited
    
   
        for (i in pages){
          tmp_pg <- sprintf(url_pg_srch,i)
          tmp_read <- GET(paste("https://scholar.google.it",tmp_pg,sep=""), handle=getOption("scholar_handle")) %>% read_html()
          tmp_pa <- tmp_read %>% html_nodes(".gs_rt") %>% html_text() %>% as.character()
          tmp_ki <- str_extract(tmp_pa,"\\[(.*?)\\]")
          tmp_pa <- gsub("\\[(.*?)\\]\\s","",tmp_pa)
          tmp_ci <- tmp_read %>% html_nodes(".gs_or_cit+ a") %>% html_text() %>% as.character()
          tmp_ci <- as.integer(str_extract(tmp_ci,'\\d{1,200}'))
          CI <- append(CI,tmp_ci)
          PA <- append(PA,tmp_pa)
          KI <- append(KI,tmp_ki)
          tmp_au <- tmp_read %>% html_nodes(".gs_a") %>% html_text() %>% as.character()
          AU <- append(AU,tmp_au)
          tmp_yy <- as.integer(str_extract(tmp_au,"\\d{4}"))
          YY <- append(YY,tmp_yy)
          tmp_ab <- srch_page %>% html_nodes(".gs_rs") %>% html_text() %>% as.character()
          AB <- append(AB,tmp_ab)
          tmp_jo <- sub(".*?-(.*?)\\s*","",tmp_au)
          JO <- append(JO,tmp_jo)
          Sys.sleep(time = sample(sleep_times))
        }
  
    AU_R <- str_extract(AU,".*?-(.*?)\\s*")
    AU_R <- gsub("\\s-","",AU_R)
    
    Data <- data.frame(PA,AU_R,AU,YY,JO,CI,KI)
    
    return(Data)
    
}    
    ##==================================================================================================================================================##
    # 29/10 Another Issue: abstract are gross, even if scraped by bibtex from Scholar. Scholar has a wider range but a very limited info retrieval.      #
    # Scholar might be usefull to retrieve a massive set of data (even if chunked by time), but incomplete on its scope. However paper titles are there  #
    # and there are a plenty (1000 obs for search is a really interesting feature, after all).                                                           #  
    # To be completed: retrieve full authors info in order to discover how much time a certain author is present in a publication set. Maybe a cross set #
    # with scopus with paper title might allow for further details. Moreover, Abstract has less col than the other pubs, even from bibtex...             #
    # A possible development regards the possibility to use thsi script to retrieve some of the authors and then scrape Scholar author by author, giving #
    # an humongous dataset.                                                                                                                              #
    ##==================================================================================================================================================##
   
    
    
    ##=======================================================================================================================##
    # Problem: Google Scholar is against scraping even for academic purposes... Cannot scrape all the pages at once...        #
    # from stack overflow: Google will eventually block your IP when you exceed a certain amount of requests...... My God!    #
    # Let's chunk the requests time by time...                                                                                #
    ##=======================================================================================================================##
    
    
    ############
    #id_tmp <- sub(".*?=(.*?)&.*", "\\1", links[18]) #to extract elements in between (.*?): match everything in a non-greedy way and capture it.
    #if(nchar(id_tmp[1])!= 12){
    #  warning("Seems like the author you have searched for is not on scholar. You might have misspelled his full name")
    #}else{
    #  return(id_tmp[1])
