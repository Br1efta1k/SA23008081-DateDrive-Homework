#---------------------------------
#Script Name
#Purpose:
  #this homework is about
  #-searching and installing packages
  #-application of the packages
  #-getting help of the package
#Author:  botaoyuan
#Email:  botaoyuan@foxmail.com
#Date:  2024/05/08  edit
#
#-------------------------------
cat("\014") #clears the console
rm(list = ls()) #remove all variables

# Check if tidyverse is installed, if not install it
if (!requireNamespace("tidyverse", quietly = TRUE)){install.packages(tidyverse)}

# Load the tidyverse package
library(tidyverse)

# Access some functions from the tidyverse package
# For example, use the ggplot() function
ggplot(mtcars, aes(x = mpg, y = disp)) + geom_point()

# Get help documentation for a function in the tidyverse package
?ggplot

help(package="tidyverse")#find help
demo(package="tidyverse")#find the application of the package

#find help
apropos("^tidyverse")
ls("package:tidyverse")
help.search("^tidyverse")
