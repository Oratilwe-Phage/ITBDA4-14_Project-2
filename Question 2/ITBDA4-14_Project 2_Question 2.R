# QUESTION 2
# Question 2.1: Data Frame Generation and Data Denoising
# Question 2.2: Latent Dirichlet Allocation (LDA) Topic Modeling
# Question 2.3: Visualizations



# 1. Loading required libraries

library(tidyverse)
library(tidytext)
library(topicmodels)
library(ggplot2)



# QUESTION 2.1: DATA FRAME GENERATION AND DATA DENOISING



# 2. Defining the directory where the extracted news files
# are located

file_dir <- "/Users/oratilwephage/Documents/Honours/Big Data Analytics/Project 2/ITBDA4-14 Project 2 Datasets-20261029/sa_news"


# 3. Checking whether the directory exists

if (!dir.exists(file_dir)) {
  stop("Error: The specified directory does not exist. Please check the file path.")
}


# 4. Locating all text files in the directory

file_paths <- list.files(
  path = file_dir,
  pattern = "\\.txt$",
  full.names = TRUE
)

# Checking whether text files were found

if (length(file_paths) == 0) {
  stop("Error: No text files were found in the specified directory.")
}

print(paste("Total text files found:", length(file_paths)))


# 5. Reading the content from each text file into memory

file_names <- basename(file_paths)

file_contents <- sapply(file_paths, function(path) {
  
  readChar(
    path,
    nchars = file.info(path)$size,
    useBytes = TRUE
  )
  
})


# 6. Generating the initial data frame with file_name and content

news_df <- data.frame(
  file_name = file_names,
  content = as.character(file_contents),
  stringsAsFactors = FALSE
)


# 7. Viewing the structure of the generated data frame

print("Data frame preview:")
print(head(news_df))

print("Data frame structure:")
str(news_df)



# 8. DATA DENOISING AND PREPROCESSING



# Loading standard English stop words

data("stop_words", package = "tidytext")


# Tokenizing and cleaning the news articles

tidy_news <- news_df %>%
  
  unnest_tokens(word, content) %>%
  
  # Converting all words to lowercase
  mutate(word = str_to_lower(word)) %>%
  
  # Removing numerical values
  mutate(word = str_remove_all(word, "[[:digit:]]")) %>%
  
  # Removing punctuation
  mutate(word = str_remove_all(word, "[[:punct:]]")) %>%
  
  # Removing empty tokens
  filter(word != "") %>%
  
  # Removing standard English stop words
  anti_join(stop_words, by = "word")


# Displaying preprocessed token count summary

print(paste("Total preprocessed tokens:", nrow(tidy_news)))

print("Preprocessed data preview:")
print(head(tidy_news))



# QUESTION 2.2: LATENT DIRICHLET ALLOCATION (LDA)
# TOPIC MODELING



# 9. Creating a Document-Term Matrix (DTM)

news_word_counts <- tidy_news %>%
  
  count(file_name, word, sort = TRUE)


# Converting word counts into a Document-Term Matrix

news_dtm <- news_word_counts %>%
  
  cast_dtm(file_name, word, n)


# Checking the Document-Term Matrix

print("Document-Term Matrix:")
print(news_dtm)


# 10. Defining the LDA model parameters

n_topics <- 3  # Number of topics (n)

k_words <- 5   # Top keywords per topic (k)


# 11. Fitting the LDA model using Gibbs sampling

set.seed(42)

lda_model <- LDA(
  news_dtm,
  k = n_topics,
  method = "Gibbs",
  control = list(seed = 42)
)


# Displaying the LDA model summary

print("LDA Model Summary:")
print(lda_model)


# 12. Extracting word distributions per topic (Beta)

lda_topics <- tidy(
  lda_model,
  matrix = "beta"
)


# Checking the extracted topic columns

print("LDA topic column names:")
print(colnames(lda_topics))


# 13. Identifying the top k words for each topic

top_terms <- lda_topics %>%
  
  group_by(topic) %>%
  
  slice_max(
    order_by = beta,
    n = k_words,
    with_ties = FALSE
  ) %>%
  
  ungroup() %>%
  
  arrange(topic, desc(beta))


# Displaying the top k words and their Beta probabilities

print("=== Top Words and Distribution (Beta) per Topic ===")

print(top_terms)



# QUESTION 2.3: VISUALIZATIONS
# VISUALIZATION METHOD 1:
# FACETED BAR CHART OF TOP KEYWORDS PER TOPIC

# Displaying the five most important words in each topic
# based on their Beta probability distributions.

plot_1 <- top_terms %>%
  
  mutate(
    term = tidytext::reorder_within(term, beta, topic)
  ) %>%
  
  ggplot(
    aes(
      x = beta,
      y = term,
      fill = factor(topic)
    )
  ) +
  
  geom_col(show.legend = FALSE) +
  
  facet_wrap(
    ~ topic,
    scales = "free_y"
  ) +
  
  tidytext::scale_y_reordered() +
  
  labs(
    title = "Top Keywords in Each LDA Topic",
    subtitle = "Word probability distribution (Beta) per topic",
    x = "Beta (Word-Topic Probability)",
    y = "Terms"
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14
    ),
    
    plot.subtitle = element_text(size = 10),
    
    axis.text = element_text(size = 9),
    
    strip.text = element_text(
      face = "bold",
      size = 11
    ),
    
    panel.spacing = unit(1.5, "lines")
  )


# Displaying the first visualization

print(plot_1)



# VISUALIZATION METHOD 2:
# DOCUMENT-TOPIC DISTRIBUTION HEATMAP (GAMMA)


# Extracting document-topic proportions (Gamma)

lda_documents <- tidy(
  lda_model,
  matrix = "gamma"
)


# Creating the document-topic heatmap

plot_2 <- ggplot(
  lda_documents,
  aes(
    x = factor(topic),
    y = document,
    fill = gamma
  )
) +
  
  geom_tile(color = "white") +
  
  scale_fill_gradient(
    low = "white",
    high = "darkblue"
  ) +
  
  labs(
    title = "Document-Topic Proportions",
    subtitle = "Distribution of topics across individual news documents",
    x = "Topic Number",
    y = "News Document",
    fill = "Gamma\nProbability"
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14
    ),
    
    plot.subtitle = element_text(size = 10),
    
    axis.text.x = element_text(size = 10),
    
    axis.text.y = element_text(size = 7),
    
    panel.grid = element_blank()
  )


# Displaying the second visualization

print(plot_2)

# Saving the heatmap as a PNG image

ggsave(
  filename = "LDA_Document_Topic_Heatmap.png",
  plot = plot_2,
  path = "/Users/oratilwephage/Documents/Honours/Big Data Analytics/Project 2/ITBDA4-14 Project 2 Datasets-20261029",
  width = 12,
  height = 10,
  dpi = 300
)

print("Heatmap successfully saved!")


# Displaying a completion message

print("Question 2 completed successfully!")
