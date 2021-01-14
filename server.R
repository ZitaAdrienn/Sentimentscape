
library(shiny)
library(tidyverse)
library(DBI)
library(RSQLite)


shinyServer(function(input, output, session) {

  dataUpdated <- reactiveVal(FALSE)
  
  observeEvent(input$search, {
    source("collect_data.R", local = TRUE)
                 dataUpdated(TRUE)
                 },
               ignoreInit = TRUE)

  sampleTweets <- eventReactive(dataUpdated(), {
    conn <- dbConnect(RSQLite::SQLite(), "data/sentimentscape.db")
    
    sql_query <- "select text
    from tw_text
    order by random()
    limit 5"
    
    sql_result <- dbGetQuery(conn, sql_query) %>%
      pull()

    dbDisconnect(conn)

    isolate(dataUpdated(FALSE))
    
  sql_result
  })
  
  output$text <- renderText({
    sampleTweets()
    "The  tweets below are examples from your data set:"
  })
  
output$table <- renderTable({
  sampleTweets()
   sampleTweets()
   })

})