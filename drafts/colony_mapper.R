##%######################################################%##
#                                                          #
####                   colony_mapper                    ####
#                                                          #
##%######################################################%##

# Packages
require(tidyverse)
require(plotly)
require(ggmap)

# Stuff to read
cm_df=read.csv("~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/testcolonizeR.csv")
min_fam_size = 1
cm_df$date = as.Date(cm_df$date, "%m/%d/%y")

mid_season = ""

# Function
cm_df$FamilyID = as.factor(cm_df$FamilyID)

cm_ind = cm_df %>% 
  filter(FamilyID !="s")

cm_fam = cm_ind %>% 
  group_by(FamilyID) %>% 
  summarise(x.fam.center = mean(x), y.fam.center = mean(y), n = n()) %>% 
  filter(n >= min_fam_size)

cm_combo = inner_join(cm_ind,cm_fam, by=c("FamilyID"))

cm_filt = cm_combo %>% 
  mutate(ctr.dist = sqrt((x - x.fam.center)^2+(y - y.fam.center)^2
  )) %>% 
  select(-species,-male,-n,-date.time,-time,-note) #%>% 
  #filter(date < "2015-06-30")#%>% 
#summarise(mean.range = mean(ctr.dist), min(ctr.dist), max(ctr.dist))

cm_stats = cm_filt %>% 
  summarise(mean.range = mean(ctr.dist), min(ctr.dist), max(ctr.dist))

cm_stats

ggplotly(ggplot(data=cm_filt) + geom_point(aes(x=x,y=y,color=FamilyID)) + geom_point(aes(x=x.fam.center,y=y.fam.center, color=FamilyID), shape=8, size=2) + geom_segment(aes(x=x.fam.center, y=y.fam.center, xend=x, yend=y, color=FamilyID), alpha=0.2) + theme_classic() + labs(x=NULL,y=NULL,title=paste("Distance to colony center:\n","Mean:",round(cm_stats[1,1],2),"\n Min distance:",round(cm_stats[1,2],2),"\n Max distance",round(cm_stats[1,3],2))) + theme(plot.title = element_text(size = rel(0.75))))

#### Trying to get basemaps working below here. 

basemap <- get_map(location=c(lon = -120.160785, lat = 39.273571), zoom=11, maptype = 'satellite')

ggmap(basemap)  + ggplot(data=cm_filt) + geom_point(aes(x=x,y=y,color=FamilyID)) + geom_point(aes(x=x.fam.center,y=y.fam.center, color=FamilyID), shape=8, size=2) + geom_segment(aes(x=x.fam.center, y=y.fam.center, xend=x, yend=y, color=FamilyID), alpha=0.2) + theme_classic() + labs(x=NULL,y=NULL,title=paste("Distance to colony center:\n","Mean:",round(cm_stats[1,1],2),"\n Min distance:",round(cm_stats[1,2],2),"\n Max distance",round(cm_stats[1,3],2))) + theme(plot.title = element_text(size = rel(0.75)))


library(rgdal)
# prepare UTM coordinates matrix
utmcoor<-SpatialPoints(cbind(cm_filt$x,cm_filt$y), proj4string=CRS("+proj=utm +zone=12"))
#utmdata$X and utmdata$Y are corresponding to UTM Easting and Northing, respectively.
#zone= UTM zone
# converting
longlatcoor<-spTransform(utmcoor,CRS("+proj=longlat"))

cm_coord = bind_cols

# Restart basemap attempts

require(sf)

df.SP <- st_as_sf(cm_filt, coords = c("x", "y"), crs = 32612)

df.SP<-st_transform(x = df.SP, crs = 4326)
df.SP$lon<-st_coordinates(df.SP)[,1] # get coordinates
df.SP$lat<-st_coordinates(df.SP)[,2] # get coordinates

df.SP<-st_set_geometry(df.SP, NULL)

df.SP1 <- st_as_sf(df.SP, coords = c("x.fam.center", "y.fam.center"), crs = 32612)

df.SP1<-st_transform(x = df.SP1, crs = 4326)
df.SP1$lon.center<-st_coordinates(df.SP1)[,1] # get coordinates
df.SP1$lat.center<-st_coordinates(df.SP1)[,2] # get coordinates

df.SP1<-st_set_geometry(df.SP1, NULL)

st_write(df.SP, "drafts/dfSP.shp")


######
#library(leaflet)

#leaflet() %>%
#  addTiles() %>%
#  addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>%
  addProviderTiles("Esri.WorldImagery", group = "ESRI Aerial") %>%
  addCircleMarkers(data=df.SP, group="FamilyID", radius = 4, opacity=1, fill = "darkblue",stroke=TRUE,
                   fillOpacity = 0.75, weight=2, fillColor = "yellow",
                   popup = paste0("Spring Name: ", df.SP$FamilyID,
                                  "<br> Temp_F: ", df.SP$FamilyID,
                                  "<br> Area: ", df.SP$FamilyID)) %>%
  addLayersControl(
    baseGroups = c("Topo","ESRI Aerial"),
    overlayGroups = c("Hot SPrings"),
    options = layersControlOptions(collapsed = T))

#####

library(ggmap)
library(cowplot)

location=c(-120.2727,39.46166) # set the center of the map

map4 <- get_map(location=location,crop = F,
                color="bw",
                maptype="terrain",
                source="google",
                zoom=14)

#ggmap(map4)
sitemap <- ggmap(map4, extent = 'device')

sitemap + 
  labs(x="Longitude (WGS84)", y="Latitude") + 
  geom_point(data=df.SP, aes(lon, lat, fill=NULL), 
            color="#2A788EFF", alpha=0.7) +
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

#df.SP1bigfams = filter(df.SP1 )

ggplotly(sitemap + 
  #geom_point(data=df.SP1, aes(x=lon,y=lat,color=FamilyID)) + 
  geom_point(data=df.SP1, aes(x=lon.center,y=lat.center, color=FamilyID), shape=8, size=2) + 
  geom_segment(data=df.SP1, aes(x=lon.center, y=lat.center, xend=lon, yend=lat, color=FamilyID), alpha=0.5) + 
  theme_classic() + 
  labs(x=NULL,y=NULL,title=paste("Distance to colony center:\n","Mean:",round(cm_stats[1,1],2),"\n Min distance:",round(cm_stats[1,2],2),"\n Max distance",round(cm_stats[1,3],2))) + theme(plot.title = element_text(size = rel(0.75))))









