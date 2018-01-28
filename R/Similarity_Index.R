library(raster)
library(RStoolbox)



########













########

set.seed(123)

data("srtm")

plot(srtm)

temp <- srtm

temp[] <- srtm[]*-.1 + 30 + rnorm(ncell(temp),sd = 1.5)

slope <- terrain(srtm, unit = 'tangent')

rain <- srtm

df <- as.data.frame(srtm, xy = T)

rain[] <- df$x/max(df$x) * 5 + (df$y/max(df$y))^(5/3) * 5 + rnorm(ncell(temp),sd = 0.01)

s <- stack(srtm, slope, temp, rain)

names(s) <- c('dem','slope','temp','pp')

plot(s)

# assuming only positive values

scalefun <- function(r, precision = 2) {
  v <- round((r - minValue(r)) / (maxValue(r) - minValue(r)),precision)
  v[is.na(v)] <- 0 # avoid NA in flat terrains (slope layer)
  v
}

ss <- scalefun(s)


plot(ss)

##

library(dplyr)

cond <- as.data.frame(ss) %>% group_by(dem,slope,temp,pp) %>%
  summarise(n = n()) %>% arrange(desc(n)) %>% head(1)

cond

# Coordinates 

cond <- as.vector(unlist(cond))

selected <- ss[[1]] == cond[1] & ss[[2]] == cond[2] & ss[[3]] == cond[3] & ss[[4]] == cond[4]

selected <- as.data.frame(selected,xy = T)

head(selected[selected[,3] == T,])




##################################################


#scale raster data
s <- scale(s) 
plot(s$dem)
#arbitrary location you like:
e <- drawExtent()

xy <- cbind(e@xmin,e@ymin)
v <- extract(s, xy) 
d <- abs(s - as.vector(v))
dd <- sum(d)

# similar sites
plot(dd < 2)
plot(dd < 3)
