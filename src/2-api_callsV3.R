# Setup ------------------------------------------------------------------------

## Libraries  ------------------------------------------------------------------
library(httr)
library(jsonlite)
library(tidyverse)
library(parallel)
library(data.table)
source("src/_shared_functions.R")

## Environmental variables  ----------------------------------------------------
source("src/_data2.R") #loads the "ls_trackers" vector, better readability
ls_types <-  c("income-statement","balance-sheet-statement","cash-flow-statement")
ls_indicators <- c("NY.GDP.MKTP.KD", "NY.GDP.DEFL.KD.ZG.AD", "SP.POP.TOTL")
threads_number <- 3

## Custom functions  -----------------------------------------------------------
camel_to_snake <- function(string) {
  string |>
    gsub("([a-z0-9])([A-Z])", "\\1_\\2", .) |>  
    tolower()  
}

import_api <- function(type, ticker, source) {
  url <- switch(source,
    "DCF" = paste0("https://discountingcashflows.com/api/", type, "/", ticker, "/"),
    "WB" = paste0("https://api.worldbank.org/v2/country/", ticker, "/indicator/", type, "?format=json"),
    stop("Invalid source provided")
  )
  
  api_response <- GET(url)
  
  if (api_response$status_code != 200) {  
    warning("API call failed")
    return(NA)
  }
  
  parsed_json <- content(api_response, as = "text", encoding = "UTF-8") |> fromJSON()
  
  if (source == "DCF") {
    DF <- parsed_json$report |>
          rename_with(camel_to_snake) |>
          select(-c(link, final_link))
    
  } else if (source == "WB") {
    DF <- parsed_json[[2]] |>
          unnest(c(indicator, country), names_sep = "_") |>
          select(year = date, country = country_value, indicator = indicator_value, value)
  }
  
  return(DF)
}

process_api <- function(type, ls_codes, source) {
  lapply(ls_codes, function(ticker) {
    import_api(type, ticker, source)
  })
}

# Main logic  ------------------------------------------------------------------
cl <- makeCluster(threads_number)

clusterExport(cl, list("import_api", "camel_to_snake", "process_api", "ls_tickers", "ls_countries"))

clusterEvalQ(cl, {
  library(httr)
  library(jsonlite)
  library(tidyverse)
})

ls_results_dcf <- parLapply(cl, ls_types, function(x) process_api(x, ls_tickers, "DCF"))

ls_results_wb <- parLapply(cl, ls_indicators, function(x) process_api(x, ls_countries, "WB"))

stopCluster(cl)

INCOME_STATEMENTS <- rbindlist(ls_results_dcf[[1]])[, .SD[order(calendar_year)], symbol]

BALANCE_SHEETS <- rbindlist(ls_results_dcf[[2]])[, .SD[order(calendar_year)], symbol]

CASHFLOWS <- rbindlist(ls_results_dcf[[3]])[, .SD[order(calendar_year)], symbol]

COUNTRY_DATA <- rbindlist(purrr::flatten(ls_results_wb))[, .SD[order(indicator, year)], country][,
  "indicator":=fcase(
    str_starts(indicator, "GDP"), "real_gdp",
    str_detect(indicator, "interest"), "lending_ir",
    str_detect(indicator, "Inflation"), "gdp_deflator",
    str_detect(indicator, "Population"), "population"
  )
]

COUNTRY_DATA <- COUNTRY_DATA|>
                pivot_wider(names_from = indicator, values_from = value)|>
                filter(year>1998&year<2024)|>
                mutate(monetary_union = if_else(
                  country%in%c("France", "Germany", "Austria", "Belgium"), "Eurozone", country))|>
                left_join(INTEREST_RATES, by=c("year", "monetary_union"))|>
                left_join(COUNTRIES_AREA, by="country")

# Export data  -----------------------------------------------------------------
dta_export(INCOME_STATEMENTS)
dta_export(BALANCE_SHEETS)
dta_export(CASHFLOWS)
dta_export(COUNTRY_DATA)