# Load the greatest package ever
require(tidyverse) 

# Read in your BestCluster File
bestCluster = read_table(file = "~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/vsw2m505k1.BestCluster", col_names = TRUE) 

# Read in your metadata
metadat = read_csv("~/Google Drive/Davis/Projects/Sierras/Data/2015/sra_matched_all.csv")

# Give a name to the output dataset
projectName = "testcolonizeR"

# Output directory
outdir = "~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/"


#
##
###
#####
# Don't mess with stuff below unless you must -- just run it. 
####
##
#



# Trim BestCluster
bestC = bestCluster %>% 
  select(ClusterIndex, OffspringID)

# Join, remove individuals absent in BestCluster, create FamilyID column, remove extra variables
dat_full <- inner_join(metadat, bestC, by=c("unique.ID"="OffspringID"))  %>% 
  arrange(ClusterIndex) %>% 
  mutate(occur = !ClusterIndex %in% ClusterIndex[duplicated(ClusterIndex)]
) %>% 
  mutate(FamilyID = if_else(occur == TRUE, "s", as.character(ClusterIndex))) %>%
  select(-occur,-gps.ID,-Library.ID,-unique.ID.old,-plate,-occur,-plate.ID)

## Save the dataframe
write_csv(dat_full, path = paste0(outdir,projectName,".csv"), col_names = TRUE) 
