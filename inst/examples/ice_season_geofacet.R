library(raadtools)
library(dplyr)
library(tibble)
icef <- icefiles(time.resolution = "monthly") %>% as_tibble()

## we need the actual year-date, but also want
## the season/group-year (i.e. January belongs to 'last year' Feb-Jan)
year_shift <- function(yr, mn) {
 ifelse(mn == 1, yr - 1, yr)
}
year_int <- function(yr, mn) {
  yr * 100 + mn
}
files <- icef %>% mutate(month = as.integer(format(date, "%m")),
                year = as.integer(format(date, "%Y"))) %>%
  mutate(year_group = year_shift(year, month),
         year_val = year_int(year, month)) %>%
  dplyr::select(date, year_group, year_val, fullname)

read_ice <- local({
  function() {
    icf <- icefiles(time.resolution = "monthly")
    function(date, ...) {
      brick(readice(date, time.resolution = "monthly", inputfiles = icf, ...))
    }
  }}()
)


rgrid <- aggregate(read_ice(), fact = 50)
grid <- spex::qm_rasterToPolygons_sp(rgrid)

library(tabularaster)
cell_map <- cellnumbers(read_ice(), grid)


extract_year <- function(date_rows, cm) {
  yg <- date_rows$year_group[1]
  month <- date_rows$year_val
  dates <- files %>% dplyr::filter(year_group == yg) %>% pull(date)
  tibble(ice = as.vector(extract(read_ice(dates), cm$cell_)),
         object_ = rep(cm$object_, length(dates)),
         cell_ = rep(cm$cell_, length(dates)),
         year = yg, month = rep(month, each = nrow(cm)))
}

year_get <- function(obj) {
  files <- obj$files
  cell_map <- obj$cell_map
  print(files$year_group[1])
  extract_year(files, cell_map) %>%
    group_by(object_, year, month) %>%
    summarize(ice = mean(ice)) %>%
    ungroup()
}

library(future)
plan(multiprocess)
l <- lapply(split(files, files$year_group), function(x) list(files = x, cell_map = cell_map))
d <- future_lapply(l, year_get)

d <- bind_rows(d) #%>% filter(ice > 0)

d$month_int <- as.integer(substr(as.character(d$month), 5, 6))
d$year_int <- as.integer(substr(as.character(d$month), 1, 4))
library(ggplot2)
d$label <- as.character(d$object_)
library(gfmaker)
library(geofacet)
gf <- gfmaker(grid, code = as.character(seq(nrow(grid))),
              name = as.character(seq(nrow(grid))), r = rgrid)
## todo combine with geofacet map
ggplot(d %>% filter(!is.na(ice), ice > 0), aes(year, ice, group = month_int,
                                    colour = factor(month_int))) +
  geom_line() +
     facet_geo(~ label, grid = gf %>% dplyr::select(row, col, code, name))


## index map for reference
plot(grid); contour(readice(latest = TRUE)[[1]], add = TRUE); text(coordinates(grid), label = seq(nrow(grid)))

