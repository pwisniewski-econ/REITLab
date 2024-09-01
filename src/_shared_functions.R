dta_export <- function(DF, base_path="data/interim/"){
  path <- paste0(base_path, tolower(deparse(substitute(DF))))
  fwrite(DF, paste0(path, ".csv"))
  arrow::write_feather(DF, paste0(path, ".feather"), compression = "zstd")
}