# Elizabeth Parker May 2022

# Untargeted metabolomics workflow stage 5 (Extract + format peak table + metadata)
# Inter operable code to tidy MALDI pre-processed data from MassUp, in order to obtain a peak table

# From MassUp you can export a .csv files for the peak table of each sample (consensus spectrum of technical reps)
# In MassUp do not change the names of the files (each should have the filename of the third technical rep for that sample with your 
# initials at the beginning e.g. "EP-061118-001")
# The .csv files should be saved in the MALDI_data folder of this project (Untargeted_metabolomics_Workflow/MALDI_data)

# You also need to save the MassLynx sample list ("samplelist.csv" should have column headings: 
# Filename, Filetext, MSFile, MSTuneFile, InletFile, Bottle, InjectVolume) in the MALDI_data folder of this project

# You will need a file in the MALDI_data folder of this project called "treatments.csv"
# This should have a column "Filetext" with the unique descriptor from "Filetext" in MALDI_samplelist.csv
# You can then add columns with class/ grouping information e.g. "Treatment1", "Treatment2"

# You need to make sure you have a folder called "Untargeted_metabolomics_workflow/Tidy_data"

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


tidy_MALDI_peak_table <- function(){

#import saved peak tables that you exported from MassUp
# get list of files to import
files_to_import <- data.frame(Filename = list.files("MALDI_data")) %>%
  filter(Filename != "treatments.csv") %>%
  filter(Filename != "samplelist.csv") %>%
  mutate(path = "MALDI_data/") %>%
  transmute(Filename = paste(path, Filename, sep=""))

peak_table <- tibble(mz = 0.1)

for(i in 1:length(files_to_import$Filename)){
  
  old_table <- peak_table
  
  a <- read.csv(files_to_import$Filename[i], sep = ";") %>%
    rename("mz" = m.z)
  
  colnames(a)[2] <- files_to_import$Filename[i]
  
  peak_table <- old_table %>%
    full_join(a)
  
}



# clean up column names so that they are the file not the whole path
file_names <- tibble(Filename = colnames(peak_table)) %>%
  transmute(Filename = str_replace(Filename, "MALDI_data/", "")) %>%
  transmute(Filename = str_replace(Filename, ".csv", ""))
  
tidy_data <- peak_table %>%
  filter(mz != 0.1)

colnames(tidy_data) <- file_names$Filename
  
#import treatment list
treatments <- read.csv("MALDI_data/treatments.csv") %>%
  mutate(Filetext = as.character(Filetext))
treat_names <- tibble(treats = colnames(treatments)) %>%
  filter(treats != "Filetext")

#import sample list
sample_list <- read.csv("MALDI_data/samplelist.csv")

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


write_csv(data_for_SIMCA, "Tidy_data/MALDI_Data_for_SIMCA.csv")
write_csv(data_for_metaboanalyst_1, "Tidy_data/MALDI_Data_for_metaboanalyst_1factor.csv")
write_csv(data_for_metaboanalyst_2, "Tidy_data/MALDI_Data_for_metaboanalyst_2factor.csv")
write_csv(metadata_for_metabolanalyst2, "Tidy_data/MALDI_metadata_for_metaboanalyst.csv")

return(paste("MALDI peak tables suitable for SIMCA + metaboanalyst saved to Tidy_data/MALDI_Data_for_SIMCA.csv"))

}

tidy_MALDI_peak_table()
