################################################################################
#' Fonction identique à file.path mais qui nettoie le chemin éviter les chevauchements
#' de slashes et anti-slashes
#' @author David Dorchies
#' @date 31/07/2014
#' $Id: file.cleanpath.R 1307 2016-12-21 12:39:59Z david.dorchies $
################################################################################
file.cleanpath <- function(path1,path2) {
    sPath = file.path(path1,path2)
    sPath = gsub("\\\\","/",sPath) # Remplace les antislashes présents (bug avec la command system)
    sPath = gsub("//","/",sPath) #Suppression des séparateurs en double
    return(sPath)
}
