friendlyShiny
=============

FriendlyShiny is my attempt at making the wonderful reactive code abilities of R's shiny package more accessible to novice users, and folks who want interactive code quickly. FriendlyShiny provides a simple syntax for specifying reactive elements in code chunk without the overhead of designing the user interface and coding the applet by hand.


To allow interactivity for a code chunk, it just needs to be wrapped in an ```interact``` function call.


Consider trying to teach a math class about line specifications. You've taught them a line can be specified by 
```y = mx + b``` 
but you'd like to show them how the line changes with its parameters.


You could write demostration code like this to plot a line, and bring the plot up in front of your students

```r
  slope <- 1
  intercept <- 0
  
  plot(0,
       ylim = c(0, 15),
       xlim = c(0, 10),
       xlab = "x",
       ylab = "y",
       col = 0)
  
  abline(intercept, slope)
```

Now you could go back to your code and change the values of slope and intercept by hand, *OR* you can make it interactive very simply like so:

```r
interact(
{
  slope <- sI("slope", 1, min = 1/3, max = 3)
  intercept <- nI("intercept", 0)

  plot(0,
       ylim = c(0, 15),
       xlim = c(0, 10),
       xlab = "x",
       ylab = "y",
       col = 0)
  
  abline(intercept, slope)
  
}, outputType = "plot")
```

All you need to do is wrap your code in curly braces and a call to ```interact```, then you need to specify you want a slider to help you choose the slope, and a numerical input box to specify the intercept (you probably want a slider for that too, but I'm sure you can see how to fix it).

 
The last argument after the curly braces tells the interact function whether to render your output as text or as a plot. Text output is useful for fine tuning parameters for modelling parameters and plot output is useful for getting the graphing parameter juuust right.


Supported Widgets
-----------------

Currently friendlyShiny supports:

  * SliderInput: **sI**(name, start, min, max, step = NULL)
  * NumericInput: **nI**(name, start)
  * TextInput: **tI**(name, start = "")
  * SelectInput (i.e. Drop down box): **dI**(name, type, start, ...) where ... are your choices (comma delimited) and type can be "character" or "numeric"
  * RadioButtons: **rI**(name, type, start, ...) exactly like dI but a different choice mode
  * CheckboxInput: **cI**(name, start = FALSE) toggles a logical between true and false

please note that the shorthand widget specifications use capital i, not l as it appears in this font.

How to install
---------------

If you're on here you probably know how to do this better than I do, but you can install this package to play with and improve (if you're up to the task) by running the following commands in R:

```r
install.packages("devtools") #if you don't already have devtools installed
library(devtools)

install_git("cfhammill/friendlyShiny")
```

Outro
-----

I hope you like my package! I sincerely hope someone takes the reigns on this project, anyone can take my code and turn it into something amazing. I don't intend to polish it much more than this, I just thought shiny should be accessible to everyone. If you notice any glaring errors please let me know.


If you like my work please check out my blog at
http://www.datamancy.blogspot.com

-Chris
