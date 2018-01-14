#!/bin/bash -l
##Name: PCA_new.sh

bamlist=$1
out=$2
nind=$3

~/bin/angsd_update/angsd/angsd -bam ${bamlist} -out ${out}.PCAMDS1 -doIBS 1 -doCounts 1 -doMajorMinor 1 -minFreq 0.05 -maxMis ${nind} -minMapQ 30 -minQ 20 -SNP_pval 0.000001 -makeMatrix 1 -doCov 1 -GL 1 -doMaf 2 -doPost 2 -nThreads 16
