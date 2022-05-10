# Elizabeth Parker May 2022

# Untargeted metabolomics workflow stage 5 (Extract + format peak table + metadata)
# Inter operable code to tidy the data from the in-house macro, in order to obtain a peak table

# Check that your project is saved in the working directory "Untargeted_metabolomics_workflow" and that this folder
# contains folders called "Data" containing the files below
# "Tidy_data" (empty for now, this is where your peak intensity tables will be stored)

# The macro saves a number of sheets within the excel file. For the peak table, we want the sheet called "% tot ion1"
# In the macro output, select the "% tot ion1" sheet and then File > Save As > Choose CSV (Comma Delimited)(*.csv) for file type and
# do not change the name of the file (it should be named after your first sample with your initials at the beginning e.g.
# "EP-061118-001a")
# Save the .csv file in the Data folder of this project (Untargeted_metabolomics_Workflow/Data)

# You also need to save the MassLynx sample list ("masslynxfilelists.csv" should have 
# column headings: Filename, Filetext, MSFile, MSTuneFile, InletFile, Bottle, InjectVolume) in the Data folder of this project

# You will need a file in the Data folder of this project called "treatments.csv"
# This should have a column "Filetext" with the unique descriptor from "Filetext" in masslynxfilelists.csv
# You can then add columns with class information called "Treatment1", "Treatment2"


# Load required packages
packages_to_load <- c("tidyr", "tibble", "dplyr", "readr", "stringr")
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

file_prefix = "EP-061118-"
mode = "esi_pos_sens"


# This function will find your file for you as long as it's in the Data folder, then it will make a table that is ready for SIMCA
tidy_for_SIMCA <- function(file_prefix){

data_filename <- paste("Data/", file_prefix, "001a.csv", sep = "")
macro_TIC <- read_csv(data_filename, name_repair = "unique") %>%
  rename("mz_bin" = ...1)
sample_list <- read_csv("Data/masslynxfilelists.csv") %>%
  filter(MSFile == mode)
treatment_list <- read_csv("Data/treatments.csv")

treat_names <- tibble(treats = colnames(treatment_list)) %>%
  filter(treats != "Filetext")

sample_names <- str_replace(colnames(macro_TIC)[2:length(colnames(macro_TIC))], "a", "")
temp <- as_tibble(t(macro_TIC))
colnames(temp) <- as.character(macro_TIC$mz_bin)
tidy_data <- temp[-1,] %>%
  add_column(Filename = sample_names, .before = TRUE)

metadata <- tidy_data %>% select(Filename) %>%
  left_join(sample_list) %>%
  left_join(treatment_list) %>%
  select(Filename, Filetext, treat_names$treats)

if_else(
  length(unique(metadata$Filetext)) == length(metadata$Filetext), 
  paste("Sample names are unique"), 
  paste("Sample names are not unique, check samplelist"))

data_for_SIMCA <- tidy_data %>%
  left_join(sample_list %>% select(Filename, Filetext)) %>% 
  select(Filename, Filetext, any_of(as.character(macro_TIC$mz_bin)))

write_csv(data_for_SIMCA, "Tidy_data/Macro_data_for_SIMCA.csv")

data_for_metaboanalyst_1 <- tidy_data %>%
  left_join(metadata %>% rename("Sample" = Filetext)) %>%
  select(Sample, treat_names$treats[1], any_of(as.character(macro_TIC$mz_bin)))

write_csv(data_for_metaboanalyst_1, "Tidy_data/Macro_data_for_metaboanalyst_1factor.csv")

data_for_metaboanalyst2 <- tidy_data %>%
  left_join(metadata %>% rename("Sample" = Filetext)) %>%
  select(Sample, any_of(as.character(macro_TIC$mz_bin)))

metadata_for_metabolanalyst2 <- metadata %>%
  select(Filetext, treat_names$treats) %>%
  rename("Sample" = Filetext)

write_csv(data_for_metaboanalyst2, "Tidy_data/Macro_data_for_metaboanalyst_2factor.csv")
write_csv(metadata_for_metabolanalyst2, "Tidy_data/Metadata_for_metaboanalyst_2factor.csv")


return(paste("Tidy versions of data and metadata saved to the Tidy_data folder - can be used for SIMCA or metaboanalyst"))

}

# !!! this is where you need to tell the code the prefix of your file (so your initials)
# e.g. if your files are called "EP-061118-001a" you need to put file_prefix = "EP-061118-" in here
tidy_for_SIMCA(file_prefix = "EP-061118-")

