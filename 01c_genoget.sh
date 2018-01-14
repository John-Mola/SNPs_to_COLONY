#!/bin/sh

list=$1
output=$2

#nInd=$(wc $list | awk '{print $1}')

#minInd=$[$nInd*5/10]

~/bin/angsd_update/angsd/angsd -bam $list -GL 1 -out $output -doMaf 1 -minInd 120 -doMajorMinor 1 -SNP_pval 1e-12 -minMapQ 20 -minQ 20 -doGeno 4 -doPost 2 -postCutoff 0.95 -minMaf 0.05

