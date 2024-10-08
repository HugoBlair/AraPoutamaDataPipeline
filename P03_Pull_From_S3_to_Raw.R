#############################################
### P3_pull_from_S3_to_raw.R              ###
#############################################

# Code to move data from S3 bucket into
# raw layer of data platform

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
library("aws.s3")
library(lubridate)

#############################################
### Pull from S3 into dataframe         #####
#############################################

# Load configuration
config <- config::get(file = "config.yml")

# Set AWS credentials
Sys.setenv(
  "AWS_ACCESS_KEY_ID" = config$aws$AWS_ACCESS_KEY_ID,
  "AWS_SECRET_ACCESS_KEY" = config$aws$AWS_SECRET_ACCESS_KEY,
  "AWS_DEFAULT_REGION" = config$aws$AWS_DEFAULT_REGION
)

#viewing stored data files
data.table::rbindlist(get_bucket(bucket = "ara-poutama-data"))

load_data_from_s3 <- function() {
  bucket <- "ara-poutama-data"
  file_name <- "df_data_scd2.csv"
  
  
  if (aws.s3::object_exists(object = file_name, bucket = bucket)) {
    s3_object <- aws.s3::get_object(object = file_name, bucket = bucket)
    raw_data <- read.csv(text = rawToChar(s3_object))
    return(raw_data)
  } else {
    stop("File not found in S3 bucket")
  }
}

# use the s3 URI
#df = s3read_using(FUN = read.csv, object = "s3://ara-poutama-data/df_data_scd2.csv")   

df = load_data_from_s3()


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
