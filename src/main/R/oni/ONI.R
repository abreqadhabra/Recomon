wd <- file.path("C:/Recomon", "data", fsep = .Platform$file.sep)
setwd(wd)
getwd()

if (!require(data.table)) {
  install.packages("data.table")
  library(data.table)
}

data.dt <-
  fread(
    "oni/recomon_data_2.csv",
    na.strings = "NA",
    verbose = TRUE,
    encoding = 'UTF-8',
    strip.white = TRUE,
    showProgress = TRUE
  )

str(data.dt)

training.dt <-
  data.dt[, list(count = .N), by = list(student_user_No, paste(개념,  중단원, 소단원, sep =
                                                                   "|"))]

nrow(training.dt)

training.dt[order(rank(student_user_No))] 


if (!require(recommenderlab)) {
  install.packages("recommenderlab")
  library(recommenderlab)
  packageVersion("recommenderlab")
}

memory.size()
memory.limit()
memory.size(T)

(training.rrm <- as(training.dt, "realRatingMatrix"))

head(as(training.rrm, "data.frame"))

recommend_model <-
  Recommender(
    training.rrm,
    # method = "ALS"
    # method = "POPULAR"
    # method = "SVD" 
    # method = "IBCF"
     method = "UBCF" 
  )

model_details <- getModel(recommend_model)
names(model_details)


#726 사용자에 대한 추천
target_user <- training.rrm['726',]
as(target_user, "list")

(
  predicted <-
  predict(
    recommend_model,
    target_user,
    n = 20
  )
)

str(predicted)

top5 <- as(bestN(predicted, n = 5), "list")
top5

#############
# ALS Top 5 #
#############
#$`726`
#[1] "59" "37" "18" "58" "23"

#############
# SVD Top 5#
#############
#$`726`
#[1] "36"   "24"   "39"   "14"   "1175" 

#############
# UBCF Top 5#
#############
#$`726`
#[1] "36"   "22"   "23"   "1186" "2142"

#############
# IBCF Top 5#
#############
#$`726`
#[1] "2133" "1168" "39"   "707"  "708" 

#data.dt[개념값 %in% unlist(top5)][, list(count = .N), by = list(개념값)]

