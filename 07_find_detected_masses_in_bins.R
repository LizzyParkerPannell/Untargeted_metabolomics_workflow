
# Elizabeth Parker May 2022

# Untargeted metabolomics workflow stage 7 (extract detected masses from macro)
# Inter operable code to tidy the data from the in-house macro, in order to detected masses

# Check that your project is saved in the working directory "Untargeted_metabolomics_workflow" and that this folder
# contains a folder called "Tidy_data" (empty for now, this is where your peak intensity tables will be stored)
# and another folder called "Data" containing the files below:

# The macro saves a number of sheets within the excel file. # Save "mass alloc" sheets from the macro output in Excel as .csv files. Save them in the "Untargeted_metabolomic_workflow/Data" folder
# (these sheets are a mess so this code will format them and extract the detected masses you want)
# Depending on how many samples you have, you may have 1, 2 or 3 mass_alloc files in the macro output. Save all 3 as separate .csv files
# with the suffix "mass_alloc1.csv", "mass_alloc2.csv" etc

# Save the .csv file in the Data folder of this project (Untargeted_metabolomics_Workflow/Data)

# If you completed step 6 in R, you will have "Untargeted_metabolomics_workflow/OPLS-DApareto/OPSDA_discriminating_variable.csv"
# which will be used to search for bins of interest in the macro data and give you detected masses for these

# Otherwise (e.g. you used SIMCA or Metaboanalyst), you need to save a file with the above filepath and at least one column named "mz"



#--- CITING

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





# this function will look in "Untargeted_metabolomic_workflow/Data" for any files that contain "mass_alloc"

tidy_mass_alloc <- function(identifier){
  
  #import mass_alloc files (as many as are saved in Untargeted_metabolomic_workflow/Data)
  # get list of files to import
  files_to_import <- data.frame(Filename = list.files("Data")) %>%
    mutate(use_file = str_detect(Filename, "mass_alloc")) %>%
    filter(use_file == TRUE) %>%
    mutate(path = "Data/") %>%
    transmute(Filename = paste(path, Filename, sep="")) %>%
    select(Filename)
  
  
  #function to tidy each table
  tidy_each_table <- function(mass_alloc, identifier){
    
    m1_filenames <- as.data.frame(colnames(mass_alloc)) %>%
      rename(Names = 1) %>%
      filter(str_detect(Names, identifier) == TRUE)
    
    test <- mass_alloc %>%
      select(as.vector(m1_filenames$Names))
    
    old_table <- test
    
    for(i in 1:length(colnames(test))){
      
      new_table <- old_table
      
      fill_with <- colnames(test[i])
      
      new_table[ , i] <- fill_with
      
      old_table <- new_table
      
    }
    
    updated <- mass_alloc
    
    for(j in 1:length(colnames(old_table))){
      
      whole_table <- updated
      
      fill_with <- colnames(old_table[j])
      
      whole_table[which(colnames(whole_table) == colnames(old_table[j]))] <- fill_with
      
      updated <- whole_table
      
      
    }
    
    mass_alloc <- updated
    
    return(mass_alloc)
    
  }
# identifier is the initials in your sample filenames e.g."EP"
# mass_alloc is the title of the mass_alloc file e.g. "mass_alloc1"
  
  #function to rearrange each table into "long" data frame (rather than wide)
  long_from_short <- function(mass_alloc, identifier){
    
    get_filenames <- as.data.frame(colnames(mass_alloc)) %>%
      rename(Names = 1) %>%
      filter(str_detect(Names, identifier) == TRUE)
    
    filenames <- mass_alloc %>%
      select(get_filenames$Names)
    
    new_data <- mass_alloc %>%
      select(1:9)
    
    colnames(new_data) <- c("Sample", "Bin", "Mass.detected", "Mass.in.list", "Acc.mass", "Formula", "Compound", "Ion", "TIC")
    
    for(i in 1:length(colnames(filenames))){
      
      old_data <- new_data
      
      j <- paste(get_filenames$Names[i]) #colname of first col we want
      k <- grep(j, colnames(mass_alloc)) #index of first col we want
      l <- paste(colnames(mass_alloc[k + 8])) #colname of last col we want
      
      add_data <- mass_alloc %>%
        select(j:l)
      
      colnames(add_data) <- c("Sample", "Bin", "Mass.detected", "Mass.in.list", "Acc.mass", "Formula", "Compound", "Ion", "TIC")
      
      new_data <- bind_rows(old_data, add_data)
      
    }
    
    return(new_data)
    
  }
  
  all_mass_alloc <- tibble(Sample = "test")
  
  for(i in 1:length(files_to_import$Filename)){
    
    old_table <- all_mass_alloc
    
    a <- read.csv(files_to_import$Filename[i])
    
    b <- tidy_each_table(a, identifier = identifier)
    
    c <- long_from_short(b, identifier = identifier)
    
    all_mass_alloc <- old_table %>%
      full_join(c)
    
  }
  
  write_csv(all_mass_alloc, "Tidy_data/macro_mass_alloc_cleaned_data.csv")
  
  return(all_mass_alloc)
  }

# run the function
all_mass_alloc <- tidy_mass_alloc(identifier = "EP")


find_detected_for_bins_of_interest <- function(){
  
  bins_of_interest <- read.csv("OPLS-DApareto/OPLSDA_discriminating_variables.csv") %>%
    mutate(mz = str_replace_all(mz, "_", ""))%>%
    mutate(Bin = as.numeric(mz)) %>%
    mutate(min_expected = Bin - 0.1) %>%
    mutate(max_expected = Bin + 0.1)
  
  # function to split the long strings of detected masses that the macro churns out (in Mass.detected column)
  split_detected_masses <- function(new_results, Bin_ID){
    detected_masses <- new_results %>%
      filter(Bin == Bin_ID) %>%
      select(Bin, Mass.detected) %>%
      mutate(masses_count = str_count(Mass.detected, "\\.")) %>%
      #mutate(masses = str_split(Mass.detected, "\\.", n=masses_count)) %>%
      mutate(mass_locate = str_locate_all(Mass.detected, "\\.")) %>%
      distinct()
    
    
    test <- data.frame((str_split_fixed(detected_masses$mass_locate, "\\,", n=detected_masses$masses_count+1)), detected_masses$masses_count, detected_masses$Bin) %>%
      transform(X1 = str_sub(X1, -1)) %>%
      transform(masses_count = paste("X", as.numeric(detected_masses.masses_count)+1, sep="")) 
    
    for(i in 1:length(test$masses_count)){
      
      old_data <- test
      
      j <- paste(test$masses_count[i]) #colname of col we want
      k <- grep(j, colnames(test)) #index of first col we want
      
      old_data[i,k] <- ""
      
      test <- old_data
      
    }
    
    all_detected_masses <- data.frame("test_bin") %>%
      rename(Bin = 1) %>%
      mutate(mz = 1) %>%
      mutate_all(as.character)
    
    for(i in 1:length(test$masses_count)){
      
      old_detected <- all_detected_masses  
      
      detected_masses$Bin. <- paste(as.character(detected_masses$Bin), ".", sep="")
      
      s = detected_masses$Mass.detected[i] #string that we want splitting
      k = detected_masses$masses_count[i] #number of masses there should be (based on decimal points earlier)
      b = as.character(detected_masses$Bin.[i]) #bin number we're looking for (includes a decimal point)
      b1 = as.character(detected_masses$Bin[i] + 0.1)
      b2 = as.character(detected_masses$Bin[i] - 0.1)
      
      t1 <- as.data.frame(str_locate_all(s, b)) #indices of the substrings we want (start and end)
      t2 <- as.data.frame(str_locate_all(s, b1))
      t3 <- as.data.frame(str_locate_all(s, b2))
      
      l <- str_length(s) #index for the end of the string
      
      t <- t1 %>%
        full_join(t2) %>%
        full_join(t3) %>%
        arrange(start)
      #nb "end" column here means end of the pre-decimal place string NOT end of the substring we want!
      
      starts <- t$start
      
      temp <- data.frame(starts - 1) %>%
        rename(ends = 1) %>%
        filter(ends != 0) %>%
        add_row(ends = l)
      
      ends <- temp$ends
      
      new_strings <- data.frame(Strings = "remove")
      
      for(y in 1:length(starts)){
        
        old_strings <- new_strings
        
        to_add <- as.data.frame(substr(s, starts[y], ends[y])) %>%
          rename(Strings = 1)
        
        new_strings <- bind_rows(old_strings, to_add)
        
      }
      
      detected_mz <- new_strings %>%
        filter(Strings != "remove") %>%
        filter(str_detect(Strings, "\\.") == TRUE) %>%
        mutate(Bin = b) %>%
        rename(mz = Strings)
      
      all_detected_masses <- full_join(old_detected, detected_mz)
      
    }
    
    return(all_detected_masses %>%
             filter(Bin != "test_bin") %>%
             transform(Bin = str_replace(Bin, "\\.", ""))
           
    )
  }
  
  # filter the macro data by the bins you're interested in (from the above csv)
  old_matches <- all_mass_alloc %>%
    filter(Bin == 0)
  
  for(i in 1:length(bins_of_interest$Bin)){
    
    new_matches <- old_matches
    
    filtered_data <- all_mass_alloc %>%
      filter(Bin > bins_of_interest$min_expected[i] & Bin < bins_of_interest$max_expected[i])
    
    old_matches <- full_join(new_matches, filtered_data)
    bins_of_interest$Bin[i] <- filtered_data$Bin[1]
  }
  
  #####
  
  #if there are no matches or a problem with the match here - an NA will come up in bins_of_interest$$Bin
  # this will halt the code later on
  # am trying to add in some defensive code to get around this
  
  #####
  
  problem_bins <- bins_of_interest %>%
    filter(is.na(Bin))
  
  paste("There were problems with the following bins:", problem_bins)
  
  bins_of_interest <- bins_of_interest %>%
    anti_join(problem_bins)
  
  #this gets round it for now
  
  
  # set up a loop to use the function to split strings for each of the bins you are interested in
  
  new_results <- old_matches
  
  old <- bins_of_interest %>%
    add_column(Detected_mass = 0.1)
  
  # if there is an error, it's possible to restart this next bit part way through by checking in "old" dataframe which index it has #stopped at (should read "0.1" in Detected_mass)
  # and putting the next index in the for loop (to replace 1)
  
  for(i in 1:length(bins_of_interest$Bin)){
    
    new <- old
    
    BIN <- bins_of_interest$Bin[i]
    
    bin <- split_detected_masses(new_results, Bin_ID = bins_of_interest$Bin[i]) %>%
      transform(mz = as.numeric(mz))
    
    hist(bin$mz, title = paste("mz", BIN))
    
    new$Detected_mass[i] <- median(bin$mz)
    
    old <- new
    
  }
  
  # table with median detected mass for each expected bin
  detected_masses_for_expected_mz <- old
  
  return(detected_mass_for_expected_mz)
}


#still bugs e.g. when detected masses contain the same digits as the bin of interest but past the decimal point
