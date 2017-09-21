require(ggplot2)
require(RColorBrewer)
require(reshape2)
require(directlabels)

for(x in 1:length(countries)){
  assign(paste(countries[x],"_costs",sep=""),costs_data[costs_data$GEO == paste(countries[x]),])
}

#plot grafico da correggere

# Grafico smoothing tutti assieme - ITA:

p1 <- ggplot(Italy_TAXclean,aes(x=TIME,y=Value,colour=CONSOM,group=BREAKDOWN))+
      geom_point(alpha=.3)+geom_smooth(alpha=.2,size=1,aes(colour=BREAKDOWN))+
      ggtitle("Valori approssimati per tipologia di spesa")

### nota che Italy_TAXclean ha in euro il costo del consumo dei consumatori, mentre Italy_costs da il costo del consumo indusriale.

### Colori Random

manyColors <- colorRampPalette((brewer.pal(name="Set3",n=11)))

lty <- setNames(unique(sample(1:1200,39,T),fromLast = T),levels(costs_data$GEO))

### Grafico per elementi industria e consumatori
graph <- function(data = df,comment = NULL,country.pos = "last.points", ...){
  ggplot(data,aes(x=as.factor(TIME),y=Value,colour=GEO,group=GEO,linetype=GEO))+
        geom_line(size=.65)+scale_colour_manual(values = manyColors(39))+
        geom_point(size=1.5)+ggtitle(paste(comment))+xlab("Anno")+
        ylab(paste("Valori indicizzati"))+scale_linetype_manual(values=lty)+
        geom_dl(aes(label = GEO), method =  paste(country.pos),cex=0.8)+
        scale_color_hue(c=100,l=50)
}

# Istogramma per componenti energetiche

# 1 Prendo i valori dei differenti profili:

consom <- unique(finalcosts_taxes$CONSOM)
consom <- as.character(consom)

# 2 Creo i dataset per profili tra tutta la popolazione europea:

for(v in 1:length(consom)){
    assign(paste(substr(consom[v],6,7),"_consum",sep=""),finalcosts_taxes[finalcosts_taxes$CONSOM==consom[v],])
}

# 3 grafico a torta
lab <- as.character(unique(DC_consum$BREAKDOWN))
require(plotrix)
piefunc <- function(x = df, country = "Italy", time = "2015S2", currency = "Euro",... ) {
    tmp <- subset(x,GEO == country & TIME == time & CURRENCY == currency, select = c(BREAKDOWN ,Value ))
    return(tmp)
}

tempo <- piefunc(DB_consum)

pie(tempo[,2],labels = tempo[,1], col = c("#FF0000FF","#00FF00FF", "#0000FFFF"),main=paste("Impatto sul prezzo totale",substr(db[d]),1,2))


####################
### SUBSET USING ###
###     GREP     ###
####################


# df[grep("thing",df$x),]


####################################
# SUBSETTING ACCORDING TO MULTIPLE #
#### LEVELS OF A CERTAIN VECTOR ####
####################################

# 1) set the elements you want to sub
# into as a vector of values:


# label_fin <- df$x


# 2) Use the subset function:


# fin_subset <- subset(df, x %in% label_fin)

#####################################
### Passare da Time Series a dati ###
######  GGPLOT 2 - Compatibili ######
#####################################

# Prezzi_energia era un dataset con nome colonne le date
# e con righe le variabili. Quindi, per passare da questo
# ad un formato compatibile con GGPLOT 2 ho usato:

 Prezzi_melted <- melt(Prezzi.energia,id.vars = "geo.time")

# Dove geo.time è il nome della colonna con i paesi all'interno.

## Il risultato è stato qualcosa di tipo con struttura: Paese | Anno | Valore, compatibile
# con GGPLOT 2.

#### Prezzi_melted si trova in sotto 2.

#### Due grafici Assieme: 
##   p1 <- graph(Prezzi_melted[Prezzi_melted$GEO == "Luxembourg"|Prezzi_melted$GEO=="United Kingdom",],tot = 37, comment = "Valore dei Prezzi medi Europei")

