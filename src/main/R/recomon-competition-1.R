wd <- file.path("C:/Recomon", "data", fsep = .Platform$file.sep)
setwd(wd)
getwd()

if (!require(data.table)) {
  install.packages("data.table")
  library(data.table)
}

if (!require(recommenderlab)) {
  install.packages("recommenderlab")
  library(recommenderlab)
  packageVersion("recommenderlab")
}
#> packageVersion("recommenderlab")
#[1] ‘0.2.1’

train.dt <-
  fread(
    "train_recomon.csv",
    na.strings = "NA",
    verbose = TRUE,
    encoding = 'UTF-8',
    strip.white = TRUE,
    showProgress = TRUE
  )

train.dt
str(train.dt)
nrow(train.dt)

memory.size()
memory.limit()
memory.size(T)

(training.dt <- train.dt[, c("user", "movie", "rating"), with = FALSE])
(training.rrm <- as(training.dt, "realRatingMatrix"))

head(as(training.rrm, "data.frame"))
nrow(as(training.rrm, "data.frame"))

recommenderRegistry$get_entries(dataType = "realRatingMatrix")

recommend_model <-
  Recommender(
    training.rrm,
    # method = "ALS" #0.88460
    method = "POPULAR" #0.93577
    # method = "SVD" #0.99534
    # method = "IBCF" #1.58986
    # method = "UBCF" #1.00384
  )

print(recommend_model)
names(getModel(recommend_model))

predicted <- predict(recommend_model, training.rrm, type = "ratings")
str(predicted)

(predicted.dt <- as.data.table(as(predicted , "data.frame")))

test.dt <-
  fread(
    "test_recomon.csv",
    na.strings = "NA",
    colClasses = c(ID = "character", user = "character", movie = "character"),
    verbose = TRUE,
    encoding = 'UTF-8',
    strip.white = TRUE,
    showProgress = TRUE
  )

test_predicted.dt <- merge(
  x = test.dt,
  y = predicted.dt,
  by.x = c("user", "movie"),
  by.y = c("user", "item"),
  all.x = TRUE
)

(submission_recomon <- test_predicted.dt[, c("ID", "rating"), with = FALSE])

setDT(submission_recomon)[rating <= 0, rating := 0.01]
setDT(submission_recomon)[is.na(rating), rating := 0.01]

nrow(submission_recomon)

write.csv(
  submission_recomon,
  "result/sample_submission_recomon.csv",
  row.names = FALSE
)
