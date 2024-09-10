library("aws.s3")
library(lubridate)
library(sqldf)
library(dplyr)
library(tidyr)

#viewing stored data files
data.table::rbindlist(get_bucket(bucket = "ara-poutama-data"))

read_from_s3 <- function(filename, bucket) {
  object <- get_object(object = filename, bucket = bucket)
  read.csv(text = rawToChar(object))
}

# use the s3 URI
df = s3read_using(FUN = read.csv, object = "s3://ara-poutama-data/df_data_scd2.csv")          

# - People with Referrals by Funding_DHB

People_with_Referrals_by_Funding_DHB <- df %>%
  group_by(Funding_DHB) %>%
  summarize(Unique_NHI_Count = n_distinct(NHI_Number_Values))

# - People with Referrals by Referral_First_Team_Type

getwd()

People_with_Referrals_by_Referral_First_Team_Type <- df %>%
  group_by(Referral_First_Team_Type) %>%
  summarize(Unique_NHI_Count = n_distinct(NHI_Number_Values))

# - People with Referrals by Activity_Code

People_with_Referrals_by_Activity_Code <- df %>%
  group_by(Activity_Code) %>%
  summarize(Unique_NHI_Count = n_distinct(NHI_Number_Values))

# - People with Referrals by Domicile_DHB

People_with_Referrals_by_Domicile_DHB <- df %>%
  group_by(Domicile_DHB) %>%
  summarize(Unique_NHI_Count = n_distinct(NHI_Number_Values))

# - People with Referrals by Age Group

People_with_Referrals_by_Age_Group <- df %>%
  group_by(Age_Group) %>%
  summarize(Unique_NHI_Count = n_distinct(NHI_Number_Values))

# - People with Referrals by Sex

People_with_Referrals_by_Sex <- df %>%
  group_by(Sex) %>%
  summarize(Unique_NHI_Count = n_distinct(NHI_Number_Values))

# - People with Referrals by Ethnicity

People_with_Referrals_by_Ethnicity <- df %>%
  group_by(Ethnicity) %>%
  summarize(Unique_NHI_Count = n_distinct(NHI_Number_Values))


### Referrals Long

# Reshape first referral data
df_first <- df %>%
  select(NHI,
         Organisation_Name,
         Funding_DHB,
         Referral_First_ID,
         Referral_First_Start,
         Referral_First_Referred_By,
         Referral_First_Team_Type,
         Referral_First_Team_Code,
         Referral_First_End_Code,
         Activity_ID,	
         Activity_Start_Date,	
         Activity_Code,	
         Age,	
         Age_Group,	
         Domicile_DHB,	
         Sex,	
         Ethnicity,	
         Extracted_Date) %>%
  rename(ID = Referral_First_ID,
         Start = Referral_First_Start,
         Referred_By = Referral_First_Referred_By,
         Team_Type = Referral_First_Team_Type,
         Team_Code = Referral_First_Team_Code,
         End_Code = Referral_First_End_Code) %>%
  mutate(Referral_Type = "First")

# Reshape second referral data
df_second <- df %>%
  select(NHI,
         Organisation_Name,
         Funding_DHB,
         Referral_Second_ID,
         Referral_Second_Start,
         Referral_Second_End_Reason,
         Referral_Second_End_Code,
         Activity_ID,	
         Activity_Start_Date,	
         Activity_Code,	
         Age,	
         Age_Group,	
         Domicile_DHB,	
         Sex,	
         Ethnicity,	
         Extracted_Date) %>%
  rename(ID = Referral_Second_ID,
         Start = Referral_Second_Start,
         End_Reason = Referral_Second_End_Reason,
         End_Code = Referral_Second_End_Code) %>%
  mutate(Referral_Type = "Second")

# Combine the two dataframes
df_combined <- bind_rows(df_first, df_second)

# Ensure all columns are present and order them
df_long <- df_combined %>%
  select(NHI,	Organisation_Name,	Funding_DHB, Referral_Type, ID, Start, Referred_By, Team_Type, Team_Code, End_Reason, End_Code, Activity_ID,	Activity_Start_Date,	Activity_Code,	Age,	Age_Group,	Domicile_DHB,	Sex,	Ethnicity,	Extracted_Date)



# - Total Referrals by Funding_DHB

Total_Referrals_by_Funding_DHB <- df_long %>%
  group_by(Funding_DHB) %>%
  summarize(Unique_Referral_Count = n_distinct(ID))



# - Total Referrals by Activity_Code

Total_Referrals_by_Activity_Code <- df_long %>%
  group_by(Activity_Code) %>%
  summarize(Unique_Referral_Count = n_distinct(ID))

# - Total Referrals by Domicile_DHB

Total_Referrals_by_Domicile_DHB <- df_long %>%
  group_by(Domicile_DHB) %>%
  summarize(Unique_Referral_Count = n_distinct(ID))

# - Total Referrals by Age Group

Total_Referrals_by_Age_Group <- df_long %>%
  group_by(Age_Group) %>%
  summarize(Unique_Referral_Count = n_distinct(ID))

# - Total Referrals by Sex

Total_Referrals_by_Sex <- df_long %>%
  group_by(Sex) %>%
  summarize(Unique_Referral_Count = n_distinct(ID))

# - Total Referrals by Ethnicity

Total_Referrals_by_Ethnicity <- df_long %>%
  group_by(Ethnicity) %>%
  summarize(Unique_Referral_Count = n_distinct(ID))



# - Percentage of Referrals resulting in second referrals by Funding_DHB

Percentage_second_referrals_by_Funding_DHB <- df %>%
  group_by(Funding_DHB) %>%
  summarise(
    Total_First_Starts = n(),
    Non_Null_Second_Starts = sum(!is.na(Referral_Second_Start)),
    Percentage_Non_Null_Second_Starts = (Non_Null_Second_Starts / Total_First_Starts) * 100
  )



# - Percentage of Referrals resulting in second referrals by Referral_First_Team_Type

Percentage_second_referrals_by_Funding_DHB <- df %>%
  group_by(Referral_First_Team_Type) %>%
  summarise(
    Total_First_Starts = n(),
    Non_Null_Second_Starts = sum(!is.na(Referral_Second_Start)),
    Percentage_Non_Null_Second_Starts = (Non_Null_Second_Starts / Total_First_Starts) * 100
  )


# - Percentage of Referrals resulting in second referrals by Activity_Code

Percentage_second_referrals_by_Activity_Code <- df %>%
  group_by(Activity_Code) %>%
  summarise(
    Total_First_Starts = n(),
    Non_Null_Second_Starts = sum(!is.na(Referral_Second_Start)),
    Percentage_Non_Null_Second_Starts = (Non_Null_Second_Starts / Total_First_Starts) * 100
  )

# - Percentage of Referrals resulting in second referrals by Domicile_DHB

Percentage_second_referrals_by_Domicile_DHB <- df %>%
  group_by(Domicile_DHB) %>%
  summarise(
    Total_First_Starts = n(),
    Non_Null_Second_Starts = sum(!is.na(Referral_Second_Start)),
    Percentage_Non_Null_Second_Starts = (Non_Null_Second_Starts / Total_First_Starts) * 100
  )


# - Percentage of Referrals resulting in second referrals by Age Group

Percentage_second_referrals_by_Age_Group <- df %>%
  group_by(Age_Group) %>%
  summarise(
    Total_First_Starts = n(),
    Non_Null_Second_Starts = sum(!is.na(Referral_Second_Start)),
    Percentage_Non_Null_Second_Starts = (Non_Null_Second_Starts / Total_First_Starts) * 100
  )

# - Percentage of Referrals resulting in second referrals by Sex

Percentage_second_referrals_by_Sex <- df %>%
  group_by(Sex) %>%
  summarise(
    Total_First_Starts = n(),
    Non_Null_Second_Starts = sum(!is.na(Referral_Second_Start)),
    Percentage_Non_Null_Second_Starts = (Non_Null_Second_Starts / Total_First_Starts) * 100
  )


# - Percentage of Referrals resulting in second referrals by Ethnicity

Percentage_second_referrals_by_Ethnicity <- df %>%
  group_by(Ethnicity) %>%
  summarise(
    Total_First_Starts = n(),
    Non_Null_Second_Starts = sum(!is.na(Referral_Second_Start)),
    Percentage_Non_Null_Second_Starts = (Non_Null_Second_Starts / Total_First_Starts) * 100
  )




