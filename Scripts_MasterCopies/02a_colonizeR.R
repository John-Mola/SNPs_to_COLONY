##%######################################################%##
#                                                          #
####             Function to create merged              ####
####            COLONY output with metadata             ####
#                                                          #
##%######################################################%##

# Provide function with a .BestCluster output from COLONY, a metadata file with a column named "unique.ID" that matches column "OffspringID" from BestCluster (ostensibly, these things already exist since that's needed for the input to DAT_maker), a name for the output file, and an output directory. 

# Run the function
colonizeR<-function(bestCluster, metadat, projectName, outdir)
{
  require(tidyverse)
  
  # Trim BestCluster
  bestC = bestCluster %>% 
    select(ClusterIndex, OffspringID)
  
  # Join, remove individuals absent in BestCluster, create FamilyID column, remove extra variables
  dat_full <- inner_join(metadat, bestC, by=c("unique.ID"="OffspringID"))  %>% 
    arrange(ClusterIndex) %>% 
    mutate(occur = !ClusterIndex %in% ClusterIndex[duplicated(ClusterIndex)]
    ) %>% 
    mutate(FamilyID = if_else(occur == TRUE, "s", as.character(ClusterIndex))) #%>%
    #select(-occur,-gps.ID,-Library.ID,-unique.ID.old,-plate,-occur,-plate.ID)
  
  ## Save the dataframe
  write_csv(dat_full, path = paste0(outdir,projectName,".csv"), col_names = TRUE) 
  
}

# BestCluster from COLONY
bc = read_table(file = "~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/vsw2m505k1.BestCluster", col_names = TRUE) 

# Metadata
md = read_csv("~/Google Drive/Davis/Projects/Sierras/Data/2015/sra_matched_all.csv")

# Name the output file
pn = "testcolonizeR2"

# Output directory for the final csv
od = "~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/"

# Run it with objects defined above (change names if desired)
colonizeR(bc,md,pn,od)

