#' Geofacet structure
#'
#' Make geofacet structure from spatial things. The first column of data is used if present.
#'
#' A row/col data frame is produced from sp, sf or raster. Get in touch if you have
#' other types to geofacet!
#'
#' @param x a spatialish thinger
#' @param max_dim the maximum dimensions of the grid (defaults to 150x150)
#' @param ... ignorad
#'
#' @return data frame of row, column number
#' @export
#' @importFrom spbabel xy_
#' @importFrom raster rasterFromXYZ
#' @importFrom tibble as_tibble
#' @examples
#'  data("wrld_simpl", package = "maptools")
#' gfmaker(wrld_simpl)
#' r <- rasterize(wrld_simpl, raster(wrld_simpl))
#' gfmaker(r)
gfmaker <- function(x, max_dim = c(150, 150), code = NULL, name = NULL, ..., r = NULL) {
  #xy <- spbabel::xy_(x)
xy <- centroid_(x)
## thefuck, doesn't work with a full grid?
if (is.null(r))  r <- raster::rasterFromXYZ(cbind(as.matrix(xy), 0), digits = 0)
  rdim <- dim(r)[1:2]
  the_dim <- pmin(max_dim, rdim)
  if (any(!the_dim == rdim)) {
    dim(r) <- the_dim
  }
  cells <- raster::cellFromXY(r, as.matrix(xy))
  rc <- tibble::tibble(row = raster::rowFromCell(r, cells),
                       col = raster::colFromCell(r, cells))

  rc[["code"]] <- if (is.null(code))  get_values(x) else code
  rc[["name"]] <- if (is.null(name)) rc[["code"]] else name
  rc[["x_"]] <- xy$x_
  rc[["y_"]] <- xy$y_
  rc
  # https://rpubs.com/cyclemumner/278962
#
#     wrld_grid <- cellnumbers(rgrid, coordinates(wrld_simpl)) %>%
#     inner_join(wrld_simpl@data %>% select(ISO3) %>% mutate(object_ = row_number())) %>%
#     mutate(row = nrow(rgrid) - rowFromCell(rgrid, cell_) + 1, col = colFromCell(rgrid, cell_)) %>%
#     select(-object_, -cell_) %>%
#     rename(label = ISO3)
}

centroid_ <- function(x) {
  if (inherits(x, "Spatial")) {
    return(setNames(as_tibble(
      coordinates(rgeos::gCentroid(x, byid = TRUE))), c("x_", "y_")))
  }
  if (inherits(x, "sf")) {
    return(matrix(unlist(sf::st_geometry(sf::st_centroid(x))), ncol = 2))
  }
  stop("unsupported type")
}
gt0 <- function(x) {
  min(x[x > 0])
}

get_values <- function(x) UseMethod("get_values")
get_values.default <- function(x) {
  x[[1L]]  ## any dataframe, sp or sf
}
get_values.BasicRaster <- function(x) {
  x[[1L]][]
}

