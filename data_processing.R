library("aws.s3")

#viewing stored data files
data.table::rbindlist(get_bucket(bucket = "ara-poutama-data"))

#saving data file to disc
datafile <= tempfile()
save_object(object = "s3://ara-poutama-data/df_data_scd2.csv", file = tempfile)
read.csv(datafile)