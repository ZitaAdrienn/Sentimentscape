# Sentimentscape
This is my new social listening and sentiment analysis project written in R.
đ
Before running the Shiny app you need to do the following:
- Install required packages

\ install.packages("rtweet", "tidyverse", "tidytext") \
- Create your token for Twitter API
\ token <- create_token(
    app = "your_app",
    consumer_key = "your_consumer_key",
    consumer_secret = "your_consumer_secret",
    access_token = "your_access_token",
    access_secret = "your_access_secret",
    set_renv = TRUE) \

For optaining your own Twitter API keys I recommend you to visit www.developer.twitter.com.