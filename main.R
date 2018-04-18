library(rvest)
library(XML)
library(RCurl)
library(rlist)
library(jsonlite)
library(stringr)
library(httr)
library(xlsx)

doc <- htmlParse(getURL(paste("https://www.populationpyramid.net/bangladesh/2017/", sep = "")),asText=TRUE)

country_table <- getNodeSet(doc, '//*[@id="countryDropdown"]/a')
countries <- data.frame(country=character(), id=character(), stringsAsFactors = FALSE)

for(n in 1:length(country_table)){
  con <- xmlValue(country_table[[n]])
  id <- xmlAttrs(country_table[[n]])["country"]
  countries[nrow(countries) + 1, ] <- c(con, id)
}

age_range <- c("20-24", "25-29", "30-34")
index <- data.frame(country=character(), age_range_male=numeric(), age_range_female=numeric(), t_index=numeric(), stringsAsFactors = FALSE)

for(n in 1:nrow(countries)) {
  pyramid <- fromJSON(paste0("https://www.populationpyramid.net/api/pp/", countries[n, 2], "/2017/"), flatten = TRUE)
  total_male <- sum(pyramid$male[pyramid$male$k %in% age_range,'v'])
  total_female <- sum(pyramid$female[pyramid$female$k %in% age_range,'v'])
  t_index <- (total_male - total_female)/total_male
  
  index[nrow(index) + 1, ] <- list(countries[n, 1], total_male, total_female, t_index)
}

write.xlsx(index, "imbalance.xlsx")
