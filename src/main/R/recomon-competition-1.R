print(Sys.setenv(RSW_HOME = "C:/recomon"))
rswHome <- Sys.getenv("RSW_HOME")

getwd()
wd <- file.path("C:/recomon", "data", fsep = .Platform$file.sep)
setwd(wd)

if (!require(data.table)) {
  install.packages("data.table")
  library(data.table)
}

training <-
  fread(
    "train_recomon.csv",
    na.strings = "NA",
    verbose = TRUE,
    encoding = 'UTF-8',
    strip.white = TRUE,
    showProgress = TRUE
  )

training
str(training)
nrow(training)

test <-
  fread(
    "test_recomon.csv",
    na.strings = "NA",
    verbose = TRUE,
    encoding = 'UTF-8',
    strip.white = TRUE,
    showProgress = TRUE
  )

test
str(test)
nrow(test)

ratings <-
  fread(
    "ratings.csv",
    na.strings = "NA",
    verbose = TRUE,
    encoding = 'UTF-8',
    strip.white = TRUE,
    showProgress = TRUE
  )

ratings
str(ratings)
nrow(ratings)

test[movie==48 & user==1]
ratings[movieId==1 & userId==48]

training[movie==3784 & user==3704]
ratings[movieId==3784 & userId==3704]
ratings[movieId==3704 & userId==3784]

setkeyv(ratings,c("userId","movieId"))
setkeyv(test,c("movie","user"))

test1 <- ratings[test, nomatch=0]

test1
str(test1)
nrow(test1)
