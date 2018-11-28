################################################################################
#' Test la présence d'un package, le télécharge au besoin et le charge.
#' Le programme est stoppé en cas d'échec.
#' @param x Chaîne de caractère avec le nom du package à charger
#' @param github_sources adresse des sources github pour installation d'un package depuis depuis github
#' @url http://stackoverflow.com/questions/9341635/how-can-i-check-for-installed-r-packages-before-running-install-packages
#' @date 31/07/2014 (Ajout source github 19/07/2018)
################################################################################
library.load <- function(x, gihub_sources = NULL)
{
    if (!require(x,character.only = TRUE)) {
        if (is.null(gihub_sources)) {
            install.packages(x,dep=TRUE,repos="http://cran.r-project.org")
        } else {
            library.load("devtools")
            devtools::install_github(github_sources)
        }
    }
    if(!require(x,character.only = TRUE)) {
        stop(paste("Loading of package", x, "failed"))
    }
    library(x,character.only = TRUE)
}
