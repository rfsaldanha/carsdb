library(tidyverse)
library(rvest)

main_page <- "https://www.planetcarsz.com"

web <- read_html(paste0(main_page, "/fabricantes-de-carros/com-letra-F"))

# Makers
makers <- web %>% html_nodes("[class='fabricantes-manufacturers__manufacturer']")

# Isolate a maker
maker_link <- makers[38] %>% html_element("a") %>% html_attr("href")
maker_name <- sub('.*\\/', '', maker_link)
maker_cars_page <- read_html(paste0(main_page, "/carros-da-", maker_name, "?p=1"))

# List vehicles on page
maker_cars <- maker_cars_page %>% html_elements("article")

# Isolate vehicle
car_link <- maker_cars[5] %>% html_element("a") %>% html_attr("href")
car_page <- read_html(paste0(main_page, car_link))

# Car info
car_info <- car_page %>% html_element("h2") %>% html_text2() %>% str_replace_all("[\r\n]" , "") %>% str_trim()
car_year <- str_extract(car_info, "[^-]+") %>% str_trim()
car_maker <- maker_name %>% str_to_upper()
car_name <- str_extract(car_info, "(?<=FORD).*") %>% str_trim()


# Car Picture
car_page %>% html_element("img") %>% html_attr("src")
