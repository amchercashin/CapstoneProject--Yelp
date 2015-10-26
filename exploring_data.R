library(jsonlite)
library(ggplot2)
library(MASS)
library(glmnet)
library(caret)
# Reading data----
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

#EXPLORATORY-----
bars <- sapply(business$categories, function(x) "Bars" %in% x)
bars <- flatten(business[bars,])
restaurants <- sapply(business$categories, function(x) "Restaurants" %in% x)
restaurants <- flatten(business[restaurants,])
sort(table(unlist(restaurants$categories)), dec = TRUE)

#DATA MUNGING
# Convinient column names----
colnames(restaurants) <- make.names(colnames(restaurants))

#Noise level attribute to integer level----
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "quiet"] <- 0
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "average"] <- 1
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "loud"] <- 2
restaurants$attributes.Noise.Level[restaurants$attributes.Noise.Level == "very_loud"] <- 3
restaurants$attributes.Noise.Level <- as.integer(restaurants$attributes.Noise.Level)

#Parking to three categories: free, paid, no ----
parkingCols <- grep("Parking", colnames(restaurants), value = TRUE)
restaurants[,parkingCols][is.na(restaurants[,parkingCols])] <- "n_a"
restaurants$park <- ifelse(restaurants$attributes.Parking.garage == "FALSE" &
                           restaurants$attributes.Parking.validated == "FALSE" &
                           restaurants$attributes.Parking.lot == "FALSE" &
                           restaurants$attributes.Parking.valet == "FALSE" &
                           restaurants$attributes.Parking.street == "FALSE", "no", 
                           ifelse(restaurants$attributes.Parking.garage == "TRUE" |
                                  restaurants$attributes.Parking.validated == "TRUE" |
                                  restaurants$attributes.Parking.lot == "TRUE" |
                                  restaurants$attributes.Parking.valet == "TRUE", "free", 
                                  ifelse(restaurants$attributes.Parking.street == "TRUE", "paid", NA)))

#Making an new atttribute type of restaurant busyness: sportbar, bar, restaurant-----
sportbars <- sapply(restaurants$categories, function(x) "Sports Bars" %in% x)
bars <- sapply(restaurants$categories, function(x) !"Sports Bars" %in% x & "Bars" %in% x)
restaurants$cat <- ifelse(sportbars, "Sports Bar", ifelse(bars, "Bar", "Restaurant"))
#na_noize <- is.na(restaurants$attributes.Noise.Level)
restaurants$cat <- factor(restaurants$cat, levels = c("Restaurant", "Sports Bar", "Bar"))

#Flatten Accepts credit cars attribute----
restaurants$attributes.Accepts.Credit.Cards <- ifelse(sapply(restaurants$attributes.Accepts.Credit.Cards, length) == 0, NA, 
                                                      unlist(restaurants$attributes.Accepts.Credit.Cards))

#Sorting out vars with lots of NA----        
na_cols <- sapply(restaurants, function(x) sum(is.na(x))) / nrow(restaurants) > 0.3
restaurants <- restaurants[, !na_cols]; rm(na_cols)

#Sorting out near zero variance vars----        
nz_attr <- nearZeroVar(restaurants[,14:46])
restaurants <- restaurants[, -(nz_attr+13)]; rm(nz_attr)

#Determine features----
feature_names <- colnames(restaurants)[14:36]
feature_names <- feature_names[!(feature_names %in% parkingCols)]
feature_names <- feature_names[!grepl("Good.For", feature_names)]
feature_names <- feature_names[!grepl("Good.for", feature_names)]
feature_names <- feature_names[!grepl("Ambience", feature_names)]

#MODELING----

#qplot(x = factor(attributes.Noise.Level), y = stars, data = restaurants, geom = "boxplot", facets = attributes.Has.TV ~ cat)
comp_cases <- complete.cases(restaurants[, feature_names])

la_model <- cv.glmnet(x = model.matrix(~ ., restaurants[comp_cases, feature_names])[,-1],
                      y = restaurants$stars[comp_cases],
                      family = "gaussian",
                      type.measure="mse"
                      )
bestLambdaCol <- which(la_model$lambda==la_model$lambda.1se)
lassoImpVars <- names(which(la_model$glmnet.fit$beta[,bestLambdaCol]!=0))
#lm_model <- lm(stars ~ cat + attributes.Noise.Level,
#               data = restaurants)

summary(lm(formula = stars ~ I(attributes.Noise.Level^2), data = restaurants, subset = comp_cases))


#business$stars <- factor(business$stars, levels = seq(1,5,0.5), ordered = TRUE)
#ol_model <- polr(stars ~ business$attributes$`Noise Level` * business$attributes$`Has TV`,
#                 data = business, subset = Restaurants, method = "logistic")