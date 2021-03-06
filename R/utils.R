

# Unexported usefull functions from shiny



# dropNulls
dropNulls <- function (x)
{
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}


# choicesWithNames
choicesWithNames <- function (choices)
{
  listify <- function(obj) {
    makeNamed <- function(x) {
      if (is.null(names(x)))
        names(x) <- character(length(x))
      x
    }
    res <- lapply(obj, function(val) {
      if (is.list(val))
        listify(val)
      else if (length(val) == 1 && is.null(names(val)))
        val
      else makeNamed(as.list(val))
    })
    makeNamed(res)
  }
  choices <- listify(choices)
  if (length(choices) == 0)
    return(choices)
  choices <- mapply(choices, names(choices), FUN = function(choice,
                                                            name) {
    if (!is.list(choice))
      return(choice)
    if (name == "")
      stop("All sub-lists in \"choices\" must be named.")
    choicesWithNames(choice)
  }, SIMPLIFY = FALSE)
  missing <- names(choices) == ""
  names(choices)[missing] <- as.character(choices)[missing]
  choices
}



# needOptgroup
needOptgroup <- function (choices)
{
  any(vapply(choices, is.list, logical(1)))
}

# validateSelected
validateSelected <- function (selected, choices, inputId)
{
  selected <- unname(selected)
  if (needOptgroup(choices))
    return(selected)
  if (is.list(choices))
    choices <- unlist(choices)
  nms <- names(choices)
  if (identical(nms, unname(choices)))
    return(selected)
  i <- (selected %in% nms) & !(selected %in% choices)
  if (any(i)) {
    warnFun <- if (all(i)) {
      selected <- unname(choices[selected])
      warning
    }
    else stop
    warnFun("'selected' must be the values instead of names of 'choices' ",
            "for the input '", inputId, "'")
  }
  selected
}


`%AND%` <- function (x, y) {
  if (!is.null(x) && !anyNA(x))
    if (!is.null(y) && !anyNA(y))
      return(y)
  return(NULL)
}


`%||%` <- function(x, y) {
  if (!is.null(x)) x else y
}

escape_jquery <- function(string) {
  gsub(x = string, pattern = "(\\W)", replacement = "\\\\\\\\\\1")
}




firstChoice <- function (choices)
{
  if (length(choices) == 0L)
    return()
  choice <- choices[[1]]
  if (is.list(choice))
    firstChoice(choice)
  else choice
}



anyNamed <- function (x) {
  if (length(x) == 0)
    return(FALSE)
  nms <- names(x)
  if (is.null(nms))
    return(FALSE)
  any(nzchar(nms))
}

normalizeChoicesArgs <- function (choices, choiceNames, choiceValues, mustExist = TRUE) {
  if (is.null(choices)) {
    if (is.null(choiceNames) || is.null(choiceValues)) {
      if (mustExist) {
        stop("Please specify a non-empty vector for `choices` (or, ",
             "alternatively, for both `choiceNames` AND `choiceValues`).")
      }
      else {
        if (is.null(choiceNames) && is.null(choiceValues)) {
          return(list(choiceNames = NULL, choiceValues = NULL))
        }
        else {
          stop("One of `choiceNames` or `choiceValues` was set to ",
               "NULL, but either both or none should be NULL.")
        }
      }
    }
    if (length(choiceNames) != length(choiceValues)) {
      stop("`choiceNames` and `choiceValues` must have the same length.")
    }
    if (anyNamed(choiceNames) || anyNamed(choiceValues)) {
      stop("`choiceNames` and `choiceValues` must not be named.")
    }
  }
  else {
    if (!is.null(choiceNames) || !is.null(choiceValues)) {
      warning("Using `choices` argument; ignoring `choiceNames` and `choiceValues`.")
    }
    choices <- choicesWithNames(choices)
    choiceNames <- names(choices)
    choiceValues <- unname(choices)
  }
  return(list(choiceNames = as.list(choiceNames), choiceValues = as.list(as.character(choiceValues))))
}

validateIcon <- function (icon)
{
  if (is.null(icon) || identical(icon, character(0))) {
    return(icon)
  }
  else if (inherits(icon, "shiny.tag") && icon$name == "i") {
    return(icon)
  }
  else {
    stop("Invalid icon. Use Shiny's 'icon()' function to generate a valid icon")
  }
}

controlLabel <- function(controlName, label) {
  label %AND% htmltools::tags$label(class = "control-label", `for` = controlName, label)
}

formatNoSci <- function(x) {
  if (is.null(x)) return(NULL)
  format(x, scientific = FALSE, digits = 15)
}
