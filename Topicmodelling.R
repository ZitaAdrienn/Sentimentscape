library(tidyverse)
library(tidytext)
library(textutils)
library(topicmodels)
library(stopwords)
library(ldatuning)






tw_text <- read_csv("tw_text.csv")

tw_text$text <- map_chr(tw_text$text, HTMLdecode)



lang <- tw_text$lang %>%
  unique() %>%
  .[. %in% c("ro","da","nl","en","fr","fi","de","hu","it","no","ru","sp","pt","se")] %>%
  map(stopwords) %>%
  unlist() %>%
  tibble(word = ., lexicon = c("other")) %>%
  bind_rows(stop_words)





filter_word <- str_replace_all(search_word, c(" OR " = "|", " " = "|"))

tw_text <- tw_text %>%
  select("user_id", "text") %>%
  unnest_tokens(word, text, token = "tweets") %>%
  anti_join(lang) %>%
  filter(!str_detect(word, "^@")) %>%
 count(user_id, word, sort=TRUE) %>%
  cast_dtm(user_id, word, n)

tw_k <- FindTopicsNumber(tw_text,
  topics = seq(from = 2, to = 7, by = 1),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 47),
  mc.cores = 4L)

tw_k_tuned <- bind_rows(
  filter(tw_k, Griffiths2004 == max(Griffiths2004)),
  filter(tw_k, CaoJuan2009 == min(CaoJuan2009)),
  filter(tw_k, Arun2010 == min(Arun2010)),
  filter(tw_k, Deveaud2014 == max(Deveaud2014))
)

k <-  parse_number(names(which(max(table(tw_k_tuned$topic))==table(tw_k_tuned$topic))))

tw_lda <- LDA(tw_text, k = k[1], control = list(seed = 47))

tw_top_terms <- tidy(tw_lda, matrix = "beta") %>%
  filter(!str_detect(term, filter_word)) %>%
           group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

  