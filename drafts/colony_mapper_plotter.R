dat_full1=read.csv("~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/testcolonizeR.csv")

dat_full1$FamilyID = as.factor(dat_full1$FamilyID)

tf =dat_full1 %>% 
  #filter(FamilyID != "s") %>% 
  group_by(ClusterIndex) %>% 
  summarise(n=n())

tf3 = dat_full1 %>% 
  filter(FamilyID =="s")

tf_in = dat_full1 %>% 
  filter(FamilyID !="s")

famcount = filter(tf, n != 1)

vosi_count = length(dat_full1$unique.ID)
vfam_count = length(famcount$n)
vsingle_count = length(tf3$unique.ID)
perc_familied = paste((round((vosi_count-vsingle_count)/vosi_count,3))*100,"%")


ggplot(tf, aes(x=n)) + geom_bar(stat="count") + labs(x= "Family size", y="Number of families")+ theme_classic() + annotate("text", label=paste(vosi_count,"individuals, \n",vsingle_count,"singletons, \n",vfam_count, "families, \n", perc_familied, "belong to families"), x = 5, y=80, hjust=0) + scale_x_continuous(breaks = seq(min(tf$n), max(tf$n), by = 1))


tf2 = dat_full1 %>% 
  filter(FamilyID !="s", site != "SH", site !="RM", site !="IN")

tf3 = dat_full1 %>% 
  filter(FamilyID =="s")

tf_in = dat_full1 %>% 
  filter(FamilyID !="s")

shared_sites = c("IN" ,  "JM02" ,"JM03" ,"JM04", "JM06" ,"JM07", "JM10" ,"SH")

tf_match_bif = dat_full1 %>% 
  filter(FamilyID !="s", site %in% shared_sites)


p1 = ggplot(tf_in, aes(x=x,y=y, color=FamilyID, group=FamilyID)) + geom_point() + geom_path(size=0.1) + theme_minimal() #+ geom_point(data=tf3, aes(x=x,y=y), alpha=0.5) 
require(plotly)

ggplotly(p1)

tf_in %>% 
  group_by(FamilyID) %>% 
  summarise(x.fam.center = mean(x), y.fam.center = mean(y), n = n()) %>% 
  filter(n>=3) %>% 
  ggplot(., aes(x=x.fam.center,y=y.fam.center, color=FamilyID)) + geom_point() + theme_classic()


fam_tf = tf_in %>% 
  group_by(FamilyID) %>% 
  summarise(x.fam.center = mean(x), y.fam.center = mean(y), n = n()) %>% 
  filter(n>=2)

indiv_tf = tf_in

combo_tf = inner_join(indiv_tf,fam_tf, by=c("FamilyID"))

filt_tf = combo_tf %>% 
  mutate(ctr.dist = sqrt((x - x.fam.center)^2+(y - y.fam.center)^2
)) %>% 
  select(-species,-male,-n,-date.time,-time,-note) #%>% 
  #summarise(mean.range = mean(ctr.dist), min(ctr.dist), max(ctr.dist))

ggplotly(ggplot(data=filt_tf) + geom_point(aes(x=x,y=y,color=FamilyID)) + geom_point(aes(x=x.fam.center,y=y.fam.center, color=FamilyID), shape=8, size=2) + geom_segment(aes(x=x.fam.center, y=y.fam.center, xend=x, yend=y, color=FamilyID), alpha=0.2) + theme_classic())


#### Extremely basic test:

require(tidyverse)

x = c(10,8,6)
y = c(5,12,9)

plot(x~y)
points(mean(x)~mean(y))

sqrt((x - mean(x))^2+(y - mean(y))^2)

