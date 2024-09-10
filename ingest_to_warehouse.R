library("aws.s3")

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



