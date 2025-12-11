source("helper/functions.R")

# unique identifier for each tidbit
# 
TB_files <- "C:/Users/ptandler/Documents/BurrelCreekProject/Year2_2025/02.Data/01.Selkirk/02.Raw_Data/03.Sensor_Data/03.Tidbits/2025-09-04/prepared"

#' enter name or ID and a given time in this format: 07:45:02 or datetime is this format: 2025-09-04 08:13:23
#' the function returns a temperature in the TB csv unit
TB_lib()

TB_temp(ID="21727174", time="09:56:00", path = TB_files)


TB_plot(ID="21727174", path = TB_files, time_start = "08:13:23", time_end = "14:56:00", type = "p")

# set path for csv containing for each tidbit location the timestamps 
time_path = "C:/Users/ptandler/Documents/BurrelCreekProject/Year2_2025/02.Data/01.Selkirk/03.Processed_Data/02.H20T/2025-09-04/CompleteAOI_014-017_019/image_times.csv"
batch_TB_temp(time_path = time_path, tidbit_path = TB_files)
