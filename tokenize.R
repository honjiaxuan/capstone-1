#
# Coursera
# Data Science Specialization
#
# Capstone Project
# Using EN_US locale data
#
# Tokenization Algorithm
#
# January 2017, Erwin Vorwerk
#

#
# Disable multicore processing on OSX (prevent error messages)
#
options(mc.cores = 1)

#
# Preload required packages
#
require(tm)         # Text Mining Library
require(RWeka)      # N-gram processes
require(wordcloud)  # Create wordclouds from ngram results
require(SnowballC)  # Snowball stemmers

#
# Global settings 
#
data_path  = './data/final'
language   = "english"
locale     = "en_US"
words      = "en"
extension  = ".txt"
srcType    = "blg"
maxWords   = 100
sampleSize = 50000

#
# Initialise variables
#
locale_path <- paste(data_path, "/", locale, "/", sep = "")

file_blogs <- paste(locale_path, locale,".blogs", extension, sep ="")
file_news <- paste(locale_path, locale,".news", extension, sep="")
file_twitter <- paste(locale_path, locale,".twiitter", extension, sep="")

#
# Function: read_n_lines
#
# Purpose
#               Read a given number of lines from a data source file
# Paramaters
#               fileName : fully qualified path & filename of file to be read
#               numLines : how many lines should be read
#
read_n_lines <- function(fileName, numLines)
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
    n_lines <- readLines(fileHandle, n=numLines, encoding="UTF-8", skipNul = TRUE)
    close(fileHandle)
  }
  
   return(n_lines)
}

#
# Function: create_sample
#
# Purpose
#             Create sample reading data from all three sources
# Parameters
#             sampleSize: size of the sample to be created
#             dataType : what data set to be used:
#                                blg -> blogs
#                                twt -> twitter
#                                nws -> news
#
create_sample <- function(sampleSize, dataType)
{
  #
  # Read sample size data from soruce files
  #
  if(dataType=="blg")
   { 
      source_data <- read_n_lines(file_blogs, sampleSize)
  }
  if(dataType=="twt")
  { 
      source_data <- read_n_lines(file_twitter, sampleSize)
  }
  if(dataType=="nws")
  { 
    source_data <- read_n_lines(file_news, sampleSize)
  }
  
  #
  # Draw sample
  #
  set.seed(1357)
  source_sample <- sample(source_data, size=sampleSize, replace=TRUE)
  
  #
  # Clean up environment and return result
  #
  #rm(source_blogs, source_twitter, source_news)
  return(source_sample)
}

#
# Function: clenase_data
#
# Purpose
#         clean the Corpus to ensure a consistent data set
# Parameters
#         corpData: the data set (Corpus) to be transformed
#
cleanse_data <- function(corpData)
{
    #
    # Using besproke functions from the Text Mining library (tm) to do content cleansing
    #
    transformedCorp <- tm_map(corpData, removeWords, stopwords(language))        # remove unwanted words
  
    #
    # Using bespoke functions from the Text Mining Library (tm) to do mechanical cleansing
    #
    transformedCorp <- tm_map(transformedCorp, removeNumbers)                    # get rid of numbers
    transformedCorp <- tm_map(transformedCorp, stripWhitespace)                  # get rid of whitespaces
    transformedCorp <- tm_map(transformedCorp, removePunctuation)                # get rid of interpunction
    transformedCorp <- tm_map(transformedCorp, content_transformer(tolower))     # convert all to lowercase   
    transformedCorp <- tm_map(transformedCorp, PlainTextDocument)                # convert all to plain text
    transformedCorp <- tm_map(transformedCorp, stemDocument)                     # stem the text (https://en.wikipedia.org/wiki/Stemming)
    
    #
    # Ensure result returned is of datatype Corpus
    #
    transformedCorp <- Corpus(VectorSource(transformedCorp))  
    
    #
    # Return result
    #
    return(transformedCorp)
}

#
# Functions: tokenize_data_one, tokenize_data_two, tokenize_data_three
#
# Purpose
#         apply Weka tokenizers on provided data 
# Parameters
#         corpusSet : character vector with strings to be tokenized
#
tokenize_data_one <- function(corpusSet)
{
  # call Weka tokenization routine for single word set
  corpusTokenized <- NGramTokenizer(corpusSet, Weka_control(min=1, max=1))
}
tokenize_data_two <- function(corpusSet)
{
  # call Weka tokenization routine for double word set
  corpusTokenized <- NGramTokenizer(corpusSet, Weka_control(min=2, max=2))
}
tokenize_data_three <- function(corpusSet)
{
  # call Weka tokenization routine for triple word set
  corpusTokenized <- NGramTokenizer(corpusSet, Weka_control(min=3, max=3))
}

#
# Function: top_Ngram
#
# Purpose 
#         return the top n data in the provided ngram
# Paramters
#        nGram  : ngram data set to be processed
#        nCount : number of items from the top to be returned
#
top_NGram <- function(nGram,nCount)
{
   #
   # Sort the provided data based on observation frequency
   #
   wordSort <- sort(rowSums(as.matrix(nGram)), decreasing=TRUE)  
   
   #
   # Now create a data frame containing the words along with the observed frequency
   #
   wordFrame <- data.frame(words=names(wordSort), frequency=wordSort)
   
   #
   # Return result
   #
   return(wordFrame)
}

#
# Main program body
#

# Create a sample from our three data sources
sample_data <- create_sample(sampleSize,srcType)                  

# Transform sample_data to Corpus
corpus_data <- Corpus(VectorSource(sample_data))    

# Cleanup the Corpus data to get a consistent data set
corpus_transformed <- cleanse_data(corpus_data)     
rm(corpus_data)

# Use the tokenize_data function to create onegram, bigram, trigram
corpus_gram_one  <- TermDocumentMatrix(corpus_transformed, control = list(tokenize = tokenize_data_one))
corpus_gram_two  <- TermDocumentMatrix(corpus_transformed, control = list(tokenize = tokenize_data_two))
corpus_gram_three <- TermDocumentMatrix(corpus_transformed, control = list(tokenize = tokenize_data_three))
rm(corpus_transformed)

#
# Get the top n words from the grams
#
corpus_top_one  <- top_NGram(corpus_gram_one,maxWords)
corpus_top_two  <- top_NGram(corpus_gram_two,maxWords)
corpus_top_three <- top_NGram(corpus_gram_three,maxWords)

#
# Create word clouds
# 
wordcloud(corpus_top_three$words,corpus_top_three$frequency,max.words=maxWords,colors=brewer.pal(8,"Dark2"),scale=c(5,0.3),rot.per=0.3)

# Remove after completion
strwrap(corpus_transformed[[1]])