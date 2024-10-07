#############################################
### P6_update_stage_layer.R               ###
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

# Simulating for now, pull from local excel

## Import Data
file_path <- "PRIMHD_Data.xlsx"


# Define the sheet names and the corresponding data frame names
sheet_names <- c("table1", "table2", "table3", "table4", "table5", "table6", "table7", "table8", "table9")
df_names <- c("DHBs_all_team_types", "NGOs_All_team_types", "DHB_MH_teams", "DHB_AOD_teams", 
              "NGO_MH_teams", "NGO_AOD_teams", "Forensic_teams", "Exceptions", "No_contract_DHB")

# Loop through the sheets and assign them to data frames with desired names
for (i in seq_along(sheet_names)) {
  assign(df_names[i], read_excel(file_path, sheet = sheet_names[i]))
}


###########################################################################
# Simulating ethnicities, gender field (none given in deidentified data)  #
###########################################################################

dataframes <- list(
  DHBs_all_team_types,
  NGOs_All_team_types,
  DHB_MH_teams,
  DHB_AOD_teams,
  NGO_MH_teams,
  NGO_AOD_teams,
  Forensic_teams,
  Exceptions,
  No_contract_DHB
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
df_names <- list(DHBs_all_team_types, NGOs_All_team_types, DHB_MH_teams, DHB_AOD_teams, 
                 NGO_MH_teams, NGO_AOD_teams, Forensic_teams, Exceptions, No_contract_DHB)

# Use bind_rows to combine all tables, filling missing columns with NA
combined_table <- bind_rows(df_names, .id = "source_table")


# Drop the 'source_table' column and remove duplicate rows
Waiting_Times_OBT <- combined_table %>%
  select(-source_table) %>%
  distinct()


