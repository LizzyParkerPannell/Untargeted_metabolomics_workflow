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

# imputation for PERMANOVA data cleaning
impute <- function(x, na.rm=FALSE)(x+1)

# This function will filter the data by the two classes you're interested in, recode them the way muma wants, and recode your
# sample names if they are too long (>5. Don't worry, it will save a file with a key to the new sample names if that's the case)
tidy_for_muma <- function(metadata_class, class_1, class_2){
  
  temp_data <- peak_table %>%
    column_to_rownames(var = "Sample")
  
  temp1 <- metadata %>%
    select(Sample, as.factor(metadata_class)) 
  
  temp <- temp1 %>%
    filter(!is.na(metadata_class)) %>%
    mutate(old_class = get(names(temp1)[2])) %>%
    mutate(old_class = as.factor(old_class)) 
  
  new_class <- tibble(old_class = levels(temp$old_class)) %>%
    mutate(Class = case_when(
      old_class == class_1 ~ "1",
      old_class == class_2 ~ "2",
      old_class != class_1 & old_class != class_2 ~ "NA"
    ))
  
  class_info <- temp %>%
    left_join(new_class) %>%
    select(Sample, Class) %>%
    mutate(unique_sample = paste("S", 1:length(Sample), sep = ""))
  
  muma_data <- peak_table %>%
    left_join(class_info) %>%
    filter(Class != "NA") %>%
    select(Sample, unique_sample, Class, any_of(colnames(temp_data))) %>%
    mutate(Sample = case_when(
      str_length(Sample) <= 5     ~ Sample,
      str_length(Sample) >= 6     ~ unique_sample
    )) 
  
  # save the data frame for use in the next step
  write_csv(muma_data %>%
              select(-unique_sample), 
            "muma_undirected_directed_analysis/data_for_muma.csv")
  
  test_sample <- str_length(peak_table[1,1])
  
  #add output of the samples and unique samples for reference
  if (test_sample >= 6) {
    
    write_csv(muma_data %>% 
                select(Sample, unique_sample), 
              "muma_undirected_directed_analysis/recoded_sample_names.csv")
    paste("Sample names were changed, see muma_undirected_directed_analysis/recoded_sample_names.csv for the new sample names") # if true, write the file
    
  } else {
    
    paste("Sample names were not changed")
  
    }
  
  
  return(paste("The data frame for muma has been saved as muma_undirected_directed_analysis/data_for_muma.csv"))
  
}
# so the following code accesses the scores, loadings, p and t values etc from the muma output and gets them in a format you can
# use to make ggplots

nicer_graphs_and_discriminating_variables <- function(pcorr1_min, pcorr1_max, p_top_n){

  oplsda_pcorr1 <- read.csv("OPLS-DApareto/pcorr1_Matrix.csv") %>%
    dplyr::rename(pcorr1=V1)
  oplsda_p1_Matrix <- read.csv("OPLS-DApareto/p1_Matrix.csv") %>%
    dplyr::rename(p1=V1)
  loadings_column <- left_join(oplsda_p1_Matrix, oplsda_pcorr1, by="X")
  
  loadings_matrix <- read.csv("OPLS-DApareto/PCA_OPLS/PCA_OPLS_LoadingsMatrix.csv")
  
  variables <- loadings_matrix %>%
    pull(X)
  
  loadings_column <- loadings_column %>%
    add_column(variables) %>%
    select(-X) %>%
    mutate(mz=str_sub(variables, 2, 9))
  
  # Here you may want to change the level of pcorr1 you filter out - take a look at the S plot for an idea of the magnitude of effect
  # You will also need to look at your S plot to see which loadings are associating with which class
  top <- loadings_column %>%
    arrange(desc(p1)) %>%
    slice(1:p_top_n) %>%
    filter(pcorr1 > pcorr1_min) # change this depending on your S plot
  
  bottom <- loadings_column %>%
    arrange(p1) %>%
    slice(1:p_top_n) %>%
    filter(pcorr1 < pcorr1_max) # change this depending on your S plot
  
  # table of variables (mz or mz__rt) of interest to get putative ids for
  discriminating_variables <- bind_rows(top, bottom, .id="id") %>%
    dplyr::rename(association=id)
  
  write.csv(discriminating_variables, "OPLS-DApareto/OPLSDA_discriminating_variables.csv")
  
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
  
  p_x_limits <- c((min(loadings_column$p1) * 1.2 ), (max(loadings_column$p1) * 1.2 ))
  p_top_n_limits <- min(top$p1)
  p_bottom_n_limits <- max(bottom$p1)
  
  new_S_plot <- ggplot(loadings_column, aes(x=p1, y=pcorr1)) +
    geom_point() +
    pca_theme +
    scale_x_continuous(limits=c(p_x_limits), expand=c(0,0)) +
    scale_y_continuous(limits=c(-1, 1.1), expand=c(0,0)) +
    #geom_text(aes(label=mz, x=p1, y=(jitter((pcorr1 + 0.05), factor=1, amount=NULL)))) +
    geom_rect(aes(xmin=p_top_n_limits, xmax=p_x_limits[2], ymin=pcorr1_min, ymax=1), fill="tomato", alpha=0.005) +
    geom_rect(aes(xmin=p_x_limits[1], xmax=p_bottom_n_limits, ymin=pcorr1_max, ymax=-1), fill="tomato", alpha=0.005)
  
  new_S_plot
  
  
  ggsave("OPLS-DApareto/ggplot_OPLSDA_S-plot.png", new_S_plot, "png")
  
  return(paste("S plot and discriminating variables table saved to OPLS-DApareto/ggplot_OPLSDA_S-plot.png and OPLS-DApareto/OPLSDA_discriminating_variables.csv"))
  
}

### you won't be able to run the subsequent code chunks unless you have loaded the above functions first
```
---
### Load your data and metadata


Now you can load your peak table. You need to define MSType as either "XCMS" or "MALDI" (for DI-ESI-MS, use "MALDI").

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
