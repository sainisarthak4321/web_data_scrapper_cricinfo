library(taskscheduleR)
library(twilio)
library(rvest)
library(magrittr)
library(jsonlite)

## get the login details 
login_info <- jsonlite::fromJSON("D:/Login_details.json")

Sys.setenv(TWILIO_SID = login_info$SID)
Sys.setenv(TWILIO_TOKEN = login_info$TOKEN)

my_phone_number <- login_info$MY_PHONE_NUMBER
twilios_phone_number <- login_info$TWILIO_PHONE_NUMBER


latest_exchange_rate = read_html("https://www.x-rates.com/calculator/?from=USD&to=INR&amount=1")
exchange_rate = html_nodes(latest_exchange_rate, ".ccOutputRslt")
exchange_rate <- data.frame(exchange_rate = html_text(exchange_rate), stringsAsFactors = FALSE)

exchange_rate %<>%
  dplyr::mutate(exchange_rate = as.numeric(gsub("[A-z]", "", exchange_rate)))


if(exchange_rate > 68)
{
  tw_send_message(from = twilios_phone_number, to = my_phone_number, 
                  body = paste0("Good day to exchange currency. Todays rate: ", exchange_rate))
  
}






