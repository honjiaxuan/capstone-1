#
# Coursera
# Data Science Specialization
#
# Capstone Project
# Using EN_US locale data
#
# Routines to prepare the modeling data set from the raw data set
#
# February 2017, Erwin Vorwerk
#

# Tweak OSX to prevent R processes to choke on memory allocation (bug)
# options(mc.cores = 1)

# Set tracer status ("on" = display tracing messages)
tracer <- "on"
# tracer <- "off"

# Change to working directory
#setwd("~/Documents/Coursera/capstone")
setwd("D:/science/capstone")

# Load data file from the internet
url  <- "http://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
if (!file.exists("coursera-swiftkey.zip"))
{
  # Get the file from 
  download.file(url, destfile="coursera-swiftkey.zip")
  
  # Then unzip the file to get source files 
  unzip("coursera-swiftkey.zip", overwrite=TRUE, junkpaths=TRUE)
}

# Set the stage
require(stringr)

# Global settings
data_path  = './data/final'
language   = "english"
locale     = "en_US"
words      = "en"
extension  = ".txt"
sampleSize = 10000

# Initialize variables
locale_path <- paste(data_path, "/", locale, "/", sep = "")

# Source file names
file_blogs <- paste(locale_path, locale,".blogs", extension, sep ="")
file_news <- paste(locale_path, locale,".news", extension, sep="")
file_twitter <- paste(locale_path, locale,".twitter", extension, sep="")

# Target file names
file_news_cleansed <- paste(locale_path, locale,".news.cleansed", ".RData", sep="")
file_blogs_cleansed <- paste(locale_path, locale,".blogs.cleansed", ".RData", sep="")
file_twitter_cleansed <- paste(locale_path, locale,".twitter.cleansed", ".RData", sep="")
file_all_cleansed <- paste(locale_path, locale,".all.cleansed", ".RData", sep="")

#
# Create function: tracer_msg
#
# Purpose
#         Dispaly tracer message to follow code execution process
# Parameters
#         str: tracer message (with tracer variable "on" = display messages)
#         
#
tracer_msg <- function(tracerMsg) {
  if(tracer=="on") print(tracerMsg)
}

#
# Create function: rmNonAlphabet
#
# Purpose
#         Get rid of non-alphanumeric characters in a string
# Parameters
#         str: string to be processed
# Note
#         created by code_musketeer, Jul 31, 2015 @ stackoverflow.com
#
rmNonAlphabet <- function(str) {
  words <- unlist(strsplit(str, " "))
  in.alphabet <- grep(words, pattern = "[a-z|0-9]", ignore.case = T)
  nice.str <- paste(words[in.alphabet], collapse = " ")
  nice.str
}

#
# Create function: read_content
#
# Purpose
#               Read from a data source file
# Paramaters
#               fileName : fully qualified path & filename of file to be read
#
read_content <- function(fileName)
{
  #
  # Initialise storage variable
  #
  n_lines <- ""
  
  #
  # Only read if file exists
  #
  if(file.exists(fileName))
  {
    fileHandle <- file(fileName,"r")
    n_lines <- readLines(fileHandle, encoding="UTF-8", skipNul = TRUE)
    close(fileHandle)
  }
  # Ensure only valid characters are returned
  # n_lines <- rmNonAlphabet(n_lines)
  
  return(n_lines)
}


# And read the content of the English language files into variables if needed
tracer_msg("Read content of files")

if (!exists("lines_blogs"))   {lines_blogs   <- read_content(file_blogs)}
if (!exists("lines_twitter")) {lines_twitter <- read_content(file_twitter)}
if (!exists("lines_news"))    {lines_news    <- read_content(file_news)}


# Start with simply looking at the number of lines
length(lines_blogs)
length(lines_twitter)
length(lines_news)

# Intialize seeder
set.seed(1357)

# Take three samples
tracer_msg("Take three samples")
lines_blogs   <- sample(lines_blogs,   size=sampleSize, replace=TRUE)
lines_news    <- sample(lines_news,    size=sampleSize, replace=TRUE)
lines_twitter <- sample(lines_twitter, size=sampleSize, replace=TRUE)

length(lines_blogs)
length(lines_twitter)
length(lines_news)

# And perform initial cleansing on the information just read in
tracer_msg("Initial cleansing")
lines_blogs   <- iconv(lines_blogs,"Latin-9")
lines_twitter <- iconv(lines_twitter,"Latin-9")
lines_news    <- iconv(lines_news, "Latin-9")

# Load required libraries
require(tm)         # Text Mining Library
require(RWeka)      # N-gram processes
require(wordcloud)  # Create wordclouds from ngram results
require(SnowballC)  # Snowball stemmers

#
# Create function: cleanse_data
#
# Purpose
#         clean the Corpus to ensure a consistent data set
# Parameters
#         corpData: the data set (Corpus) to be transformed
#
cleanse_data <- function(corpData)
{
  
  #
  # Using bespoke functions from the Text Mining Library (tm) to do mechanical cleansing
  #
  tracer_msg("Remove numbers")
  transformedCorp <- tm_map(corpData, removeNumbers)                           # get rid of numbers
  tracer_msg("Remove whitespaces")
  transformedCorp <- tm_map(transformedCorp, stripWhitespace)                  # get rid of whitespaces
  tracer_msg("Remove punctuation")
  transformedCorp <- tm_map(transformedCorp, removePunctuation)                # get rid of interpunction
  tracer_msg("Convert to plain text")
  transformedCorp <- tm_map(transformedCorp, PlainTextDocument)                # convert all to plain text
  tracer_msg("Remove capitals")
  transformedCorp <- tm_map(transformedCorp, content_transformer(tolower))     # convert all to lowercase   
  tracer_msg("Stem the text")
  transformedCorp <- tm_map(transformedCorp, stemDocument)                     # stem the text (https://en.wikipedia.org/wiki/Stemming)

  #
  # Using besproke functions from the Text Mining library (tm) to do content cleansing
  #
  #tracer_msg("Remove stopwords")
  #transformedCorp <- tm_map(corpData, removeWords, stopwords(words))        # remove unwanted words

  #
  # Ensure result returned is of datatype Corpus
  #
  transformedCorp <- Corpus(VectorSource(transformedCorp))  
  
  #
  # Return result
  #
  return(transformedCorp)
}

# NEWS
# 
# Convert, cleanse'news' data, then remove orginal data from environment
#

# First check if it was already done
if (!file.exists(file_news_cleansed))
{
  # Cleanse data
  tracer_msg("Cleanse news data")
  corpus_news          <- Corpus(VectorSource(lines_news))
  corpus_news_cleansed <- cleanse_data(corpus_news)
  rm(corpus_news, lines_news)
  
  # Now write the cleansed data to disk for later use
  save(corpus_news_cleansed, file=file_news_cleansed)
  rm(corpus_news_cleansed)
}


# BLOGS
# 
# Convert, cleanse 'blogs' data, then remove orginal data from environment
#

# First check if it was already done
if (!file.exists(file_blogs_cleansed))
{
  # Cleanse data
  tracer_msg("Cleanse blogs data")
  corpus_blogs          <- Corpus(VectorSource(lines_blogs))
  corpus_blogs_cleansed <- cleanse_data(corpus_blogs)
  rm(corpus_blogs, lines_blogs)
  
  # Now write the cleansed data to disk for later use
  save(corpus_blogs_cleansed, file=file_blogs_cleansed)
  rm(corpus_blogs_cleansed)
}

# TWITTER
# 
# Convert, cleanse 'twitter' data, then remove orginal data from environment
#

# First check if it was already done
if (!file.exists(file_twitter_cleansed))
{
  # Cleanse data
  tracer_msg("Cleanse twitter data")
  corpus_twitter          <- Corpus(VectorSource(lines_twitter))
  rm(lines_twitter)
  corpus_twitter_cleansed <- cleanse_data(corpus_twitter)
  rm(corpus_twitter)
  
  # Now write the cleansed data to disk for later use
  save(corpus_twitter_cleansed, file=file_twitter_cleansed)
  rm(corpus_twitter_cleansed)
  
}

#
# CONCATENATE
#
load(file_twitter_cleansed)
load(file_blogs_cleansed)
load(file_news_cleansed)
corpus_all_cleansed <- c(corpus_twitter_cleansed, corpus_news_cleansed, corpus_blogs_cleansed)
save(corpus_all_cleansed, file=file_all_cleansed)
