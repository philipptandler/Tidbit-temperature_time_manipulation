unitedf <- function(paths){
  
  dflist <- lapply(paths, read.csv)
  
  len <- length(dflist)
  colnames <- c()
  if(len > 0){
    cnames <- colnames(dflist[[1]])
    remaining <- len-1
    while(remaining >= 1){
      i <- len-remaining+1
      cnames <- intersect(cnames, colnames(dflist[[i]]))
      remaining <- remaining-1
    }
  for(i in 1:length(dflist)){
    dflist[[i]] <- dflist[[i]][cnames]
    dflist[[i]]$scene <-i
  }   
  df_final <- do.call(rbind, dflist)
  }
  
   

  
  
}


TB_paths <- list(
  "D:/Year2_2025/03.Deliverables/03.Products/02.Tidbit_Temperature_Records/2024-10-10/tidbit_measurements_ortho_01.csv",
  "D:/Year2_2025/03.Deliverables/03.Products/02.Tidbit_Temperature_Records/2025-09-04/tidbit_measurements_ortho_02.csv",
  "D:/Year2_2025/03.Deliverables/03.Products/02.Tidbit_Temperature_Records/2025-09-04/tidbit_measurements_ortho_03.csv",
  "D:/Year2_2025/03.Deliverables/03.Products/02.Tidbit_Temperature_Records/2025-09-04/tidbit_measurements_ortho_04.csv",
  "D:/Year2_2025/03.Deliverables/03.Products/02.Tidbit_Temperature_Records/2025-11-28/tidbit_measurements_ortho_05.csv"
)

df <- unitedf(TB_paths)
df$scene <- as.factor(df$scene)
df$delta <- df$Temp_Ortho - df$Temp_TB
plot(Temp_Ortho ~ Temp_TB, data = df, col=as.factor(df$scene))

plot(df$delta ~ df$scene)
plot(df$delta ~ as.factor(df$scene))
abline(h=0)
