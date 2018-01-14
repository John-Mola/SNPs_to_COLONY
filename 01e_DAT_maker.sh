#!/bin/sh

geno=$1
header=$2
output=$3

perl ~/scripts/Geno2Colony.pl.fixed $geno $header > $output
