library(geofacet)
library(ggplot2)
# ggplot(state_unemp, aes(year, rate)) +
#   geom_line() +
#   facet_geo(~ state, grid = "us_state_grid2") +
#   scale_x_continuous(labels = function(x) paste0("'", substr(x, 3, 4))) +
#   ylab("Unemployment Rate (%)")
#

# ggplot(fortify(wrld_simpl) %>%
#          inner_join(wrld_simpl@data %>%
#                       mutate(rn = row.names(wrld_simpl)), c("id" = "rn")),
#       aes(long, lat, group =group, fill = factor(REGION))) +
#   geom_polygon() + guides(colour = FALSE)


library(tibble)
library(dplyr)
data("wrld_simpl", package = "maptools")
library(gfmaker)
library(sf)
library(spdplyr)
#map <- subset(wrld_simpl, REGION == 2)
map1 <- read_sf(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
ind <- unique( unlist(st_touches(map1[unlist(st_touches(map1[2,], map1)), ], map1)))
map1 <- as(map1, "Spatial") %>% slice(ind)

#gf <- gfmaker(map, code = map$ISO2, name = map$NAME)
gf <- gfmaker(map1, code = as.character(map1$CNTY_ID), name = map1$NAME, max_dim = c(12, 12))
gf <- distinct(gf, row, col, .keep_all = TRUE)
nn <- 1e3

#map <- subset(map, ISO2 %in% gf$code)
d <- tibble(x = rnorm(nn), y = rnorm(nn),
            label = sample(as.character(map1$CNTY_ID), nn, replace = TRUE)) %>%
  arrange(label)


library(geofacet)
library(ggplot2)
ggplot(d, aes(x, y)) +
  geom_line() +
  facet_geo(~ label, grid = gf %>% select(row, col, code, name)) +
  scale_x_continuous(labels = function(x) paste0("'", substr(x, 3, 4))) +
  ylab("Unemployment Rate (%)")


asp <- 1/cos(mean(gf$y_) * pi / 180)
plot(map1, main = "pure geography", asp = asp)
plot(gf$col, 1+ max(gf$row) - gf$row, asp = asp, main = "the generated grid")
