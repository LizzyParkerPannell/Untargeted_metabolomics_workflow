
# Elizabeth Parker December 2022
# Prep, libraries and functions for untargeted metabolomics workflow
# See https://untargeted-metabolomics-workflow.netlify.app/ for guidance


# auto install packages
RequiredPackages <- c("tidyr", "tibble", "dplyr", "readr", "stringr", "ggplot2", "pcaMethods", "muma", "forcats", "vegan")
  for (i in RequiredPackages) { #Installs packages if not yet installed
  if (!require(i, character.only = TRUE)) install.packages(i)
  }


# PACKAGES AND CITATIONS
  # Load required packages
  lapply(RequiredPackages, require, character.only = TRUE)  
  
  # Don't forget to cite these packages in your thesis/ manuscript (this code will automatically make a table of text citations for you)
  cite_packages <- tibble(Package = "1", Citation = "1")
  for (i in 1:length(RequiredPackages)){
    j <- RequiredPackages[i]
    
    k <- citation(j)$textVersion
    
    cite_packages[i, 1] <- j
    cite_packages[i, 2] <- k
    
  }
  
  cite_packages

# TIDY DATA FROM MASSUP (MALDI AND DIMS)

tidy_MALDI_peak_table <- function(file_path){
  
  #import saved peak tables that you exported from MassUp
  # get list of files to import
  files_from_Massup <- data.frame(directories = list.files(file_path)) %>%
    filter(directories != "treatments.csv") %>%
    filter(directories != "samplelist.csv")
  
  files_to_import <- tibble(Filename = "")
  
  for (x in 1:length(files_from_Massup$directories)){
    
    a <- tibble(Filename = paste(file_path, files_from_Massup$directories[x], (list.files(paste(file_path, files_from_Massup$directories[x], sep="/"))), sep = "/")) %>%
      mutate(Filename = paste(Filename, "/spectrum1.csv", sep = ""))
    
    files_to_import <- files_to_import %>%
      full_join(a) %>%
      filter(Filename != "") %>%
      mutate()
    
  }
  
  
  peak_table <- tibble(mz = 0.1)
  
  for(i in 1:length(files_to_import$Filename)){
    
    old_table <- peak_table
    
    a <- read.csv(files_to_import$Filename[i], sep = ",") %>%
      rename("mz" = 1)
    
    colnames(a)[2] <- files_to_import$Filename[i]
    
    peak_table <- old_table %>%
      full_join(a)
    
  }
  
  
  
  # clean up column names so that they are the file not the whole path
  file_names <- tibble(Filename = colnames(peak_table)) %>%
    transmute(Filename = str_replace(Filename, file_path, "")) %>%
    transmute(Filename = str_replace(Filename, ".csv", "")) %>%
    transmute(Filename = str_replace(Filename, "/spectrum1", "")) %>%
    transmute(Filename = str_replace(Filename, "/\\s*(.*?)\\s*/", "")) ### need to remove stuff between / to get it down to just sample name and not path
  
  tidy_data <- peak_table %>%
    filter(mz != 0.1)
  
  colnames(tidy_data) <- file_names$Filename
  
  #import treatment list
  treatments <- read.csv(paste(file_path,"/treatments.csv", sep="")) %>%
    mutate(Filetext = as.character(Filetext)) %>%
    distinct()
  treat_names <- tibble(treats = colnames(treatments)) %>%
    filter(treats != "Filetext")
  
  #import sample list
  sample_list <- read.csv(paste(file_path, "/samplelist.csv", sep=""))
  
  temp <- as_tibble(t(peak_table))
  colnames(temp) <- as.character(peak_table$mz)
  tidy_data <- temp %>%
    filter(is.na(`0.1`)) %>%
    select(-`0.1`) %>%
    add_column((file_names %>% filter(Filename != "mz")), .before = TRUE)
  
  metadata <- tidy_data %>% select(Filename) %>%
    left_join(sample_list) %>% 
    left_join(treatments) %>%
    select(Filename, Filetext, treat_names$treats) %>%
    distinct()
  
  data_for_SIMCA <- tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, treat_names$treats, any_of(as.character(peak_table$mz))) %>%
    mutate(Sample = str_replace_all(Sample, " ", "_"))
  
  data_for_metaboanalyst_1 <- tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, treat_names$treats[1], any_of(as.character(peak_table$mz))) %>%
    mutate(Sample = str_replace_all(Sample, " ", "_"))
  
  data_for_metaboanalyst_2 <- tidy_data %>%
    left_join(metadata) %>%
    rename("Sample" = Filetext) %>%
    select(Sample, any_of(as.character(peak_table$mz))) %>%
    mutate(Sample = str_replace_all(Sample, " ", "_"))
  
  metadata_for_metabolanalyst2 <- metadata %>%
    select(-Filename) %>%
    rename("Sample" = Filetext)
  
  
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
