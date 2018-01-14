##%######################################################%##
#                                                          #
####                     Real Data                      ####
#                                                          #
##%######################################################%##


require(tidyverse)
gf1 = read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/matched_600k_lib1.geno", col_names = FALSE)

gf1 = gf1 %>% 
  mutate(SNP = paste0(X1,X2)) %>% 
  select(-X1,-X2,-X3,-X4) %>% 
  select(SNP, everything())

#rand_df = data.frame(replicate((length(gf1)+3),sample(-1:2,nrow(gf1),rep=TRUE)))
#rand_df1 = cbind(gf1$SNP, rand_df)
#rand_df2 = rand_df1 %>% 
#  select(-X1,-X2,-X3,-X4)

#rand_df = gf1[sample(nrow(gf1)),]
#rand_df1 = rand_df %>% 
#  select(-SNP)
#rand_df2 = cbind(gf1$SNP, rand_df1)

rand_df = gf1 %>% 
  select(-SNP)
rand_df1 = rand_df[,sample(ncol(rand_df))]
names(rand_df1) <- paste0('X', 5:(length(gf1)+3))
rand_df2 = cbind(gf1$SNP, rand_df1)

gf2 = read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/matched_600k_lib2.geno", col_names = FALSE) 

gf2 = gf2 %>% 
  mutate(SNP = paste0(X1,X2)) %>% 
  select(-X1,-X2,-X3,-X4) %>% 
  select(SNP, everything()) 

gf3 = inner_join(gf1,gf2,by=c("SNP"))

gf3.r = inner_join(gf1,rand_df2,by=c("SNP"="gf1$SNP"))


gf4 = gather(gf3, key="individual", value="genotype", -SNP) %>% 
  separate(individual, c("individual", "library")) %>% 
  spread(library,genotype)

gf4.r = gather(gf3.r, key="individual", value="genotype", -SNP) %>% 
  separate(individual, c("individual", "library")) %>% 
  spread(library,genotype)

gf5 = mutate(gf4, score = if_else(x == -1 | y == -1, NA, if_else(x==y, TRUE, FALSE)))

gf5.r = mutate(gf4.r, score = if_else(x == -1 | y == -1, NA, if_else(x==y, TRUE, FALSE)))


gf5.1 = gf5 %>% 
  group_by(SNP, score) %>% 
  summarise(count=n()) %>% 
  filter(score == TRUE)

gf5.1.r = gf5.r %>% 
  group_by(SNP, score) %>% 
  summarise(count=n()) %>% 
  filter(score == TRUE)


gf5.2 = gf5 %>% 
  group_by(SNP, score) %>% 
  summarise(count=n()) %>% 
  filter(score == FALSE)

gf5.2.r = gf5.r %>% 
  group_by(SNP, score) %>% 
  summarise(count=n()) %>% 
  filter(score == FALSE)

full_join_NA <- function(x, y, ...) {
  full_join(x = x, y = y, by = ...) %>% 
    mutate_all(funs(replace(., which(is.na(.)), 0)))
}

gf5.3 = full_join_NA(gf5.1,gf5.2, by=c("SNP")) %>% 
  mutate(percent_correct = count.x/(count.y+count.x)) #%>% 
  #filter(percent_correct >= 0.95)

gf5.3.r = full_join_NA(gf5.1.r,gf5.2.r, by=c("SNP")) %>% 
  mutate(percent_correct = count.x/(count.y+count.x)) #%>% 
#filter(percent_correct >= 0.95)

maf_gf=read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/matched_600k_lib1.mafs")  

maf_gf = mutate(maf_gf, SNP = paste0(chromo,position))

gf5.4 = inner_join(gf5.3, maf_gf, by = c("SNP"))

gf5.4.r = inner_join(gf5.3.r, maf_gf, by = c("SNP"))

gf5.4.1 = inner_join(gf5, maf_gf, by = c("SNP"))

gf5.4.1.r = inner_join(gf5.r, maf_gf, by = c("SNP"))

  ggplot() + geom_point(data=gf5.4, aes(x = knownEM, y = percent_correct, color=nInd), alpha=0.2) + geom_point(data=gf5.4.r, aes(x= knownEM, y= percent_correct), color = "orange", alpha=0.05) + labs(x = "MAF from library 1") + scale_colour_continuous() + labs(title="600k -- yellow is randomized")

#maf_gf2=read_tsv("~/Google Drive/Davis/Projects/RAD Sequencing/matched_600k_lib2.mafs")  

#maf_gf2 = mutate(maf_gf2, SNP = paste0(chromo,position))

#gf5.4.2 = inner_join(gf5.3, maf_gf2, by = c("SNP"))

#ggplot(data = gf5.4.2, aes(x = knownEM, y = percent_correct)) + geom_point() + labs(x = "MAF from library 2")

gf5.4 %>% 
  #filter(nInd >= 49) %>% 
  ggplot(., aes(x=percent_correct)) + geom_bar(stat="count", binwidth = 0.01) + labs(title="600k")

gf5.4.r %>% 
  #filter(nInd >= 49) %>% 
  ggplot(., aes(x=percent_correct)) + geom_bar(stat="count", binwidth = 0.01) + labs(title="600k randomized")


gf5.4.1 %>% 
  filter(!is.na(score)) %>% 
  summarise(true_count=sum(score), total_count=n(), percent = true_count/total_count)

gf5.4.1.r %>% 
  filter(!is.na(score)) %>% 
  summarise(true_count=sum(score), total_count=n(), percent = true_count/total_count)


##%######################################################%##
#                                                          #
####                    Example Data                    ####
#                                                          #
##%######################################################%##

require(tidyverse)
raint = c(-1:2)
prob1 = c(0.01, 0.05, 0.05, 0.9)
tf1 = data_frame(SNP = c("SNP1", "SNP2", "SNP3", "SNP4", "SNP5"), 
                 ind1 = sample(raint, 5, replace=TRUE, prob = prob1),
                 ind2 = sample(raint, 5, replace=TRUE, prob = prob1),
                 ind3 = sample(raint, 5, replace=TRUE, prob = prob1),
                 ind4 = sample(raint, 5, replace=TRUE, prob = prob1),
                 ind5 = sample(raint, 5, replace=TRUE, prob = prob1))

tf2 = data_frame(SNP = c("SNP1", "SNP2", "SNP3", "SNP4"), 
                 ind1 = sample(raint, 4, replace=TRUE, prob = prob1),
                 ind2 = sample(raint, 4, replace=TRUE, prob = prob1),
                 ind3 = sample(raint, 4, replace=TRUE, prob = prob1),
                 ind4 = sample(raint, 4, replace=TRUE, prob = prob1),
                 ind5 = sample(raint, 4, replace=TRUE, prob = prob1))

tf3 = inner_join(tf1,tf2,by=c("SNP"))

tf4 = gather(tf3, key="individual", value="genotype", -SNP) %>% 
  separate(individual, c("individual", "library")) %>% 
  spread(library,genotype)

tf5 = mutate(tf4, score = if_else(x == -1 | y == -1, NA, if_else(x==y, TRUE, FALSE)))

tf5.1 = tf5 %>% 
  group_by(SNP, score) %>% 
  summarise(count=n()) %>% 
  filter(score == TRUE)


tf5.2 = tf5 %>% 
  group_by(SNP, score) %>% 
  summarise(count=n()) %>% 
  filter(score == FALSE)

full_join_NA(tf5.1,tf5.2, by=c("SNP")) %>% 
  mutate(percent_correct = count.x/(count.y+count.x))


tf5 %>% 
  filter(!is.na(score)) %>% 
  summarise(true_count=sum(score), total_count=n(), percent = true_count/total_count) 


















