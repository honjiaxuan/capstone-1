#
# Coursera
# Data Science Specialization
#
# Capstone Project
# Using EN_US locale data
#
# Shiny App to wrap user interface around natural language prediction model
# Server Component
#
# March 2017, Erwin Vorwerk
#

# Global settings
data_path  = './data'
locale     = "en_US"
words      = "en"

# Initialize variables
locale_path <- paste(data_path, "/", locale, "/", sep = "")
buttonPressed <- 0

# nGram file name
nGramFile <- paste(data_path, "/", locale,".x.nGram.RData", sep ="")

#
# Load required libraries without messages
#
suppressPackageStartupMessages(c(require(shiny),require(ANLP)))

#
# Load prediction n-gram data files, but suppress messages
#
load(nGramFile)

#
# Kick off the server component
#
shinyServer(function(input, output)
 {
  
     # Only execute if the submit button was pressed   
     predictWord  <- eventReactive(input$submitButton, 
                                 {
     
                                 # Start timer
                                 startTime <- Sys.time()
                                     
                                 # Predcit the next word base don user input
                                 predictWord <- predict_Backoff(input$text, nGramModelsList)

                                 # Calculate lapse/processing time
                                 lapseTime <- Sys.time()-startTime
                                 output$timing <- renderText({paste(sprintf("total processing time: %5.2f msecs",1000*lapseTime))})
                                 
                                 # Return predicted word
                                 predictWord
                                 })
  
   # Return indication that user can start (after large nGrams file has loaded)
   output$message <- renderText("(the engine is now operational)")
   
   # Processing time
   #output$timing <- renderText({paste(sprintf("total processing time: %5.2f msecs",1000*lapseTime))})
   
   # Return the predicted word and text input to be displayed to the user
   output$predictedWord <- renderText(predictWord())
   output$enteredWord   <- renderText({input$text}, quoted = FALSE)

 }
)
