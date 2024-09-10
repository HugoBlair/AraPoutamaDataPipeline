install.packages("aws.s3", repos = "https://cloud.R-project.org")
library("aws.s3")

#Accessing AWS user
#This user has been created with read/write access to a single bucket only.
#It does not have the ability to create or delete buckets.
bucket = "ara-poutama-data"
put_object(
  file = file.path(tempdir(),"df_data_scd2.csv"),
  object = "df_data_scd2.csv",
  bucket = bucket
)
file.remove(df_data_scd2.csv)



