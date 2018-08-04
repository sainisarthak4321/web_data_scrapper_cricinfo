## get all the required packages
library(rvest)
library(Rcrawler)
library(dplyr)
library(magrittr)
library(foreach)
library(doParallel)

## Settings
data_directory <- "D:/cricket/web_data/google_scorecard_files"
all_files <- list.files(data_directory, c(".html"))


scrapping_clusters = makeCluster(5)
registerDoParallel(scrapping_clusters)

batsman_data_all = foreach(i = 1 : length(all_files), .packages=c("dplyr", "rvest", "magrittr")) %dopar%
{
  
  data_cricinfo <- read_html(file.path(data_directory, all_files[[i]]))
  batsman_data_raw <- html_nodes(data_cricinfo, ".imspo_tps__rbpwd")
  batsman_data_raw <- data.frame(html_text(batsman_data_raw))
  
  stadium_name <- html_nodes(data_cricinfo, ".imspo_mff__mff-fv")
  stadium_name <- data.frame(html_text(stadium_name))
  
  batsman_data <- cbind(
    data.frame(player =  batsman_data_raw[seq(1, nrow(batsman_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(runs =  batsman_data_raw[seq(2, nrow(batsman_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(balls =  batsman_data_raw[seq(3, nrow(batsman_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(fours =  batsman_data_raw[seq(4, nrow(batsman_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(sixes =  batsman_data_raw[seq(5, nrow(batsman_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(sr =  batsman_data_raw[seq(6, nrow(batsman_data_raw), by = 6), ], stringsAsFactors = FALSE)) 
  
  batsman_data <- batsman_data %>%
    dplyr::filter(runs != "")%>%
    dplyr::mutate(stadium = stadium_name[1,])
  
  batsman_data_all <- rbind(batsman_data_all, batsman_data)
  bowler_data_all <- rbind(bowler_data_all, bowler_data)
}

bowler_data_all = foreach(i = 1 : length(all_files), .packages=c("dplyr", "rvest", "magrittr")) %dopar%
{
  data_cricinfo <- read_html(file.path(data_directory, all_files[[i]]))
  bowler_data_raw <- html_nodes(data_cricinfo, ".imspo_tps__rbpwod")
  bowler_data_raw <- data.frame(html_text(bowler_data_raw))
  
  bowler_data <- cbind(
    data.frame(player =  bowler_data_raw[seq(1, nrow(bowler_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(overs =  bowler_data_raw[seq(2, nrow(bowler_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(maiden =  bowler_data_raw[seq(3, nrow(bowler_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(runs =  bowler_data_raw[seq(4, nrow(bowler_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(wicket =  bowler_data_raw[seq(5, nrow(bowler_data_raw), by = 6), ], stringsAsFactors = FALSE),
    data.frame(economy =  bowler_data_raw[seq(6, nrow(bowler_data_raw), by = 6), ], stringsAsFactors = FALSE)) 
  
  bowler_data <- bowler_data %>%
    dplyr::filter(overs != "")
  
  bowler_data
}  
stopCluster(scrapping_clusters)