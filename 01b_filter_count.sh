#!/bin/bash -l


list=$1
num=$2
name=$3

#for f in `cat $list`
#do samtools view -c ${f}
#done

for f in `cat $list`
do
count=$(samtools view -c ${f})
if [ $num -le $count ]
then
 echo $f >> $name
 fi
done



