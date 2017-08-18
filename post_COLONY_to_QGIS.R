require(tidyverse) # always

# Read in FS cluster
tf = read_table(file = "Google Drive/Davis/Projects/RAD Sequencing/BIG_SEQUENCE_DUMP_trials/perl outputs/vm_m25_maf10_n86_r1.BestCluster", col_names = TRUE)

tf = tf %>% 
  select(ClusterIndex, OffspringID)

metadat<- read_csv("~/Google Drive/Davis/Projects/McLaughlin/Data/AllYears/mcl_all_matched.csv")

metadat$queen[is.na(metadat$queen)] <- 0
metadat$male[is.na(metadat$male)] <- 0
dat <- filter(metadat, queen == 0  & male == 0 & year == 2015)

dat_full <- inner_join(dat, tf, by=c("unique.ID"="OffspringID"))  %>% arrange(ClusterIndex)

dat_full1 = dat_full %>% 
  mutate(occur = !dat_full$ClusterIndex %in% dat_full$ClusterIndex[duplicated(dat_full$ClusterIndex)]
) %>% 
  mutate(FamilyID = if_else(occur == TRUE, "s", as.character(ClusterIndex)))

write_csv(dat_full1, path = "Google Drive/Davis/Projects/RAD Sequencing/BIG_SEQUENCE_DUMP_trials/perl outputs/vm_m25_maf10_n86_r1_Qready.csv", col_names = TRUE) ## write the offspring genotypes
