# Characterization and biogeography of the healthy human gut metasecretome
We annotated MAGs from the Nayfach et al 2019 study (https://doi.org/10.1038/s41586-019-1058-x) using 
SignalP, TMHMM, and eggNOG to obtain a 
dataset of putative gut secreted proteins. Using Elinav et al 2018 study 
(https://doi.org/10.1016/j.cell.2018.08.041) we mapped metagenomic reads from 
biopsies taken along the gastrointestinal tract to our secreted gut proteins reference and inferred the gastrointestinal sublocalization of secreted protein functions.

The compressed fasta of human gut bacterial predicted secreted proteins available for download: HGM_secreted_orfs.faa.gz
ORFs are named according to their MAG provenance. Metadata on these MAGs is available in the **20190504_HGM_prodigal folder**.

## The pipeline for generating these predicted secreted proteins involves the following steps:
-**Step 1**: Annotation of ORFs from Nayfach MAGs (20220906_HGM_prodigal)
-**Step 2**: Clustering of ORFs (20220907_HGM_usearch)
-**Step 3**: Annotation of large cluster centroids of all clusters in HGM
 -Annotation of signal peptides (20220927_HGM_signalP)
 -Annotation of transmembrane domains (20221003_HGM_Parks_tmhmm)
-**Step 4**: Functional annotation
 -Annotation of COG categories and eggNOG proteins
 -Annotation of carbohydrate-active enzymes (20221005_hmmer_dbcan_HGM_representatives)

## Figure generation scripts
Jupyter notebooks for generation of Figures 1, 2, and 3, and Supplementary 
Figures S1, S2, along with the R script for generation of PCoA for Figure 3 of our paper are found in **20221005_metasecretome_notebooks**. Jupyter notebooks for generating Figures 4 and 5 as well as Supplementary 
Figure S4, S5, and S6 are found in **20210602_metasecretome_figures**.

## Further description of file contents:
-20220927_HGM_signalP: Bash script and markdown for SignalP annotation (includes TMHMM markdown).
-20221003_HGM_Parks_tmhmm: Bash script for TMHMM annotation.
-20220907_HGM_usearch: Fasta and large cluster centroids (representative sequences) of all clusters in HGM 
with at least 5 sequences; Compressed cluster information (.uc output file) for all clusters of HGM 
predicted by USEARCH.
-20220906_HGM_prodigal: Markdown (includes USEARCH clustering commands) and bash script for ORF annotation 
using Prodigal.
-20221005_hmmer_dbcan_HGM_representatives: Bash script and markdown for annotation of HMMER against dbCAN 
CAZyme database.
