#' Interact
#'
#' Specify a code chunk as interactive and generate an applet in a new window
#' @param code the code to be made interactive
#' @param outputType character specification of output type, "character" or "numeric"
#' @keywords interact, shiny, reactive
#' @export
#' @examples
#' interact({
#' plot(1:5 * sI("multiplier", 3, min = 0, max = 5, step = .01), 1:5,
#'     xlab = tI("xlabel", "Woah"),
#'     xlim = c(0, 25))
#' },
#' outputType = "plot")
#'
#' interact({
#'  plot(1:5 * dI("multiplier", "numeric", 3, list(1,2,3)), 1:5,
#'       xlab = tI("xlabel", "Woah"),
#'       ylab = as.character(cI("log", FALSE)),
#'       xlim =c(0,15))
#' },
#' outputType = "plot")
interact <- function(code, outputType){
  if(!require(shiny)){stop("Please install shiny and try again")}
  codeText <- paste0(deparse(substitute(code)), collapse = "\n") 
  
  widgets <- findWidgets(codeText)
  
  firstArgument <- matchPull("(?s)\\(.+?[,\\)]", widgets, perl = TRUE)
  
  widgetName <- matchPull("\\w+", firstArgument, perl = TRUE)

  widgetsToPass <- lapply(widgets, function(w){eval(eval(parse(text = w)))})
  
  codeFixed <- codeText
  for(i in 1:length(widgets)){
    widget <- widgets[i]
    
    if(grepl("[rd]I\\(", widget, perl = TRUE)){
      
      if(grepl("type *=", widget, perl = TRUE)){
        type <- sub("type *= *", "", matchPull("type *= *\\w+", widget), perl = TRUE)
      } else {
        type <- gsub("[^\\w]", "", matchPull(", *[\'\"]?\\w+", widget, perl = TRUE), perl = TRUE)
      }
      
      if(type != "character" && type != "numeric"){stop("Please choose either numeric or character type")}
      
      codeFixed <- switch(type,
                          numeric = sub(widget, paste0("as.numeric(input$", widgetName[i],")"), codeFixed, fixed = TRUE),
                          character = sub(widget, paste0("input$", widgetName[i]), codeFixed, fixed = TRUE))
  
    } else {
      codeFixed <- sub(widget, paste0("input$", widgetName[i]), codeFixed, fixed = TRUE)
    }
  }

 
  shinyApp(
    ui = fluidPage(
      sidebarLayout(
        sidebarPanel(widgetsToPass),
        mainPanel(
          if(outputType == "text"){
            textOutput("main")
            } else if(outputType == "plot"){
              plotOutput("main")
            } else {
              stop("Only text and plot output supported, please specify")
            },
          htmlOutput("code")
          )
        )),
    
    server = function(input, output){
     input
     if(outputType == "text"){
       output$main <- renderText(eval(parse(text = codeFixed)))  
     } else if(outputType == "plot"){
       output$main <- renderPlot(eval(parse(text = codeFixed)))
     } else {
       stop("Only text and plot output supported, please specify")
     }
     
     output$code <- renderText({
       variables <- unlist(matchPull("input\\$\\w+", codeFixed, perl = TRUE, global = TRUE))
       codeReturn <- paste0(as.character(codeFixed), collapse = "\n")
       
       for(i in 1:length(variables)){
         val <- eval(parse(text = variables[i]))
         codeReturn <- sub(variables[i], 
                           as.character(val), 
                           codeReturn,
                           fixed = TRUE)
       }
       
       codeReturn <- gsub("\n", "<br>", codeReturn, fixed = TRUE)
       codeReturn
       })
    }
    )
}

#' findWidgets
#'
#' Auxillary function for text manipulation. Finds and extracts a complete widget function
#' call by bracket matching
#' @param text character string of code to be searched
#' @return character vector of each widget function call
#' @export
findWidgets <- function(text){
  matchStarts <- unlist(gregexpr("(?s)[srcdtn]I\\(", text, perl = TRUE))
  widgetsCleaned <- character(length(matchStarts))
  
  for(i in 1:length(matchStarts)){
    inParen <- FALSE
    open <- 0
    end <- 0
    
    for(j in matchStarts[i]:nchar(text)){
      if(substr(text, j, j) == "("){open <- open + 1}
      if(substr(text, j, j) == ")"){open <- open - 1}
      if(open == 1 && !inParen){inParen <- TRUE}
      if(open == 0 && inParen){end <- j; break}
    }
    
    widgetsCleaned[i] <- substr(text, matchStarts[i], end)
  }
  
  widgetsCleaned
}

#' matchPull
#'
#' Auxillary function for text manipulation. Finds and extracts a substring specified
#' by a regular expression. Can be applied arbitrary length vectors
#' @param pattern regular expression to be extracted
#' @param text character vector to be searched
#' @param invert logical, indicating whether to extract matched substring (invert = FALSE) or remainder (default FALSE)
#' @param global logical, find multiple matches within a character string (default FALSE)
#' @return character vector of matches or if text has more than one element and global is true a list of vectors of matches 
#' @keywords substring, regex
#' @seealso \code{\link{regex}}, \code{\link{regexpr}}, \code{\link{regmatches}}
#' @export
#' @examples
#' cat_function()
matchPull <- function(pattern, text, invert = FALSE, global = FALSE, ...){
  if(global){
    match <- gregexpr(pattern, text, ...)
  } else {
    match <- regexpr(pattern, text, ...)
  }
  
  pulled <- regmatches(text, match, invert)
  if(length(pulled) == 0) pulled <- NA
  
  pulled
}

#' Friendly Slider Widget Function
#'
#' Alias for \code{\link{sliderInput}}(name, name, min, max, step)
#' @param name character, the name and label to be used for this widget, must be a proper R variable name
#' @param start numeric, initial value of the slider
#' @param min numeric, minimum value of the slider
#' @param max numeric, maximum value of the slider
#' @param step numeric, smallest step slider can move (optional)
#' @return unevaluated function to be used in generating code for \code{\link{interact}} 
#' @keywords slider, sliderInput, widget
#' @seealso \code{\link{sliderInput}}, \code{\link{interact}}
#' @export
sI <- function(name, start, min = NULL, max = NULL, step = NULL){
  if(is.null(min) || is.null(max)){stop("Please specify only one named start value in addition to min and max")}
  
  inputId <- name
  value <- start
  
  return(substitute(sliderInput(inputId, inputId, min = min, max = max, value = value, step = step)))
}

#' Friendly Numeric Input Widget Function
#'
#' Alias for \code{\link{numericInput}}(name, name, start)
#' @param name character, the name and label to be used for this widget, must be a proper R variable name
#' @param start numeric, initial value of the input
#' @return unevaluated function to be used in generating code for \code{\link{interact}} 
#' @keywords numericInput, widget
#' @seealso \code{\link{numericInput}}, \code{\link{interact}}
#' @export
nI <- function(name, start = NULL){
  if(is.null(start)){stop("Please specify a starting value")}
  
  inputId <- name
  value <- as.numeric(start)
  
  return(substitute(numericInput(inputId, inputId, value = value)))
}

#' Friendly Radio Button Widget Function
#'
#' Alias for \code{\link{radioButtons}}(name, name, ..., selected = start) additional functionality
#' permits radio buttons for specific numeric inputs
#' @param name character, the name and label to be used for this widget, must be a proper R variable name
#' @param type character, the object class for the options, only supports numeric and character
#' @param start character or numeric, initial radio button selected 
#' @param ... comma delimited list of possible values for the radio buttons
#' @return unevaluated function to be used in generating code for \code{\link{interact}} 
#' @keywords radio buttons, radioButtons, widget
#' @seealso \code{\link{radioButtons}}, \code{\link{interact}}
#' @export
rI <- function(name, type, start, ...){
  argList <- as.list(unlist(list(...), recursive = TRUE))
  if(type != "numeric" & type != "character"){ stop("You must specify radio button type (character or numeric)")}
  
  selected <- start
  choices <- switch(type,
                    numeric = lapply(argList, as.numeric),
                    character = lapply(argList, as.character))
  
  inputId <- name
  
  value <- switch(type,
                  numeric = as.numeric(selected),
                  character = as.character(selected))
  
  return(substitute(radioButtons(inputId, inputId, choices = choices, selected = value)))
}

#' Friendly Drop Down Box Widget Function
#'
#' Alias for \code{\link{selectInput}}(name, name, ..., selected = start) additional functionality
#' permits radio buttons for specific numeric inputs
#' @param name character, the name and label to be used for this widget, must be a proper R variable name
#' @param type character, the object class for the options, only supports numeric and character
#' @param start character or numeric, initial radio button selected 
#' @param ... comma delimited list of possible values for the drop down box
#' @return unevaluated function to be used in generating code for \code{\link{interact}} 
#' @keywords drop down box, selectInput, widget
#' @seealso \code{\link{radioButtons}}, \code{\link{interact}}
#' @export
dI <- function(name, type, start = NULL, ...){
  argList <- as.list(unlist(list(...), recursive = TRUE))
  if(type != "numeric" & type != "character"){ stop("You must specify radio button type (character or numeric)")}
  
  selected <- start
  choices <- switch(type,
                    numeric = lapply(argList, as.numeric),
                    character = lapply(argList, as.character))
  
  inputId <- name
  
  value <- switch(type,
                  numeric = as.numeric(selected),
                  character = as.character(selected))
  
  return(substitute(selectInput(inputId, inputId, choices = choices, selected = value)))
}

#' Friendly Text Input Widget Function
#'
#' Alias for \code{\link{textInput}}(name, name, start)
#' @param name character, the name and label to be used for this widget, must be a proper R variable name
#' @param start character, initial value of the input
#' @return unevaluated expression to be used in generating code for \code{\link{interact}} 
#' @keywords textInput, widget
#' @seealso \code{\link{textInput}}, \code{\link{interact}}
#' @export
tI <- function(name, start = ""){
  inputId <- name
  value <- as.character(start)
  
  return(substitute(textInput(inputId, inputId, value = value)))
}

#' Friendly Check Box Widget Function
#'
#' Alias for \code{\link{checkboxInput}}(name, name, start)
#' @param name character, the name and label to be used for this widget, must be a proper R variable name
#' @param start logical, initial value of the input
#' @return unevaluated expression to be used in generating code for \code{\link{interact}} 
#' @keywords check box, checkboxInput, widget
#' @seealso \code{\link{checkboxInput}}, \code{\link{interact}}
#' @export
cI <- function(name, start = FALSE){
  inputId <- name
  value <- as.logical(start)
  
  return(substitute(checkboxInput(inputId, inputId, value = value)))
}


