#' adjust according to needs.
#' for time formatting, see https://www.statscodes.com/basics/dates-and-times-in-r/

# format of the tidbit record sheet
tidbitsheet_colname_time <- 2
tidbitsheet_time_format <- "%m/%d/%Y %H:%M:%S"
tidbitsheet_colname_temperature <- 3
TB_suffix <- ".csv"

# for batch process: format time input sheet
timesheet_colname_TBID <- "TB_ID"
timesheet_colname_times <- "timestamp_custom"
timesheet_time_format <- "%m-%d-%Y %H:%M:%S"


# general
time_zone <- "America/Vancouver"

# Tidbit Library
tidbit_lib <- read.csv("config/tidbit_name_ID_lib.csv")
