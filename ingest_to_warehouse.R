install.packages("aws.s3", repos = "https://cloud.R-project.org")
library("aws.s3")

#Accessing AWS user
#This user has been created with read/write access to a single bucket only.
#It does not have the ability to create or delete buckets.

bucketlist()


