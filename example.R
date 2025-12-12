source("helper/functions.R")

# unique identifier for each tidbit
# 
TB_files <- "C:/Users/ptandler/Documents/BurrelCreekProject/Year2_2025/02.Data/01.Selkirk/02.Raw_Data/03.Sensor_Data/03.Tidbits/2025_09-04_11-28_full_timeseries"

#' enter name or ID and a given time in this format: 07:45:02 or datetime is this format: 2025-09-04 08:13:23
#' the function returns a temperature in the TB csv unit
TB_lib()

TB_temp(ID="21688182", time="15:00:00", path = TB_files)


TB_plot(name="44D", path = TB_files, datetime_start = "2025-09-04 8:00:00", datetime_end = "2025-11-28 16:00:00", type="l", col = "dodgerblue3")

# set path for csv containing for each tidbit location the timestamps 
time_path = "C:/Users/ptandler/Documents/BurrelCreekProject/Year1_2024/01.Data/01.Selkirk/03.Processed_Data/05.H20T/CompleteAOI_001-003/image_times.csv"
batch_TB_temp(time_path = time_path, tidbit_path = TB_files)
