### 1. Conda Environment    
I created and used a simple conda environment. 

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
  - bioconductor-deseq2
  - bioconductor-annotationhub
  - bioconductor-tximport
```

The conda environment file (**environment.yml**) was placed in the working directory (**Salmon-test**) and the conda environment was created with a commend below. 


```bash

conda env create -f environment.yml

```

Salmon mapping was performed under the conda environment named **salmon** activated with following commend. 


```bash

conda activate salmon 

```



