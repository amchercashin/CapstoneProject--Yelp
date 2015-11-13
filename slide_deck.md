Attributes to deal with to improve your restaurant rating on Yelp
========================================================
author: 
date: 



Method
========================================================

Every restaurant is different, but some characteristics they share. Examples:
 - Is there parking
 - Do they have alcohol in menu
 - What's the noise level there

Using Yelp business dataset, treating star rating as a response and these and others attributes as predictors, we will use linear model to infer which is really important and where.

Where and what
========================================================

Mean rating:

|          | Erope| Canada|  USA|
|:---------|-----:|------:|----:|
|Cafe      |  3.98|   3.81| 3.70|
|Other     |  3.72|   3.54| 3.43|
|Fast Food |  3.45|   3.27| 3.16|
|Buffet    |  3.09|   2.91| 2.80|

First answer these questions:
- In what part of the world your restaurant is?
- What restaurant type your restaurant is?

Thus you can find the baseline. There is a tendency to rate restaurants different in different parts of the world.

Parking
========================================================

If you planning to open business consider a place with parking options. This could boost your score from 0.25 to 0.4 of a star.

If you already have no parking consider reorient and start to offer alcohol. This could shrink your no parking penalty by half!

Alcohol is tricky
========================================================

It could help with no parking but it needs care:

 - If you are a **Cafe** and offering alcohol: get a **-0.2** rating penalty!
 - But if you are a **fast food** or **buffet** start to offer some: **+0.5** your reward!

Noise is awful
========================================================

No matter who you are: reduce the **NOISE**!

If it is stated that you have *very loud* environment, going one step to *loud* will give you **0.27** and one step further to *average* level - **0.16** more.

Almost **half of a star** lays here!
