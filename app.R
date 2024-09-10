library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(aws.s3)
library(yaml)
library(rsconnect)

#Access the deployed version the dashboard below:
#https://hugoblair.shinyapps.io/arapoutamadatapipeline/

# Load configuration
config <- config::get(file = "config.yml")

# Set AWS credentials
Sys.setenv(
  "AWS_ACCESS_KEY_ID" = config$aws$AWS_ACCESS_KEY_ID,
  "AWS_SECRET_ACCESS_KEY" = config$aws$AWS_SECRET_ACCESS_KEY,
  "AWS_DEFAULT_REGION" = config$aws$AWS_DEFAULT_REGION
)


# Function to load data from S3
load_data_from_s3 <- function() {
  bucket <- "ara-poutama-data"
  file_name <- "df_data_scd2.csv"
  
  if (object_exists(object = file_name, bucket = bucket)) {
    s3_object <- get_object(object = file_name, bucket = bucket)
    raw_data <- read.csv(text = rawToChar(s3_object))
    return(raw_data)
  } else {
    stop("File not found in S3 bucket")
  }
}

# Function to process data
process_data <- function(raw_data) {
  referrals_by_ethnicity <- raw_data %>%
    group_by(Ethnicity) %>%
    summarise(count = n())
  
  referrals_by_age <- raw_data %>%
    group_by(Age_Group) %>%
    summarise(count = n())
  
  referrals_over_time <- raw_data %>%
    mutate(Referral_Date = as.Date(Referral_First_Start)) %>%
    group_by(Referral_Date) %>%
    summarise(count = n())
  
  referrals_by_org <- raw_data %>%
    group_by(Organisation_Name) %>%
    summarise(count = n())
  
  list(
    referrals_by_ethnicity = referrals_by_ethnicity,
    referrals_by_age = referrals_by_age,
    referrals_over_time = referrals_over_time,
    referrals_by_org = referrals_by_org,
    raw_data = raw_data
  )
}

# UI
ui <- fluidPage(
  titlePanel("Mental Health Referrals Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("plot_type", "Select Plot:",
                  choices = c("Referrals by Ethnicity", "Referrals by Age Group", 
                              "Referrals Over Time", "Referrals by Organization")),
      conditionalPanel(
        condition = "input.plot_type == 'Referrals Over Time'",
        dateRangeInput("date_range", "Select Date Range:",
                       start = "2024-01-01", end = "2024-04-01")
      )
    ),
    
    mainPanel(
      plotOutput("referral_plot"),
      dataTableOutput("data_table")
    )
  )
)

# Server
server <- function(input, output, session) {
  # Load and process data
  processed_data <- reactive({
    raw_data <- load_data_from_s3()
    process_data(raw_data)
  })
  
  # Render plot
  output$referral_plot <- renderPlot({
    data <- processed_data()
    
    switch(input$plot_type,
           "Referrals by Ethnicity" = ggplot(data$referrals_by_ethnicity, aes(x = Ethnicity, y = count)) +
             geom_bar(stat = "identity", fill = "steelblue") +
             theme_minimal() +
             labs(title = "Referrals by Ethnicity", x = "Ethnicity", y = "Number of Referrals") +
             theme(axis.text.x = element_text(angle = 45, hjust = 1)),
           
           "Referrals by Age Group" = ggplot(data$referrals_by_age, aes(x = Age_Group, y = count)) +
             geom_bar(stat = "identity", fill = "darkgreen") +
             theme_minimal() +
             labs(title = "Referrals by Age Group", x = "Age Group", y = "Number of Referrals") +
             theme(axis.text.x = element_text(angle = 45, hjust = 1)),
           
           "Referrals Over Time" = {
             filtered_data <- data$referrals_over_time %>%
               filter(Referral_Date >= input$date_range[1] & Referral_Date <= input$date_range[2])
             
             ggplot(filtered_data, aes(x = Referral_Date, y = count)) +
               geom_line(color = "red") +
               geom_point() +
               theme_minimal() +
               labs(title = "Referrals Over Time", x = "Date", y = "Number of Referrals") +
               scale_x_date(date_breaks = "1 week", date_labels = "%Y-%m-%d") +
               theme(axis.text.x = element_text(angle = 45, hjust = 1))
           },
           
           "Referrals by Organization" = ggplot(data$referrals_by_org, aes(x = reorder(Organisation_Name, -count), y = count)) +
             geom_bar(stat = "identity", fill = "orange") +
             theme_minimal() +
             labs(title = "Referrals by Organization", x = "Organization", y = "Number of Referrals") +
             theme(axis.text.x = element_text(angle = 45, hjust = 1))
    )
  })
  
  # Render data table
  output$data_table <- renderDataTable({
    data <- processed_data()$raw_data
    data[, c("NHI", "Organisation_Name", "Ethnicity", "Age_Group", "Referral_First_Start")]
  })
}

# Run the app
shinyApp(ui = ui, server = server)
