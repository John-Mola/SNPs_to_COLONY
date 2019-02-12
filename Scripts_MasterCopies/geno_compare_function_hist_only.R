genotype_compare_h <-
function(gf1, gf2, maf_gf, threshold)
{
  
require(tidyverse)
require(cowplot)
  
gf1 = gf1 %>% 
  mutate(SNP = paste0(X1,X2)) %>% 
  select(-X1,-X2,-X3,-X4) %>% 
  select(SNP, everything())

rand_df = gf1 %>% 
  select(-SNP)
rand_df1 = rand_df[,sample(ncol(rand_df))]
names(rand_df1) <- paste0('X', 5:(length(gf1)+3))
rand_df2 = cbind(gf1$SNP, rand_df1)


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

maf_gf = mutate(maf_gf, SNP = paste0(chromo,position))

gf5.4 = inner_join(gf5.3, maf_gf, by = c("SNP"))

gf5.4.r = inner_join(gf5.3.r, maf_gf, by = c("SNP"))

gf5.4.1 = inner_join(gf5, maf_gf, by = c("SNP"))

gf5.4.1.r = inner_join(gf5.r, maf_gf, by = c("SNP"))

#p1 = ggplot() + geom_point(data=gf5.4, aes(x = knownEM, y = percent_correct, color=nInd), alpha=0.2) + geom_point(data=gf5.4.r, aes(x= knownEM, y= percent_correct), color = "orange", alpha=0.05) + labs(x = "MAF from library 1") + scale_colour_continuous() + annotate("text", x=0.1, y=0.01,label="Yellow is randomized") + labs(title= threshold)

real_dat_sum = gf5.4.1 %>% 
  filter(!is.na(score)) %>% 
  summarise(test= "real data", true_count=sum(score), total_count=n(), percent = true_count/total_count)

rand_dat_sum = gf5.4.1.r %>% 
  filter(!is.na(score)) %>% 
   summarise(test= "random data", true_count=sum(score), total_count=n(), percent = true_count/total_count) #%>% 
#   slice(1) %>% 
#   unlist(., use.names=F)
# 
# rand_label = paste(" ",rand_dat_sum, collapse = "")

real_label = paste(" # comparisons:", real_dat_sum[1,3], "\n % matched:", round(real_dat_sum[1,4],digits = 3)*100)

rand_label = paste(" # comparisons:", rand_dat_sum[1,3], "\n % matched:", round(rand_dat_sum[1,4],digits = 3)*100)

p2 = gf5.4 %>% 
  #filter(nInd >= 49) %>% 
  ggplot(., aes(x=percent_correct)) + geom_bar(stat="count", binwidth = 0.01) + labs(title=paste(threshold, "True Data")) + annotate("text", x=-Inf, y=Inf, label = real_label, hjust=0,vjust=1)

p3 = gf5.4.r %>% 
  #filter(nInd >= 49) %>% 
  ggplot(., aes(x=percent_correct)) + geom_bar(stat="count", binwidth = 0.01) + labs(title=paste(threshold,"Randomized")) + annotate("text", x=-Inf, y=Inf, label = rand_label, hjust=0,vjust=1)

#sum_of_sums = bind_rows(real_dat_sum,rand_dat_sum)

#p1.1 <- add_sub(p1, write.table(sum_of_sums[1:2,], col.names = F, row.names = F, quote = F))

bottom = plot_grid(p2,p3)
#plot_grid(p1, bottom, nrow = 2)
bottom
}
