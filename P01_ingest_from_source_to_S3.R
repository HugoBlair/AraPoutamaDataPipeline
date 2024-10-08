library("aws.s3")

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

#Accessing AWS user
#This user has been created with read/write access to a single bucket only.
#It does not have the ability to create or delete buckets.

# Load configuration
config <- config::get(file = "config.yml")

# Set AWS credentials
Sys.setenv(
  "AWS_ACCESS_KEY_ID" = config$aws$AWS_ACCESS_KEY_ID,
  "AWS_SECRET_ACCESS_KEY" = config$aws$AWS_SECRET_ACCESS_KEY,
  "AWS_DEFAULT_REGION" = config$aws$AWS_DEFAULT_REGION
)

bucket <- "ara-poutama-data"
file_name <- "df_data_scd2.csv"

# Ensure the file exists before attempting to upload
if (file.exists(file_name)) {
  # Upload the file to S3
  put_object(
    file = file_name,
    object = file_name,
    bucket = bucket
  )
  
  # Check if the upload was successful
  if (object_exists(object = file_name, bucket = bucket)) {
    print(paste("File", file_name, "successfully uploaded to", bucket))
    
    #remove the local file
    file.remove(file_name)
  } else {
    print(paste("Failed to upload", file_name, "to", bucket))
  }
} else {
  print(paste("File", file_name, "not found in the current directory"))
}





