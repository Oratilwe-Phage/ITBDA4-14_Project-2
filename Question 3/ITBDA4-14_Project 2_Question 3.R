# Title: WebText API Proof of Concept - Text Mining & Summarisation Pipeline
# Description: Scrapes a compliant web source, preprocesses textual data, 
#              performs dual summarisation (Frequency/Extractive & LDA Topic Modeling),
#              and generates analytical visualisations.

# 1. Loading the  Required Libraries
suppressPackageStartupMessages({
  library(rvest)       
  library(xml2)       
  library(tm)          
  library(stringr)     
  library(wordcloud)  
  library(topicmodels) 
  library(ggplot2)     
  library(dplyr)       
})


# Question 3.1: Web Scraping & Data Structure Formation


# Select a compliant site (using Wikipedia's Natural Language Processing entry as a robust, static, and fair-use example)
target_url <- "https://en.wikipedia.org/wiki/Natural_language_processing"

# Read HTML content with polite check / error handling
webpage <- tryCatch({
  read_html(target_url)
}, error = function(e) {
  stop("Failed to retrieve the webpage. Check network connection or URL.")
})

# Extract body paragraphs specifically, stripping navigation, footers, and sidebars
article_paragraphs <- webpage %>%
  html_nodes("p") %>%
  html_text()

# Combine paragraphs into a single raw text string and form an R data structure (Data Frame)
raw_text_data <- data.frame(
  source_url = target_url,
  raw_content = paste(article_paragraphs, collapse = " "),
  stringsAsFactors = FALSE
)

cat("Successfully scraped", nchar(raw_text_data$raw_content), "characters of raw text.\n")


# Question 3.2: Textual Data Preprocessing

# Convert the raw text into a volatile corpus
corpus <- VCorpus(VectorSource(raw_text_data$raw_content))

# Apply comprehensive text cleaning transformations
corpus <- tm_map(corpus, content_transformer(tolower))                  # Converting  to lowercase
corpus <- tm_map(corpus, removePunctuation)                             # Removing  punctuation marks
corpus <- tm_map(corpus, removeNumbers)                                 # Removing  digits
corpus <- tm_map(corpus, removeWords, stopwords("english"))             # Removing English stop words
corpus <- tm_map(corpus, removeWords, c("can", "used", "using", "also")) # Removing domain-specific noise words
corpus <- tm_map(corpus, stripWhitespace)                               # Removing extra white spaces

# Creating a Document-Term Matrix (DTM) for statistical and modeling workflows
dtm <- DocumentTermMatrix(corpus)

# Removing sparse terms to optimize matrix density (retaining terms that appear in at least 1% of docs/segments)
dtm_trimmed <- removeSparseTerms(dtm, 0.99)

# Extracting cleaned token representations back into a character vector for inspection
cleaned_text <- sapply(corpus, as.character)

cat("Preprocessing complete. DTM dimensions:", dim(dtm_trimmed)[1], "documents by", dim(dtm_trimmed)[2], "terms.\n")


# Question 3.3: Text Summarisation Techniques & Visualisations


# --- Technique 1: Extractiving the Frequency-Based Summarisation (Term Frequency Analysis) ---
term_frequencies <- colSums(as.matrix(dtm))
sorted_freqs <- sort(term_frequencies, decreasing = TRUE)
top_terms_df <- data.frame(Term = names(sorted_freqs), Frequency = sorted_freqs)

# Visualization 1: Top 15 Most Frequent Terms Bar Chart
v1 <- ggplot(head(top_terms_df, 15), aes(x = reorder(Term, Frequency), y = Frequency, fill = Frequency)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  coord_flip() +
  scale_fill_gradient(low = "#dac4ad", high = "#62401e") +
  labs(
    title = "Top 15 Most Frequent Terms in Scraped Corpus",
    subtitle = "Extractive Frequency Summary Indicator",
    x = "Terms",
    y = "Absolute Frequency",
    caption = "Source: Wikipedia - Natural Language Processing"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", color = "#62401e"),
    axis.text = element_text(color = "black")
  )

print(v1)

# --- Technique 2: Latent Dirichlet Allocation (LDA) Topic Modeling Summarisation ---
# Filter out empty rows from DTM if any exist prior to LDA fitting
row_totals <- rowSums(as.matrix(dtm_trimmed))
dtm_clean_lda <- dtm_trimmed[row_totals > 0, ]

# Fit a 3-topic LDA model to summarize core latent themes
lda_model <- LDA(dtm_clean_lda, k = 3, control = list(seed = 1234))
lda_topics <- posterior(lda_model)$terms

# Extracting the top 5 terms for each latent topic to build the thematic summary table
topic_summary <- lapply(1:nrow(lda_topics), function(i) {
  top_indices <- order(lda_topics[i, ], decreasing = TRUE)[1:5]
  colnames(lda_topics)[top_indices]
})
names(topic_summary) <- paste0("Topic_", 1:3)
print("LDA Topic Summarisation Keywords:")
print(topic_summary)

# Visualization 2: Word Cloud Summarisation of Key Textual Themes
set.seed(42)
png("text_summary_wordcloud.png", width = 800, height = 600, res = 120)
wordcloud(
  words = names(term_frequencies),
  freq = term_frequencies,
  scale = c(3.5, 0.5),
  min.freq = 2,
  max.words = 100,
  random.order = FALSE,
  rot.per = 0.35,
  colors = brewer.pal(8, "Dark2")
)
dev.off()

cat("Summarisation visualisations successfully generated and saved.\n")

getwd()
