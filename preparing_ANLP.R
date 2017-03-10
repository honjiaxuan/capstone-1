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
# Updates
# 
# March 2017  Run time and results optimized using the ANLP CRAN package
#

# Tweak OSX to prevent R processes to choke on memory allocation (bug)
# options(mc.cores = 1)

# Ensure JVM has enough memory to perform RWeka functions
options(java.parameters = "- Xmx1024m")

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
require(ANLP)

# Global settings
data_path  = './data/final'
language   = "english"
locale     = "en_US"
words      = "en"
extension  = ".txt"
sampleSize = 0.10

# Intialize seeder
set.seed(1357)

# Initialize variables
locale_path <- paste(data_path, "/", locale, "/", sep = "")

# Source file names
file_blogs <- paste(locale_path, locale,".blogs", extension, sep ="")
file_news <- paste(locale_path, locale,".news", extension, sep="")
file_twitter <- paste(locale_path, locale,".twitter", extension, sep="")

# Target file names
n1_file <- paste(locale_path, locale,".1.nGram", ".RData", sep="")
n2_file <- paste(locale_path, locale,".2.nGram", ".RData", sep="")
n3_file <- paste(locale_path, locale,".3.nGram", ".RData", sep="")
nx_file <- paste(locale_path, locale,".x.nGram", ".RData", sep="")

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
    n_lines <- readTextFile(fileName,"UTF-8")
  }
  
  return(n_lines)
}


#
#
# NEWS
# 
# Read, convert, cleanse 'news' data, then remove orginal data from environment
#

# Read the content of the language files into variables 
tracer_msg("Read news")
lines_news    <- read_content(file_news)
length(lines_news)

# Take a sample of SampleSize & clean up
tracer_msg("Sample news")
lines_news_sample    <- sampleTextData(lines_news,sampleSize)
length(lines_news_sample)
rm(lines_news)

# Cleanse the data & clean up
tracer_msg("Cleanse news")
lines_news_cleansed <- cleanTextData(lines_news_sample)
rm(lines_news_sample)


#
#
# BLOGS
# 
# Read, convert, cleanse 'blogs' data, then remove orginal data from environment
#

# Read the content of the language files into variables 
tracer_msg("Read blogs")
lines_blogs    <- read_content(file_blogs)
length(lines_blogs)

# Take a sample of SampleSize & clean up
tracer_msg("Sample blogs")
lines_blogs_sample    <- sampleTextData(lines_blogs,sampleSize)
length(lines_blogs_sample)
rm(lines_blogs)

# Cleanse the data & clean up
tracer_msg("Cleanse blogs")
lines_blogs_cleansed <- cleanTextData(lines_blogs_sample)
rm(lines_blogs_sample)



#
#
# TWITTER
# 
# Read, convert, cleanse 'twitter' data, then remove orginal data from environment
#

# Read the content of the language files into variables 
tracer_msg("Read twitter")
lines_twitter    <- read_content(file_twitter)
length(lines_twitter)

# Take a sample of SampleSize & clean up
tracer_msg("Sample twitter")
lines_twitter_sample    <- sampleTextData(lines_twitter,sampleSize)
length(lines_twitter_sample)
rm(lines_twitter)

# Cleanse the data & clean up
tracer_msg("Cleanse twitter")
lines_twitter_cleansed <- cleanTextData(lines_twitter_sample)
rm(lines_twitter_sample)


#
# Concatenate sampled & cleansed lines
#

lines_all <- c(lines_blogs_cleansed,lines_news_cleansed, lines_twitter_cleansed)
rm(lines_blogs_cleansed, lines_news_cleansed, lines_twitter_cleansed)
gc()

#
# Create n-gram models
#

n1gramModel <- generateTDM(lines_all,1)
n2gramModel <- generateTDM(lines_all,2)
n3gramModel <- generateTDM(lines_all,3)

nGramModelsList <- list(n1gramModel, n2gramModel, n3gramModel)
rm(lines_all)

#
# Save nGram files for later usage
#
if(!file.exists(n1_file))
{
  tracer_msg("Save n1 file")
  save(n1gramModel, file=n1_file)
}

if(!file.exists(n2_file))
{
  tracer_msg("Save n2 file")
  save(n2gramModel, file=n2_file)
}

if(!file.exists(n3_file))
{
  tracer_msg("Save n3 file")
  save(n3gramModel, file=n3_file)
}

if(!file.exists(nx_file))
{
  tracer_msg("Save n3 file")
  save(nGramModelsList, file=nx_file)
}

