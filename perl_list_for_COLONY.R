# RAPTURE bamlist & bamclst creation for different groups/sites
# 2017-Jun
# 2017-July, Mola edits

# LOAD LIBRARIES ----------------------------------------------------------

suppressMessages({
  library(tidyverse);
  library(lubridate);
  library(magrittr)
})

options(scipen = 12) # to avoid issues with paste functions

# Create the necessary bamlist on cluster, with whatever subsampling and filters needed

# GET DATA ----------------------------------------------------------------

# set subsample number & site (only needed if subsampled script was run)
bamNo<-30
site<-"vosi_mcl"

# metadata
metadat<- read_csv("McLaughlin/Data/AllYears/mcl_all_matched.csv")

# read in the bamlist (after transferring from cluster):
bams <- read_tsv("McLaughlin/Data/AllYears/vm_30_bams_matched", col_names = F)

# remove the *000 component for join (only needed if subsampled script was run and bams have number in them)
subsamp<-format(bamNo*1000, scientific=F) 
bams$X1<-gsub(pattern = paste0(".sort.flt_",subsamp,".bam"), replacement = "", bams$X1)


# JOIN WITH FLT SUBSAMPLE LIST --------------------------------------------

dfout <- inner_join(metadat, bams, by=c("library.ID"="X1")) %>% arrange(library.ID) #ALWAYS CHECK THAT THIS MATCHES THE ORIGINAL ORDER OF THE BAMLIST!! It should...but paranoia is appropriate here. 

# WRITE TO BAMLIST --------------------------------------------------------

# Write out the header file needed for Geno2Colony.pl
write_delim(as.data.frame(paste0(dfout$unique.ID)),
           path = "McLaughlin/Data/AllYears/vm_sub_30_perl_header", col_names = F)

