# Elizabeth Parker May 2022

# Untargeted metabolomics workflow stage 6 (Undirected and directed analysis of untargeted metabolomics data)
# Inter operable code to perform basic analysis of untargeted MALDI or DI-MS or LCMS (alternative to Metaboanalyst or SIMCA)

# N.B. You will need your peak table in a specific format, if you have tidied your data using 05_tidy_data_from_ MassUp, XCMS or macro,
# then you should already have the files you need.

# Otherwise you will need a pre-processed peak intensity table saved as a .csv with features (m/z or m/z__RT or m/z bins) as columns 
# and samples as rows in a column called "Sample"
# you will need either your treatments (classes/ grouping information) in columns following the first column ("Sample")
# OR you will need a metadata file with "Sample" as the first column followed by you treatments (classes/ grouping information) in separate columns

# Load required packages
packages_to_load <- c("tidyr", "tibble", "dplyr", "readr", "stringr", "ggplot2", "pcaMethods", "muma")
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

# If you tidied your peak table using "05_tidy_data_from..." you can use this function to get the peak table
get_peak_table <- function(MStype){
  
  files <- tibble(list_of_files = list.files("Tidy_data")) %>%
    filter(str_detect(list_of_files, "Data_for_metaboanalyst_2factor") == TRUE) %>%
    filter(str_detect(list_of_files, MStype) == TRUE)
  
  file_path <- paste("Tidy_data/", files$list_of_files[1], sep="")
  
  file_to_import <- read_csv(file_path)
  
  paste("The function found", file_path, "and imported it for you", sep = " ")
  
  return(file_to_import)
  
  
}

peak_table <- get_peak_table(MStype = "XCMS")

# If you saved the tidied peak table yourself from another source, check it is formatted correctly, and then define it here
# This is also an option if you have e.g. multiple tidied xcms downloads in the same folder

### peak_table <- read_csv("Tidy_data/Specify_you_file_name_here.csv")

get_metadata <- function(MStype){
  
  files <- tibble(list_of_files = list.files("Tidy_data")) %>%
    filter(str_detect(list_of_files, "metadata") == TRUE) %>%
    filter(str_detect(list_of_files, MStype) == TRUE)
  
  file_path <- paste("Tidy_data/", files$list_of_files[1], sep="")
  paste("The function found", file_path, "and imported it for you", sep = " ")
  
  file_to_import <- read_csv(file_path)
  
  return(file_to_import)
  
}


metadata <- get_metadata(MStype = "XCMS")

# This function will run an initial PCA on your data so you can see whether there are any major outliers, and if
# there's a strong enough pattern to proceed with directed analysis

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

results_for_PCA_graphs <- initial_PCA(MStype = "XCMS")

## Now you are ready to make a scores plot

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
    geom_point(aes(colour = get(names(data_for_graph)[3]), shape = get(names(data_for_graph)[4]))) +
    stat_ellipse(aes(linetype=get(names(data_for_graph)[4]), colour=get(names(data_for_graph)[3]))) + 
    scale_colour_discrete(colour_class) +
    scale_shape_discrete(shape_class) +
    scale_linetype(shape_class) +
    pca_theme +
    labs(x = (paste(sep = "", PC_x, "(", raw.sum$R2percent[raw.sum$rowname == PC_x], "%)")),
         y = (paste(sep = "", PC_y, "(", raw.sum$R2percent[raw.sum$rowname == PC_y], "%)"))) + #will show the R2 of the specified PC - make sure they match
    ggtitle(paste("PCA Scores plot")) +
    theme(legend.justification = c(0,0), legend.position = c(0.9, 0.1), legend.key.size = unit(0.8,"cm"), legend.text = element_text(size = 12))
    
    # load scores plot
   return(graph_raw)
  
}


# use the function draw_scores_plot to make various graphs (it will automatically tell you the variance associated with the PCs you choose)
# If you only have one class (treatment group) then you still need to define both colour_class and shape_class but they can be the sames
scores_plot <- draw_scores_plot(PC_x = "PC1",
                             PC_y = "PC2",
                             colour_class = "Treat",
                             shape_class = "Treat")

scores_plot

 

