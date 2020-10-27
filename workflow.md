### 1. Setting Conda Environment    
I created and used a simple conda environment. Check out docs below for more info:   

- **Conda**: https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html
- **Salmon**: https://salmon.readthedocs.io/en/latest/
- **R**: https://cran.r-project.org/
- **AnnotationHub**: https://bioconductor.org/packages/devel/bioc/vignettes/AnnotationHub/inst/doc/AnnotationHub.html 
- **DESeq2**: http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html 

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

Salmon mapping was performed under the conda environment **salmon** activated with following commend. 


```bash

conda activate salmon 

```



