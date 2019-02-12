# Geno2Colony without filters
# Just want to take all SNPs, rename them as appropriate (ACGT>1,2,3,4), and add the headers

# Packages
require(tidyverse)

# Set some parameters for COLONY 
# Marker type (0 for biallelic SNPs, allelic dropout rate, genotype error rate)

mtype = 0
adrop = 0.05
gerror = 0.05

# Load genotype and header files
hd = read_tsv("../../Projects/RAD Sequencing/Dump/mcl16w_header", col_names = F)
generic=data_frame(X1=c("chromosome", "location"))
header=bind_rows(generic,hd)

geno_raw = read_delim("../../Projects/RAD Sequencing/Dump/m16w_100k.geno", col_names = F, delim="\t") 
geno_raw = geno_raw[, sapply(geno_raw, function(i) !all(is.na(i)))]
colnames(geno_raw) <- t(header)

geno = geno_raw %>% 
  mutate(SNP=paste0(chromosome,location)) %>% 
  select(SNP,everything(), -chromosome,-location)

dft = geno %>% # Splits individuals into their genotypes in two columns
  gather(individual, val, -SNP) %>%
  spread(SNP, val) %>% 
  gather(snp, value, -individual) %>% 
  extract(value, into=c('h1', 'h2'), '(.)(.)') 

allele_names = dft %>%# Obtains marker names and assigns them error rates
  distinct(snp) %>% 
  transmute(snp) %>% 
  mutate(marktype = mtype, alleledrop = adrop, genoerror = gerror) %>% 
  gather(col1, val, -snp) %>% 
  spread(snp, val)

allele_names$col1 = as.factor(allele_names$col1) #finishes marker name formatting
allele_names$col1  <- factor(allele_names$col1 , levels = c("marktype","alleledrop","genoerror"))
allele_names = allele_names[order(allele_names$col1), ]
allele_names = select(allele_names, -col1)

dft$h1 = as.character(dft$h1) # Reassigns genotypes to numerical values
dft$h2 = as.character(dft$h2) 
dft$h1 = recode(dft$h1, A= 1, T= 4, C = 2, G = 3, N = 0) 
dft$h2 = recode(dft$h2, A= 1, T= 4, C = 2, G = 3, N = 0)
dft$h1 = as.character(dft$h1)
dft$h2 = as.character(dft$h2) 

## Could easily add a filter here based on the .mafs file (e.g. take only SNPs with maf > 0.05 and < 0.40 or something)
mafs_raw = read_delim("../../Projects/RAD Sequencing/Dump/m16w_100k.mafs", delim="\t") 
#nInds = length(unique(dft$individual))
#mafs_flt = filter(mafs_raw, knownEM > 0.05, knownEM < 0.4, nInd > 0.75*nInds)
mafs_flt = filter(mafs_raw, knownEM > 0.05, knownEM < 0.4)
#...ok, could add stricter filters to get down to a more reasonable place...but then at that point, we're basically just doing the perl script...


dft1 = dft %>%   # Splits values, formats for colony
  gather(variable, value, -(individual:snp)) %>%
  unite(temp, snp, variable) %>%
  spread(temp, value)

write_delim(dft1, "mp_OG_v3", col_names = FALSE, delim="\t") ## write the offspring genotypes
write_delim(allele_names, "mp_ER_v3", delim="\t") ## write allele names with error rates



