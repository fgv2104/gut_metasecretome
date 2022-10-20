#!/bin/bash

#Running Prodigal ORF prediction for contigs using parallel
#Instead of remaking oneline fastas we are using same ones from 20190504_HGM_prodigal
#Using single mode in Prodigal

#Define path to input contigs
contigs="/home/ec2-user/20190504_HGM_prodigal/oneline_fastas/*.fna" #Check extension
#Define output folder for prodigal
out_path="/home/ec2-user/20220906_HGM_prodigal"

###############################################################

dataset="HGM"
outiso=${out_path}/prodigal_output_${dataset}
mkdir ${outiso}

#Specify location of contigs for each dataset
contigs="/home/ec2-user/20190504_HGM_prodigal/oneline_fastas/*.fna"

#Loop through contigs
for fna in ${contigs}
do
	filename=${fna##/*/}
	rootname=$(echo $filename | awk -F '.' '{print $1}')
	#Run prodigal in normal mode (train on each set of contigs separately) and produce a protein fasta and gff for each set of contigs
	built_command="prodigal -g 11 -i $fna -f 'gff' -o ${outiso}/${rootname}.gff -a ${outiso}/${rootname}.faa -d ${outiso}/${rootname}.fna -p 'single' -s ${outiso}/${rootname}_scores.tsv -q"
	echo ${built_command} >> commands.txt
done
cat commands.txt | parallel -j 64
