library(jsonlite)
library(ggplot2)
library(MASS)
library(glmnet)
library(caret)
# Reading data
# business <- stream_in(file("./data/yelp_academic_dataset_business.json"))
# saveRDS(business, "./data/businessRDS")

# checkin <- stream_in(file("./data/yelp_academic_dataset_checkin.json"))
# saveRDS(checkin, "./data/checkinRDS")

# review <- stream_in(file("./data/yelp_academic_dataset_review.json"))
# saveRDS(review, "./data/reviewRDS")

# tip <- stream_in(file("./data/yelp_academic_dataset_tip.json"))

# user <- stream_in(file("./data/yelp_academic_dataset_user.json"))

#tip <- readRDS("./data/tipRDS")
#user <- readRDS("./data/userRDS")
business <- readRDS("./data/businessRDS")

#checkin <- readRDS("./data/checkinRDS")

#EXPLORATORY
bars <- sapply(business$categories, function(x) "Bars" %in% x)
bars <- flatten(business[bars,])
restaurants <- sapply(business$categories, function(x) "Restaurants" %in% x)
restaurants <- flatten(business[restaurants,])
sort(table(unlist(restaurants$categories)), dec = TRUE)

#DATA MUNGING
colnames(restaurants) <- make.names(colnames(restaurants))
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "quiet"] <- 0
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "average"] <- 1
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "loud"] <- 2
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "very_loud"] <- 3
restaurants$attributes.Noise.Level <- as.integer(restaurants$attributes.Noise.Level)

sportbars <- sapply(restaurants$categories, function(x) "Sports Bars" %in% x)
bars <- sapply(restaurants$categories, function(x) !"Sports Bars" %in% x & "Bars" %in% x)
restaurants$cat <- ifelse(sportbars, "Sports Bar", ifelse(bars, "Bar", "Restaurant"))
#na_noize <- is.na(restaurants$attributes.Noise.Level)
restaurants$cat <- factor(restaurants$cat, levels = c("Restaurant", "Sports Bar", "Bar"))

restaurants$attributes.Accepts.Credit.Cards <- ifelse(sapply(restaurants$attributes.Accepts.Credit.Cards, length) == 0, NA, 
                                                      unlist(restaurants$attributes.Accepts.Credit.Cards))
na_cols <- sapply(restaurants, function(x) sum(is.na(x))) / nrow(restaurants) > 0.3
restaurants <- restaurants[, !na_cols]

nz_attr <- nearZeroVar(restaurants[,14:46])
restaurants <- restaurants[, -(nz_attr+13)]

qplot(x = factor(attributes.Noise.Level), y = stars, data = restaurants, geom = "boxplot", facets = attributes.Has.TV ~ cat)



lm_model <- lm(stars ~ cat + attributes.Noise.Level,
               data = restaurants)

ls_model <- cv.glmnet()


business$stars <- factor(business$stars, levels = seq(1,5,0.5), ordered = TRUE)
ol_model <- polr(stars ~ business$attributes$`Noise Level` * business$attributes$`Has TV`,
                 data = business, subset = Restaurants, method = "logistic")