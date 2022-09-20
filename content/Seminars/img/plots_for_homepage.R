remotes::install_github("kjhealy/covdata")
remotes::install_github("kjhealy/ukelection2019")
library(covdata)
library(ukelection2019)
library(tidyverse)

data(apple_mobility)

uk_mob <- filter(apple_mobility, region == "United Kingdom")

ggplot(uk_mob, aes(date, score, colour = transportation_type)) +
  geom_point() + geom_smooth() + theme_minimal() +
  labs(x = "Date in 2020", y = "Relative activity score", colour = "Transport method",
       title = "Transport usage in the UK in 2020")

ggsave("covid_transport.png", path = "img/")

elec <- ukelection2019::ukvote2019

toptwo <- elec %>%
  filter(vrank %in% c(1,2))

winners <- toptwo %>%
  filter(vrank == 1)

win_margs <- toptwo %>%
  group_by(constituency) %>%
  summarise(margin_vic = abs(diff(vote_share_percent)),
            winner = case_when(vrank == 1 ~ party_name),
            electorate = electorate) %>%
  ungroup() %>%
  drop_na()

closest_races <- win_margs %>%
  arrange(margin_vic) %>%
  head(n = 30L) %>%
  mutate(party_col = case_when(
    winner == "Conservative" ~ "#0087DC",
    winner == "Labour" ~ "#DC241f",
    winner == "Liberal Democrat" ~ "#FDBB30",
    winner == "Scottish National Party" ~ "#FFF95D",
    winner == "Sinn Féin" ~ "#326760"
  ))

ggplot(closest_races, aes(x = reorder(constituency, desc(margin_vic)), y = margin_vic, fill = winner)) + 
  geom_bar(stat = "identity") + 
  scale_fill_manual(values = c("Conservative" = "#0087DC",
                               "Labour" = "#DC241f",
                               "Liberal Democrat" = "#FDBB30",
                               "Scottish National Party" = "#FFF95D",
                               "Sinn Féin" = "#326760")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = "", y = "Vote share difference between first and second place", fill = "Winning party",
       title = "Twenty closest-run constituencies in 2019 UK general election") 

ggsave("close_races_2019.png", path = "img/")
