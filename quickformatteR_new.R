require(tidyverse)
require(rcolony)

#Edit this stuff each time. Minimum individuals, minor allele frequency, number of individuals, run number (1-3) -----
minInd = 25
maf = 10
numInd = 500   
run.no = 1   
perl_run = paste0("vm_m",minInd,"_maf",maf,"_n",numInd,"_r",run.no)
perl_run_OG = paste0("m",minInd,"_maf",maf,"_n",numInd,"_r",run.no,"_OG.txt")
perl_run_ER = paste0("m",minInd,"_maf",maf,"_n",numInd,"_r",run.no,"_ER.txt")

#Create error rates file, set aside basically (might run into problems where subsets don't really have useable SNPs...might actually end up having to scrap this, backing up to do GenoToColony.pl with the wanted subset, then to COLONY -----
ER_input = read_tsv(file = perl_run, col_names = FALSE, n_max =4)
write_tsv(ER_input, path = perl_run_ER, col_names = FALSE) ## write the error rates

#Create offspring genotype file -----
OG_input = read_tsv(file = perl_run, col_names = FALSE, skip =4)
OG_input = OG_input[,-2]
#write_tsv(OG_input, path = perl_run_OG, col_names = FALSE) ## write the offspring genotypes

#Load in the matching file ----
metadat<- read_csv("~/Google Drive/Davis/Projects/McLaughlin/Data/AllYears/mcl_all_matched.csv")

#Filter the metadat file to whatever want ----

#Filter to year and exclude queens and males
metadat$queen[is.na(metadat$queen)] <- 0
metadat$male[is.na(metadat$male)] <- 0
dat <- filter(metadat, queen == 0  & male == 0 & year == 2015)

#Write out "dat" file for re-matching after COLONY

dat_full <- inner_join(dat, OG_input, by=c("unique.ID"="X1"))

write_tsv(dat_full, path = paste0("vm_m",minInd,"_maf",maf,"_n",n.loci,"_r",run.no,"2015_workers.txt"), col_names = TRUE) ## write the offspring genotypes

#Lapply OG_input with matching file by the unique.ID/X1 
dat_red = select(dat, unique.ID)

OG_out <- inner_join(dat_red, OG_input, by=c("unique.ID"="X1"))

#Export subset genotype file out, remove header
write_tsv(OG_out, path = perl_run_OG, col_names = FALSE) ## write the offspring genotypes


#The below steps may be easier/faster in shell
#Import and edit the header

#Import and edit the footer

#Concatenate all 4 files (header, ER file, OG file, colony)



# number of loci ----
n.loci = ncol(ER_input)
n.loci
# number of offspring
n.offspring = nrow(OG_out)
n.offspring
# Build colony.DAT file




