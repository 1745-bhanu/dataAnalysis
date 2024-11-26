# Load libraries 

library(tidyverse)
library(ggplot2)

# Read the data 

head(data.long)

# Visualizations

# Bar plots

data.long %>%
  filter(gene == 'BRCA1') %>%
  ggplot(., aes(x=samples, y= FPKM, fill=tissue)) + geom_col()

# Density plot 

data.long %>%
  filter(gene == 'BRCA1') %>%
  ggplot(., aes(x=FPKM, fill=tissue)) + geom_density(alpha=0.2)

# Box plot 

data.long %>%
  filter(gene=='BRCA1') %>%
  ggplot(., aes(x=metastasis, y=FPKM, fill = metastasis)) + geom_boxplot()

# scatter plot

data.long %>%
  filter(gene=='BRCA1' | gene == 'BRCA2') %>%
  spread(key=gene, value = FPKM) %>%
  ggplot(., aes(x=BRCA1, y=BRCA2, colour = tissue)) + geom_point() + geom_smooth(method = 'lm', 
                                                                se = FALSE)

# Heat map

genes_of_interest <- c('BRCA1', 'BRCA2', 'TP53', 'ALK', 'MYCN')

data.long %>%
  filter(gene %in% genes_of_interest) %>%
  ggplot(., aes(x=samples, y=gene, fill=FPKM)) + geom_tile() + 
  scale_fill_gradient(low = 'white', high = 'red')













