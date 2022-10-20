#!/bin/bash

#Running dbCAN CAZyme search for each representative MAG of HGM using parallel

#Define output folder for prodigal
out_path="/home/ec2-user/20221005_hmmer_dbcan_HGM_representatives/hmmer_dbcan_output"
#Specify location of contigs for each dataset
input_mags="/home/ec2-user/20221005_hmmer_dbcan_HGM_representatives/input_mags"
#Path to dbCAN database of CAZymes
dbcan_path="/home/ec2-user/bin/dbCAN/dbCAN-HMMdb-V11.txt"

#Loop through contigs
for faa in ${input_mags}/*.faa
do
	filename=${faa##*/}
	rootname=${filename%%.*}
	built_command="hmmscan --domtblout ${out_path}/${rootname}.out.dm ${dbcan_path} ${faa} > ${out_path}/${rootname}.out"
	echo ${built_command} >> commands.txt
done
cat commands.txt | parallel -j 24
