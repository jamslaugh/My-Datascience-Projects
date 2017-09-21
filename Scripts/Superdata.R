# Area name. Da lista areas prendo i nomi delle query da interrogare. Per cui ho:
# Area data che presenta la media delle aree geografiche
# Country data che presenta la stima paese per paese.
# La scelta del termine di paragone è dato dai valori, calcolati in media, presenti per gli indici per i paesi OECD

# Superdata[is.na(Superdata)] <- 0

Area_data <- Superdata[Superdata$Country.Name %in% areas,]
Country_data <- Superdata[Superdata$Country.Name %in% country,]

#Superdata index. Per usare gli indici Superdata.
diff <- data.frame()
for(i in 1:length(index)){
  tmp1 <- Superdata[Superdata$Series_Name==index[i],]
  opt <- tmp1[tmp1$Country.Name=="OECD members",]
    # Valerio integration
    subG <- tmp1[tmp1$Country.Name=="Germany",]
    for(yy in 1:length(opt)){
      if(is.na(opt[yy]) ){ opt[yy]<- subG[yy] }
    }
  den=(sapply(tmp1[,5:20],var, na.rm=T))
  idx <- data.frame()
  for(j in 1:length(country)){
    tmp2 <- tmp1[tmp1$Country.Name==country[j],]
    num=abs(tmp2[,5:20]-opt[,5:20])
    id=1-(num/den)
    id <- cbind(tmp2[,1:4],id)
    idx <- rbind(idx,id)
  }  
  diff <- rbind(diff,idx)
}


# controlla quanti andrebbero modificati/sostituiti. SOLO 48 (di cui alcuni sostituiti con NA)
ccount <- 0
for(i in 1:length(index)){
  tmp1 <- Superdata[Superdata$Series_Name==index[i],]
  opt <- tmp1[tmp1$Country.Name=="OECD members",]
  if(opt[19] %in% "NA"){ 
    print(opt[19])
    print(tmp1[tmp1$Country.Name=="Germany",19])
    flush.console() 
    ccount <- 1 + ccount
  }
}
