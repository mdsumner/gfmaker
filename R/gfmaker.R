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
gfmaker <- function(x, max_dim = c(150, 150), ...) {
  xy <- spbabel::xy_(x)
  r <- raster::rasterFromXYZ(xy, digits = 0)
  rdim <- dim(r)[1:2]
  the_dim <- pmin(max_dim, rdim)
  if (any(!the_dim == rdim)) {
    dim(r) <- the_dim
  }
  cells <- raster::cellFromXY(r, as.matrix(xy))
  rc <- tibble::tibble(row = 1L + nrow(r) - raster::rowFromCell(r, cells),
                       col = raster::colFromCell(r, cells))

  rc[[names(x)[1L]]] <- get_values(x)
  rc
  # https://rpubs.com/cyclemumner/278962
#
#     wrld_grid <- cellnumbers(rgrid, coordinates(wrld_simpl)) %>%
#     inner_join(wrld_simpl@data %>% select(ISO3) %>% mutate(object_ = row_number())) %>%
#     mutate(row = nrow(rgrid) - rowFromCell(rgrid, cell_) + 1, col = colFromCell(rgrid, cell_)) %>%
#     select(-object_, -cell_) %>%
#     rename(label = ISO3)
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

