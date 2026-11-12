# Question 4.1 and 4.2
# ETL Manipulating using R and PostgreSQL
# Web Scraping Wikipedia: Generation Z

# STEP 0: LOADING REQUIRED PACKAGES


# IMPORTANT:
# Install packages separately in the R Console.
# Do not run install.packages() every time you execute this script.

library(rvest)
library(httr)
library(dplyr)
library(stringr)
library(readr)
library(xml2)



# QUESTION 4.1: WEB SCRAPING WIKIPEDIA

# STEP 1: Defining the Wikipedia article URL

wiki_url <- "https://en.wikipedia.org/wiki/Generation_Z"


# STEP 2: Sending a request to Wikipedia

wiki_response <- GET(
  wiki_url,
  user_agent("Student ETL Analytics Project")
)


# STEP 3: Checking whether the request was successful

stop_for_status(wiki_response)

# Displaying the HTTP status code
status_code(wiki_response)


# STEP 4: Reading the webpage HTML content

wiki_page <- read_html(
  content(wiki_response, as = "raw")
)


# STEP 5: Extracting article paragraphs

paragraphs <- wiki_page |>
  html_elements("#mw-content-text .mw-parser-output p") |>
  html_text2()


# STEP 6: Removing empty paragraphs

paragraphs <- paragraphs[
  str_length(str_trim(paragraphs)) > 0
]


# STEP 7: Creating a raw dataset

raw_data <- data.frame(
  record_id = seq_along(paragraphs),
  article_text = paragraphs,
  stringsAsFactors = FALSE
)


# STEP 8: Displaying extracted data

head(raw_data)

# Checking number of extracted paragraphs
nrow(raw_data)


# STEP 9: EXTRACTING SOCIAL MEDIA SECTION


# Searching for the Social Media section heading

social_media_heading <- wiki_page |>
  html_elements("h2, h3, h4") |>
  html_element("span.mw-headline") |>
  html_text2()

# Displaying available section headings
social_media_heading


# STEP 10: REGEX ANALYSIS


# Extracting the first numerical value from each paragraph

raw_data$numeric_value <- str_extract(
  raw_data$article_text,
  "\\d+(\\.\\d+)?"
)

# Converting numerical values into numeric data

raw_data$numeric_value <- as.numeric(
  raw_data$numeric_value
)


# Extracting percentages using regex

raw_data$percentage <- str_extract(
  raw_data$article_text,
  "\\d+(\\.\\d+)?%"
)

# Removing percentage symbol and converting to numeric

raw_data$percentage <- as.numeric(
  str_remove(raw_data$percentage, "%")
)


# Extracting years using regex

raw_data$year <- str_extract(
  raw_data$article_text,
  "\\b(19|20)\\d{2}\\b"
)


# Displaying regex results

head(raw_data)


# Checking extracted numerical information

summary(raw_data$numeric_value)

summary(raw_data$percentage)

summary(raw_data$year)



# QUESTION 4.2: CLEANING AND IMPUTATION

# STEP 1: Creating a cleaned copy of the raw dataset

cleaned_data <- raw_data


# STEP 2: Removing extra whitespace

cleaned_data$article_text <- str_squish(
  cleaned_data$article_text
)


# STEP 3: Removing Wikipedia citation markers
# Example: [1], [2], [15]

cleaned_data$article_text <- str_replace_all(
  cleaned_data$article_text,
  "\\[\\d+\\]",
  ""
)


# STEP 4: Removing duplicate paragraphs

cleaned_data <- cleaned_data |>
  distinct(article_text, .keep_all = TRUE)


# STEP 5: Removing empty and missing records

cleaned_data <- cleaned_data |>
  filter(
    !is.na(article_text),
    article_text != ""
  )


# STEP 6: Imputing missing numerical values using median

median_value <- median(
  cleaned_data$numeric_value,
  na.rm = TRUE
)

# Replacing missing numerical values with median

if (is.finite(median_value)) {
  
  cleaned_data$numeric_value[
    is.na(cleaned_data$numeric_value)
  ] <- median_value
  
}


# STEP 7: Displaying cleaned dataset

head(cleaned_data)


# STEP 8: VALIDATING CLEANED DATA


# Checking dataset dimensions

dim(cleaned_data)


# Checking remaining missing values

colSums(is.na(cleaned_data))


# Checking data structure

str(cleaned_data)


# Checking summary statistics

summary(cleaned_data)



# STEP 9: EXPORTING CLEANED DATASET

# Defining output file name

output_file <- "genz_wikipedia_cleaned.csv"


# Exporting cleaned data to CSV

write_csv(
  cleaned_data,
  output_file
)


# Confirming successful export

if (file.exists(output_file)) {
  
  print("Dataset successfully exported!")
  
  print(file.path(getwd(), output_file))
  
} else {
  
  print("Dataset export failed!")
  
}



# QUESTION 4.3
# LOADING CLEANED DATA INTO POSTGRESQL


# 1. Loading required libraries

library(DBI)
library(RPostgres)
library(readr)
library(dplyr)


# 2. Reading the cleaned CSV dataset

# Make sure the CSV file is in your working directory.

cleaned_data <- read_csv(
  "genz_wikipedia_cleaned.csv",
  col_types = cols(
    year = col_character()
  )
)

# Displaying the dataset
head(cleaned_data)


# 3. Establishing a PostgreSQL connection
library(DBI)
library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "ETL_Project_Question 4.3",
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = "Kaboratilwe@17"
)

# Test database connection
dbIsValid(con)


# 4. Checking the database connection

if (dbIsValid(con)) {
  print("Successfully connected to PostgreSQL!")
}


# 5. Creating a database table

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS genz_wikipedia (
    record_id INTEGER,
    article_text TEXT,
    numeric_value DOUBLE PRECISION,
    percentage DOUBLE PRECISION,
    year TEXT
  )
")


# 6. Clearing previous records before reloading

# This prevents duplicate records when running the script again.

dbExecute(
  con,
  "DELETE FROM genz_wikipedia"
)


# 7. Loading cleaned data into PostgreSQL

dbWriteTable(
  con,
  "genz_wikipedia",
  cleaned_data,
  append = TRUE,
  row.names = FALSE
)


# 8. Checking whether the data was loaded successfully

loaded_data <- dbGetQuery(
  con,
  "SELECT * FROM genz_wikipedia LIMIT 10"
)

# Displaying the first 10 records
print(loaded_data)


# 9. Counting the number of records in PostgreSQL

record_count <- dbGetQuery(
  con,
  "SELECT COUNT(*) AS total_records
   FROM genz_wikipedia"
)

print(record_count)


# 10. Checking the table structure

table_structure <- dbGetQuery(
  con,
  "SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_name = 'genz_wikipedia'"
)

print(table_structure)


# 11. Disconnecting from PostgreSQL

dbDisconnect(con)

print("ETL process completed successfully!")
