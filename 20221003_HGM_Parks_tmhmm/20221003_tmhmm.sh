#!/bin/bash
##This script takes input peptides in fasta oneline format, no spaces or special characters in fasta headers,
# and outputs tsv file with peptides found to contain secretion signal peptide and the location of cleavage site.
##Requires hmmer to be installed and hmmer and hmmer/bin folders to be in the path. Also make sure bin contents are executable. We 
##are taking all peptides found in the HMP genomes by Prokka and running them through the hmmer program.
#Repeat hmmer analysis for each peptide fasta file in fa_path and output to output_hmmer folder
#We are running this on cfncluster. Must check stderr and stdout files produced and run error-handling script accordingly.

dataset="HGM"
fa_path="/home/ec2-user/20220907_HGM_usearch/HGM_largeclustercentroids.oneline.fasta"
out_path="/home/ec2-user/20221003_HGM_Parks_tmhmm/${dataset}_tmhmm_out" ##CHANGE ME
fa_split_path="${out_path}/fa_split"
mkdir ${out_path}
mkdir ${fa_split_path}

#Split HGM centroids (large cluster representatives) into multiple files that can be run on hmmer independently
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
	#create variable that is the path to the hmmer output file and includes the genome name from the input fasta 
	#file
	outroot="${out_path}/${rootname}"
	#Generate command for hmmer and print it to a job script
	hmmcommand="/home/ec2-user/bin/tmhmm-2.0c/bin/tmhmm ${peptides} > ${outroot}.out"
	echo "#!/bin/bash" >> ${outroot}.sh
	echo $hmmcommand >> ${outroot}.sh
done

for script in ${out_path}/*.sh
do
	qsub $script
	sleep 5s
done

