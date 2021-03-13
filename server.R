
library(shiny)
library(tidyverse)
library(tidyfst)


shinyServer(function(input, output, session) {

  dataUpdated <- reactiveVal(FALSE)
  
  observeEvent(input$search, 
               ignoreInit = TRUE, {
                 dataUpdated(FALSE)
    source("collect_data.R",
           local = TRUE)
                 dataUpdated(TRUE)
                 })

  sampleTweets <- eventReactive(dataUpdated(),
                                ignoreInit = TRUE, {
    req(dataUpdated())
                                  
    withProgress({
    tw_text <- parse_fst("data/tw_text.fst")
    
spl <-  sample(nrow(tw_text), 5)

    result <- tw_text %>%
  select_fst(text, status_url) %>%
      slice_fst(spl) %>%
      transmute(tweets = paste0(text, " (", status_url, ")")) %>%
      pull()
    
    setProgress(value = 1)
    
  result
  },
  
  message = "Sampling...")
  })
  
  output$text <- renderText({
    sampleTweets()
    "The  tweets below are examples from your data set:"
  })
  
output$table <- renderTable({
  sampleTweets()
   },
  colnames = FALSE)
})