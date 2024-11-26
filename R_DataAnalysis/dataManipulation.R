
#Installing packages which are not already installed

install.packages("tidyverse")
install.packages("BiocManager")

BiocManager::install("GEOquery")


install.packages("GEOquery")

#Load Libraries

library(dplyr)
library(tidyverse)
library(GEOquery)

# Read the data

data <- read.csv('GSE183947_fpkm.csv')

dim(data)

head(data)

# Get the meta data 
#Getting Meta data is important because it tells us the information about the 
# samples being used and any additional we might require to data manipulation
# or data visualization



GSE <- getGEO(GEO = 'GSE183947', GSEMatrix = TRUE)

GSE


metadata <- pData(phenoData(GSE[[1]]))

head(metadata)

# Renaming features names into more meaningful ones and replacing text inside the dataset

metadata_subset <- metadata %>%
  select("title", "characteristics_ch1", "characteristics_ch1.1", "description")

metadata_subset <- metadata_subset %>%
  rename(tissue = characteristics_ch1) %>%
  rename(metastasis = characteristics_ch1.1) %>%
  mutate(tissue = gsub("tissue: ", "", tissue)) %>%
  mutate(metastasis = gsub("metastasis: ", "", metastasis))


# reshaping data

data.long <- data %>%
  rename(gene=X) %>%
  gather(key = 'samples', value = 'FPKM', -gene) 

# Joining the data frames (data.long + metadata_subset)

colnames(metadata_subset) # to get the column names of the data set

data.long <- data.long %>%
  left_join(metadata_subset, by=c("samples" = "description"))

# Data Exploration 

data.long %>%
  filter(gene == 'BRCA1' | gene == 'BRCA2') %>%
  group_by(gene, tissue) %>%
  summarize(mean_fpkm = mean(FPKM), 
            median_fpkm = median(FPKM)) %>%
  arrange(desc(mean_fpkm))


  
