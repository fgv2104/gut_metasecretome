# Characterization and biogeography of the healthy human gut metasecretome
mSystems publication [link here]

We annotated MAGs from the Nayfach et al 2019 study (https://doi.org/10.1038/s41586-019-1058-x) using 
SignalP, TMHMM, and eggNOG to obtain a 
dataset of putative gut secreted proteins. Using Elinav et al 2018 study 
(https://doi.org/10.1016/j.cell.2018.08.041) we mapped metagenomic reads from 
biopsies taken along the gastrointestinal tract to our secreted gut proteins reference and inferred the gastrointestinal sublocalization of secreted protein functions.


20190504_HGM_prodigal: Metadata from Nayfach MAGs.

HGM_secreted_orfs.faa.gz: Compressed fasta of human gut bacterial predicted secreted proteins.

20221005_metasecretome_notebooks: Jupyter notebooks for generation of Figures 1, 2, and 3, and Supplementary 
Figures S1, S2. R script for generation of PCoA for Figure 3.

20210602_metasecretome_figures: Jupyter notebooks for generating Figures 4 and 5 as well as Supplementary 
Figure S4, S5, and S6.

20220927_HGM_signalP: Bash script and markdown for SignalP annotation (includes TMHMM markdown).

20221003_HGM_Parks_tmhmm: Bash script for TMHMM annotation.

20220907_HGM_usearch: Fasta and large cluster centroids (representative sequences) of all clusters in HGM 
with at least 5 sequences; Compressed cluster information (.uc output file) for all clusters of HGM 
predicted by USEARCH.

20220906_HGM_prodigal: Markdown (includes USEARCH clustering commands) and bash script for ORF annotation 
using Prodigal.

20221005_hmmer_dbcan_HGM_representatives: Bash script and markdown for annotation of HMMER against dbCAN 
CAZyme database.
