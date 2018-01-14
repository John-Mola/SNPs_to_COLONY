# SNPs to COLONY...and beyond!

I'll be putting a full annotation and workflow up eventually. For now, here's a general idea of the process. Please contact me if you'd like more information or want help in using RADseq data with the program COLONY. 

![](https://github.com/John-Mola/SNPs_to_COLONY/blob/master/WorkFlow.png?raw=true)

## Brief description of scripts

#### Sequence data to sibships

* `01a_runalign` aligns to reference genome using `bwa`

* `01b_filter_count` provides list of bams with a minimum number of aligned reads

* `01c_genoget` calls genotypes using `angsd`

* `o1d_geno2colony` selects SNPs using user-defined criteria

* `01e_DAT_maker` creates necessary input for program `COLONY`

* `o1f_colony_runner` runs `COLONY` on cluster

#### COLONY organizeR -- Getting COLONY data ready for analyses

* `02a_colonizeR` merges metadata (user provided) with output of `COLONY`, creates necessary variables for family matching

* `02b_sibshipPlots` DOESN'T EXIST YET create basic plots of `COLONY` output data (e.g. family sizes)

* `02c_colony_mapper` DOESN'T EXIST YET creates maps of `colonizeR` output (e.g. family locations, floral abundance, seasonality, etc)

* `02d_summarise_colony` DOESN'T EXIST YET basic summary statistics from `colonizeR` output

#### Downstream data analyses -- The good stuff!!

* `03a_sib_finder` DOESN'T EXIST YET calculates separation distances between siblings (worker-worker or queen-worker, whatever)

* `03b_colony_counter` DOESN'T EXIST YET estimates colony abundance/density from a given set of parameters (site, year, region, burn status, etc)

* `03c_nest_finder` DOESN'T EXIST YET estimates nest locations for sibling groups 

* `03d_colony_survivor` DOESN'T EXIST YET calculates basic demographic measures like survivorship, reproduction, and growth using redetections of families

#### Additional scripts 

* `xx_alignment_counts` Creates a histogram of number of aligned reads for samples. Good for exploring genetic data before further use

* `xx_genotype_compare` Calculates level of agreement between different libraries with the same individuals. Very good for ensuring depth of sequencing reliably yields correct genotypes. Degree of matching can be used to inform error rate in `COLONY`. 

* `xx_list_maker` Makes bamlists, headers for `COLONY` input and more by matching/filtering with metadata. Originally made by Ryan Peek. 