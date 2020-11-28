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

if (!exists("search_place")) {
  search_place <- readline(prompt = "Where?")
}

if (any(search_place %in% cities$country)) {
  search_place <- filter(cities, country == search_place) %>%
                         select("city", "lat", "lng")
} else if (any(search_place %in% cities$city)) {
  search_place <- filter(cities, city == search_place) %>%
                         select("city", "lat", "lng")
} else {
  rm(search_place)
}

if (!exists("search_word")) {
  search_word <- readline(prompt = "What?")
}

search_coords <- paste('"',
                       paste(search_place$lat, search_place$lng, "25mi",
                             sep = ",", collapse = '","'),
                       '"')

tweets <- search_tweets(
  q = search_word,
  n = 18000,
  type = "recent",
  include_rts = FALSE,
  geocode = cat(search_coords),
  max_id = NULL,
  parse = TRUE,
  retryonratelimit = TRUE,
  verbose = TRUE)

write_as_csv(tweets, file_name = "sentiment.csv")
