##%######################################################%##
#                                                          #
####                    sibshipPlots                    ####
#                                                          #
##%######################################################%##

# Load in a csv output from colonizeR
sp_df = read.csv("~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/testcolonizeR.csv")

# Filtering to our population/area/site/whatever of interest
# e.g. site-specific estimates
vsw_01 = filter(sp_df, site == "JM01")
vsw_02 = filter(sp_df, site == "JM02")
vsw_03 = filter(sp_df, site == "JM03")
vsw_04 = filter(sp_df, site == "JM04")
vsw_05 = filter(sp_df, site == "JM05")
vsw_06 = filter(sp_df, site == "JM06")
vsw_07 = filter(sp_df, site == "JM07")


# Run the function
colony_counter = function(coloniesToCount, maxPop, bootNumber)
{
  require(tidyverse)
  require(capwire)
  
  coloniesToCount$FamilyID = as.factor(coloniesToCount$FamilyID)
  
  sp_full = coloniesToCount %>% 
    group_by(ClusterIndex) %>% 
    summarise(n=n())
  
  captable=buildClassTable(sp_full$n)
  
  res.tirm <- fitTirm(data=captable, max.pop=maxPop)
  res.bootstrap <- bootstrapCapwire(res.tirm, bootstraps = bootNumber)
  
  output <- data_frame(ml.colony.num =  res.tirm[[3]], CI.lower= res.bootstrap[[2]][[1]], CI.upper = res.bootstrap[[2]][[2]])
  
  return(output)

}


colony_counter(vsw_02, 1000, 5)




### Same thing but hopefully with a full list of sites that then puts it into a data frame

## This works but is not satisying for several reasons

lapply(listOfPops, function(x) {
  require(tidyverse)
  require(capwire)
  
  x$FamilyID = as.factor(x$FamilyID)
  
  sp_full = x %>% 
    group_by(ClusterIndex) %>% 
    summarise(n=n())
  
  captable=buildClassTable(sp_full$n)
  
  res.tirm <- fitTirm(data=captable, max.pop = 1000)
  #res.bootstrap <- bootstrapCapwire(res.tirm, bootstraps = bootNumber)
  
  output <- data_frame(ml.colony.num =  res.tirm[[3]])
  
  return(output)
  
})


## This works, too. Returns separate datframes though. 

list_colony_counter = function(coloniesToCount, maxPop, bootNumber)
{
  require(tidyverse)
  require(capwire)
  
  coloniesToCount$FamilyID = as.factor(coloniesToCount$FamilyID)
  
  sp_full = coloniesToCount %>% 
    group_by(ClusterIndex) %>% 
    summarise(n=n())
  
  captable=buildClassTable(sp_full$n)
  
  res.tirm <- fitTirm(data=captable, max.pop=maxPop)
  res.bootstrap <- bootstrapCapwire(res.tirm, bootstraps = bootNumber)
  
  output <- data_frame(ml.colony.num =  res.tirm[[3]], CI.lower= res.bootstrap[[2]][[1]], CI.upper = res.bootstrap[[2]][[2]])
  
  return(output)
  
}

lapply(listOfPops, list_colony_counter, maxPop=1000, bootNumber=2)





### Works pretty ok below. A bit disatisfying. 

#### Another attempt. I want the end result all in one dataframe with an extra column indicating which df it came from
# e.g.
# pop.origin  ml.colony.num  CI.lower  CI.upper
#  pop1           56          25          100
#  pop2           40          20          60
#  pop3           50          20          80



#list_colony_counter = function(coloniesToCount, maxPop, bootNumber)
{
  require(tidyverse)
  require(capwire)
  
  coloniesToCount$FamilyID = as.factor(coloniesToCount$FamilyID)
  
  sp_full = coloniesToCount %>% 
    group_by(ClusterIndex) %>% 
    summarise(n=n())
  
  captable=buildClassTable(sp_full$n)
  
  res.tirm <- fitTirm(data=captable, max.pop=maxPop)
  res.bootstrap <- bootstrapCapwire(res.tirm, bootstraps = bootNumber)
  
  output <- data_frame(ml.colony.num =  res.tirm[[3]], CI.lower= res.bootstrap[[2]][[1]], CI.upper = res.bootstrap[[2]][[2]])
  
  return(output)
  
}

#for (i in listOfPops) {
  
  i$FamilyID = as.factor(i$FamilyID)
  
  sp_full = i %>% 
    group_by(ClusterIndex) %>% 
    summarise(n=n())
  
  captable=buildClassTable(sp_full$n)
  
  res.tirm <- fitTirm(data=captable, max.pop=1000)
  res.bootstrap <- bootstrapCapwire(res.tirm, bootstraps = 1)
  
  noutput <- data_frame(ml.colony.num =  res.tirm[[3]], CI.lower= res.bootstrap[[2]][[1]], CI.upper = res.bootstrap[[2]][[2]])
  
}



# This is the only way I could get this stupid thing to work. 

# Load in a csv output from colonizeR
sp_df = read.csv("~/Google Drive/Davis/Projects/RAD Sequencing/testCOLONYoutputs/testcolonizeR.csv")

# Filtering to our population/area/site/whatever of interest
# e.g. site-specific estimates
vsw_01 = filter(sp_df, site == "JM01")
vsw_02 = filter(sp_df, site == "JM02")
vsw_03 = filter(sp_df, site == "JM03")

comment(vsw_01) <- "vsw_01"
comment(vsw_02) <- "vsw_02"
comment(vsw_03) <- "vsw_03"

# Function to make lists with actual names (and not just index)
namedList <- function(...) {
  L <- list(...)
  snm <- sapply(substitute(list(...)),deparse)[-1]
  if (is.null(nm <- names(L))) nm <- snm
  if (any(nonames <- nm=="")) nm[nonames] <- snm[nonames]
  setNames(L,nm)
}

listOfPops = namedList(vsw_01,vsw_02,vsw_03)


# Does everything I want except doesn't create a metadata column (I want the name of the inputted dataframe as an output  in one column)
list_colony_counter = function(listOfPops, maxPop, bootCount){
  
  require(tidyverse)
  require(foreach)
  require(capwire)
  
  foreach::foreach(i=listOfPops, .combine='rbind') %do% {
  
  sp_full = i %>% 
    group_by(ClusterIndex) %>% 
    summarise(n=n())
  
  captable=buildClassTable(sp_full$n)
  
  res.tirm <- fitTirm(data=captable, max.pop=1000)
  res.bootstrap <- bootstrapCapwire(res.tirm, bootstraps = 1)
  
  #df.name <- names(listOfPops[i])
  dFnm <- comment(i)
  
  data_frame(df.name = dFnm, ml.colony.num =  res.tirm[[3]], CI.lower= res.bootstrap[[2]][[1]], CI.upper = res.bootstrap[[2]][[2]])
  
}}

list_colony_counter(listOfPops,1000,1)
