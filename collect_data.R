library(tidyverse)
library(tidyfst)
library(rtweet)

clean_list <- function(x) {
  x %>%
    paste0(collapse = ",") %>%
    str_replace_all(c("NA," = ""))
}



cities <- parse_fst("data/cities.fst")

search_place <- input$search_place %>%
  str_replace_all(c(", " = "|"))

if (any(str_detect(cities$country, search_place))) {
  search_coords <- cities %>%
    filter_fst(str_detect(country, search_place))
} else if (any(str_detect(cities$city, search_place))) {
  search_coords <- cities %>%
    filter_fst(str_detect(city, search_place))
} else {
  search_coords <- NULL
}

if (!is.null(search_coords)) {
  search_coords_str <- str_c(
    '"',
    str_c(search_coords$lat, search_coords$lng, "25mi",
          sep = ",", collapse = '","'
    ),
    '"'
  )
} else {
  search_coords_str <- ""
}


search_term <- input$search_term %>%
  str_replace_all(c(", " = " OR "))

all_tweets <- search_tweets(
  q = search_term,
  n = 18000,
  type = "recent",
  include_rts = FALSE,
  geocode = writeLines(search_coords_str),
  max_id = NULL,
  parse = TRUE,
  retryonratelimit = FALSE,
  verbose = TRUE
)


all_tweets %>%
  select(
    "user_id", "status_id", "created_at", "screen_name", "text",
    "favorite_count", "retweet_count", "quote_count", "reply_count", "hashtags",
    "symbols", "mentions_screen_name", "lang", "place_url", "place_name",
    "place_full_name", "place_type", "country_code", "geo_coords", "status_url"
  ) %>%
  mutate(across(where(is.list), clean_list)) %>%
  export_fst("data/tw_text.fst")

all_tweets %>%
  select(
    "user_id", "name", "location", "description",
    "followers_count", "friends_count", "listed_count", "statuses_count",
    "favourites_count", "account_created_at", "verified", "account_lang"
  ) %>%
  unique() %>%
  export_fst("data/tw_users.fst")

rm(all_tweets)