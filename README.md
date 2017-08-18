# sibship_analysis
Helpful scripts for the SNP to sibship pipeline!

NOTE: I am by no means a coding master and am a git novice. I'm working on updating these files to be useable by other humans. Please contact me with any questions you may have or suggestions for making them clearer. I will be updating this repository with a workflow, guide, and annotated scripts over the next several months. 

Cheers,

John

## Explanation of files

##### Geno2Colony.pl
- Perl script used for choosing loci for analysis with software COLONY. Set your minimum minor allele frequency, desired number of loci, percent missing genotypes, linkage equilibrium filter, etc.



##### Geno_quality_test.R
 - Takes output of an angsd geno file and compares it to the number of aligned reads. Run this to understand what level of sequencing you'll need for success.

##### perl_list_for_COLONY.R
- Generates the proper header for the Geno2Colony script

##### post_COLONY_to_QGIS.R
- Takes COLONY output and formats it to be useable for QGIS

##### quickformatteR_new.R
- Takes output of Geno2Colony and prepares it for program COLONY by creating the necessary .DAT file

##### rapture_make_bamclst_lists_post_JM.R
- Make proper post-filtering bamlists or other inputs needed for various scripts.
