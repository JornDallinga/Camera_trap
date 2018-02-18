library(raster)
library(RStoolbox)



########



dem <- raster('./Results/Criteria_data/dem_crit.tif')
slope <- raster('./Results/Criteria_data/slope_crit.tif')
precip <- raster('./Data/Climate/Precipitation/crop/precipitation.tif')
temp <- raster('./Data/Climate/Temperature/crop/temperature.tif')
hpi <- raster('./Results/hpi/hpi.tif')



s <- stack(dem, slope, precip, temp, hpi)
names(s) <- c('dem','slope','precip','temp', 'hpi')

scalefun <- function(r, precision = 2) {
  v <- round((s - minValue(s)) / (maxValue(s) - minValue(s)),precision)
  v[is.na(v)] <- 0 # avoid NA in flat terrains (slope layer)
  v
}


#scale raster data
s <- scale(s) 
plot(dem)
#arbitrary location you like:
e <- drawExtent()

xy <- cbind(e@xmin,e@ymin)
v <- extract(s, xy) 
d <- abs(s - as.vector(v))
dd <- sum(d)

# similar sites
plot(dd < 2)
plot(dd < 3)
