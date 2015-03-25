notify <- function() {
  e <- get("e", parent.frame())
  if(e$val == "No") return(TRUE)

  good <- FALSE
  while(!good) {
    # Get info
    name <- readline_clean("¿Cuál es tu nombre completo? ")
    address <- readline_clean("¿Cuál es la dirección de correo electrónico de la persona a la que querrías notificar? ")

    # Repeat back to them
    message("\n¿Está todo como corresponde?\n")
    message("Tu nombre: ", name, "\n", "Enviar a: ", address)

    yn <- select.list(c("Sí", "No"), graphics = FALSE)
    if(yn == "Sí") good <- TRUE
  }

  # Get course and lesson names
  course_name <- attr(e$les, "course_name")
  lesson_name <- attr(e$les, "lesson_name")

  subject <- paste(name, "acaba de completar", course_name, "-", lesson_name)
  body = ""

  # Send email
  swirl:::email(address, subject, body)

  hrule()
  message("He intentado crear un nuevo correo electrónico con la siguiente información:\n")
  message("Para: ", address)
  message("Asunto: ", subject)
  message("Cuerpo: <empty>")

  message("\nSi no ha salido bien, puedes enviar el correo electrónico manualmente.")
  hrule()

  # Return TRUE to satisfy swirl and return to course menu
  TRUE
}

readline_clean <- function(prompt = "") {
  wrapped <- strwrap(prompt, width = getOption("width") - 2)
  mes <- stringr::str_c("| ", wrapped, collapse = "\n")
  message(mes)
  readline()
}

hrule <- function() {
  message("\n", paste0(rep("#", getOption("width") - 2), collapse = ""), "\n")
}

match_call <- function(correct_call = NULL) {
  e <- get("e", parent.frame())
  # Trivial case
  if(is.null(correct_call)) return(TRUE)
  # Get full correct call
  full_correct_call <- expand_call(correct_call)  
  # Expand user's expression
  expr <- deparse(e$expr)
  full_user_expr <- expand_call(expr)
  # Compare function calls with full arg names
  identical(full_correct_call, full_user_expr)
}

# Utility function for match_call answer test
# Fills out a function call with full argument names
expand_call <- function(call_string) {
  # Quote expression
  qcall <- parse(text=call_string)[[1]]
  # If expression is not greater than length 1...
  if(length(qcall) <= 1) return(qcall)
  # See if it's an assignment
  is_assign <- is(qcall, "<-")
  # If assignment, process righthandside
  if(is_assign) {
    # Get righthand side
    rhs <- qcall[[3]]
    # If righthand side is not a call, can't use match.fun()
    if(!is.call(rhs)) return(qcall)
    # Get function from function name
    fun <- match.fun(rhs[[1]])
    # match.call() does not support primitive functions
    if(is.primitive(fun)) return(qcall)
    # Get expanded call
    full_rhs <- match.call(fun, rhs)
    # Full call
    qcall[[3]] <- full_rhs
  } else { # If not assignment, process whole thing
    # Get function from function name
    fun <- match.fun(qcall[[1]])
    # match.call() does not support primitive functions
    if(is.primitive(fun)) return(qcall)
    # Full call
    qcall <- match.call(fun, qcall)
  } 
  # Return expanded function call
  qcall
}
