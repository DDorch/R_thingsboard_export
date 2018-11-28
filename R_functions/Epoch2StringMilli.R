#' Convert a numeric into a string with trailing "000"
#'
#' @param epoch numeric
#'
#' @return string
#' @export
#'
#' @examples Epoch2StringMilli(as.numeric(Sys.time()))
Epoch2StringMilli <- function(epoch) {
    return (paste0(as.character(floor(epoch)), "000"))
}
