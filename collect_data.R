library(rtweet)
library(tidyverse)

collect_data <- function(term = NULL, place = NULL) {
  token <- get_token()
  
  search_word <- term %>%
    str_replace_all(c(", " = " OR "))
  
  cities <- read_csv("data/cities.csv") %>%
    select("country", "city", "lat", "lng")
  
  search_place <- place %>%
    str_replace_all(c(", " = "|"))
  
  if (any(str_detect(cities$country, search_place))) {
    search_place <- filter(cities, str_detect(country, search_place)) %>%
      select("city", "lat", "lng")
  } else if (any(str_detect(cities$city, search_place))) {
    search_place <- filter(cities, city == search_place) %>%
      select("city", "lat", "lng")
  } else {
    search_place <- NULL
  }
  
  if (!is.null(search_place)) {
    search_coords <- str_c('"',
                           str_c(search_place$lat, search_place$lng, "25mi",
                                 sep = ",", collapse = '","'),
                           '"')
  } else {
    search_coords <- ""
  }
  
  all_tweets <- search_tweets(
    q = search_word,
    n = 18000,
    type = "recent",
    include_rts = FALSE,
    geocode = writeLines(search_coords),
    max_id = NULL,
    parse = TRUE,
    retryonratelimit = TRUE,
    verbose = TRUE)
  
  tw_text <- all_tweets %>%
    select("user_id", "status_id", "created_at", "screen_name", "text",  
           "favorite_count", "retweet_count", "quote_count", "reply_count", "hashtags",
           "symbols", "mentions_screen_name", "lang", "place_url", "place_name",
           "place_full_name", "place_type", "country", "country_code", "geo_coords") %>%
    write_as_csv(file_name = "data/tw_text.csv")
  
  tw_users <- all_tweets %>%
    select("user_id", "name", "location", "description",
           "followers_count", "friends_count", "listed_count", "statuses_count",
           "favourites_count", "account_created_at", "verified", "account_lang") %>%
    unique() %>%
    write_as_csv(file_name = "data/tw_users.csv")
  }