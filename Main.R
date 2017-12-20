# Main script

# load packages R
library(raster)
install.packages('RStoolbox')
library(RStoolbox)

# load test data
## download Climate data at http://worldclim.org/version2

## set Data location
dirloc <- "./Data"

# loop through folders
lf <- list.files(dirloc, pattern = ".tif", include.dirs = T, recursive = T, full.names = T)

# stack raster files
stack_lis <- stack(lf)

# draw extent of a single raster
ras1 <- stack_lis[[1]]
plot(ras1)
ex <- drawExtent()

# crop stacked raster dataset to drawn extent
stack_crop <- crop(stack_lis, ex)

# Raster PCA
## set the nComp to 3 (usually the first 3 components explain most variance), feel free to test this

t <- rasterPCA(stack_crop , nSamples = NULL, nComp = 3, spca = T,
          maskCheck = TRUE)

t
plot(t)
summary(t$model)
plot(t$map)

# ------------------------------------------------------------------------------------#

# set values between 0 and 1
#final <- (x - minValue(x)) / (maxValue(x)- minValue(x))
#plot(final)

# ------------------------------------------------------------------------------------#


# Unsupervised classification 
test <- unsuperClass(t$map, nSamples = 10000, nClasses = 5, nStarts = 30,
             nIter = 100, norm = F, clusterMap = T,
             algorithm = "Hartigan-Wong")

plot(test$map)

