# ITBDA4_Project-2: Big Data Analytics


## ETL Analytics, MapReduce Process, Advancing Research and Analysis Project

## 📝 Project Overview
This project demonstrates an end-to-end data analytics workflow involving data extraction, transformation, cleaning, and loading using R and PostgreSQL.

## 🧩 Repository Structure
### For Data and Notebooks

- Data:
  - This contains all the datasets used for this Project
 
- Question 1:
  - R Script for Question 1
  - MapReduce Keyword Search Results CSV file


- Question 2:
  - R Script for Question 2
  - Question 2 (a) image : Top Keywords in Each LDA Topic plot
  - Question 2 (b) image : Document-Topic Proportions plot


- Question 3:
  - R Script for Question 3
  - Question 3 image : Top 15 Most Frequent Terms in Scraped Corpus plot
  - Text Summary Word cloud image


- Question 4:
  - Python Script for Question 4
  - ELT Project Question 4.3 SQL script
  - ELT Project Question 4.3 (PostgreSQL table) CSV file
  - Genz Wikipedia Cleaned CSV file
  - Genz Wikipedia Raw CSV file


## 📊 Workflows
### Question 1 Workflow: 
I implemented the MapReduce process using R to demonstrate the fundamental concepts of the MapReduce programming model. Although I did not use the actual Hadoop framework, my implementation reproduces the Mapper, Shuffle and Sort, and Reducer stages. I selected R because it allowed me to implement and test the functionality locally without configuring a distributed Hadoop environment. However, I acknowledge that my implementation is a simulation and does not demonstrate Hadoop's distributed processing capabilities.


### Question 2 Workflow: 
The South African news text files were imported into R and combined into a data frame with the file names and article content as the first step in the procedure for this inquiry. After that, the captured text was cleaned and preprocessed using tokenization, lowercase word conversion, and the removal of common stop words, digits, and punctuation. The frequency of words in the news documents was then represented by a Document-Term Matrix (DTM). The five most important terms for each of the three underlying subjects were then extracted using Latent Dirichlet Allocation (LDA). Ultimately, two visualizations were created: a heatmap that used Gamma probabilities to show the distribution of subjects among the various news articles, and a faceted bar chart that showed the top keywords and their Beta probability.


### Question 3 Workflow:
The workflow follows a methodical three-stage data science pipeline: first, it uses web scraping tools to extract raw content from a compliant web source and create an initial R data structure; second, it cleans and structures the text using extensive NLP preprocessing steps (such as tokenization, lowercasing, noise removal, and Document-Term Matrix generation); and third, it distills the content using two summarization techniques (extractive frequency analysis and Latent Dirichlet Allocation (LDA) topic modeling), which are then presented through analytical visualizations.


### Question 4 Workflow: 
Using R and PostgreSQL, this question illustrates the entire ETL (Extract, Transform, and Load) procedure. First, R was used for web scraping in order to gather data from the Generation Z article on Wikipedia. The retrieved text was then analyzed using regular expressions (regex) to extract numerical data, such as years and percentages. After that, the dataset was cleaned up by eliminating duplicates, fixing inconsistent formatting, imputing missing values, and getting the data ready for analysis. Using pgAdmin, the cleaned dataset was imported into a PostgreSQL database after being exported as a CSV file. In order to show how unstructured web data may be converted into structured information for analytical reporting, two SQL analytical investigations were carried out to look at social media platform mentions and numerical references inside the Wikipedia page.


## 🤖 Technologies Used
- R
- PostgreSQL
- pgAdmin
- SQL
- Regular Expressions
