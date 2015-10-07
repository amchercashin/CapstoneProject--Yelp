library(jsonlite)

business <- stream_in(file("./data/yelp_academic_dataset_business.json"))
checkin <- stream_in(file("./data/yelp_academic_dataset_checkin.json"))
review <- stream_in(file("./data/yelp_academic_dataset_review.json"))
tip <- stream_in(file("./data/yelp_academic_dataset_tip.json"))
user <- stream_in(file("./data/yelp_academic_dataset_user.json"))
