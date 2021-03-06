% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gfmaker.R
\name{gfmaker}
\alias{gfmaker}
\title{Geofacet structure}
\usage{
gfmaker(x, max_dim = c(150, 150), code = NULL, name = NULL, ...,
  r = NULL)
}
\arguments{
\item{x}{a spatialish thinger}

\item{max_dim}{the maximum dimensions of the grid (defaults to 150x150)}

\item{...}{ignorad}
}
\value{
data frame of row, column number
}
\description{
Make geofacet structure from spatial things. The first column of data is used if present.
}
\details{
A row/col data frame is produced from sp, sf or raster. Get in touch if you have
other types to geofacet!
}
\examples{
 data("wrld_simpl", package = "maptools")
gfmaker(wrld_simpl)
r <- rasterize(wrld_simpl, raster(wrld_simpl))
gfmaker(r)
}
