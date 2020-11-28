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


### 4. Extracting gene/transcript read counts from the quant.sf files with R tximport package

- count level: **singlequant_counts.Rmd** -> **csv/Read_count.csv**

```{r}


# Loading required packages 
library(data.table)
library(AnnotationHub)
library(tidyverse)
library(tximport)


# AnnotationHub Setup 
AnnotationSpecies <- "Homo sapiens"  # Assign your species 
ah <- AnnotationHub(hub=getAnnotationHubOption("URL"))   # Bring annotation DB


ahQuery <- query(ah, c("OrgDb", AnnotationSpecies))      # Filter annotation of interest

if (length(ahQuery) == 1) {
    DBName <- names(ahQuery)
} else if (length(ahQuery) > 1) {
               DBName <- names(ahQuery)[1]
} else {
    print("You don't have a valid DB")
    rmarkdown::render() 
} 

AnnoDb <- ah[[DBName]] # Store into an OrgDb object  


# Explore your OrgDb object with following accessors:
# columns(AnnpDb)
# keytypes(AnnoDb)
# keys(AnnoDb, keytype=..)
# select(AnnoDb, keys=.., columns=.., keytype=...)
AnnoKey <- keys(AnnoDb, keytype="ENSEMBLTRANS")

# Note: Annotation has to be done with not genome but transcripts 
AnnoDb <- select(AnnoDb, 
                 AnnoKey,
                 keytype="ENSEMBLTRANS",
                 columns="SYMBOL")


# Check if your AnnoDb has been extracted and saved correctely
class(AnnoDb)
head(AnnoDb)

# Define sample names 
SampleNames <-  c("Mock_72hpi_S1",
                 "Mock_72hpi_S2",
                 "Mock_72hpi_S3",
                 "SARS-CoV-2_72hpi_S7",
                 "SARS-CoV-2_72hpi_S8",
                 "SARS-CoV-2_72hpi_S9") 

# Define group level
GroupLevel <- c("Mock", "COVID")

# Define contrast for DE analysis
Contrast <- c("Group", "COVID", "Mock")


# Set a directory to save csv files
dir.create("./csv")


# Define .sf file path
sf <- c(paste0(SampleNames,
               ".fastq.gz.salmon_quant/quant.sf"))

# Define sample groups
group <- c(rep("Mock", 3), rep("COVID", 3))

# Create metadata
metadata <- data.frame(Sample=factor(SampleNames, levels=SampleNames),
                       Group=factor(group, levels=GroupLevel),
                       Path=sf)

rownames(metadata) <- SampleNames

# Explore the metadata
print(metadata)

ReadTable <- data.frame(Gene=AnnoDb$SYMBOL)

# Extract TPM and combine to the ReadTable data frame
 for (x in sf) {
        
        txi <- tximport(x,            # path to a quant.sf file  
                        type="salmon",     
                        tx2gene=AnnoDb,txOut=TRUE)

        txi.sum <- summarizeToGene(txi, AnnoDb)
        
        read <- as.data.frame(txi.sum$counts)

        read <- rownames_to_column(read, var = colnames(ReadTable)[1])

        ReadTable <- full_join(ReadTable, 
                               read, 
                               by = colnames(ReadTable)[1]) %>%
        distinct()

 }

# Assign column names to sample names 
colnames(ReadTable)[2:ncol(ReadTable)] <- SampleNames


# Remove NA-containing transcripts
ReadTable <- ReadTable[complete.cases(ReadTable),]


# Remove zero-Read transcripts 
nonzeroRead <- rowSums(ReadTable[2:ncol(ReadTable)]) > 0
ReadTable <- ReadTable[nonzeroRead,]

# Exploratory data analysis
dim(ReadTable)
head(ReadTable)
summary(ReadTable)

# Save the raw tpm table as a csv file
write.csv(ReadTable, "./csv/Read_counts.csv")


```

- TPM level: **singlequant_tpm.Rmd** -> **csv/TPM_count.csv**

```r
# Loading required packages
library(data.table)
library(rmarkdown)
library(AnnotationHub)
library(tidyverse)
library(tximport)
library(ggplot2)
library(DESeq2)
library(pheatmap)

# AnnotationHub Setup 
AnnotationSpecies <- "Homo sapiens"  # Assign your species 
ah <- AnnotationHub(hub=getAnnotationHubOption("URL"))   # Bring annotation DB


ahQuery <- query(ah, c("OrgDb", AnnotationSpecies))      # Filter annotation of interest

if (length(ahQuery) == 1) {
    DBName <- names(ahQuery)
} else if (length(ahQuery) > 1) {
               DBName <- names(ahQuery)[1]
} else {
    print("You don't have a valid DB")
    rmarkdown::render() 
} 

AnnoDb <- ah[[DBName]] # Store into an OrgDb object  


# Explore your OrgDb object with following accessors:
# columns(AnnpDb)
# keytypes(AnnoDb)
# keys(AnnoDb, keytype=..)
# select(AnnoDb, keys=.., columns=.., keytype=...)
AnnoKey <- keys(AnnoDb, keytype="ENSEMBLTRANS")

# Note: Annotation has to be done with not genome but transcripts 
AnnoDb <- select(AnnoDb, 
                 AnnoKey,
                 keytype="ENSEMBLTRANS",
                 columns="SYMBOL")


# Check if your AnnoDb has been extracted and saved correctely
class(AnnoDb)
head(AnnoDb)

# Define sample names 
SampleNames <-  c("Mock_72hpi_S1",
                 "Mock_72hpi_S2",
                 "Mock_72hpi_S3",
                 "SARS-CoV-2_72hpi_S7",
                 "SARS-CoV-2_72hpi_S8",
                 "SARS-CoV-2_72hpi_S9") 

# Define group level
GroupLevel <- c("Mock", "COVID")

# Define contrast for DE analysis
Contrast <- c("Group", "COVID", "Mock")


# Set a directory to save csv files
dir.create("./csv")


# Define .sf file path
sf <- c(paste0(SampleNames,
               ".fastq.gz.salmon_quant/quant.sf"))

# Define sample groups
group <- c(rep("Mock", 3), rep("COVID", 3))

# Create metadata
metadata <- data.frame(Sample=factor(SampleNames, levels=SampleNames),
                       Group=factor(group, levels=GroupLevel),
                       Path=sf)

rownames(metadata) <- SampleNames

# Explore the metadata
print(metadata)


TPMTable <- data.frame(Transcript=AnnoDb$ENSEMBLTRANS,
    Gene=AnnoDb$SYMBOL)

# Extract TPM and combine to the TPMTable data frame
 for (x in sf) {
        
        txi <- tximport(x,            # path for a quant.sf file  
                        type="salmon",     
                        tx2gene=AnnoDb,txOut=TRUE) 
        txi.sum <- summarizeToGene(txi, AnnoDb)
        tpm <- as.data.frame(txi.sum$abundance) 
         
        tpm <- rownames_to_column(tpm, var = colnames(TPMTable)[1]) 
        TPMTable <- full_join(TPMTable, 
                              tpm, 
                              by=colnames(TPMTable)[1]) %>% 
        distinct()
 }



# Assign column names to sample names 
colnames(TPMTable)[2:ncol(TPMTable)] <- SampleNames


# Remove NA-containing transcripts
TPMTable <- TPMTable[complete.cases(TPMTable),]


# Remove zero-TPM transcripts 
nonzeroTPM <- rowSums(TPMTable[2:ncol(TPMTable)]) > 0
TPMTable <- TPMTable[nonzeroTPM,]

# Exploratory data analysis
dim(TPMTable)
head(TPMTable)
summary(TPMTable)

# Save the raw tpm table as a csv file
write.csv(TPMTable, "./csv/Read_TPM.csv")
```

