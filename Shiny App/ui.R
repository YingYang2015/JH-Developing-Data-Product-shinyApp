
library(shiny)
shinyUI(fluidPage(
        titlePanel("Is this tweet from Trump or his staff?"),
        sidebarLayout(
                sidebarPanel(
                        checkboxInput(inputId="help", "Click to see the documentation"),
                        
                        textInput(inputId="tweet", label = "Enter a tweet here"), 
                        checkboxInput("showModel_glm", "Show the prediction model", value = FALSE),
                        actionButton(inputId="goButton", "Click to see the prediction!")
                ),
                mainPanel(
                        plotOutput("CloudWordsPlot"),
                        h3(textOutput("pred")),
                        h4(textOutput("predmodel")),
                        h4(textOutput("help"))
        )
)))                         
