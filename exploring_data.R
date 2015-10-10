library(jsonlite)

# Reading data
business <- stream_in(file("./data/yelp_academic_dataset_business.json"))
checkin <- stream_in(file("./data/yelp_academic_dataset_checkin.json"))
review <- stream_in(file("./data/yelp_academic_dataset_review.json"))
tip <- stream_in(file("./data/yelp_academic_dataset_tip.json"))
user <- stream_in(file("./data/yelp_academic_dataset_user.json"))

#Select users with more then 100 friends
user100 <- user[sapply(user$friends, length) >= 100,]

#Compute friends friends counts for these users
user100$friendsCounts <- lapply(user100$friends, function(u) {
        sapply(unlist(u), function(f){
                length(user$friends[user$user_id == f][[1]])
        })
})

#Select first significant digits fron counts
user100$friendsCountsFSD <- lapply(user100$friendsCounts, function(u) {
        sapply(unlist(u), function(fc) {
                as.integer(substr(as.character(format(abs(fc), scientific = TRUE)), start = 1, stop = 1))
        })
})

#Make factors from them with levels 1:9
user100$friendsCountsFSD <- lapply(user100$friendsCountsFSD, function(u) {
        factor(unlist(u), levels = 1:9)
})

#Calculate correletions betweeen friends of friends counts and reference Benford distribution
benfordDistr <- log10(1 + 1/1:9)
user100$friendsCountsFSDcor <- sapply(user100$friendsCountsFSD, function(fsd) {
        cor(table(unlist(fsd)) / length(unlist(fsd)), benfordDistr)
})



#Plot FSD counts with Benford's distribution reference
strangeUsers <- which(user100$friendsCountsFSDcor < .8)
bp <- barplot(table(user100$friendsCountsFSD[[strangeUsers[4]]]) / length(user100$friendsCountsFSD[[strangeUsers[4]]]), 
              main = "First digit appearance counts", 
              xlab = "first digit from generated number sequence",
              ylab = "count"
)
lines(x = bp, y = log10(1 + 1/1:9), col = "red", lty = 3, lwd = 5)
legend("topright", "Benford's law first digit distribution", col = "red",
       text.col = "black", lty = 3, lwd = 4,
       merge = TRUE, bg = "white")

rbenford <- function(n, max) {
        upper_bounds <- sapply(1:n, function(i) {runif(1, max = max)})
        for(i in 1:n) { out[i] <- runif(1, max = upper_bounds[i]) }
        out
}


rb <- sapply(1:5000, function(n) rbenford(150,3000))

rb_fsd <- apply(rb, 2, function(col) {
        sapply(col, function(el) {
                as.integer(substr(as.character(format(abs(el), scientific = TRUE)), start = 1, stop = 1))
        }
     )})
rb_fsd <- as.data.frame(rb_fsd)
rb_fsd <- as.data.frame(lapply(rb_fsd, function(col) {factor(col, levels = 1:9)}))

rb_fsd_cor <- sapply(rb_fsd, function(fsd) {
        cor(table(fsd) / length(fsd), benfordDistr)
})

head(sort(rb_fsd_cor))
