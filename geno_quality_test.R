### Genotype quality test

### ON CLUSTER
#Obtain the number of aligned reads using this, where "ts_bams" is your bamlist (do not sub-sample), and ts_bam_count is your output:
#for f in `cat ts_bams`; do samtools view -c ${f} ; done > ts_bams_count
#scp or sftp the "ts_bams_count" file to a local directory


##### Packages ----
require(tidyverse)

###### 

tf = read_csv("~/Google Drive/Davis/Projects/RAD Sequencing/test_nosubs_geno.csv", col_names = FALSE) ### Read in the file, I did it as a csv here, but could easily re-write this to be straight from cluster. I dumped it into excel first them converted because I wanted to visually check something


tf$X1 <- NULL # Remove first two columns cause we don't need them
tf$X2 <- NULL

tf_sub <- lapply(tf, function(x) {  #Rename all "NN" genotypes to 0
                   gsub("NN",0, x)
                })


tf_sub1 <- lapply(tf_sub, function(x) { #Rename all other genotypes to "AA" as a placeholder
  gsub("[A-Z]","A", x)
})

tf_sub2 <- lapply(tf_sub1, function(x) { #Rename all "AA" as 0
  gsub("AA",1, x)
})

tf_sub2 = as_tibble(tf_sub2) # Probably not necessary, but colSums was being a dick


tf_sub3 = sapply(tf_sub2, as.numeric) # Needed for colSums

geno_calls = colSums(tf_sub3) # Make a vector with the sum of all below calls


bam_counts = read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/ts_bams_count", col_names = FALSE) # load in that bam counts file

combined = bam_counts %>% #Mutate the two columns together, divide geno_calls by the # of SNPs given by length of a column
  mutate(geno_calls = geno_calls/length(tf_sub2$X3))

options(scipen=12)

p1 = ggplot(data = combined, aes(x=X1, y=geno_calls)) + geom_point() + geom_smooth() + labs(x="Alignments", y="Fraction of genotypes called")

p1


p2 = ggplot(data = combined, aes(x=X1)) + geom_histogram(binwidth = 20000) + labs(x="Alignments", y="# of samples")
p2
