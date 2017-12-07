require(tidyverse) # always

#Setwd
setwd("~/Google Drive/Davis/Projects/Sierras/Analyses/RAD to COLONY/")

# Read in FS cluster
tf = read_table(file = "colony_outputs/bestFS/bsw_75_005_1k_1k.BestCluster", col_names = TRUE)

tf = tf %>% 
  select(ClusterIndex, OffspringID)

metadat<- read_csv("../../Data/2015/sra_matched_all.csv")

metadat$queen[is.na(metadat$queen)] <- 0
metadat$male[is.na(metadat$male)] <- 0
dat <- filter(metadat, queen == 0  & male == 0 & year == 2015)

dat_full <- inner_join(dat, tf, by=c("unique.ID"="OffspringID"))  %>% arrange(ClusterIndex)

dat_full1 = dat_full %>% 
  mutate(occur = !dat_full$ClusterIndex %in% dat_full$ClusterIndex[duplicated(dat_full$ClusterIndex)]
) %>% 
  mutate(FamilyID = if_else(occur == TRUE, "s", as.character(ClusterIndex)))

write_csv(dat_full1, path = "matched_outputs/matched_bsw_75_005_1k_1k.csv", col_names = TRUE) ## write the offspring genotypes
