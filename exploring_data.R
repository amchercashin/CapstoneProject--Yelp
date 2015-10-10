library(jsonlite)

# Reading data
# business <- stream_in(file("./data/yelp_academic_dataset_business.json"))
# saveRDS(business, "./data/businessRDS")

# checkin <- stream_in(file("./data/yelp_academic_dataset_checkin.json"))
# saveRDS(checkin, "./data/checkinRDS")

# review <- stream_in(file("./data/yelp_academic_dataset_review.json"))
# saveRDS(review, "./data/reviewRDS")

# tip <- stream_in(file("./data/yelp_academic_dataset_tip.json"))

# user <- stream_in(file("./data/yelp_academic_dataset_user.json"))

tip <- readRDS("./data/tipRDS")
user <- readRDS("./data/userRDS")
business <- readRDS("./data/businessRDS")
checkin <- readRDS("./data/checkinRDS")
#Exploratory data analisis

