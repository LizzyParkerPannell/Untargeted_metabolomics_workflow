---
title: R for Multivariate analysis
weight: 3
---

> Alternatively see the code at [Github](https://github.com/LizzyParkerPannell/Untargeted_metabolomics_workflow/blob/e6fc5ff3ac5a9e4871b035d9036ddce1a5882eb3/06_undirected_directed_analysis.R)

You will need your peak table in a specific format:

- if you have tidied your data using [05_tidy_data_from_MassUp](https://github.com/LizzyParkerPannell/Untargeted_metabolomics_workflow/blob/e6fc5ff3ac5a9e4871b035d9036ddce1a5882eb3/05_tidy_data_from_MassUp.R) or [XCMS](https://github.com/LizzyParkerPannell/Untargeted_metabolomics_workflow/blob/e6fc5ff3ac5a9e4871b035d9036ddce1a5882eb3/05_tidy_data_from_XCMS-online.R), then you should already have the files you need in `"Untargeted_metabolomics_workflow\Tidy_data"`
- Otherwise you will need a pre-processed peak intensity table saved as a .csv with features (m/z or m/z__RT or m/z bins) as columns and samples as rows in a column called "Sample". Then you will need either your treatments (classes/ grouping information) in columns following the first column ("Sample") **OR** you will need a metadata file with "Sample" as the first column followed by you treatments (classes/ grouping information) in separate columns

You will also need to have installed the following packages in R (or RStudio): 
`tidyr`, `tibble`, `dplyr`, `readr`, `stringr`, `ggplot2`, `pcaMethods`, `muma`, `forcats`, `vegan`.

---
### Load everything you will need into R

Firstly load all the libraries that you will need:

```
# Load required packages
packages_to_load <- c("tidyr", "tibble", "dplyr", "readr", "stringr", "ggplot2", "pcaMethods", "muma", "forcats", "vegan")
lapply(packages_to_load, require, character.only = TRUE)  

# Don't forget to cite these packages in your thesis/ manuscript (this code will automatically make a table of text citations for you)
cite_packages <- tibble(Package = "1", Citation = "1")
for (i in 1:length(packages_to_load)){
  j <- packages_to_load[i]
  
  k <- citation(j)$textVersion
  
  cite_packages[i, 1] <- j
  cite_packages[i, 2] <- k
  
}
cite_packages
```
Now load the functions we will be using by pasting this code into R or RStudio (it looks long and scary but will save a lot of time later on). If anyone wants to contribute to making this into a package, that would be great!
```
get_peak_table <- function(MStype){
  
  files <- tibble(list_of_files = list.files("Tidy_data")) %>%
    filter(str_detect(list_of_files, "Data_for_metaboanalyst_2factor") == TRUE) %>%
    filter(str_detect(list_of_files, MStype) == TRUE)
  
  file_path <- paste("Tidy_data/", files$list_of_files[1], sep="")
  
  file_to_import <- read_csv(file_path)
  
  paste("The function found", file_path, "and imported it for you", sep = " ")
  
  return(file_to_import)
  
  
}

get_metadata <- function(MStype){
  
  files <- tibble(list_of_files = list.files("Tidy_data")) %>%
    filter(str_detect(list_of_files, "metadata") == TRUE) %>%
    filter(str_detect(list_of_files, MStype) == TRUE)
  
  file_path <- paste("Tidy_data/", files$list_of_files[1], sep="")
  paste("The function found", file_path, "and imported it for you", sep = " ")
  
  file_to_import <- read_csv(file_path)
  
  return(file_to_import)
  
}

initial_PCA <- function(MStype){

  
  temp <- peak_table %>%
    column_to_rownames(var = "Sample")
  
  #pca model on raw data
  raw <- prep(temp, scale="pareto", centre=TRUE)
  raw.mod <- pca(raw, method="nipals", nPcs=5)
  raw.sum <- as.data.frame(t(summary(raw.mod))) 
  colnames(raw.sum) <- c("R2", "Cumulative_R2")
  raw.sum$PC <- c(1:5)
  
  # add class info so later can use for aesthetics of pca scores plots
  #sl_raw <- merge(raw, raw.mod@scores, by=0)
  sl_raw <- merge(raw, raw.mod@scores, by=0)
  class_info <- metadata %>%
    rename("Row.names" = Sample)
  
  new_sl_raw <- left_join(sl_raw, class_info, by = "Row.names")
  
  if_else(
    anyNA(new_sl_raw) == TRUE,
    paste("NAs are present in the PCA scores or metadata - double check your sample and treatment lists"),
    paste("No NAs in in PCA scores or metadata")
  )
  
  # turn R2 values into percentages so they can be added to the axes
  raw.sum$R2percent <- signif(raw.sum$R2, digits=3)*100
  
  list_objects <- list(raw.sum, new_sl_raw)
  
  return(list_objects)
  
}

draw_scores_plot <- function(PC_x, PC_y, colour_class, shape_class){
  
  new_sl_raw <- results_for_PCA_graphs[[2]] %>%
    select(PC_x, PC_y, colour_class, shape_class)
  
  new_sl_raw$extra_class <- new_sl_raw[,ncol(new_sl_raw)]
  
  data_for_graph <- new_sl_raw  %>%
    filter(str_detect(extra_class, "NA") != TRUE)

  data_for_graph <- new_sl_raw

  
  raw.sum <- results_for_PCA_graphs[[1]] %>%
    rownames_to_column()
  
  pca_theme<- theme_bw() +
    theme(axis.text.x=element_text(hjust=0.5, vjust=0.5, size=12), 
          axis.text.y=element_text(size=12),
          axis.title.x=element_text(size=12),
          axis.title.y=element_text(size=12),
          legend.title=element_text(size=12),
          legend.background=element_blank(),
          legend.key=element_blank(), 
          plot.background = element_blank(), 
          panel.grid.major = element_line(colour = NA), 
          panel.grid.minor = element_line(colour = NA), 
          panel.background = element_rect(fill = "white"),
          panel.border = element_blank(), axis.line = element_line())
  
  #graph of PCA with 95%CI ellipses coded by treatment and timepoint
  graph_raw <- ggplot(data_for_graph, aes(x=get(names(data_for_graph)[1]), y=get(names(data_for_graph)[2]))) +
    geom_point(aes(colour = get(names(data_for_graph)[3]), shape = get(names(data_for_graph)[4])), size = 3) +
    stat_ellipse(aes(linetype=get(names(data_for_graph)[4]), colour=get(names(data_for_graph)[3]))) + 
    scale_colour_discrete(colour_class, na.translate = F) +
    scale_shape_discrete(shape_class, na.translate = F) +
    scale_linetype(shape_class, na.translate = F) +
    pca_theme +
    labs(x = (paste(sep = "", PC_x, "(", raw.sum$R2percent[raw.sum$rowname == PC_x], "%)")),
         y = (paste(sep = "", PC_y, "(", raw.sum$R2percent[raw.sum$rowname == PC_y], "%)"))) + #will show the R2 of the specified PC - make sure they match
    ggtitle(paste("PCA Scores plot")) +
    theme(legend.justification = c(0,0), legend.position = c(0.9, 0.1), legend.key.size = unit(0.8,"cm"), legend.text = element_text(size = 12))
    
    # load scores plot
   return(graph_raw)
  
}
```

Now you can load your peak table:

```
# If you tidied your peak table using "05_tidy_data_from..." you can use this function to get the peak table
peak_table <- get_peak_table(MStype = "XCMS")
```

And your meta data:
```
metadata <- get_metadata(MStype = "XCMS") 
```

At this point, it is useful to check how many features are included in your analysis (i.e. how many mz/RT peaks were found). This should be the number of variables in peak_table minus 1 (the 1 being the column of samples). You could report this, for example:

>"After grouping and alignment, the processed data comprised XXX features for analysis."

---
### Run the PCA model

The next step is to arrange the data so that it can be read by the `pcaMethods` package in R. The following function will do this and run the initial model. You need to define MSType as either "XCMS" or "MALDI" (for DI-ESI-MS, use "MALDI").

```
results_for_PCA_graphs <- initial_PCA(MStype = "XCMS")
```
From this we can then make an initial PCA scores plot

```
# use the function draw_scores_plot to make various graphs (it will automatically tell you the variance associated with the PCs you choose)
# If you only have one class (treatment group) then you still need to define both colour_class and shape_class but they can be the same
scores_plot <- draw_scores_plot(PC_x = "PC1",
                             PC_y = "PC2",
                             colour_class = "Time",
                             shape_class = "Treat")

scores_plot
```
In the above function it is possible to define which combination of principal components you want to show in your 2D scores plot, as well as which classes will be used to colour/shape code your samples. However, it is worth noting that the metadata has not been used in running the model - you are applying the colours after the analysis.
