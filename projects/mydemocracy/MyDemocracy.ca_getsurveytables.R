library(rvest); library(dplyr); library(readr); 
library(jsonlite); library(stringr)

# scrape page html
page.html <- 
     read_html("http://web.archive.org/web/20170208190748/https://www.canada.ca/en/campaign/electoral-reform/learn-about-canadian-federal-electoral-reform/mydemocracyca-online-digital-consultation-engagement-platform.html")

# scrape raw html data from the 8 tables in section 4.1 "Response Rates"
section_4.1_tables <- 
     page.html %>% 
     html_nodes(".table-bordered") %>% 
     .[1:8]

# Loop through each table, grab the data and add it to a list
section_4.1_data <- vector(mode = "list", length = 8)
for(i in 1:8){
     section_4.1_data[[i]]$table_name <- 
          section_4.1_tables %>% .[i] %>% html_nodes("small") %>% html_text() %>% make.names()
     section_4.1_data[[i]]$data <- 
          section_4.1_tables %>% .[i] %>% html_table(fill = TRUE) %>% .[[1]]
     if(str_detect(section_4.1_data[[i]]$data[nrow(section_4.1_data[[i]]$data),1], "\\* Source")){
          section_4.1_data[[i]]$data <- section_4.1_data[[i]]$data[-nrow(section_4.1_data[[i]]$data),]
     }
}

# Write data to single JSON file
write_file(toJSON(section_4.1_data), "projects/mydemocracy/data/mydemocracyca_data_section4-1.json")

# Write data to 8 csv files
for(i in 1:8){
     write_csv(section_4.1_data[[i]]$data, 
               path = paste0("projects/mydemocracy/data/", 
                             section_4.1_data[[i]]$table_name, 
                             ".csv"))
}

# # scrape raw html data from the 30 tables in Appendix A "Findings"
# appendix_a_tables <- 
#      page.html %>% 
#      html_nodes(".table-bordered") %>% 
#      .[10:39]
# 
# appendix_a_data <- vector(mode = "list", length = 30)
# for(i in 1:30){
#      appendix_a_data[[i]] <- appendix_a_tables[[i]] %>% html_table()
# }
# 
# appendix_a_text <- page.html %>% html_nodes(".lst-spcd a") %>% html_text()
# appendix_a_ids <- read_lines("projects/mydemocracy/data/appendix_a_ids.txt")
# 
# names(appendix_a_data) <- appendix_a_text %>% lapply(function(x) str_extract(x, "\\d\\.\\d\\.?\\d?") %in% appendix_a_ids) %>% unlist() %>%
#      appendix_a_text[.]
# 
# ## NEED TO FIGURE OUT THE 30 VS 31 ISSUE (NOT SURE HOW MANY TABLES THERE ARE)