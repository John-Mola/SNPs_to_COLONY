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

# SUBSAMPLE ON FARM -------------------------------------------------------

# sbatch -p high -t 24:00:00 02b_run_subsample.sh bam_sort_list 30000

# MAKE BAMLIST_FLT --------------------------------------------------------

# ls *flt_100000* > bamlist_flt_100k

## USE SFTP TO GRAB FILE:

# cd Documents/github/rabo_genomics/data/RAPTURE
# sftp -P 2022 rapeek@farm.cse.ucdavis.edu
# cd projects/rana_rapture/fastq
# get bamlist_flt_100k

# GET DATA ----------------------------------------------------------------

# set subsample number & site
bamNo<-100
site<-"vosi_mcl"
# "NFA_sites", "NFA", "YUB", "SM-RASI", "RANA", "AMER_YUB", "MFA_RUB" # useless Ryan stuff ;) 

# metadata
# NOTE FOR RYAN: would be good for there to be an indication of what the metadata file should look like. Or at least what the columns are. Just realizing mine has no column headers lol
metadat<- read_csv("McLaughlin/Data/AllYears/mcl_all_matched.csv")

# this is the filtered subsampled list:
# NOTE: modify per user's naming convention
bams <- read_tsv("RAD Sequencing/BIG_SEQUENCE_DUMP_trials/bam_lists/vm_100_bam", col_names = F)

# remove the *000 component for join
subsamp<-format(bamNo*1000, scientific=F) ## Had to add format to keep R from doing scientific notation which then ruined below gsub. Probably a cleaner way to do it. 
bams$X1<-gsub(pattern = paste0(".sort.flt_",subsamp,".bam"), replacement = "", bams$X1)

# FILTER TO HUC OR REGIONS ---------------------------------------------

# NFA (H8) & AMER/YUB
#h8<- c("North Fork American", "Upper Yuba", "South Fork American")
#h8<- c("North Fork American")

# join samples with platelist:
#dat <- filter(metadat, HU_8_Name %in% h8)

# FILTER TO PLATE ---------------------------------------------------------

# MUSSULMAN SAMPLES ONLY:
#dat<- filter(metadat, RAD_ID=="RAD-212" | RAD_ID=="RAD-213") %>% filter(is.na(YYYY))

# ALL RANIDS
#dat<- filter(metadat, Collection=="WSU4")

# FILTER BY SITE NAME -----------------------------------------------------

# filter by site name:
# dim(metadat[startsWith(x = metadat$Locality, "NFA"),])
# dim(metadat[startsWith(x = metadat$Locality, "NFY"),])
# dim(metadat[startsWith(x = metadat$Locality, "MFA"),])
# dim(metadat[startsWith(x = metadat$Locality, "RUB"),])

# Specific Sites Only: NFA
#dat <- metadat[startsWith(x = metadat$Locality, "NFA"),]

# Specific Sites Only: MFA_RUB
#dat <- metadat[startsWith(x = metadat$Locality, "MFA")| startsWith(x = metadat$Locality, "RUB"),]
             

# FILTER BY SPECIES -------------------------------------------------------

# filter to RASI ONLY for both NFA and WSU samples
#dat <- filter(metadat, SPP_ID=="RASI" | SPP_pc1=="RASI")


# RENAME CASTES -----
metadat$queen <- if_else(metadat$queen == 1, "queen", "worker", "worker")

# NO FILTER, JUST RENAME -----
dat <- metadat
# JOIN WITH FLT SUBSAMPLE LIST --------------------------------------------

dfout <- inner_join(dat, bams, by=c("library.ID"="X1")) %>% arrange(library.ID)

# WRITE TO BAMLIST --------------------------------------------------------

# Write out to a the bam list for angsd
write_delim(as.data.frame(paste0(dfout$library.ID, ".sort.flt_",subsamp,".bam")),
           path = "./RAD Sequencing/BIG_SEQUENCE_DUMP_trials/vm_30_bams_matched", col_names = F)

# WRITE CLST FILE ---------------------------------------------------------

names(dfout)


# LOCAL VERSION FOR PLOTTING: River, Pop, ID
# clst_out1<-select(dfout, Locality, SampleID, HUC_10) %>%
#   dplyr::rename(FID=Locality, IID=SampleID, CLUSTER=HUC_10)

clst_out1<-dfout %>% 
  dplyr::select(unique.ID, queen, year) %>% #had to add dplyr:: because clashing with MASS (prob from the 12 other R files I'm running at once)
  dplyr::rename(FID=unique.ID, IID=queen, CLUSTER=year)
head(clst_out1)
write_delim(clst_out1, path=paste0("vm_",bamNo,"_clst"))


# BASH --------------------------------------------------------------------

# ANGSD SITES
# sbatch -p high -t 24:00:00 03_pca_calc_sites.sh bamlist_YUB_100k yub_100k

# PCA
# sbatch -p med -t 12:00:00 04_pca_plot.sh yub_100k bamlist_YUB_100k_clst
