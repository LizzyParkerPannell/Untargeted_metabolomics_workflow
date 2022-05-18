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
packages_to_load <- c("tidyr", "tibble", "dplyr", "readr", "stringr", "ggplot2", "pcaMethods", "muma", "forcats")
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

# If you have some clustering/ separation between your classes then you can use directed analysis to pull out the features (mz__rt or mz bin)
# that have the biggest, most reliable effect on the OPLS-DA model ...

# muma package will do an OPLS-DA

### the next bit gets the peak_table (the mz values for each sample)
# into the format that muma package wants
# so needs Samples (4-5 characters, unique) and then Class (integers)
# as the first 2 columns and then all the mz slices as variables

# useful for PCA and OPLSDA theory https://metabolomics.se/Courses/MVA/MVA%20in%20Omics_Handouts_Exercises_Solutions_Thu-Fri.pdf

# if you want to do OPLS-DA you have to run muma with the original 
# data file recoded so that Class only contains "1" or "2"


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

# Run the function for the class and levels of that class that you are interested in
tidy_for_muma(metadata_class = "Time",
              class_1 = "T1",
              class_2 = "T3")



# so now the data is in the right format, we let muma do all the hard work:

# for details/ help see
# ?muma
# or documentation https://rdrr.io/cran/muma/

#here we will use pareto scaling but it is worth exploring whether that is the best scaling for your data
# you will also need to adjust imputation and imput if you have MALDI data (likely to have a lot of missing values)
explore.data(file="muma_undirected_directed_analysis/data_for_muma.csv", scaling="pareto",
             scal=TRUE, normalize=TRUE, imputation=FALSE,
             imput="ImputType")

# the muma package saves all the output of the analysis to "muma_undirected_directed_analysis/"
Plot.pca(pcx=1, pcy=2, scaling="pareto", test.outlier=TRUE)
#repeat for any combination of PCs - muma will paste the best combinations in R
# you may get the following error but it doesn't seem to cause a problem (I generally ignore)
# Error in dist1[, 1] : argument "i" is missing, with no default

# now get muma to run the oplsda - you must specify the same type of scaling as in the PCA
oplsda(scaling="pareto")



# now these graphs are fine but you might want nicer outputs for thesis/ publication/ presentation
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


# Here you need to tell the function the following:
# p_top_n -> How many variables do you want the function to look at associated with each class (you may get fewer returned if they had low reliability in
# the model but it will start with the number you give it)
# p_corr1_min -> this is the minimum positive value of ~reliability in the model for the bottom end of the list of discriminating variables
# i.e. (how strict do you want to be, look at pcorr1 on S plot)
# p_corr1_max -> this is the maximum negative value of ~reliability for the bottom end of the list of discriminating variables
# These values will be slightly different in every analysis - you really do need to look at the data and think about what you want to know
nicer_graphs_and_discriminating_variables(pcorr1_min = 0.4,
                                          pcorr1_max = -0.4,
                                          p_top_n = 20
                                          )
