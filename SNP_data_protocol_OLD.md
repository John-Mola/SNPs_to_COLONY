# SNP Data -- February 28, 2017

### Below is specifically for the methods plate with Bombus vosnesenskii using the Bombus impatiens reference genome


### Split and match fastq files
Working directory is set to ~/Mola.  
The .fastq files are located in /Mola/methods_plate

`sbatch -p  high -t 1:00:00 ../scripts/run_BestRadSplit.sh methods_plate/SOMM127_R1_GTCCGC.fastq methods_plate/SOMM127_R3_GTCCGC.fastq SOMM127_GTCCGC`

Basically, this says run the job on SLURM for a one hour timelimit, then calls the name of the script, then the inputs (2 read files, plus a name)

### Reference genome
Download it

`srun -t 1:00:00 wget "ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/188/095/GCF_000188095.1_BIMP_2.0/GCF_000188095.1_BIMP_2.0_genomic.fna.gz"`

Unzip it
`srun -t 1:00:00 gunzip GCF_000188095.1_BIMP_2.0_genomic.fna.gz`

Prepare for alignment
` srun -t 1:00:00 bwa index GCF_000188095.1_BIMP_2.0_genomic.fna`

Prepare the .fastq files into one two column list
`ls methods_plate/*RA* > listA`
`ls methods_plate/*RB* > listB`
`paste listA listB > listMethods`
`rm listA`
`rm listB`

Remove .fastq from all of the file names in the list
`sed -i 's/\.fastq//g' listMethods `

Ready to align!
`sbatch -t 2:00:00 ../scripts/run_align.sh listMethods B_imp_ref_genome/GCF_000188095.1_BIMP_2.0_genomic.fna`

ls *RA* | sed "s/\.fastq\.gz//g" > listA
ls *RB* | sed "s/\.fastq\.gz//g" > listB


sbatch -t 24:00:00 ../run_align.sh list_CAGATC ../../Mola/B_imp_ref_genome/GCF_000188095.1_BIMP_2.0_genomic.fna

johnmola@farm.cse.ucdavis.edu:~/Mola/






# THE NEW SHIT STARTS BELOWWWWWW

## Tidying stuff

- Make directory for new plate (call it plate#_barcode)
- Move .fastq R1 and R3 to the new directory


## Splitting R1 and R2

- sbatch -p high -t 24:00:00 ../run_BestRadSplit_PstI.sh SOMM185_R1_ACTTGA.fastq  SOMM185_R3_ACTTGA.fastq SOMM185_ACTTGA

## Compress files (do in a new screen)
- srun -t 24:00:00 gzip *TGCAG.fastq


## Make lists and align
- ls *RA* | sed "s/\.fastq\.gz//g" > listA
- ls *RB* | sed "s/\.fastq\.gz//g" > listB
- paste listA listB > list_ACTTGA
- sbatch -t 24:00:00 ../run_align.sh list_ACTTGA ../../Mola/B_imp_ref_genome/GCF_000188095.1_BIMP_2.0_genomic.fna

## Tidying end
- mkdir aligned_files
- mkdir filtered_bams
- mkdir slurm_outputs
- mkdir zipped_fastq

- Move files into respective folders
- Check length of bams with ls filtered_bams/ | wc

In the end, only 4 directories, the list, and the two original .fastq files should remain.

## Monitoring commands and other
smap -c | grep johnmola | wc


## match and rename (works on lists...not sure how to do this with files in a directory...might be an easy way by just calling sed to copy or something)
sed 's| *\([^ ]*\) *\([^ ]*\).*|s/\1/\2/g|' < FILE_WITH_MATCH_SPACE_RENAME | sed -f- FILE_TO_FILTER > outfile

#Make a list of what bam files we want, then grep them using below
grep -wf SUBSET_WANTED LIST_TO_FILTER > new_list_name

#Kill those dumb text wraps when importing
tr '\r' '\n' < oldfile.csv > newfile.csv

#Replace commas with empty space
sed 's/,/ /g' filename >resultfile

#Making the clst file
sed 's/\.sort\.flt_10000\.bam/ 1 1/g' sub_10_bam > sub_10_out.clst
