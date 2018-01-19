##%######################################################%##
#                                                          #
####                    sibshipPlots                    ####
#                                                          #
##%######################################################%##


# Packages
require(tidyverse)

# Run the function
sibshipPlot<-function(sp_df, data_info)
{
  require(tidyverse)
  
  sp_df$FamilyID = as.factor(sp_df$FamilyID)
  
  sp_full = sp_df %>% 
    group_by(ClusterIndex) %>% 
    summarise(n=n())
  
  sp_singles = sp_df %>% 
    filter(FamilyID =="s")
  
  sp_families = filter(sp_full, n != 1)
  
  samp_count = length(sp_df$unique.ID)
  fam_count = length(sp_families$n)
  single_count = length(sp_singles$unique.ID)
  perc_familied = paste((round((samp_count-single_count)/samp_count,3))*100,"%")
  
  
  ggplot(sp_full, aes(x=n)) + geom_bar(stat="count") + labs(x= "Family size", y="Number of families", title=data_info)+ theme_classic() + annotate("text", label=paste(samp_count,"individuals, \n",single_count,"singletons, \n",fam_count, "families, \n", perc_familied, "belong to families"), x = max(sp_full$n)*0.6, y=single_count*0.6, hjust=0) + scale_x_continuous(breaks = seq(min(sp_full$n), max(sp_full$n), by = 1)) + geom_text(stat="count",aes(label=..count..),vjust=-1) + scale_y_continuous(limits = c(0,single_count*1.05))
  
}

# Load in a csv output from colonizeR
sp_df = read.csv("~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/testcolonizeR.csv")

# Some metadata for the project (could code in, but I want interaction here for double checking)
species = "vosnesenskii"
location = "Sierras"
year = "2015"
data_info = paste("Species:",species,"Location:",location,"Year:",year)

# Take two arguments, the colonizeR output you read in, and the data_info compiled above. 
sibshipPlot(sp_df,data_info)


