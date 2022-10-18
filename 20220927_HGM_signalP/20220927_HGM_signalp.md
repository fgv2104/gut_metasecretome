# Simplify HGM data 
## We will do this by filtering out redundant protein ORFs (>= 95% amino acid identity) and proteins that are not well represented in the dataset (<5 member sequences in protein cluster)
## Filter for representative sequences of large clusters (>=5 member sequences)
```
$ aws s3 sync s3://florencia-velez/working/20220907_HGM_usearch 20220907_HGM_usearch
$ cd 20220907_HGM_usearch
#Get only cluster info lines from uc file
$ awk -F '\t' '{if($1=="C") print $0}' all_HGM.uc > all_HGM_clusterinfo.uc
#Put centroids fasta in oneline format
$ awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' \
 all_HGM.centroids.fasta | awk '{print $1}' > \
 all_HGM.centroids.oneline.fasta &
#Get centroids of clusters that have at least 5 member sequences
$ awk -F '\t' '{if($3>=5) print $9}' all_HGM_clusterinfo.uc | awk '{print $1}' \
 | fgrep -A 1 -w -f - all_HGM.centroids.oneline.fasta | sed '/--/d' > HGM_largeclustercentroids.oneline.fasta &
$ fgrep -c ">" HGM_largeclustercentroids.oneline.fasta
1399997
#There are 1.4M clusters of at least 5 sequences in the HGM ORFs dataset 
$ cd
$ aws s3 sync 20220907_HGM_usearch s3://florencia-velez/working/20220907_HGM_usearch
```

# Start cluster using AWS parallel-cluster and install signalP
```
$ cd ~/.parallelcluster/
$ pcluster configure --config fgvCluster_new.yaml
$ pcluster create-cluster --cluster-configuration fgvCluster_new.yaml --cluster-name fgvCluster --region us-east-1

$ mkdir bin; cd bin
$ aws s3 cp s3://florencia-velez/working/signalp-5.0.Linux.tar.gz .
$ tar -xzf signalp-5.0.Linux.tar.gz
$ cd signalp-5.0/bin/
$ export PATH=$PATH:$(pwd)
```
# Run script that chops up large fasta of HGM ORFs into smaller fasta files and runs gram positive and gram negative prediction on each fasta
```
$ cd
$ mkdir
$ mkdir 20220927_HGM_signalP; cd 20220927_HGM_signalP
$ aws s3 cp s3://florencia-velez/working/20200202_HGM_Parks_signalp/20200202_signalp_v2.sh .

$ nano 20221002_signalp_v2.sh
$ chmod +x 20221002_signalp_v2.sh 
$ ./20221002_signalp_v2.sh &> 20221002_signalp_v2.log &
# Ran for about 1.5 hours on AWS parallel-cluster
# Organizing some of the files
$ mv *.sh.* run_logs/
$ cd HGM_signalp_out
$ mkdir scripts
$ mv *.sh scripts/
# Back up to s3
$ cd
$ aws s3 sync 20220927_HGM_signalP s3://florencia-velez/working/20220927_HGM_signalP
```
# Create fasta files for each dataset containing mature proteins with signal peptides that are predicted for each protein with either gram positive or gram negative
```
$ cd 20220927_HGM_signalP
$ mkdir signalp_analysis
```
## Concatenate all signalp mature proteins
```
$ cat HGM_signalp_out/*gramneg_mature.fasta | awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' | awk '{if(NR%2==1) print $0"_neg"; else print $1}' > signalp_analysis/HGM_all-gramneg_mature.fasta
$ cat HGM_signalp_out/*grampos_mature.fasta | awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' | awk '{if(NR%2==1) print $0"_pos"; else print $1}' | cat - signalp_analysis/HGM_all-gramneg_mature.fasta > signalp_analysis/HGM_all_mature.fasta
```
# Filter out low confidence (<=0.9) secretion predictions
```
$ cat HGM_signalp_out/*grampos_summary.signalp5 > signalp_analysis/HGM_all-grampos_summary.tsv
$ cat HGM_signalp_out/*gramneg_summary.signalp5 > signalp_analysis/HGM_all-gramneg_summary.tsv
$ awk -F '\t' '{if($3>0.9 || $4>0.9 || $5>0.9) print $1}' signalp_analysis/HGM_all-grampos_summary.tsv | sed 's/$/_pos/g' | fgrep -A 1 -f - signalp_analysis/HGM_all_mature.fasta > signalp_analysis/HGM_all_grampos_mature.fasta
$ awk -F '\t' '{if($3>0.9 || $4>0.9 || $5>0.9) print $1}' signalp_analysis/HGM_all-gramneg_summary.tsv | sed 's/$/_neg/g' | fgrep -A 1 -f - signalp_analysis/HGM_all_mature.fasta > signalp_analysis/HGM_all_gramneg_mature.fasta
```
# Concatenate into a single file with high confidence mature secreted protein predictions
```
$ cat signalp_analysis/HGM_all_gramneg_mature.fasta signalp_analysis/HGM_all_grampos_mature.fasta | sed '/--/d' > signalp_analysis/high_confidence_mature_HGM.fasta
```
# Back up to s3
```
$ cd
$ aws s3 sync 20220927_HGM_signalP s3://florencia-velez/working/20220927_HGM_signalP
```
# Install TMHMM
```
$ aws s3 cp s3://florencia-velez/working/tmhmm-2.0c.Linux.tar.gz bin/tmhmm-2.0c.Linux.tar.gz
$ cd bin
$ tar -xzf tmhmm-2.0c.Linux.tar.gz 
$ cd tmhmm-2.0c
#Follow readme instructions (change perl path in scripts, use which perl to find path)
$ which perl
/usr/bin/perl
$ nano bin/tmhmm
$ nano bin/tmhmmformat.pl
$ cd bin
$ export PATH=$PATH:$(pwd)
```
# Make output folder and run script
```
$ mkdir 20221003_HGM_Parks_tmhmm; cd 20221003_HGM_Parks_tmhmm
$ nano 20221003_tmhmm.sh
$ chmod +x 20221003_tmhmm.sh 
$ ./20221003_tmhmm.sh &> 20221003_tmhmm.log &
```