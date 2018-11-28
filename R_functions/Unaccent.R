#' Remove accents from a string
#'
#' @param text The string where accents need to be removed
#'
#' @return the string without accents
#' @see From https://data.hypotheses.org/564
#'
#' @examples
Unaccent <- function(text, from="UTF-8") {
    text <- gsub("['`^~\"]", " ", text)
    text <- iconv(text, from=from, to="ASCII//TRANSLIT//IGNORE")
    text <- gsub("['`^~\"]", "", text)
    return(text)
}


UnaccentSmart <- function(text, from="UTF-8", alterfrom="latin1") {
    tOut = Unaccent(text, from)
    if(nchar(text) != nchar(tOut)) {
        # Des caractères ont visiblement été oubliés dans la conversion, on essaie un autre charset
        tOut = Unaccent(text, from=alterfrom)
    }
    return(tOut)
}
