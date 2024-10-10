#############################################
### P9_update_report_layer.R             ###
#############################################

# Code to use business layer data to create 
# summary tables for reporting

#############################################
### Create Summary Tables                 ###
#############################################




Waiting_Times_OBT <- Stage_Waiting_Times_OBT 


# - People with Referrals by TEAM_TYPE_CODE (replaced with endcode descriptions)

People_with_Referrals_by_TEAM_TYPE_CODE <- Waiting_Times_OBT %>%
  group_by(TEAM_TYPE_CODE) %>%
  summarize(Unique_Referral_ID_Count = n_distinct(REFERRAL_ID))%>%
  left_join(all_code_descriptions, by =c("TEAM_TYPE_CODE"="Code"))%>%
  select(Description, Unique_Referral_ID_Count)


# - People with Referrals by REFERRAL_FROM (replaced with endcode descriptions)

People_with_Referrals_by_Referral_From <- Waiting_Times_OBT %>%
  group_by(REFERRAL_FROM) %>%
  summarize(Unique_Referral_ID_Count = n_distinct(REFERRAL_ID))%>%
  left_join(all_code_descriptions, by = c("REFERRAL_FROM" = "Code")) %>%
  select(Description, Unique_Referral_ID_Count)


# - People with Referrals by FUNDING_DHB

People_with_Referrals_by_Funding_DHB <- Waiting_Times_OBT %>%
  group_by(FUNDING_DHB) %>%
  summarize(Unique_Referral_ID_Count = n_distinct(REFERRAL_ID))

# - People with Referrals by Age Group

People_with_Referrals_by_Age_Group <- Waiting_Times_OBT %>%
  group_by(AGE_GROUP) %>%
  summarize(Unique_Referral_ID_Count = n_distinct(REFERRAL_ID))

# - People with Referrals by Gender

People_with_Referrals_by_Gender <- Waiting_Times_OBT %>%
  group_by(Gender) %>%
  summarize(Unique_Referral_ID_Count = n_distinct(REFERRAL_ID))

# - People with Referrals by Ethnicity

People_with_Referrals_by_Ethnicity <- Waiting_Times_OBT %>%
  group_by(Ethnicity) %>%
  summarize(Unique_Referral_ID_Count = n_distinct(REFERRAL_ID))

# - People with Referrals by INSCOPE_REFERRAL_END_CODE (replaced with endcode descriptions)

People_with_Referrals_by_Referral_End_Code <- Waiting_Times_OBT %>%
  group_by(INSCOPE_REFERRAL_END_CODE) %>%
  summarize(Unique_Referral_ID_Count = n_distinct(REFERRAL_ID)) %>%
  left_join(all_code_descriptions, by = c("INSCOPE_REFERRAL_END_CODE" = "Code")) %>%
  select(Description, Unique_Referral_ID_Count)


### Inserting summary stats for mean waits per DHB, ethnicity, etc

ethnicity_summary <- Waiting_Times_OBT %>%
  group_by(Ethnicity) %>%
  summarize(
    Mean_Wait_Days = mean(WAIT_DAYS, na.rm = TRUE),
    Median_Wait_Days = median(WAIT_DAYS, na.rm = TRUE)
  )


gender_summary <- Waiting_Times_OBT %>%
  group_by(Gender) %>%
  summarize(
    Mean_Wait_Days = mean(WAIT_DAYS, na.rm = TRUE),
    Median_Wait_Days = median(WAIT_DAYS, na.rm = TRUE)
  )

district_region_summary <- Waiting_Times_OBT %>%
  group_by(DISTRICT_REGION) %>%
  summarize(
    Mean_Wait_Days = mean(WAIT_DAYS, na.rm = TRUE),
    Median_Wait_Days = median(WAIT_DAYS, na.rm = TRUE)
  )

dhbdom_summary <- Waiting_Times_OBT %>%
  group_by(DHBDOM) %>%
  summarize(
    Mean_Wait_Days = mean(WAIT_DAYS, na.rm = TRUE),
    Median_Wait_Days = median(WAIT_DAYS, na.rm = TRUE)
  )

organisation_summary <- Waiting_Times_OBT %>%
  group_by(ORGANISATION_NAME) %>%
  summarize(
    Mean_Wait_Days = mean(WAIT_DAYS, na.rm = TRUE),
    Median_Wait_Days = median(WAIT_DAYS, na.rm = TRUE)
  )


