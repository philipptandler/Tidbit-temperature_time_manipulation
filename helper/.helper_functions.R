source("config/config.R")

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
  date <- format(dt, "%d-%m-%Y")
  date
}


# df as dataframe with times and temp, time as time_start and time_end
.extract_temp <- function(df, time = NULL, time_start = NULL, time_end = NULL){

  
  # TODO find time before and after given time
  # Read all values from that time
  
  # return
  rdf <- data.frame()
  rdf$time <- timevec
  rdf$temp <- tempvec
  rdf
}

# for a name retrieves ID from library
.get_ID <- function(name){
  ID <- tidbit_lib[tidbit_lib$name == name,]$ID
  ID
}

# df as dataframe with times in df$datetime and temperature, time as point
.interpolate_temp <- function(df, time_target){
  
   # Time before and after given time
  time_before <- max(df$datetime[df$datetime <= time_target])
  time_after <- min(df$datetime[df$datetime >= time_target])
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
  if(!is.null(datetime)) return(strptime(datetime, tz = time_zone))
  if(!is.null(time)) return(strptime(paste(fallback, time),"%d-%m-%Y %H:%M:%S", tz = time_zone))
  stop("Specify either time or datetime input")
  
}


# returns dataframe for a tidbit ID
.read_TB_csv <- function(ID, path){
  df <- read.csv(file.path(path, paste0(ID, TB_suffix)))
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
                     datetime_start = NULL, datetime_end = NULL, ...){
  ID <- .check_and_read_ID_name(ID, name)
  df <- .read_TB_csv(ID, path)
  time_target_start <- .parse_time_input(time_start, datetime_start, 
                                         fallback = .date_of_reading(df))
  time_targed_end <- .parse_time_input(time_end, datetime_end,
                                       fallback = .date_of_reading(df))
  rdf <- .extract_temp(df,
                       time_target_start = time_target_start,
                       time_targed_end = time_targed_end)
  
  
  
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
.batch_TB_temp <- function(time_path, tidbit_path, write = TRUE, average = TRUE){
  df_time <- .read_time_csv(time_path)
  df_time$TB_temp <- NULL
  for (entry in 1:nrow(df_time)){
    time_target <- df_time$datetime[entry]
    ID = df_time[[timesheet_colname_TBID]][entry]
    df_time$TB_temp[entry] <- .TB_temp(ID = ID, path = tidbit_path)
  }
  
  if(write){
    new_file <- sub("(\\.csv)$", "_modified\\1", time_path)
    write.csv(df_time, file.path(new_file))
  }
  if(average){
    df_condensed <- aggregate(target ~ ID, data = df, FUN = mean)
  }
  
  return(df_time)
}
