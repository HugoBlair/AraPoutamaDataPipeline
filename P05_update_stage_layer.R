#############################################
### P5_update_stage_layer.R               ###
#############################################

# Code to move data from raw layer into staging layer
# and perform any necessary transformations

# (Combined seperate tables into one)


#############################################
### Load Libraries, Variables etc.      #####
#############################################

set.seed(0)
library(lubridate)
library(sqldf)
library(dplyr)
library(tidyr)
library(readxl)
library(dplyr)
library(purrr)


#############################################
### Update stage tables                   ###
#############################################

####################################
## Import Data as Separate Tables ##
####################################

# Move data from raw to stage

df_names <-  list(
  "Raw_DHBs_all_team_types",
  "Raw_NGOs_All_team_types",
  "Raw_DHB_MH_teams",
  "Raw_DHB_AOD_teams",
  "Raw_NGO_MH_teams",
  "Raw_NGO_AOD_teams",
  "Raw_Forensic_teams",
  "Raw_Exceptions",
  "Raw_No_contract_DHB"
)

# Loop through the list of data frame names
for (df_name in df_names) {
  # Replace "stage" with "raw" in the name
  new_name <- gsub("Raw", "Stage", df_name)
  
  # Use assign to create a new dataframe with the new name
  assign(new_name, get(df_name))
}


###########################################################################
# Simulating ethnicities, gender field (none given in deidentified data)  #
###########################################################################

dataframes <- list(
  Stage_DHBs_all_team_types,
  Stage_NGOs_All_team_types,
  Stage_DHB_MH_teams,
  Stage_DHB_AOD_teams,
  Stage_NGO_MH_teams,
  Stage_NGO_AOD_teams,
  Stage_Forensic_teams,
  Stage_Exceptions,
  Stage_No_contract_DHB
)


ethnicities <- c("Maori", "Non-Maori, Non-Pacific", "Pasific", "Other")
ethnicitiesProbabilities <- c(0.4, 0.3, 0.2, 0.1) 
for (i in 1:length(dataframes)) {
  n <- nrow(dataframes[[i]])
  dataframes[[i]]$Ethnicity <- sample(ethnicities, size = n, replace = TRUE, prob = ethnicitiesProbabilities)
}


genders <- c("Male","Female","Other")
gendersProbabilities <- c(0.5,0.45,0.05)
for (i in 1:length(dataframes)) {
  n <- nrow(dataframes[[i]])
  dataframes[[i]]$Gender <- sample(genders, size = n, replace = TRUE, prob = gendersProbabilities)
}


###############################
### Add Extra Columns       ###
###############################

##################################
# Add whether NGO or DHB Column #
#################################
DHB <- list("Stage_DHBs_all_team_types", "Stage_DHB_MH_teams", "Stage_DHB_AOD_teams")
NGO <- list("Stage_NGOs_All_team_types", "Stage_NGO_MH_teams", "Stage_NGO_AOD_teams")
DHB_No_Contract <- list("Stage_No_contract_DHB")
Forensic <- list("Stage_Forensic_teams")
Exception <- list("Stage_Exceptions")

# Function to add team_type column to the actual dataframes by name
add_team_type <- function(df_names, type_name) {
  for (df_name in df_names) {
    # Retrieve the dataframe by name, add the team_type column, and assign it back
    df <- get(df_name)                # Get the dataframe
    df$team_type <- type_name         # Add the team_type column
    assign(df_name, df, envir = .GlobalEnv)  # Assign it back to the original name
  }
}

# Apply the function to each list of dataframes
add_team_type(DHB, "DHB")
add_team_type(NGO, "NGO")
add_team_type(DHB_No_Contract, "DHB_No_Contract")
add_team_type(Forensic, "Forensic")
add_team_type(Exception, "Exception")

####################################################### #
# Add Organisation_DHB_Name Name/Organisation_NGO_Name  #
#########################################################

DHB_tables <- list("Stage_DHBs_all_team_types", "Stage_DHB_MH_teams", "Stage_DHB_AOD_teams", "Stage_No_contract_DHB", "Stage_Forensic_teams", "Stage_Exceptions")
NGO_tables <- list("Stage_NGOs_All_team_types", "Stage_NGO_MH_teams", "Stage_NGO_AOD_teams")

# Function to copy Organisation_Name to the specified column for each list
add_organisation_name <- function(df_names, new_col_name) {
  for (df_name in df_names) {
    # Retrieve the dataframe by name
    df <- get(df_name)
    
    # Create the new column as a copy of Organisation_Name
    df[[new_col_name]] <- df$ORGANISATION_NAME
    
    # Reassign the modified dataframe back to the original name
    assign(df_name, df, envir = .GlobalEnv)
  }
}

# Apply the function to Organisation_DHB_Name list
add_organisation_name(DHB_tables, "Organisation_DHB_Name")

# Apply the function to Organisation_NGO_Name list
add_organisation_name(NGO_tables, "Organisation_NGO_Name")



##############################
### Add Meatdata           ###
##############################

# Read the codeset
doc <- read_docx("HISO-10023.3-2024-PRIMHD-Code-Set-Standard.docx")


# Get the number of tables
num_tables <- docx_tbl_count(doc)

#save each table to a list entry
tables <- list()
for (i in 1:num_tables) {
  tables[[i]] <- docx_extract_tbl(doc, i)
}

# open a df 
all_code_descriptions <- data.frame(Code = character(), Description = character(), 
                                    UsedForComment = character(), stringsAsFactors = FALSE)
#save each code description to a row
for (tbl in tables) {
  if (all(c("Code", "Description", "Used.for.Comment") %in% colnames(tbl))) {
    selected_tbl <- tbl %>% select(Code, Description, `Used.for.Comment`)
    all_code_descriptions <- rbind(all_code_descriptions, selected_tbl)
  }
}


#############################
### Create One Big Table ####
#############################


# Create a list of the dataframe names
df_names <- list(Stage_DHBs_all_team_types, Stage_NGOs_All_team_types, Stage_DHB_MH_teams, Stage_DHB_AOD_teams, 
                 Stage_NGO_MH_teams, Stage_NGO_AOD_teams, Stage_Forensic_teams, Stage_Exceptions, Stage_No_contract_DHB)

# Use bind_rows to combine all tables, filling missing columns with NA
combined_table <- bind_rows(df_names, .id = "source_table")


# Drop the 'source_table' column and remove duplicate rows
Stage_Waiting_Times_OBT <- combined_table %>%
  select(-source_table) %>%
  distinct()


