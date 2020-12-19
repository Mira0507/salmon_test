## Salmon mapping (with decoy) test run  


### File Description 

**1. source.txt**     
Link to raw data source [GSE 157852](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE157852)

**2. singlequant.sh**    
A bash file executing salmon transcription mapping (with decoy) returning .sf files 

**3. singlequant_tpm.Rmd**    
R code for extracting TPM from .sf files and performing downstream DE analysis

**4. singlequant_tpm.html**   
An html file rendered from singlequant_tpm.Rmd 

**5. singlequant_counts.Rmd**    
R code for extracting counts from .sf files and performing downstream DE analysis

**6. singlequant_counts.html**   
An html file rendered from singlequant_counts.Rmd 

**7. singlequant_txi.Rmd**   
R code for conducting DE analysis with txi input in DESeq2 pipeline 

**8. singlequant_txi.html**   
An html file rendered from singlequant_txi.Rmd

**9. singlelquant_txi_plots.Rmd**   
R code for saving plots in DE analysis with txi input in DESeq2 pipeline

**10. DEGranking_shrinkage.Rmd**    
R code for DEG ranking comparison with or without shrinkage by input

**11. DEGranking_shrinkage.html**   
An html file rendered from DEGranking_shrinkage.Rmd

**12. workflow.md**   
Entire workflow from raw data to downstream analysis

