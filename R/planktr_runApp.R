#' run planktonr app
#'
#' @return launches planktonr plankton counting shiny app
#' @export
#'
#' @examples planktr_runApp()
planktr_runApp <- function() {
    appDir <- system.file("shiny", "app", package = "planktonr")
    if (appDir == "") {
        stop("Could not find example directory. Try re-installing `planktonr`.", call. = FALSE)
    }

    shiny::runApp(appDir, display.mode = "normal")
}
