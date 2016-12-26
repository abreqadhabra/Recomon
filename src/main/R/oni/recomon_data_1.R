wd <- file.path("C:/Recomon", "data", fsep = .Platform$file.sep)
setwd(wd)
getwd()

if (!require(data.table)) {
  install.packages("data.table")
  library(data.table)
}

data.dt <-
  fread(
    "oni/recomon_data_1.csv",
    na.strings = "NA",
    verbose = TRUE,
    encoding = 'UTF-8',
    strip.white = TRUE,
    showProgress = TRUE
  )

str(data.dt)

questions <- unique(data.dt[,1:2])

ratings<- unique(data.dt[,3:7])

users <- unique(data.dt[,8:15])

write.csv(
  questions,
  "oni/questions.csv",
  row.names = FALSE
)

write.csv(
  ratings,
  "oni/ratings.csv",
  row.names = FALSE
)

write.csv(
  users,
  "oni/users.csv",
  row.names = FALSE
)
