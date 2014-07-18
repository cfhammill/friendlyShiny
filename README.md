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

x <- 1:5
y <- 1:5 * slope + intercept

plot(x, y)
```

This can be made interactive very simply like so

```r
interact(
{
slope <- sI("slope", 1, min = 1/3, max = 3)
intercept <- nI("intercept", 0)

x <- 1:5
y <- 1:5 * slope + intercept

plot(x, y)
}, outputType = "plot")

```
