### 1. Setting a conda environment    
I wrote and used a simple conda environment introduced below. Check out related docs for more info:   

- **Conda**: https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html
- **Salmon**: https://salmon.readthedocs.io/en/latest/
- **R**: https://cran.r-project.org/
- **AnnotationHub**: https://bioconductor.org/packages/devel/bioc/vignettes/AnnotationHub/inst/doc/AnnotationHub.html 
- **DESeq2**: http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html 
- **tximport**: https://bioconductor.org/packages/devel/bioc/vignettes/tximport/inst/doc/tximport.html

```environment.yml
name: salmon
channels:
  - conda-forge
  - bioconda 
  - defaults 
dependencies:
  - salmon 
  - r-base =4.0.2
  - bedtools 
  - gawk 
  - r-tidyverse
  - r-data.table
  - r-ggplot2
  - r-markdown
  - r-pheatmap
  - bioconductor-deseq2
  - bioconductor-annotationhub
  - bioconductor-tximport
```

The conda environment file (**environment.yml**) was placed in the working directory (**Salmon-test**) and the conda environment was created with a commend below. 


```bash

conda env create -f environment.yml

```

Salmon mapping was performed under the conda environment **salmon** activated with following commend. 


```bash

conda activate salmon 

```

### 2. Writing a bash file running salmon 



Flags:   
- **salmon quant** run salmon
- **-i** path to indexing files 
- **-l A** library type A 
- **-r** for single-end reads 
- **-p** number of threads (8-12)
- **--validateMapping** selective alignment to the transcriptome 
- **-o** path to output files 
- **--seqBias** enable it to learn and correct for sequence-specific biases in the input data
- **--gcBias** enable it to learn and correct for fragment-level GC biases in the input data

Note:
- 6 Raw .fastq.gz files are in ./rawdata 
- Indexing files were obtained from refgenie (http://refgenomes.databio.org/, hg19 asset name:tag=salmon_sa_index:default). Consult the salmon docs if you would like to build your own indexing files. 
- Check out the Salmon docs for other flags when changing options (e.g. paired-reads, etc)



```singlequant.bash

#!/bin/bash

cd rawdata

for read in $(ls) 
do
    salmon quant -i ../salmon_sa_index_hg19 -l A --gcBias --seqBias -r $read -p 8 --validateMappings -o ../${read}.salmon_quant
done

cd ..


```

### 3. Running Salmon by executing the bash commend

Output quant.sf files are saved in ./<sample_name>.salmon_quant


```terminal

bash singlequant.sh

```


