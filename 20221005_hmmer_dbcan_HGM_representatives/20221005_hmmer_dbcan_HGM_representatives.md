### HMMER ORFs against carbohydrate-active enzyme database
#### Started instance using Amazon Linux 2 AMI with c5.9xlarge and 400 GB
Install HMMER
```
$ aws configure
$ sudo yum install gcc -y
$ mkdir bin; cd bin
$ wget http://eddylab.org/software/hmmer/hmmer-3.3.2.tar.gz
$ tar -xzf hmmer-3.3.2.tar.gz 
$ cd hmmer-3.3.2/
$ sudo make install
$ ./configure
$ make
$ make check
$ cd src
$ adpa="$(pwd)"
$ export PATH=$PATH:$adpa
$ cd
$ cd bin
$ wget http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2
$ tar -xjvf parallel-latest.tar.bz2
$ cd parallel-20220922/
$ ./configure
$ sudo make
$ sudo make check
$ sudo make install
$ cd src
$ screen
$ export PATH=$PATH:$(pwd)
```
Download and press dbCAN files
```
$ cd bin
$ mkdir dbCAN; cd dbCAN
$ wget https://bcb.unl.edu/dbCAN2/download/Databases/V11/dbCAN-HMMdb-V11.txt
$ wget https://bcb.unl.edu/dbCAN2/download/Databases/V11/hmmscan-parser.sh
$ chmod + hmmscan-parser.sh
$ hmmpress dbCAN-fam-HMMs.txt
```
Download representative MAGs and format them
```
$ cd
$ aws s3 cp s3://florencia-velez/working/20210519_signalp_analysis/ipynb_out/representative_hgm_mags.csv ~/20210519_signalp_analysis/ipynb_out/representative_hgm_mags.csv
$ aws s3 cp s3://florencia-velez/working/20220906_HGM_prodigal/prodigal_output_HGM/faa_output.tar.gz 20220906_HGM_prodigal/prodigal_output_HGM/faa_output.tar.gz
$ cd 20220906_HGM_prodigal/prodigal_output_HGM
$ tar -xzf faa_output.tar.gz &
$ cd
$ mkdir 20221005_hmmer_dbcan_HGM_representatives; cd 20221005_hmmer_dbcan_HGM_representatives
$ awk -F "," '{if(NR>1) print $2}' ../20210519_signalp_analysis/ipynb_out/representative_hgm_mags.csv | sort | uniq > representative_mags.csv
$ mkdir input_mags
# Make oneline fastas out of the representative MAG predicted ORF aminoacid fastas
$ faa_path="/home/ec2-user/20220906_HGM_prodigal/prodigal_output_HGM/faa_output"; \
while read mag; do awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' ${faa_path}/${mag}.faa > input_mags/${mag}.faa; done < representative_mags.csv 
```
Run hmmer with parallel GNU, took about 40 min on 36 cpu machine
```
$ mkdir hmmer_dbcan_output
$ ./run_hmmer_dbcan_parallel.sh &> run_hmmer_dbcan_parallel.log &
```
Parse output from hmmer
```
$ mkdir parsed_hmmer_dbcan_output
$ for outfile in hmmer_dbcan_output/*.out.dm; \
do yourfile=${outfile##*/}; \
sh ~/bin/dbCAN/hmmscan-parser.sh hmmer_dbcan_output/${yourfile} > parsed_hmmer_dbcan_output/${yourfile}.ps; \
done
#Upload to s3
$ aws s3 sync 20221005_hmmer_dbcan_HGM_representatives s3://florencia-velez/working/20221005_hmmer_dbcan_HGM_representatives
```