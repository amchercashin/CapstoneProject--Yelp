library(jsonlite)
library(ggplot2)
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
#Exploratory data analisis
bars <- sapply(business$categories, function(x) "Bars" %in% x)

qplot(x = attributes$`Wi-Fi`, y = stars, data = business[bars,], geom = "boxplot", facets =  ~ state)
