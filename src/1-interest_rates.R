# Setup ------------------------------------------------------------------------

## Libraries  ------------------------------------------------------------------
library(tidyverse)
library(data.table)
library(readxl)
source("src/_shared_functions.R")

## Environmental variables  ----------------------------------------------------
base_path <- "data/external/interest_rates/"

## Custom functions  -----------------------------------------------------------
annual_rate <- function(DF, var, monetary_union_name){
  DF|>
    group_by(year=substr(DATE, 1,4))|>
    summarise(interest_rate = mean({{var}}, na.rm=T), monetary_union=monetary_union_name)|>
    ungroup()
}

# Main logic  ------------------------------------------------------------------

## Singapore  ------------------------------------------------------------------
SG_RATE <- fread(paste0(base_path, "Domestic Interest Rates.csv"), skip=7, 
             col.names = c("year", "month", "day", "interbank_rate", "deposit_rate"))|>
           fill(year, .direction = "down")|>
           mutate(deposit_rate=as.numeric(deposit_rate), interbank_rate=as.numeric(interbank_rate))|>
           replace_na(list(deposit_rate=0, interbank_rate=0))|>
           group_by(year)|>
           summarise(interest_rate=mean((interbank_rate+deposit_rate)/2, na.rm=F), monetary_union="Singapore")

## Bank of England  ------------------------------------------------------------
DATE_SEQ <- data.frame(DATE=seq(as.Date("1997/04/01"), as.Date("2023/12/01"), "months"))

BOE_RATE <- read_excel(paste0(base_path,"baserate.xls"), 
                       sheet = "HISTORICAL SINCE 1694", skip = 950)|>
            select(year=`Repo Rate`,month=...3, value=...4)|>
            filter(!is.na(value))|>
            fill(year, .direction = "down")|>
            mutate(DATE=mdy(paste0(month, " 1st ", year)))

BOE_RATE <- DATE_SEQ |> 
            left_join(BOE_RATE, by="DATE")|>
            fill(value, .direction = "down")|>
            annual_rate(value, "United Kingdom")

## European Central Bank  ------------------------------------------------------
ECB_RATE <- fread(paste0(base_path,"ECBR.csv"))|>
            annual_rate(ECBDFR, "Eurozone")

##Federal Reserve  -------------------------------------------------------------
FED_RATE <- fread(paste0(base_path,"RIFSPFFNA.csv"))|>
            reframe(year=substr(DATE, 1, 4), 
                    interest_rate = RIFSPFFNA, 
                    monetary_union="United States")

##Bank of Japan  ---------------------------------------------------------------
BOJ_RATE <- fread(paste0(base_path,"ir01_m_1_en.csv"), skip = 8, 
                  col.names = c("DATE", "interest_rate"))|>
            annual_rate(interest_rate, "Japan")

# Export results  --------------------------------------------------------------
INTEREST_RATES <- rbind(BOE_RATE, ECB_RATE, FED_RATE, SG_RATE, BOJ_RATE)|>
                  filter(year>1998&year<2024)

dta_export(INTEREST_RATES)