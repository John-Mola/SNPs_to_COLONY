##%######################################################%##
#                                                          #
####  Example of how to use angsd data with snpStats    ####
#                                                          #
##%######################################################%##


## snpStats requires 3 things
# 1. A SNP Matrix with genotype calls in their fancy format. Basically, SNPs are the columns, and sample IDs are the rows. 
# 2. A SNP support data frame with the row names being the SNP names from the matrix
# 3. A sample support data frame with the row names equivalent to the row names of the matrix. Then, variables for whatever you want (e.g. population)


# Packages -----
require(snpStats)
require(tidyverse)
require(beepr)


# 1. Making the SNP Matrix ----
# Read in a genotype file (in this case genotypes are typed as 0,1,2 or -1 for no call)
df_wide = read_tsv("For_VSBuffalo/mcl_all_100k.geno", col_names = F)

# Make it into long format (takes a while, so in this example just 1000 SNPs, but all samples)
df_long = df_wide %>% 
  mutate(SNP = paste0(X1,"_",X2)) %>% 
  select(SNP, everything(), -X1, -X2, -X3, -X4) %>% 
  gather(individual, genotype, -SNP) %>% 
  mutate(confidence = "1") # Adding a "confidence" for the SNPcall arbitrarily. I don't know how to get a better confidence call? Maybe from like -doCounts or something??

# Need to make sure the column names are not saved!!
write_tsv(df_long, "./scripts/drafts/df_long", col_names = F)

gdata <- read.long("./scripts/drafts/df_long",
                   #samples = Sample_names,
                   #snps = SNP_names,
                   fields=c(snp=1, sample=2, genotype=3, confidence=4),
                   gcodes=c("0", "1", "2"),
                   threshold=0.95, # Setting above the required shit
                   no.call="-1") ; beep("mario") # Because this takes forever (not in this example with a reduced data set though!)



#write.SnpMatrix(gdata, "./metadata/vsw_400k") # Saving this shit so it loads in faster next time...except it's being a PITA

# read_back = read_file("./metadata/vsw_400k")
# new("SnpMatrix", read_back)
# summary(read_back)

# 2. Making the SNP support data frame -----

# TO DO ...can probably make this easily from the .mafs file??
# Looks like:
#       chr   pos   A1   A2
# SNP1  10   1166   A    T
# SNP2  10   1177   C    G
# etc...


# 3. Making the sample support data frame -----
# This is pulled from the df_long file above...but otherwise is probably equivalent to all of our other header lists with sample names
Sample_names = unique(df_long$individual)
# Making an arbitrary population distinction (should do actual data)
ab = rep(c("a","b"), length.out = 110)
# Making the data frame
samp.support = data.frame(pop=ab)
# Making the row names the sample names...not in their own column!
rownames(samp.support) <- Sample_names 

# Calculating Fst as an example of stuff you can do ----

f1 <- Fst(gdata, group = samp.support$pop, pairwise=T)
weighted.mean(f1$Fst, f1$weight)