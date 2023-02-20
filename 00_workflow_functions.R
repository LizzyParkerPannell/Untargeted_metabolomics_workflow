
# Elizabeth Parker December 2022
# Prep, libraries and functions for untargeted metabolomics workflow
# See https://untargeted-metabolomics-workflow.netlify.app/ for guidance

RequiredPackages <- c("devtools","dplyr","forcats","ggplot2","pcaMethods","readr", "stringr","tibble","tidyr","vegan", "BiocManager")

# TIDY DATA FROM MASSUP (MALDI AND DIMS)

tidy_MALDI_peak_table <- function(file_path){
  
  #import saved peak tables that you exported from MassUp
  # get list of files to import
  files_from_Massup <- data.frame(directories = list.files(file_path)) %>%
    filter(directories != "treatments.csv") %>%
    filter(directories != "samplelist.csv") %>% 
    filter(directories != "Tidy_data") %>% 
    filter(directories != list.files(file_path, pattern = "\\.Rproj$")) %>% 
    filter(directories != list.files(file_path, pattern =  "\\.R$"))
  
  files_to_import <- tibble(Filename = "")
  
  for (x in 1:length(files_from_Massup$directories)){
    
    a <- tibble(Filename = paste(file_path, files_from_Massup$directories[x], (list.files(paste(file_path, files_from_Massup$directories[x], sep="/"))), sep = "/")) %>%
      mutate(Filename = paste(Filename))
    
    files_to_import <- files_to_import %>%
      full_join(a) %>%
      filter(Filename != "") %>%
      mutate()
    
  }
  
  
  peak_table <- tibble(mmz = 0.1)
  
  for(i in 1:length(files_to_import$Filename)){
    
    old_table <- peak_table
    
    a <- read.csv(files_to_import$Filename[i], sep = ",") %>%
      rename("mmz" = 1)
    
    colnames(a)[2] <- files_to_import$Filename[i]
    
    peak_table <- old_table %>%
      full_join(a)
    
  }
  
  
  
  # clean up column names so that they are the file not the whole path
  file_names <- tibble(Filename = colnames(peak_table)) %>%
    transmute(Filename = str_replace(Filename, file_path, "")) %>%
    transmute(Filename = str_replace(Filename, ".csv", "")) %>%
    transmute(Filename = str_replace(Filename, "/spectrum1", "")) %>% 
    transmute(Filename = str_replace(Filename, Filename, substr(Filename, 2,nchar(Filename))))
  
  Tidy_data <- peak_table %>%
    filter(mmz != 0.1)
  
  colnames(Tidy_data) <- file_names$Filename
  
  #import treatment list
  treatments <- read.csv(paste(file_path,"/treatments.csv", sep="")) %>%
    mutate(Filetext = as.character(Filetext)) %>%
    distinct()
  treat_names <- tibble(treats = colnames(treatments)) %>%
    filter(treats != "Filetext")
  
  #import sample list
  sample_list <- read.csv(paste(file_path, "/samplelist.csv", sep=""))
  
  temp <- as_tibble(t(peak_table))
  colnames(temp) <- as.character(peak_table$mmz)
  Tidy_data <- temp %>%
    filter(is.na(`0.1`)) %>%
    select(-`0.1`) %>%
    add_column((file_names %>% filter(Filename != "mz")), .before = TRUE)
  
  metadata <- Tidy_data %>% select(Filename) %>%
    left_join(sample_list) %>% 
    left_join(treatments) %>%
    select(Filename, Filetext, treat_names$treats) %>%
    distinct()
  
  data_for_SIMCA <- Tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, treat_names$treats, any_of(as.character(peak_table$mmz))) %>%
    mutate(Sample = str_replace_all(Sample, " ", "_"))
  
  data_for_metaboanalyst_1 <- Tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, treat_names$treats[1], any_of(as.character(peak_table$mmz))) %>%
    mutate(Sample = str_replace_all(Sample, " ", "_"))
  
  data_for_metaboanalyst_2 <- Tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, treat_names$treats[2], any_of(as.character(peak_table$mmz))) %>%
    mutate(Sample = str_replace_all(Sample, " ", "_"))
  
  metadata_for_metabolanalyst2 <- metadata %>%
    select(-Filetext) %>%
    rename("Sample" = Filename)
  
  
  write_csv(data_for_SIMCA, "Tidy_data/Massup_Data_for_SIMCA.csv")
  write_csv(data_for_metaboanalyst_1, "Tidy_data/Massup_Data_for_metaboanalyst_1factor.csv")
  write_csv(data_for_metaboanalyst_2, "Tidy_data/Massup_Data_for_metaboanalyst_2factor.csv")
  write_csv(metadata_for_metabolanalyst2, "Tidy_data/Massup_metadata_for_metaboanalyst.csv")
  
  return(paste("MALDI peak tables suitable for SIMCA + metaboanalyst saved to Tidy_data/MALDI_Data_for_SIMCA.csv"))
  
}

# TIDY DATA FROM XCMS ONLINE (LCMS)

tidy_xcms_online_peak_table <-function(folder, prefix, main_treatment){
  
  path <- paste("Data/", folder, "/results", sep = "")
  
  file <- tibble(names = list.files(path)) %>%
    filter(str_detect(names, "XCMS.diffreport.") == TRUE) %>%
    filter(str_detect(names, ".tsv") == TRUE)
  
  diffreport <- read_table(paste(path, "/", file$names[1], sep = ""))
  colnames(diffreport) <- str_replace_all(colnames(diffreport), "\\.", "_") 
  
  sample_cols <- tibble(col_names = colnames(diffreport)) %>%
    filter(str_detect(col_names, prefix) == TRUE)
  
  paste("The function thinks you have", length(sample_cols$col_names), "samples (double check this number!)")
  
  temp <- diffreport %>% 
    mutate(mzmed = round(mzmed, digits = 5)) %>%
    mutate(rtmed = round(rtmed, digits = 2)) %>%
    mutate(Feature = paste(mzmed, rtmed, sep = "__")) %>%
    select(Feature, sample_cols$col_names)
  
  Features <- c("Filename", temp$Feature)
  samples <- c("Feature", sample_cols$col_names)
  
  tidy_data <- as.tibble(t(temp)) %>%
    add_column(Filename = samples, .before = TRUE) %>%
    mutate(Filename = str_replace_all(Filename, "-", "_")) %>%
    filter(Filename != "Feature")
  colnames(tidy_data) <- Features
  
  
  sample_list <- read_csv("Data/samplelist.csv") %>%
    mutate(Filename = str_replace_all(Filename, "-", "_"))
  
  treatment_list <- read_csv("Data/treatments.csv")
  
  treat_names <- tibble(treats = colnames(treatment_list)) %>%
    filter(treats != "Filetext")
  
  metadata <- tidy_data %>% select(Filename) %>%
    left_join(sample_list) %>%
    left_join(treatment_list) %>%
    select(Filename, Filetext, treat_names$treats)
  
  paste("The function thinks you have", length(metadata$Filetext), "labelled samples (double check this number!)")
  
  if_else(
    length(unique(metadata$Filetext)) == length(metadata$Filetext), 
    paste("Sample names are unique"), 
    paste("Sample names are not unique, check samplelist"))
  
  if_else(
    anyNA(metadata) == TRUE,
    paste("NAs are present in the metadata - double check your sample and treatment lists"),
    paste("No NAs in metadata - always double check your metadata table looks how you expect")
  )
  
  data_for_SIMCA <- tidy_data %>%
    left_join(metadata) %>% 
    select(Filetext, treat_names$treats, any_of(as.character(temp$Feature))) %>%
    rename("Sample" = Filetext)
  
  write_csv(data_for_SIMCA, "Tidy_data/XCMS_Data_for_SIMCA.csv")
  
  treatment1 <- as.character(treat_names %>%  filter(treats == main_treatment))
  
  data_for_metaboanalyst_1 <- tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, treatment1 , any_of(as.character(temp$Feature)))
  
  data_for_metaboanalyst_2 <- tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, any_of(as.character(temp$Feature)))
  
  metadata_for_metabolanalyst2 <- metadata %>%
    select(-Filename) %>%
    rename("Sample" = Filetext)
  
  write_csv(data_for_metaboanalyst_1, "Tidy_data/XCMS_Data_for_metaboanalyst_1factor.csv")
  write_csv(data_for_metaboanalyst_2, "Tidy_data/XCMS_Data_for_metaboanalyst_2factor.csv")
  write_csv(metadata_for_metabolanalyst2, "Tidy_data/XCMS_metadata_for_metaboanalyst.csv")
  
  return(paste("Peak intensity tables suitable for SIMCA + metaboanalyst saved as .csv to Untargeted_metabolomics_workflow/Tidy_data"))
  
}

# RETRIEVE TIDY PEAK TABLE FOR USE IN ANALYSIS

get_peak_table <- function(MStype){
  
  files <- tibble(list_of_files = list.files("Tidy_data")) %>%
    filter(str_detect(list_of_files, "Data_for_metaboanalyst_2factor") == TRUE) %>%
    filter(str_detect(list_of_files, MStype) == TRUE)
  
  file_path <- paste("Tidy_data/", files$list_of_files[1], sep="")
  
  file_to_import <- read_csv(file_path)
  
  paste("The function found", file_path, "and imported it for you", sep = " ")
  
  return(file_to_import)
  
  
}

# RETRIEVE METADATA TABLE

get_metadata <- function(MStype){
  
  files <- tibble(list_of_files = list.files("Tidy_data")) %>%
    filter(str_detect(list_of_files, "metadata") == TRUE) %>%
    filter(str_detect(list_of_files, MStype) == TRUE)
  
  file_path <- paste("Tidy_data/", files$list_of_files[1], sep="")
  paste("The function found", file_path, "and imported it for you", sep = " ")
  
  file_to_import <- read_csv(file_path)
  
  return(file_to_import)
  
}

# RUN INITIAL PCA

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

# DRAW SCORES PLOT(S) FROM INITIAL PCA MODEL

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

# CLEAN DATA FOR MUMA (PCA AND OPLSDA)

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

# FORMAT GRAPHS FROM MUMA FOR PRESENTATION/ PUBLICATION

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
