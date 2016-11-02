# JH-Developing-Data-Product-shinyApp

What does this app do?  
This app is to predict whether a specific tweet is from Trump or Trump's staff.  
You can type a tweet, the app will provide you the chance of this specific tweet that comes from Trump.  

This is based on David Robinson's popular [sentiment analysis of Trumps tweets](http://varianceexplained.org/r/trump-tweets/). The data is provided by him from this [link]("http://varianceexplained.org/files/trump_tweets_df.rda"). 
There are 1512 tweets in this analysis.   

How to deploy the app

Here are the steps of how to deploy the App.  
* create your own directory, and put all files in the directory 
* set the working directory the same as the directory you just created 
* run shiny app. The app will load the image ("wordcloud.png") into the server. 
* It takes a little while to fit the model when start the app. Therefore, wait until the an image appears in the app before you type a new tweet. 
* Now, type a new tweet, click the button, you can see the probability of this tweet comes from Trump.  


Enjoy the App!
