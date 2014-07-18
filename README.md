friendlyShiny
=============

FriendlyShiny is my attempt at making the wonderful reactive code abilities of R's shiny package more
accessible to novice users, and folks who want interactive code quickly. FriendlyShiny provides a recognizable
syntax for specifying reactive elements in code chunk without the overhead of designing the user
interface and coding the applet by hand.

To allow interactivity for a code chunk, it just needs to be wrapped in an ```interact``` function call.

For example, consider the trivial example of wanting to adjust the slope of a straight line between 1/3 and 3 with some
intercept to demonstrate how lines are specified to a math class

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

You could go back to your code and change the values of slope and intercept by hand or
you can make it interactive very simply like so:

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

All you needed to do was wrap you code in curly braces and a call to ```interact```, then you needed to specify you wanted
a slider to help you choose the slope between 1/3 and 3, and a numerical input box to specify the intercept (you probably
wanted a slider for that too, but I'm sure you can see how to fix it).

Supported Widgets
-----------------

Currently friendlyShiny supports:
  * SliderInput: sI(name, start, min, max, step = NULL)
  * NumericInput: nI(name, start)
  * TextInput: tI(name, start = "")
  * SelectInput (i.e. Drop down box): dI(name, type, start, ...) where ... are your choices (comma delimited) and
    type can be "character" or "numeric"
  * RadioButtons: rI(name, type, start, ...) exactly like dI but a different choice mode
  * CheckboxInput: cI(name, start = FALSE) toggles a logical between true and false

How to install
---------------

If you're on here you probably know how to do this better than I do, but you can install this package to play with
and improve (if you're up to the task) by running the following commands in R:

```r
install.packages("devtools") #if you don't already have devtools installed
library(devtools)

install_git("cfhammill/friendlyShiny")
```

Outro
-----

I hope you like my package! I sincerely hope someone takes the reigns on this project. I don't intend to
polish it much more than this, I just thought shiny should be accessible to everyone. If you notice any
glaring errors please let me know.

If you like my work please check out my blog at
www.datamancy.blogspot.com

-Chris
