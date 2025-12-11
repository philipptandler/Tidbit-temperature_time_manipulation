source("config/config.R")

# for writing the average of temperature values ifor each tidbit
.average_temp_by_ID <- function(df, ID_col, temp_col){
  df$avgTemp <- ave(df[[temp_col]], df[[ID_col]],
                    FUN = function(x) mean(x, na.rm = TRUE)) 
  df
}

#aggregates data frame with duplicates into a condensed version where temp is averaged by all tidbits
.aggregate_per_TB_ID <- function(df, ID_col){
  # Function to check if a column is constant per ID
  constant_cols <- sapply(df, function(col) {
    all(tapply(col, df[[ID_col]], function(x) length(unique(x)) == 1))
  })
  
  # Keep constant columns
  cols_to_keep <- names(df)[constant_cols]
  df_constant <- df[ , cols_to_keep]
  df_final <- unique(df_constant)
  
  # return
  df_final
}


# returns ID for Id or name
.check_and_read_ID_name <- function(ID = NULL, name = NULL){
  if(is.null(ID) && is.null(name)){stop("Specify either tidbit ID or name.")}
  if(!is.null(ID)){
    ID <- as.numeric(ID)
    if(!ID%in%tidbit_lib$ID){stop("Invalid tidbit ID. \nRun TB_lib() to view valid tidbit IDs or check and modify 'config/tidbit_name_ID_lib.csv'")}
    return(ID)
  }
  if(!is.null(name)){
    if(!name%in%tidbit_lib$name){stop("Invalid tidbit name. \nRun TB_lib() to view valid tidbit names or check and modify 'config/tidbit_name_ID_lib.csv'")}
    ID <- .get_ID(name)
    return(ID)
  }
}

.date_of_reading <- function(df){
  dt <- df$datetime[[1]]
  date <- format(dt, "%Y-%m-%d")
  date
}


# df as dataframe with times and temp, time as time_start and time_end
.extract_temp <- function(df, time_target_start, time_targed_end){
  
  dt <- df$datetime
  temp <- df[[tidbitsheet_colname_temperature]]
  selection <- (dt >= time_target_start & dt <= time_targed_end)

  timevec <- dt[selection]
  tempvec <- temp[selection]
  # return
  rdf <- data.frame(
    time = timevec,
    temp = tempvec
  )
}

# for a name retrieves ID from library
.get_ID <- function(name){
  ID <- tidbit_lib[tidbit_lib$name == name,]$ID
  ID
}

# df as dataframe with times in df$datetime and temperature, time as point
.interpolate_temp <- function(df, time_target){
  
  if(time_target < min(df$datetime)){
    stop("requested time is out of boundry (too small) for the provided tidibit sheet.")
  }
  if(time_target > max(df$datetime)){
    stop("requested time is out of boundry (too large) for the provided tidibit sheet.")
  }
  # Time before and after given time
  time_before <- max(df$datetime[df$datetime <= time_target])
  time_after <- min(df$datetime[df$datetime >= time_target])
  # fix time_target == time entry
  if(time_before == time_after){
    return(df[[tidbitsheet_colname_temperature]][df$datetime == time_before])
  }
  dtarget <- as.numeric(time_target - time_before, units = "secs")
  dtotal  <- as.numeric(time_after - time_before, units = "secs")
  
  # temperature interpolate
  temp_before <- df[[tidbitsheet_colname_temperature]][df$datetime == time_before]
  temp_after <- df[[tidbitsheet_colname_temperature]][df$datetime == time_after]
  
  temp_inter <- temp_before + (temp_after-temp_before)*dtarget/dtotal
  
  #return
  temp_inter
}

# parse time input to datetime
.parse_time_input <- function(time, datetime, fallback){
  if(!is.null(datetime)) return(strptime(datetime, "%Y-%m-%d %H:%M:%S", tz = time_zone))
  if(!is.null(time)) return(strptime(paste(fallback, time),"%Y-%m-%d %H:%M:%S", tz = time_zone))
  stop("Specify either time or datetime input")
  
}


# returns dataframe for a tidbit ID
.read_TB_csv <- function(ID, path){
  df <- read.csv(file.path(path, paste0(ID, TB_suffix)))
  df <- na.omit(df)
  df$datetime <- strptime(df[[tidbitsheet_colname_time]], tidbitsheet_time_format, tz = time_zone)
  df
}

.read_time_csv <- function(path){
  df <- read.csv(file.path(path))
  df$datetime <- strptime(df[[timesheet_colname_times]], timesheet_time_format, tz = time_zone)
  df
}


# returns Tidbit library as dataframe
.TB_lib <- function(){
  tidbit_lib
}

# returns plot for tidbit
.TB_plot <- function(name = NULL, ID = NULL, path = NULL,
                     time_start = NULL, time_end = NULL, 
                     datetime_start = NULL, datetime_end = NULL,
                     return_df = TRUE,
                     xlab = "Time",
                     ylab = "Temperature (°C)",
                     ...){
  ID <- .check_and_read_ID_name(ID, name)
  df <- .read_TB_csv(ID, path)
  time_target_start <- .parse_time_input(time_start, datetime_start, 
                                         fallback = .date_of_reading(df))
  time_targed_end <- .parse_time_input(time_end, datetime_end,
                                       fallback = .date_of_reading(df))
  rdf <- .extract_temp(df,
                       time_target_start = time_target_start,
                       time_targed_end = time_targed_end)
  
  plot(temp ~ time, data = rdf,
       xlab = xlab,
       ylab = ylab,
       ...)
  #return used dataframe
  if(return_df) return(rdf)
}


# returns interpolated temperature value
.TB_temp <- function(name = NULL, ID = NULL, path = NULL, time = NULL, datetime = NULL){
  ID <- .check_and_read_ID_name(ID, name)
  df <- .read_TB_csv(ID, path)
  time_target <- .parse_time_input(time, datetime, fallback = .date_of_reading(df))
  temp_inter <- .interpolate_temp(df, time_target = time_target)
  temp_inter
}

# for batch processing of temperatures for timestamp
.batch_TB_temp <- function(time_path, tidbit_path){
  df_time <- .read_time_csv(time_path)
  tempvec <- c()
  for (entry in 1:nrow(df_time)){
    time_target <- df_time$datetime[entry]
    ID <- df_time[[timesheet_colname_TBID]][entry]
    tempvec[entry] <- .TB_temp(ID = ID, path = tidbit_path,
                               datetime = df_time$datetime[entry])
  }
  df_time$TB_temp <- tempvec
  # average
  df_time <- .average_temp_by_ID(df = df_time,
                                 ID_col = timesheet_colname_TBID,
                                 temp_col = "TB_temp")
  # aggregate
  df_time_aggregated <- .aggregate_per_TB_ID(df_time, ID_col = timesheet_colname_TBID)
  
  # write both df
  name_dftime <- sub("(\\.csv)$", "_TB-temp\\1", time_path)
  write.csv(df_time, file.path(name_dftime))
  name_dftime_avg <- sub("(\\.csv)$", "_TB-temp-avg\\1", time_path)
  write.csv(df_time_aggregated, file.path(name_dftime_avg))
  
  l <- list(
    full_df = df_time,
    aggregated_df = df_time_aggregated
  )
}



