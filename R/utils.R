unzip_ <- function(path) {
  if (is.na(path)) return(NA)
  if (!file.exists(path)) stop("The file ", path, " does not exist", call. = FALSE)
  extracted_files <- utils::unzip(path, exdir = tempdir(), list = TRUE)
  if (nrow(extracted_files) == 1) {
    utils::unzip(path, exdir = tempdir())
    return(file.path(tempdir(), extracted_files[["Name"]]))
  } else {
    return(NA)
  }
}
