# ORF prediction on HGM MAGs on m5.24xlarge AWS machine with 700 GB of storage.
### Install and configure space
```
$ sudo yum install gcc
$ mkdir bin; cd bin
$ wget http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2
$ tar -xjvf parallel-latest.tar.bz2
$ cd parallel-20220822
$ ./configure
$ sudo make
$ sudo make check
$ sudo make install
$ cd src
$ screen
$ export PATH=$PATH:$(pwd)
$ cd ~/bin
$ wget https://github.com/hyattpd/Prodigal/archive/refs/tags/v2.6.3.tar.gz
$ tar -xzf v2.6.3.tar.gz 
$ cd Prodigal-2.6.3/
# Modify prodigal source code such that we can find smaller genes
$ nano node.h
# Change parameters to:
#define MIN_GENE 15
#define MIN_EDGE_GENE 15
#define MAX_SAM_OVLP 15
#define ST_WINDOW 15
#define OPER_DIST 15
$ sudo make install
# Save modified prodigal source code in s3
$ cd ~/bin
$ aws configure
$ aws s3 sync Prodigal-2.6.3/ s3://florencia-velez/working/mod_bin_20220906/Prodigal-2.6.3/
```
### Download filtered Parks and HGM MAGs
```
$ cd
$ aws s3 cp s3://florencia-velez/working/20190504_HGM_prodigal/oneline_fastas.tar.gz 20190504_HGM_prodigal/oneline_fastas.tar.gz
$ cd 20190504_HGM_prodigal; tar -xzf oneline_fastas.tar.gz &
```

### Download and run script that runs Prodigal on single (not meta) mode using parallel (took ~2 hours for 25k MAGs)
```
$ mkdir 20220906_HGM_prodigal; cd 20220906_HGM_prodigal
$ nano run_prodigal_single_contigs_parallel.sh
$ chmod +x run_prodigal_single_contigs_parallel.sh 
$ ./run_prodigal_single_contigs_parallel.sh &> run_prodigal_single_contigs_parallel.log &
```
### Concatenate output protein fasta ORFs
```
$ cat faa_output/* > HGM_all_genes.faa
```
### Download usearch
```
$ cd ~/bin
$ gunzip usearch10.0.240_i86linux64.gz 
$ mv usearch10.0.240_i86linux64 usearch
$ chmod +x usearch
$ export PATH=$PATH:$(pwd)
```
### Cluster ORFs at 95% amino acid identity (expect it will take ~3 hours on 1 cpu)
```
$ mkdir 20220907_HGM_usearch; cd 20220907_HGM_usearch
$ mkdir all_HGM_clusters
$ ~/bin/usearch -cluster_fast ~/20220906_HGM_prodigal/prodigal_output_HGM/HGM_all_genes.faa \
 -id 0.95 -sort size -uc all_HGM.uc \
 -minsl 0.95 -target_cov 0.95 \
 -clusters all_HGM_clusters/all_HGM_clusters \
 -consout all_HGM.consensus.fasta \
 -centroids all_HGM.centroids.fasta &> all_HGM_out.log &
#Minimum value of shorter_seq_length / longer_seq_length = 0.95
#Fraction of the target sequence that is aligned, in the range 0.0 to 1.0 = 0.95
```
