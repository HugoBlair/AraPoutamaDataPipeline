# Ara Poutama's (NZ Department of Corrections) Data Pipeline

Ara Poutama presented a project to create a Data Pipeline to ingest and visualise Mental Health data from a Ministry of Health dataset called PRIMHD, specifically data relating to Waiting Times for Mental Health Services.

## Access The Dashboard Here:
https://hugoblair.shinyapps.io/arapoutamadatapipeline/

## Pipeline Specifications

### Raw Layer:
- Ingesting from S3 bucket
- Extracting data from Excel
- Creating DataFrames

### Stage Layer:
- Cleansing the data by:
  - Combining Tables
  - Generating missing data based on Ara Poutama Specifications:
    - Ethnicities
    - Gender
- Creating, Combining, and Transforming columns:
  - NGO/DHB type
  - Organization Name
  - Team Type
  - Metadata

### Reporting Layer:
- Creating summary tables which sort referrals by:
  - Region
  - Team Type
  - Referring Organization
  - Funding DHB
  - Age Group
  - Gender
  - Ethnicity
- Creating statistical summaries for mean wait times sorted by:
  - Ethnicities
  - Gender
  - Region
  - DHB
  - Organization
- A prototype dashboard has been produced and deployed to R Shiny based on dummy data. This produces:
  - A table view of the aggregated data
  - Visualisations of summaries based on the following variables:
    - Ethnicity
    - Age Group
    - Referral DHB
    - Time
- A suite of architectural diagrams including:
  - Logical Model
  - Conceptual Diagrams
  - Physical Model
  - Entity Relationship Diagrams

## Completeness
- An initial prototype of the data pipeline has been developed. 
- The prototype was developed outside of the Ara Poutama data platform and the following aspects must be considered:
  - The source of the data is an import from a local .csv file due to external limitations.
  - Internal naming conventions were not provided.
  - Column and table names may need to be changed to better integrate into the existing data platform.

### Next Steps:
- Workshop to walk users through use of the data.
- Perform User Acceptance Testing.
- Gather and consider feedback from users.
- Create and maintain documentation on the data pipeline for both users and future developers.
- Fork our GitHub repository to a new repository internal to Ara Poutama.
- Deployment to organization’s teams, psychology, data analytics, justice.
- Update the dashboard with current visualisation variables to meet Ara Poutama's internal requirements.
- Switch cloud storage service to Ara Poutama’s provider of choice.

## Future Improvements:
- Ideally, an API integration would be produced to serve data to the pipeline directly from the PRIMHD data mart.
- Data Quality Monitoring.
- Unit testing each script individually to ensure validity of output data, tables, and visualisations.
- Dashboard improvements:
  - The ability for users to download data directly from the dashboard.
  - Use of shape maps to visualise data by region.
  - Switching the website hosting for the dashboard from ShinyApps.io to a scalable platform capable of dealing with more traffic.
  - Conversions between MOH and Ara Poutama region names.
