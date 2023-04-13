# Instalar paquetes y cargarlos
install.packages("rgbif")
library(rgbif)

# Buscar un conjuntos de datos
# En este caso vamos a buscar los datos subidos por promigas
orgs<-organizations(country="CO",limit=60)
uuid.promigas<-orgs$data$key[grep("Promigas",orgs$data$title)]

# Dentro de los datos subidos por promigas hay varios conjuntos de datos
promigas.datasets<-dataset_search(publishingOrg = uuid.promigas)
# En este caso el que queremos es el conjunto de datos esta en la posición 2
# Monitoreos en areas de compensación por perdidad... Gasoducto Mamonal-Paiva
key.MamonalPaiva<-promigas.datasets$data$datasetKey[2]
# Guardamos la información del conjunto de datos
dtset.INFO<-datasets(data = "all",type="occurrence",uuid=key.MamonalPaiva)

# Descargar los datos
# Para descargar el conjunto de datos, ingresar el user, pwd y email de la cuenta
# personal creada en GBIF
dtset<-occ_download(pred("datasetKey",key.MamonalPaiva),user="XXXX",pwd = "XXXXXX",email="XXXXXX")
occ_download_wait('0165224-230224095556074')
d.MP <- occ_download_get('0165224-230224095556074') %>%
  occ_download_import()

# Vamos a analizar los datos solamente de las aves.
# Para esto entonces tomamos un subset que corresponde solamente al conjunto de
# observaiones de aves
d.MP.Aves<-d.MP[d.MP$class=="Aves",]
unique(d.MP.Aves$samplingProtocol)

# Como pueden ver en la descripción de los datos, hay varias formas de registro
# de aves. En este caso, solo vamos a tomar los de capturas
d.MP.Aves<-d.MP.Aves[d.MP.Aves$samplingProtocol=="Captura",]

# Organizar por diferentes eventos. Corresponden a diferentes sitios 
# o diferentes fechas
eventos.muestreo<-data.frame(d.MP.Aves[which(!duplicated(d.MP.Aves$eventID))
                                       ,c("eventID"
                                          ,"eventDate"
                                          ,"decimalLongitude"
                                          ,"decimalLatitude")])
# Organizar una tabla por evento de muestreo y especies para obtener estadisticas
# por evento
MP.commmat<-table(d.MP.Aves$eventID,d.MP.Aves$species)
MP.commmat<-as.data.frame.matrix(MP.commmat)

# Estadisticas por evento de muestreo
# Numero de especies
specnumber(MP.commmat)

# Diversidad de Shannon
exp(diversity(MP.commmat))

# Estimadores de riqueza
estimateR(MP.commmat)

# Estadisticas para el conjunto de datos en total
specpool(MP.commmat)

# Distancia en composición entre los conjuntos de datos
vegdist(MP.commmat,binary=TRUE)

################################################################################
#Plantas
d.MP.plantas<-d.MP[d.MP$phylum=="Tracheophyta",]
unique(d.MP.plantas$samplingProtocol)
# Ver la información del muestreo de flora asociada con la información del conjunto
# de datos
dtset.INFO$data$samplingDescription$methodSteps[1]

# Tomar solo las observaciones que corresponden a un muestreo por Avistamiento
d.MP.plantas<-d.MP.plantas[d.MP.plantas$samplingProtocol=="Avistamiento",]

# Continuar aqui calculando el numero de especies por evento de muestreo, la diversidad
# de cada evento y la similitud entre los eventos de muestreo.
