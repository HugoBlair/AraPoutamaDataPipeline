#############################################
### P1_ingest_from_source_to_S3.R         ###
#############################################

# Code to ingest data from source

#############################################
### Ingest from Source                    ###
#############################################

# Simulating for now, pull from local excel

## Import Data
file_path <- "PRIMHD_Data.xlsx"


# Define the sheet names and the corresponding data frame names
sheet_names <- c("table1", "table2", "table3", "table4", "table5", "table6", "table7", "table8", "table9")
df_names <- c("Raw_DHBs_all_team_types", "Raw_NGOs_All_team_types", "Raw_DHB_MH_teams", "Raw_DHB_AOD_teams", 
              "Raw_NGO_MH_teams", "Raw_NGO_AOD_teams", "Raw_Forensic_teams", "Raw_Exceptions", "Raw_No_contract_DHB")

# Loop through the sheets and assign them to data frames with desired names
for (i in seq_along(sheet_names)) {
  assign(df_names[i], read_excel(file_path, sheet = sheet_names[i]))
}


#############################################
### Write to S3                           ###
#############################################


