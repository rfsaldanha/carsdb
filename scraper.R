library(tidyverse)
library(rvest)
options(timeout = 60*3)

# Sleep time
st <- 1

# Empty tibble
cars_info <- tibble()

# Main page address
main_page <- "https://www.planetcarsz.com"

# For each maker first letter...
for(m in LETTERS){
  message(m)
  # Access makers list with that letter
  Sys.sleep(time = st)
  web <- read_html(paste0(main_page, "/fabricantes-de-carros/com-letra-", m))
  
  # List makers
  makers <- web %>% html_nodes("[class='fabricantes-manufacturers__manufacturer']")
  
  # For each maker...
  for(k in 1:length(makers)){
    # Isolate a maker
    maker_link <- makers[k] %>% html_element("a") %>% html_attr("href")
    maker_name <- sub('.*\\/', '', maker_link)
    
    message(maker_name)
    
    # Access maker first page
    Sys.sleep(time = st)
    maker_cars_page <- read_html(paste0(main_page, "/carros-da-", maker_name, "?p=1"))
    
    # Number of pages
    pages <- maker_cars_page %>% html_nodes("[class=pagination__list-item]")
    
    if(length(pages) != 0){
      last_page <- pages[length(pages)-1] %>% html_element("a") %>% html_attr("href")
      last_page <- sub('.*\\=', '', last_page)
      
      # Access maker pages
      for (p in 1:last_page){
        message(p)
        Sys.sleep(time = st)
        maker_cars_page <- read_html(paste0(main_page, "/carros-da-", maker_name, "?p=", p))
        
        # List vehicles on page
        maker_cars <- maker_cars_page %>% html_elements("article")
        
        # For each vehicle on page
        for(v in 1:length(maker_cars)){
          # Isolate vehicle
          car_link <- maker_cars[v] %>% html_element("a") %>% html_attr("href")
          Sys.sleep(time = st)
          car_page <- read_html(paste0(main_page, car_link))
          
          # Car info
          car_info <- car_page %>% html_element("h2") %>% html_text2() %>% str_replace_all("[\r\n]" , "") %>% str_trim()
          car_year <- str_extract(car_info, "[^-]+") %>% str_trim()
          car_maker <- maker_name %>% str_to_upper() %>% str_replace("-", " ") %>% str_replace("-", " ") %>% str_replace("LOGO", "") %>% str_trim()
          car_name <- str_extract(car_info, paste0("(?<=", car_maker, ").*")) %>% str_trim()
          
          message(car_info)
          
          # Car Picture
          car_picture <- car_page %>% html_element("img") %>% html_attr("src")
          
          # Store info
          tmp <- tibble(
            full_info = car_info,
            maker = car_maker,
            name = car_name,
            year = car_year,
            img = basename(paste0(main_page, car_picture))
          )
          
          download.file(url = URLencode(paste0(main_page, car_picture)), destfile = paste0("img/", basename(paste0(main_page, car_picture))), mode = "wb")
          
          cars_info <- bind_rows(cars_info, tmp)
        }
      }
    } else {
      # List vehicles on page
      maker_cars <- maker_cars_page %>% html_elements("article")
      
      # For each vehicle on page
      for(v in 1:length(maker_cars)){
        # Isolate vehicle
        car_link <- maker_cars[v] %>% html_element("a") %>% html_attr("href")
        Sys.sleep(time = st)
        car_page <- read_html(paste0(main_page, car_link))
        
        # Car info
        car_info <- car_page %>% html_element("h2") %>% html_text2() %>% str_replace_all("[\r\n]" , "") %>% str_trim()
        car_year <- str_extract(car_info, "[^-]+") %>% str_trim()
        car_maker <- maker_name %>% str_to_upper() %>% str_replace("-", " ") %>% str_replace("-", " ") %>% str_replace("LOGO", "") %>% str_trim()
        car_name <- str_extract(car_info, paste0("(?<=", car_maker, ").*")) %>% str_trim()
        
        message(car_info)
        
        # Car Picture
        car_picture <- car_page %>% html_element("img") %>% html_attr("src")
        
        # Store info
        tmp <- tibble(
          full_info = car_info,
          maker = car_maker,
          name = car_name,
          year = car_year,
          img = basename(paste0(main_page, car_picture))
        )
        
        download.file(url = URLencode(paste0(main_page, car_picture)), destfile = paste0("img/", basename(paste0(main_page, car_picture))), mode = "wb")
        
        
        cars_info <- bind_rows(cars_info, tmp)
      }
    }
    
    saveRDS(object = cars_info, file = "cars_info.rds")
    
  }
}

