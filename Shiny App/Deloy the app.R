install.packages('rsconnect')
library(rsconnect)


rsconnect::setAccountInfo(name='yangyingtina', token='4D8E44414D8BEFE21DC94B266F8B954C', 
                          secret='jZQweVOBv41bjfbocKovbOBUDXHpteFHXndgI8/Q')
setwd("C:/Users/User/Dropbox/Data Science/Jonhs Hopkins Courses/R coding practice _Ying/9. Developing Data Products/Final project/Shiny App")
deployApp()