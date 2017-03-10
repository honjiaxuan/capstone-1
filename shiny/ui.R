#
# Coursera
# Data Science Specialization
#
# Capstone Project
# Using EN_US locale data
#
# Shiny App to wrap user interface around natural language prediction model
# User Interface Component
#
# March 2017, Erwin Vorwerk
#

#
# Load required libraries
#
suppressPackageStartupMessages(c(require(shiny),require(shinythemes)))

#
# Main function
#
shinyUI(navbarPage("Data Science Capstone - Coursera", 
        
        # Apply theme     
        theme = shinytheme("yeti"),
  
  # First tab - Application
  
  tabPanel("Application", 
  
   fluidRow(

      column(3,
             # 
             # Area for text input
             #
             textInput('text', h5(em(strong("Enter your text:"))), value = ""),
             
             h5('Then please press \'Submit\' to see the word prediction result.'),
             h5('For example:\'my first friend\' or \'will go home\'.'),
             
             HTML("<br>"),
             actionButton("submitButton","Submit")

            ),
      column(6,
             # 
             # Area for Next Word Predcition results
             #
             h4('Word Prediction Result', style ="color:orange"),
             
             h5('The objective of the application is to predict the next word based on your input. 
                 It will work only with English words. 
                 Once the engine reports it is ready, you can start entering your text. 
                 Press the Submit button to get the next predicted word'),
             
             # Display message once engine is ready
             h5(textOutput("message"), align="right"),
             
             # Feedback entered text
             h4("The text you have entered", style ="color:orange"),
             verbatimTextOutput("enteredWord", placeholder = TRUE),
             
             # Feedback next predicted word
             h4("The next word predicted by the engine:", style ="color:orange"),
             verbatimTextOutput("predictedWord", placeholder = TRUE),
             
             # Feedback prediction lapse time
             h5(em(textOutput("timing")))
            )
      
   ) # end fluidRow
   
  ), # end tabPanel

  tabPanel("About This Application",
           
     fluidPage(
      
       column(12,
       mainPanel(
              #includeMarkdown("presentation.md"),
              includeHTML("presentation.html"),
              width=12
              
       )
              )
       
     ) # end fluidRow
     
  ) # end tabPanel
  
 ) #end navbarPage       
 
) #end shinyUI
 
