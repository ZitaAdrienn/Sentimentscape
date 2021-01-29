
library(shiny)
library(tidyverse)
library(DBI)
library(RSQLite)


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

    conn <- dbConnect(RSQLite::SQLite(), "data/sentimentscape.db")
    
    sql_query <- "select text || ' (' || status_url || ')'
    from tw_text
    order by random()
    limit 5"
    
    sql_result <- dbGetQuery(conn, sql_query) %>%
      pull()

    dbDisconnect(conn)
    
    setProgress(value = 1)
    
  sql_result
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