# Setup ------------------------------------------------------------------------

## Libraries  ------------------------------------------------------------------
library(tidyverse)
library(parallel)
library(data.table)
source("src/_shared_functions.R")

## Environmental variables  ----------------------------------------------------
base_path <- "data/external/reit_returns/"
dividend_path <- "data/external/reit_dividends/"

## Custom functions  -----------------------------------------------------------
coma2numeric <- function(string){
  as.numeric(str_replace(string, ",", "."))
}

import_dividend <- function(filename){
  ticker <- str_extract(filename, "^[^.]+")
  data_frame <- fread(paste0(dividend_path, filename))|>
                arrange(Date)|>
                mutate(ticker = ticker, 
                       Date = as.IDate(paste0(substr(Date, 1, 8), "01")),
                       Dividends = cumsum(Dividends))
}

import_returns <- function(filename, DIVIDENDS_DF=REIT_DIVIDENDS){
  
  if (str_detect(filename, "Historical")) {
    data_frame <- fread(paste0(base_path,filename))|>
                  rename(Close=Price, Volume=Vol.)|>
                  mutate(Date=as.IDate(Date, format="%m/%d/%Y"),
                         Volume=if_else(str_detect(Volume, "K"), 
                                  as.numeric(str_remove(Volume, "K"))*1e3, 
                                  as.numeric(str_remove(Volume, "M"))*1e6))
    ticker <- str_extract(filename, "\\b[A-Z]+\\b")
  } else if (str_detect(filename, "Historyczne")) {
    data_frame <- fread(paste0(base_path,filename))|>
                  mutate(Close=coma2numeric(Ostatnio),
                         Date=as.IDate(Data, format="%d.%m.%Y"),
                         Volume=if_else(str_detect(Wol., "K"), 
                                  coma2numeric(str_remove(Wol., "K"))*1e3, 
                                  coma2numeric(str_remove(Wol., "M"))*1e6))
    ticker <- str_extract(filename, "\\b[A-Z]+\\b")
  } else {
    data_frame <- fread(paste0(base_path,filename))
    ticker <- str_extract(filename, "^[^.]+")
  }
  
  
  
  data_frame <- data_frame |> 
                mutate(ticker=ticker) |>
                left_join(DIVIDENDS_DF, by=c("ticker", "Date")) |>
                filter(Date<"2024-07-02") |> 
                arrange(Date) |>
                fill(Dividends, .direction = "down")|>
                mutate(Close = if_else(is.na(Dividends), Close, Close+Dividends),
                       monthly_return = lead(Close)/Close, 
                       ticker=ticker) |> 
                group_by(year=as.integer(substr(Date, 1,4)))|> 
                mutate(cnt=n(), 
                       volume = mean(Volume), 
                       standard_deviation = sd(monthly_return)*sqrt(12), 
                       total_return = cumprod(monthly_return)) |>
                ungroup() |>
                filter(cnt==12&substr(Date, 6,7)=="12") |>
                select(ticker, year, standard_deviation, total_return, volume)
  
  return(data_frame)
  
}

#Main logic --------------------------------------------------------------------
REIT_DIVIDENDS <- list.files(dividend_path)|>
                  lapply(import_dividend)|>
                  rbindlist()

REIT_RETURNS <- list.files(base_path)|>
                lapply(import_returns, DIVIDENDS_DF=REIT_DIVIDENDS)|>
                rbindlist()|>
                suppressWarnings() 
#NA introduced by coercion in as.numeric due to empty chars

#Export results  ---------------------------------------------------------------
dta_export(REIT_RETURNS)
