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

## USE SCP or SFTP to obtain file and put in a local directory

# GET DATA ----------------------------------------------------------------

# set subsample number & site
bamNo<-100
site<-"vosi_mcl"

# metadata
# This file should include your barcodes for each individual, and whatever information you have associated with those samples. 
# e.g. barcode | sample name | year | caste | site | species
#     ATCG...  | jm_bee1     | 2015 | queen | mcl1 | vosnesenskii
metadat<- read_csv("~/Google Drive/Davis/Projects/Sierras/Data/2015/sra_matched_all.csv")

# this is the filtered subsampled list:
# NOTE: modify per user's naming convention
bams <- read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/bamlists/sub_100k_bams", col_names = F)

# remove the *000 component for join
subsamp<-format(bamNo*1000, scientific=F) 
bams$X1<-gsub(pattern = paste0(".sort.flt_",subsamp,".bam"), replacement = "", bams$X1)

## BELOW are Ryan's examples of this to filter. Modify for YOUR needs. e.g. I most commonly need to filter by year and bumble bee caste. If you're just trying to match a subsampled bamlist made with the minimum aligned reads filter to your metadata, you can skip to line 79. 

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

# FILTER BY SPECIES -------------------------------------------------------

# filter to RASI ONLY for both NFA and WSU samples
#dat <- filter(metadat, SPP_ID=="RASI" | SPP_pc1=="RASI")


# RENAME CASTES -----
#metadat$queen <- if_else(metadat$queen == 1, "queen", "worker", "worker")

#datVSW = metadat %>% 
#  filter(is.na(male)) %>% 
#  mutate(caste = if_else(is.na(queen), "worker", "queen")) %>% 
#  filter(caste == "worker", year == 2015, species == "vosnesenskii")

#metadat <- metadat %>% 
#  mutate(caste = if_else(metadat$queen == 1, "queen", if_else(metadat$male == 1, "male", "worker")))

# NO FILTER, JUST RENAME (for consistency below) -----
#dat <- metadat

# JOIN WITH FLT SUBSAMPLE LIST --------------------------------------------

dfout <- inner_join(datB, bams, by=c("Library.ID"="X1")) %>% arrange(Library.ID) # modify "library.ID" to match your metadata file.

# WRITE TO BAMLIST --------------------------------------------------------

# Write out to a the bam list for angsd
write_delim(as.data.frame(paste0(dfout$library.ID, ".sort.flt_",subsamp,".bam")),
           path = "./RAD Sequencing/BIG_SEQUENCE_DUMP_trials/vm_30_bams_matched", col_names = F)

# WRITE CLST FILE ---------------------------------------------------------

names(dfout) # just so you know what to call stuff below

# Modify "unique.ID" "queen" and "year" to whatever you want
clst_out1<-dfout %>% 
  dplyr::select(unique.ID, site, date) %>% 
  dplyr::rename(FID=unique.ID, IID=site, CLUSTER=date)
head(clst_out1)
write_delim(clst_out1, path="~/Google Drive/Davis/Projects/Sierras/Analyses/RAD to COLONY/clst/vsw_pca_100k_out_clst")


## Write perl header file

write_delim(as.data.frame(dfout$unique.ID),
            path = "~/Google Drive/Davis/Projects/Sierras/Analyses/RAD to COLONY/perl headers/bsw_100k_header", col_names = F)


# BASH --------------------------------------------------------------------

# ANGSD SITES
# sbatch -p high -t 24:00:00 03_pca_calc_sites.sh bamlist_YUB_100k yub_100k

# PCA
# sbatch -p med -t 12:00:00 04_pca_plot.sh yub_100k bamlist_YUB_100k_clst
