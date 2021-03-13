library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Sentimentscape"),
  
  fluidRow(
    
    column(3,
           textInput("search_term", "Terms to check:", ""),
           textInput("search_place", "Geographic location:", "everywhere"),
           actionButton("search", "Load tweets!")
    ),
    
    column(3,
           numericInput("number", "Number of topics:", value = 1, min = 1, max = 15, step = 1),
           checkboxInput("tuning", "Guess number!")
    ),
    
    column(3,
           radioButtons("results_mode", "View results:",
                        c("Search results" = "search", "Other tweets" = "other", "User favourites" = "favourites"))
    ),
    
    column(3,
           checkboxGroupInput("sentiment", "Sentiment:",
                              c("Positive" = "positive", "Negative" = "negative", "Neutral" = "neutral"))
    )
  ),
  
  fluidRow(
    column(12,
           textOutput("text"),
           tableOutput("table")
    )
  )
))
