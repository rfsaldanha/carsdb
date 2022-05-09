library(tidyverse)
library(rvest)

main_page <- "https://www.planetcarsz.com"

web <- read_html(paste0(main_page, "/carros?p=1"))

cars <- web %>% html_elements("article")

tmp_link <- cars[3] %>% html_element("a") %>% html_attr("href")

tmp_page <- read_html(paste0(main_page, tmp_link))

# Title
tmp_page %>% html_element("h2") %>% html_text2()

# Picture
tmp_page %>% html_element("img") %>% html_attr("src")
