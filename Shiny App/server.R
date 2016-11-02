library(shiny)
shinyServer(function(input, output) {
        
        
        library(dplyr) 
        library(purrr)
        library(tidyr)
        library(h2o)
        library(stringr)
        library(tidytext)
        # initiate h2o package
        h2o.init()
        # load the data
        load(url("http://varianceexplained.org/files/trump_tweets_df.rda"))
        tweets <- trump_tweets_df %>%
                select(id, statusSource, text, created) %>%
                extract(statusSource, "source", "Twitter for (.*?)<") %>%
                filter(source %in% c("iPhone", "Android"))
        
        # Use the tidytext package to clean up the text a bit, remove stopwords
        find_tweet_words <- function(tweets){
                reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"
                tweet_words <- tweets %>%
                        filter(!str_detect(text, '^"')) %>%
                        mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%
                        unnest_tokens(word, text, token = "regex", pattern = reg) %>%
                        filter(!(word %in% stop_words$word),
                               str_detect(word, "[a-z]"))
                tweet_words
        }
        
        # compute ti-idf (term frequency, inverse document frequency)
        compute_tf_idf <- function(tweet_words){
                tweet_word_counts <- tweet_words[, c("word", "id")] %>% count(id, word)
                tweet_word_counts <- bind_tf_idf(tweet_word_counts, word, id, n)
                tweet_word_counts
        }
        # compute document term matrix
        cast_dtm_h2o <- function(data, row_col, column_col, value_col = 1, sparse = FALSE) {
                # This function is a modified version of tidytext::cast_sparse_
                # ungroup the data
                data <- ungroup(data)
                data <- distinct_(data, row_col, column_col, .keep_all = TRUE)
                row_names <- data[[row_col]]
                col_names <- data[[column_col]]
                if (is.numeric(value_col)) {
                        values <- value_col
                } else {
                        values <- data[[value_col]]
                }
                
                # if it's a factor, preserve ordering
                if (is.factor(row_names)) {
                        row_u <- levels(row_names)
                        i <- as.integer(row_names)
                } else {
                        row_u <- unique(row_names)
                        i <- match(row_names, row_u)
                }
                
                if (is.factor(col_names)) {
                        col_u <- levels(col_names)
                        j <- as.integer(col_names)
                } else {
                        col_u <- unique(col_names)
                        j <- match(col_names, col_u)
                }
                
                ret <- Matrix::sparseMatrix(i = i, j = j, x = values,
                                            dimnames = list(row_u, col_u))
                if (!sparse) {
                        # Convert the sparse matrix to an H2OFrame
                        ret <- as.h2o(as.matrix(ret))
                }
                ret
        }
        
        # construct the document term matrix
        tweet_words <- find_tweet_words(tweets)
        tweet_word_counts <- compute_tf_idf(tweet_words)
        dtm <- cast_dtm_h2o(tweet_word_counts, "id", "word", 1)
        
        # plot cloudwords
        output$CloudWordsPlot <- renderImage({
                filename <- normalizePath(file.path('./wordcloud.png')) # set the directory where the image is
                list(src = filename)

        }, deleteFile = FALSE)

        #' I use h2o package to fit the machine learning models
        #' logistic regression, random forest, and gbm

        labels <- semi_join(tweets[,c("id", "source")],
                            tweet_word_counts[,c("id")],
                            by = "id")
        dtm <- h2o.cbind(dtm, as.h2o(labels$source))
        names(dtm)[ncol(dtm)] <- "source"
        
        y <- "source"
        x <- setdiff(names(dtm), y)
        
        # model fitting
        glm_fit <- h2o.glm(x = x, y = y, family = "binomial", training_frame = dtm, nfolds = 5)

        # model prediction
        glm_pre <- reactive({
                # input a new tweet
                NewTweet <- data.frame('id'= "1", 'source' = NA, 'text' = input$tweet, 'created' = NA)
                NewTweet_words <- find_tweet_words(NewTweet)
                NewTweet_word_counts <- compute_tf_idf(NewTweet_words)
                Newdtm <- cast_dtm_h2o(NewTweet_word_counts, "id", 'word', 1)
                # predict the chance whether this tweet is from trump
                pre_glm <- h2o.predict(glm_fit, Newdtm)
                paste("The chance this tweet comes from Trump is",
                      as.character(as.data.frame(round(pre_glm$Android*100,2))),"%")
        })
        
        output$predmodel <- renderText({
                if(input$showModel_glm){'The model this prediction based on is Logistic Regression'}
                else{'  '}
        })
        
        output$pred <- renderText({
          if(input$goButton){paste(glm_pre())}
          else{'Enter a tweet and click the button to see the prediction'}
        })
        
        output$help <- renderText({
          if(input$help){paste("This app is to predict whether a specific tweet is from Trump or Trump's staff.", "\n",
            "You can type a tweet, the app will provide you the chance of this specific tweet that comes from Trump.",
            "This is based on David Robinson's popular sentiment analysis of Trumps tweets(http://varianceexplained.org/r/trump-tweets/).",
            "The data is provided by him from (http://varianceexplained.org/files/trump_tweets_df.rda).",
            "There are 1512 tweets in this analysis.","\n", 
            "To run this applicaiton, you need to install a few packages in your R studio, including dplyr, purrr, tidyr, h2o, stringr, tidytext", "\n",
            "It takes a little while to fit the model when start the app. Therefore, wait until the an image appears in the app before you type a new tweet.","\n", 
            "Now, type a new tweet, click the button, you can see the probability of this tweet comes from Trump.","\n", 
            "Enjoy the App!", sep='\n')
 
          }else{'  '}
        })
        
        
        print("you can use your app now!")
})        
