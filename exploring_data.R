library(jsonlite)

# Reading data
business <- stream_in(file("./data/yelp_academic_dataset_business.json"))
checkin <- stream_in(file("./data/yelp_academic_dataset_checkin.json"))
review <- stream_in(file("./data/yelp_academic_dataset_review.json"))
tip <- stream_in(file("./data/yelp_academic_dataset_tip.json"))
user <- stream_in(file("./data/yelp_academic_dataset_user.json"))

#Exploratory data analisis
sum(sapply(user$friends, length) >= 100)
user100 <- user[sapply(user$friends, length) >= 100,]

user100$friendsCounts <- lapply(user100$friends, function(u) {
        sapply(u[[1]], function(f){
                length(user$friends[user$user_id == f][[1]])
        })
})
