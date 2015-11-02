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
restaurants$parking <- ifelse(restaurants$attributes.Parking.garage == "FALSE" &
                           restaurants$attributes.Parking.validated == "FALSE" &
                           restaurants$attributes.Parking.lot == "FALSE" &
                           restaurants$attributes.Parking.valet == "FALSE" &
                           restaurants$attributes.Parking.street == "FALSE", "no", 
                           ifelse(restaurants$attributes.Parking.garage == "TRUE" |
                                  restaurants$attributes.Parking.validated == "TRUE" |
                                  restaurants$attributes.Parking.lot == "TRUE" |
                                  restaurants$attributes.Parking.valet == "TRUE", "yes", 
                                  ifelse(restaurants$attributes.Parking.street == "TRUE", "street", NA)))
restaurants$parking <- factor(restaurants$parking, levels = c("no", "yes", "street"))

#Making an new atttribute type of restaurant busyness: sportbar, bar, restaurant-----
sportbars <- sapply(restaurants$categories, function(x) "Sports Bars" %in% x)
bars <- sapply(restaurants$categories, function(x) !"Sports Bars" %in% x & "Bars" %in% x)
restaurants$cat <- ifelse(sportbars, "Sports Bar", ifelse(bars, "Bar", "Restaurant"))
#na_noize <- is.na(restaurants$attributes.Noise.Level)
restaurants$cat <- factor(restaurants$cat, levels = c("Restaurant", "Sports Bar", "Bar"))

#Flatten Accepts credit cars attribute----
restaurants$attributes.Accepts.Credit.Cards <- ifelse(sapply(restaurants$attributes.Accepts.Credit.Cards, length) == 0, NA, 
                                                      unlist(restaurants$attributes.Accepts.Credit.Cards))

#Dealing with categories vars----
cat2 <- sapply(restaurants$categories, function(x) {
        if (sum(x=="Afghan")>0|sum(x=="African")>0|sum(x=="Asian Fusion")>0|sum(x=="Bangladeshi")>0|sum(x=="Basque")>0|
            sum(x=="Bavarian")>0|sum(x=="Belgian")>0|sum(x=="British")>0|sum(x=="aCajun/Creole")>0|sum(x=="Cambodian")>0|
            sum(x=="Cantonese")>0|sum(x=="Cuban")>0|sum(x=="Egyptian")>0|sum(x=="Ethiopian")>0|sum(x=="French")>0|
            sum(x=="German")>0|sum(x=="Greek")>0|sum(x=="Hawaiian")>0|sum(x=="Himalayan/Nepalese")>0|sum(x=="Hungarian")>0|
            sum(x=="Indian")>0|sum(x=="Indonesian")>0|sum(x=="Irish")>0|sum(x=="Italian")>0|sum(x=="Japanese")>0|
            sum(x=="Korean")>0|sum(x=="Latin American")>0|sum(x=="Lebanese")>0|sum(x=="Malaysian")>0|sum(x=="Mediterranean")>0|
            sum(x=="Arabian")>0|sum(x=="Argentine")>0|sum(x=="Australian")>0|sum(x=="Brazilian")>0|sum(x=="Caribbean")>0|
            sum(x=="Arabian")>0|sum(x=="Argentine")>0|sum(x=="Australian")>0|sum(x=="Brazilian")>0|sum(x=="Caribbean")>0|
            sum(x=="Chinese")>0|sum(x=="Colombian")>0|sum(x=="Czech")>0|sum(x=="Eastern European")>0|sum(x=="Eastern German")>0|
            sum(x=="Ethnic Food")>0|sum(x=="Filipino")>0|sum(x=="Czech")>0|sum(x=="Haitian")>0|sum(x=="Iberian")>0|
            sum(x=="Laotian")>0|sum(x=="Middle Eastern")>0|sum(x=="Modern European")>0|sum(x=="Mongolian")>0|sum(x=="Moroccan")>0|
            sum(x=="Oriental")>0|sum(x=="Pakistani")>0|sum(x=="Persian/Iranian")>0|sum(x=="Peruvian")>0|sum(x=="Polish")>0|
            sum(x=="Portuguese")>0|sum(x=="Russian")>0|sum(x=="Scandinavian")>0|sum(x=="Scottish")>0|sum(x=="Shanghainese")>0|
            sum(x=="Singaporean")>0|sum(x=="Southern")>0|sum(x=="Spanish")>0|sum(x=="Szechuan")>0|sum(x=="Taiwanese")>0|
            sum(x=="Thai")>0|sum(x=="Trinidadian")>0|sum(x=="Turkish")>0|sum(x=="Ukrainian")>0|sum(x=="Uzbek")>0|
            sum(x=="Venezuelan")>0|sum(x=="Vietnamese")>0|sum(x=="Turkish")>0|sum(x=="Ukrainian")>0|sum(x=="Uzbek")>0) {
                "ThemedOther"}
        else {if(sum(x=="American (New)")>0|sum(x=="American (Traditional)")>0) {"ThemedAmerican"}
                else {if (sum(x=="Mexican")>0|sum(x=="Tex-Mex")>0) {"ThemedMexican"}
                        else "NotThemed"}
                }
})

cat1 <- sapply(restaurants$categories, function(x) {
        if (sum(x=="Buffets")>0) "Buffets"
        else if(sum(x=="Fast Food")>0|sum(x=="Chicken Wings")>0|sum(x=="Burgers")>0|sum(x=="Pizza")>0) "Fast Food"
                #else if (sum(x=="Restaurants")>0) "Restaurants"
                        else if (sum(x=="Bars")>0|sum(x=="Pubs")>0|sum(x=="Irish Pub")>0) "Bars"
                                else if (sum(x=="Cafes")>0) "Cafes"
                                        else "Other"
        
})

#Geographocals points----
library(ggmap)
cities<-c('Edinburgh, UK', 'Karlsruhe, Germany', 'Montreal, Canada', 'Waterloo, Canada', 
          'Pittsburgh, PA', 'Charlotte, NC', 'Urbana-Champaign, IL', 'Phoenix, AZ', 'Las Vegas, NV', 'Madison, WI')
city_centres<-geocode(cities)
#set.seed(43046721)
geo_cluster<-kmeans(restaurants[,c('longitude','latitude')],city_centres)
city2<- factor(geo_cluster$cluster, levels=1:10, labels = cities)
region <- ifelse(geo_cluster$cluster<=2, "Europe", ifelse(geo_cluster$cluster<=4, "Canada", "USA"))

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

summary(lm(formula = stars ~ region+cat1+cat2+parking+I(attributes.Noise.Level^2), data = restaurants, subset = comp_cases))

la_cat_model <- cv.glmnet(x = model.matrix(~., data.frame(b = restaurants$attributes.Price.Range[comp_cases],a=prevCat[comp_cases]))[,-1],
                      y = restaurants$stars[comp_cases],
                      family = "gaussian",
                      type.measure="mse"
)
#business$stars <- factor(business$stars, levels = seq(1,5,0.5), ordered = TRUE)
#ol_model <- polr(stars ~ business$attributes$`Noise Level` * business$attributes$`Has TV`,
#                 data = business, subset = Restaurants, method = "logistic")