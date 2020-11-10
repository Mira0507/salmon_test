## This repo is intended to store an example workflow for salmon-mediated mapping and downstream analysis 


### File Description 

**1. source.txt**     
Link to raw data source [GSE 157852](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE157852)

**2. singlequant.sh**    
A bash file executing salmon transcription mapping (with decoy) returning .sf files 

**3. singlequant_gene.Rmd**    
R code for extracting count data (gene level) from .sf files and performing downstream DE analysis

**4. singlequant_gene.html**
An html file rendered from singlequant_gene.Rmd 

**5. singlequant_transcript.Rmd**    
R code for extracting count data (transcript level) from .sf files and performing downstream DE analysis

**6. singlequant_transcript.html**
An html file rendered from singlequant_transcript.Rmd 

**7. workflow.md**   
Entire workflow from raw data to downstream analysis

