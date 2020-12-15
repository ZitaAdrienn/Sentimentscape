library(rtweet)
library(tidyverse)

token <- get_token()

if (!exists("token")) {
  app <- readline(prompt = "Name of your app?")
  consumer_key <- readline(prompt = "What's your API key?")
  consumer_secret <- readline(prompt = "What's your secret key?")
  access_token <- readline(prompt = "What's your access token?")
  access_secret <- readline(prompt = "What's your access secret key?")

  token <- create_token(
    app = app,
    consumer_key = consumer_key,
    consumer_secret = consumer_secret,
    access_token = access_token,
    access_secret = access_secret,
    set_renv = TRUE)
  
  rm(consumer_key, consumer_secret, access_token, access_secret)
}

cities <- read_csv("cities.csv") %>%
select("country", "city", "lat", "lng")

  search_place <- readline(prompt = "Where?")

if (any(search_place %in% cities$country)) {
  search_place <- filter(cities, country == search_place) %>%
                         select("city", "lat", "lng")
} else if (any(search_place %in% cities$city)) {
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

  search_word <- readline(prompt = "What?") %>%
    str_replace_all(c(", " = " OR "))


tweets <- search_tweets(
  q = search_word,
  n = 18000,
  type = "recent",
  include_rts = FALSE,
  geocode = writeLines(search_coords),
  max_id = NULL,
  parse = TRUE,
  retryonratelimit = TRUE,
  verbose = TRUE)

rm(search_place, search_coords)

tw_text <- tweets %>%
  select("user_id", "status_id", "created_at", "screen_name", "text",  
         "favorite_count", "retweet_count", "quote_count", "reply_count", "hashtags",
         "symbols", "mentions_screen_name", "lang", "place_url", "place_name",
         "place_full_name", "place_type", "country", "country_code", "geo_coords") %>%
  write_as_csv(file_name = "tw_text.csv")

tw_users <- tweets %>%
  select("user_id", "name", "location", "description",
         "followers_count", "friends_count", "listed_count", "statuses_count",
         "favourites_count", "account_created_at", "verified", "account_lang") %>%
  unique() %>%
  write_as_csv(file_name = "tw_users.csv")
