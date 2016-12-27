> wd <- file.path("C:/Recomon", "data", fsep = .Platform$file.sep)
> setwd(wd)
> getwd()
[1] "C:/Recomon/data"
> 
> if (!require(data.table)) {
+   install.packages("data.table")
+   library(data.table)
+ }
> 
> data.dt <-
+   fread(
+     "oni/recomon_data_1.csv",
+     na.strings = "NA",
+     verbose = TRUE,
+     encoding = 'UTF-8',
+     strip.white = TRUE,
+     showProgress = TRUE
+   )
Input contains no \n. Taking this to be a filename to open
File opened, filesize is 0.002018 GB.
Memory mapping ... ok
Detected eol as \r\n (CRLF) in that order, the Windows standard.
Positioned on line 1 after skip or autostart
This line is the autostart and not blank so searching up for the last non-blank ... line 1
Detecting sep ... ','
Detected 13 columns. Longest stretch was from line 1 to line 30
Starting data input on line 1 (either column names or first row of data). First 10 characters: question_N
All the fields on line 1 are character fields. Treating as the column names.
Count of eol: 30010 (including 1 at the end)
Count of sep: 360108
nrow = MIN( nsep [360108] / (ncol [13] -1), neol [30010] - endblanks [1] ) = 30009
Type codes (point  0): 1111431411444
Type codes (point  1): 1111431411444
Type codes (point  2): 1111431411444
Type codes (point  3): 1111431411444
Type codes (point  4): 1111431411444
Type codes (point  5): 1111431411444
Type codes (point  6): 1111431411444
Type codes (point  7): 1111431411444
Type codes (point  8): 1111431411444
Type codes (point  9): 1111431411444
Type codes (point 10): 1111431411444
Type codes: 1111431411444 (after applying colClasses and integer64)
Type codes: 1111431411444 (after applying drop or select (if supplied)
Allocating 13 column slots (13 - 0 dropped)
Read 30009 rows. Exactly what was estimated and allocated up front
   0.000s (  0%) Memory map (rerun may be quicker)
   0.000s (  0%) sep and header detection
   0.005s (  9%) Count rows (wc -l)
   0.003s (  6%) Column type detection (100 rows at 10 points)
   0.000s (  0%) Allocation of 30009x13 result (xMB) in RAM
   0.046s ( 85%) Reading data
   0.000s (  0%) Allocation for type bumps (if any), including gc time if triggered
   0.000s (  0%) Coercing data already read in type bumps (if any)
   0.000s (  0%) Changing na.strings to NA
   0.054s        Total
> 
> str(data.dt)
Classes ‘data.table’ and 'data.frame':	30009 obs. of  13 variables:
 $ question_No    : int  1 2 3 4 5 6 7 8 9 10 ...
 $ student_user_No: int  78787 45286 68332 78916 10106 78918 78916 78912 26405 26405 ...
 $ 개념값         : int  51 48 22 21 21 21 21 62 61 63 ...
 $ 좋은 문제인지  : int  0 3 0 3 0 3 3 3 3 4 ...
 $ 난이도         : chr  "\\N" "2" "\\N" "3" ...
 $ 답변평가점수   : num  0 0 0 5 0 ...
 $ 학교넘버       : int  288 1608 10833 20 410 10736 20 3443 921 921 ...
 $ 성별           : chr  "MAN" "WOMAN" "WOMAN" "WOMAN" ...
 $ 등급           : int  472 472 462 464 463 462 464 472 472 472 ...
 $ 학년           : int  477 477 480 480 480 480 480 478 478 478 ...
 $ 수학점수       : chr  "56" "48" "0" "89" ...
 $ 학교           : chr  "용산중학교" "화홍중학교" "보라고등학교" "강릉여자고등학교" ...
 $ 지역           : chr  "서울특별시" "경기도" "경기도" "강원도" ...
 - attr(*, ".internal.selfref")=<externalptr> 
> 
> training.dt <- data.dt[, list(count = .N), by = list(student_user_No, 개념값 )]
> 
> nrow(training.dt)
[1] 9962
> 
> training.dt[order(rank(student_user_No))] 
      student_user_No 개념값 count
   1:             726     26     2
   2:             726     33     3
   3:             726     35     2
   4:             726     31     1
   5:             726     32     4
  ---                             
9958:           78910     39     1
9959:           78912     62     1
9960:           78913    823     1
9961:           78916     21     2
9962:           78918     21     1
> 
> student_no <- 26405
> 
> if (!require(recommenderlab)) {
+   install.packages("recommenderlab")
+   library(recommenderlab)
+   packageVersion("recommenderlab")
+ }
> 
> memory.size()
[1] 428.23
> memory.limit()
[1] 16292
> memory.size(T)
[1] 1560.19
> 
> (training.rrm <- as(training.dt, "realRatingMatrix"))
6756 x 235 rating matrix of class ‘realRatingMatrix’ with 9962 ratings.
> 
> head(as(training.rrm, "data.frame"))
     user item rating
3392  726   26      2
3982  726   30      3
4045  726   31      1
4150  726   32      4
4468  726   33      3
4723  726   35      2
> 
> recommend_model <-
+   Recommender(
+     training.rrm,
+     # method = "ALS"
+     # method = "POPULAR"
+     # method = "SVD" 
+     # method = "IBCF"
+      method = "UBCF" 
+   )
> 
> model_details <- getModel(recommend_model)
> names(model_details)
[1] "description" "data"        "method"      "nn"          "sample"      "normalize"   "verbose"    
> 
> 
> #726 사용자에 대한 추천
> target_user <- training.rrm['726',]
> as(target_user, "list")
$`726`
26 30 31 32 33 35 
 2  3  1  4  3  2 

> 
> (
+   predicted <-
+   predict(
+     recommend_model,
+     target_user,
+     n = 20
+   )
+ )
Recommendations as ‘topNList’ with n = 20 for 1 users. 
> 
> str(predicted)
Formal class 'topNList' [package "recommenderlab"] with 4 slots
  ..@ items     :List of 1
  .. ..$ 726: int [1:20] 20 9 10 139 225 22 23 24 25 26 ...
  ..@ ratings   :List of 1
  .. ..$ 726: num [1:20] 5.36 3.04 2.68 2.52 2.51 ...
  ..@ itemLabels: chr [1:235] "12" "13" "14" "16" ...
  ..@ n         : int 20
> 
> top5 <- as(bestN(predicted, n = 5), "list")
> top5
$`726`
[1] "36"   "22"   "23"   "1186" "2142"

> 
> #############
> # ALS Top 5 #
> #############
> #$`726`
> #[1] "59" "37" "18" "58" "23"
> 
> #############
> # SVD Top 5#
> #############
> #$`726`
> #[1] "36"   "24"   "39"   "14"   "1175" 
> 
> #############
> # UBCF Top 5#
> #############
> #$`726`
> #[1] "36"   "22"   "23"   "1186" "2142"
> 
> #############
> # IBCF Top 5#
> #############
> #$`726`
> #[1] "2133" "1168" "39"   "707"  "708" 
> 
> data.dt[개념값 %in% unlist(top5)][, list(count = .N), by = list(개념값)]
   개념값 count
1:     22   363
2:     23   647
3:     36   507
4:   2142    11
5:   1186     4
> 