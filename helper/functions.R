source("helper/.helper_functions.R")

TB_lib <- function(){
  .TB_lib()
}

TB_temp <- function(name = NULL, ID = NULL, path, time = NULL, datetime = NULL){
  .TB_temp(name = name, ID = ID, path = path, time, datetime)
}

TB_plot <- function(name = NULL, ID = NULL, path,
                    time_start = NULL, time_end = NULL,
                    datetime_start = NULL, datetime_end = NULL, ...){
  .TB_plot(name = name, ID = ID, path = path,
           time_start, time_end, datetime_start,datetime_end)
}

batch_TB_temp <- function(time_path, tidbit_path,
                          write = TRUE,
                          average = TRUE){
  .batch_TB_temp(time_path, tidbit_path, write, average)
}