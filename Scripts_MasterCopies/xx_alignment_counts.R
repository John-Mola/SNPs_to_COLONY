### Genotype quality test

### ON CLUSTER
#Obtain the number of aligned reads using this, where "ts_bams" is your bamlist (do not sub-sample), and ts_bam_count is your output:
#for f in `cat ts_bams`; do samtools view -c ${f} ; done > ts_bams_count
#scp or sftp the "ts_bams_count" file to a local directory


##### Packages ----
require(tidyverse)

###### 

# tf = read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/test_nosubs_geno.csv", col_names = FALSE) ### Read in the file, I did it as a csv here, but could easily re-write this to be straight from cluster. I dumped it into excel first them converted because I wanted to visually check something
# 
# 
# tf$X1 <- NULL # Remove first two columns cause we don't need them
# tf$X2 <- NULL
# 
# tf_sub <- lapply(tf, function(x) {  #Rename all "NN" genotypes to 0
#                    gsub("NN",0, x)
#                 })
# 
# 
# tf_sub1 <- lapply(tf_sub, function(x) { #Rename all other genotypes to "AA" as a placeholder
#   gsub("[A-Z]","A", x)
# })
# 
# tf_sub2 <- lapply(tf_sub1, function(x) { #Rename all "AA" as 0
#   gsub("AA",1, x)
# })
# 
# tf_sub2 = as_tibble(tf_sub2) # Probably not necessary, but colSums was being a dick
# 
# 
# tf_sub3 = sapply(tf_sub2, as.numeric) # Needed for colSums
# 
# geno_calls = colSums(tf_sub3) # Make a vector with the sum of all below calls


bam_counts = read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/merged_bams_count", col_names = FALSE) # load in that bam counts file

# combined = bam_counts %>% #Mutate the two columns together, divide geno_calls by the # of SNPs given by length of a column
#   mutate(geno_calls = geno_calls/length(tf_sub2$X3))

options(scipen=12)

#p1 = ggplot(data = combined, aes(x=X1, y=geno_calls)) + geom_point() + geom_smooth() + labs(x="Alignments", y="Fraction of genotypes called")

#p1


p2 = ggplot(data = bam_counts, aes(x=X1)) + 
  geom_histogram(binwidth = 20000) + 
  labs(x="Alignments (hundred thousand)", y="# of samples") + 
  scale_x_continuous(limits=c(0,2000000), breaks=seq(0,2000000,by=100000), labels=seq(0,20,by=1)) + 
  geom_vline(xintercept = 200000, color="red", linetype = 2) + 
  geom_vline(xintercept = 100000, color="red", linetype=3) + 
  geom_vline(xintercept = 150000, color="blue", linetype=2) + 
  #geom_vline(xintercept = 50000, color="blue", linetype=3) + 
  annotate("text", x = 200000, y = 80, label = "76%") +
  annotate("text", x = 100000, y = 90, label = "95%") +
  annotate("text", x = 150000, y = 80, label = "96%") +
  #annotate("text", x = 50000, y = 90, label = "98%") +
  theme_classic() 
p2

bam_counts %>% 
  filter(X1 >= 200000) %>% 
  summarise(n=n()/1632)

bam_counts %>% 
  filter(X1 >= 100000) %>% 
  summarise(n=n()/1632)

bam_counts %>% 
  filter(X1 >= 150000) %>% 
  summarise(n=n()/1632)

# bam_counts %>% 
#   filter(X1 >= 50000) %>% 
#   summarise(n=n()/1632)
