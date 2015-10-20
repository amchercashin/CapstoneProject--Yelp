library(jsonlite)
library(ggplot2)
library(MASS)
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
business$stars <- factor(business$stars, levels = seq(1,5,0.5), ordered = TRUE)
#checkin <- readRDS("./data/checkinRDS")
#Exploratory data analisis
bars <- sapply(business$categories, function(x) "Bars" %in% x)
Restaurants <- sapply(business$categories, function(x) "Restaurants" %in% x)

qplot(x = attributes$`Wi-Fi`, y = stars, data = business[Restaurants,], geom = "boxplot", facets =  ~ state)

lm_model <- lm(stars ~ business$attributes$`Noise Level` + attributes$`Price Range` + 
                      attributes$`Wi-Fi` + business$attributes$`Has TV`,
              data = business, subset = Restaurants)
