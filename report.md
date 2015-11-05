---
title: "Restaurant busyness attributes effects on busyness star rating"
author: "Alexandr Cherkashin"
date: "4 ноября 2015 г."
output: html_document
---





# Introduction

This report provides an attempt to find some objective restaurant characteristics which affects business star rating. There is no goal of building comprehensive predictive model. Instead there is an attempt to keeping in mind collinearity possobilities separately identify meaningful attributes that busyness of type restaurants could deal with to improve it star rating on Yelp.

# Methods and Data

In analysis we will use Yelp business dataset. This dataset contains `star` variable that is an averaged business star rating from 1 to 5 star rounded to half of a star. It will be our response variable. As we interesed in businesses with type "restaurant" we'll take into analysis only observations with string "Restaurants" in `categories` variable.

In addition dataset contain several busyness characteristics some of them we will use as predictors. There are differents kinds of variables. Some of them we will tranform:

1. From latitude and longitude we'll generate `region` variable wich can take three different values: USA, Canada, Europe.
2. `attributes.Noise.Level` will be encoded into integer,  from "quiet" to "very_loud"" into `0:3`.
3. Attributes related to *parking* we will transform to `parking` variable with 3 different values: "no"" if there is no parking avalible, "yes" if there are some parking option exept it is not parking street, "street" if there is parking street there.
4. From `categories` var there would be an attempt to make var with some sort of geographic theme or cuisine: `ThemedAmerican`, `ThemedMexican`, `ThemedOther` - al other regional themes, and `NotThemed`.
5. Another attemp of categorixation based on `categories` variable would be type of restaurant business: `Buffets`, `Fast Food`, `Bars`, `Cafes`, `Other`.

There are some variables which containes "Good.For" or "Ambience" substrings in their names. Such vars appears a little vague on what they means and how they measures. In this report we will not take them into analisys, concentrating on more clear some.

Other variables will be taken without tranformation.

There will be no attempts to impute missing values. Only `complete.cases` will be taken.

There were some hesitaion on what model to choose. Actually, our response: `stars`, which measure in halfs of a star from 0 to 5, could be interpreted as an ordered factor variable. It has an ordered nature for sure, it is an averaged users star rating rounded to half of a star, there is no clue that the "distances" between star halfs are the same despite their location. So models like [ordered logit](https://web.stanford.edu/~hastie/Papers/ordered.pdf) or [ordered probit](http://web.stanford.edu/class/polisci203/ordered.pdf) could be used.

But after all consideration choice was made in favor of linear models. The main point of this is that the goal of this work is not to build a good predictive model. Instead, we'd like to find what affects star rating most and try to infer the effect and *interpret* it. So the interpretability is what most valuable, and linear model is really easyer to interpret. So will use linear models and refer to `star` variable like it was a real number.

# Results

First of all we found that `attributes.Noise.Level` have a big sustainible effect on star rating. And it looks like the effect is squared: every next level of loudness give an squared negative effect on ratig:



# Discussion


This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:


```r
summary(cars)
```

```
##      speed           dist       
##  Min.   : 4.0   Min.   :  2.00  
##  1st Qu.:12.0   1st Qu.: 26.00  
##  Median :15.0   Median : 36.00  
##  Mean   :15.4   Mean   : 42.98  
##  3rd Qu.:19.0   3rd Qu.: 56.00  
##  Max.   :25.0   Max.   :120.00
```

You can also embed plots, for example:

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png) 

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
