# Load libraries

if (!require(rgdal)) install.packages('rgdal')
if (!require(rgeos)) install.packages('rgeos')
if (!require(raster)) install.packages('raster')
if (!require(plotKML)) install.packages('plotKML')
if (!require(gdalUtils)) install.packages('gdalUtils')


# Get data

shape <- readOGR(dsn = "./Data/Extent", layer = "Joeri_Extent")
shape <- reproject(shape, CRS = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0', program = 'GDAL', method = 'near')

#shape@bbox

# download clim data @ http://worldclim.org/version2
# save downloaded Climate files in folder "./Data/Climate/Precipitation" or "./Data/Climate/Temperature"

dir.create("./Data/Climate/", showWarnings = F)
dir.create("./Data/Climate/Precipitation", showWarnings = F)
dir.create("./Data/Climate/Temperature", showWarnings = F)
dir.create("./Data/Climate/Precipitation/crop", showWarnings = F)
dir.create("./Data/Climate/Temperature/crop", showWarnings = F)



precip <- list.files("./Data/Climate/Precipitation/", pattern = ".tif", full.names = T)
temp <- list.files("./Data/Climate/Temperature/", pattern = ".tif", full.names = T)

# calc mean precipitation
precip <- stack(precip)
precip <- crop(precip, shape)
precip <- calc(precip, fun = mean)
precip <- resample(precip, dem, method="bilinear")

# calc mean temperature
temp <- stack(temp)
temp <- crop(temp, shape)
temp <- calc(temp, fun = mean)
temp <- resample(temp, dem, method="bilinear")

writeRaster(precip, filename = "./Data/Climate/Precipitation/crop/precipitation.tif", overwrite = T)
writeRaster(temp, filename = "./Data/Climate/Temperature/crop/temperature.tif", overwrite = T)


### DEM

mosaic_rasters(dem, dst_dataset = "./Data/Precipitation/Mosaic/Mosaic_Precip.tif")
precip <- raster("./Data/Precipitation/Mosaic/Mosaic_Precip.tif")
dem <- crop(dem, shape)
writeRaster(dem,filename = "./Data/SRTM/Mosaic/Mosaic_SRTM_crop.tif")

# download SRTM data at https://earthexplorer.usgs.gov/ or http://dwtkns.com/srtm/
# save downloaded DEM files in folder "./Data/SRTM/"

dem <- list.files("./Data/SRTM/", pattern = ".tif", full.names = T)
dir.create("./Data/SRTM/Mosaic", showWarnings = F)
mosaic_rasters(dem, dst_dataset = "./Data/SRTM/Mosaic/Mosaic_SRTM.tif")
dem <- raster("./Data/SRTM/Mosaic/Mosaic_SRTM.tif")
dem <- crop(dem, shape)
writeRaster(dem,filename = "./Data/SRTM/Mosaic/Mosaic_SRTM_crop.tif")

# create slope from DEM
dir.create("./Data/Slope", showWarnings = F)
terrain(dem, opt='slope', unit='degrees', neighbors=4, filename='./Data/Slope/Slope.tif')
slope <- raster('./Data/Slope/Slope.tif')

# prep criteria data sets
dir.create("./Results", showWarnings = F)
dir.create("./Results/Criteria_data", showWarnings = F)

slope[slope > 8] <- NA
dem[dem > 1500] <- NA

writeRaster(slope, filename = "./Results/Criteria_data/slope_crit.tif")
writeRaster(dem, filename = "./Results/Criteria_data/dem_crit.tif")

# HPI
hpi <- raster('./Data/Human pressure Index/hpi/hpi_1_1000_16b_cmp.tif')
shape <- reproject(shape, CRS = '+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0', program = 'GDAL', method = 'bilinear')
hpi <- crop(hpi, shape)
hpi <- reproject(hpi, CRS = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0', program = 'GDAL', method = 'bilinear')
hpi <- resample(hpi, dem, method="bilinear")

dir.create("./Results/hpi", showWarnings = F)
writeRaster(hpi, filename = './Results/hpi/hpi.tif', overwrite = T)
