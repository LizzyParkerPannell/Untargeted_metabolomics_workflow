# Elizabeth Parker May 2022

# Untargeted metabolomics workflow stage 5 (Extract + format peak table + metadata)
# Inter operable code to tidy pre-processed data from XCMS online, in order to obtain a peak table

# XCMS online will download a .zip file. Save this .zip file in the "Untargeted_metabolomics_workflow/Data" folder
# Give it a name that will help you identify your experiment (e.g. "2022-05-08_LCMS_barley_exp4_org_pos")
# Make sure to extract all from this .zip files once you have it in the right folder

# You also need to save the MassLynx sample list ("samplelist.csv" should have column headings: 
# Filename, Filetext, MSFile, MSTuneFile, InletFile, Bottle, InjectVolume) in the "Untargeted_metabolomics_workflow/Data" folder

# You will also need a file in the "Untargeted_metabolomics_workflow/Data" folder of this project called "treatments.csv"
# This should have a column "Filetext" with the unique descriptor from "Filetext" in samplelist.csv
# You can then add columns with class/ grouping information e.g. "Treatment1", "Treatment2"

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


# This function contains code to find the diffreport file from the xcms results and then tidy it 
#ready for metaboanalyst or SIMCA (or further analysis in R)
# First you need to load the function by running this piece of code:
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


# Then you can run the function on your data by changing "folder = " to be the name you gave your unzipped xcms download folder
# Change "prefix = " to the initials used when you ran MassLynx (e.g. Joe Bloggs would have files called JB-051222-001.mzML etc)
# Change "main_treatment = " to the treatment you want for 1factor analysis e.g. if you will be doing 1factor analysis in metaboanalyst
tidy_xcms_online_peak_table(
  folder = "2022-05-23_aq_pos_T3NMonly_DSvWW",
  prefix = "ep",
  main_treatment = "Drought")
