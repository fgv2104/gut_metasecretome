#!/bin/bash
##This script takes input peptides in fasta oneline format, no spaces or special characters in fasta headers,
# and outputs tsv file with peptides found to contain secretion signal peptide and the location of cleavage site.
##Requires signalp to be installed and signalp and signalp/bin folders to be in the path. Also make sure bin contents are executable. We 
##are taking all peptides found in the HMP genomes by Prokka and running them through the SignalP program.
#Repeat signalp analysis for each peptide fasta file in fa_path and output to output_signalp folder
#We are running this on cfncluster. Must check stderr and stdout files produced and run error-handling script accordingly.

dataset="HGM"
fa_path="/home/ec2-user/20220907_HGM_usearch/HGM_largeclustercentroids.oneline.fasta"
out_path="/home/ec2-user/20220927_HGM_signalP/${dataset}_signalp_out" ##CHANGE ME
fa_split_path="${out_path}/fa_split"
mkdir ${out_path}
mkdir ${fa_split_path}

#Split HGM centroids (large cluster representatives) into multiple files that can be run on signalp independently
prefix_split="${fa_split_path}/${dataset}_largeclustercentroids_"
cat ${fa_path} | paste - - | split -d -l 10000 - "${prefix_split}"
for splitfa in ${prefix_split}* #${fa_split_path}/largeclustercentroids_*
do
	cat $splitfa | tr '\t' '\n' > ${splitfa}.faa
done

for peptides in ${fa_split_path}/*.faa
do
	#get name of input oneline small peptides fasta
	fasta="${peptides##*/}"
	#get name of genome (genbank id, generally) that was annotated with these peptides by prokka
	rootname="${fasta%%.*}"
	#create variable that is the path to the signalp output file and includes the genome name from the input fasta 
	#file
	sigoutroot="${out_path}/${rootname}"
	#print to log
	#echo "Starting $rootname $(date)" >> ${out_path}/signalp.log
	#perform signalp using gram positive signal peptide library
	echo "#!/bin/bash" >> ${sigoutroot}_gramneg.sh
	echo "~/bin/signalp-5.0/bin/signalp -format 'short' -plot 'none' -mature -org gram- -prefix ${sigoutroot}_gramneg -fasta ${peptides}" >> ${sigoutroot}_gramneg.sh
	echo "#!/bin/bash" >> ${sigoutroot}_grampos.sh
        echo "~/bin/signalp-5.0/bin/signalp -format 'short' -plot 'none' -mature -org gram+ -prefix ${sigoutroot}_grampos -fasta ${peptides}" >> ${sigoutroot}_grampos.sh
        #perform signalp using gram negative signal peptide library
	#print to log
	#echo "Ending $rootname $(date)" >> ${out_path}/signalp.log
done

for script in ${out_path}/*.sh
do
	qsub $script
	sleep 5s
done

