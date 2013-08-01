setwd("../scrf/")

library(geosphere)

year = 2011
min.train = 25
inner.radius = 1.5E5
outer.radius = 3E5

partial.stops = c(1, 2, 5, 10)


centers = regularCoordinates(12)



library(raster)
library(caret)
source("inst/data extraction/species-handling.R")

# eliminate unacceptable (e.g. non-species) taxa
valid.species.df = validateSpecies()


# As stated in runtype.txt, runs are only valid if RunType == 1
{
  runs = read.csv("proprietary.data/BBS/weather.csv")
  runs = runs[runs$RunType == 1, ]
}


stop.data.names  = dir(
  "proprietary.data/BBS/50-StopData/1997ToPresent_SurveyWide/", 
  pattern = "\\.csv$",
  full.names = TRUE
)

stop.data = do.call(
  rbind,
  lapply(
    stop.data.names,
    function(path){
      df = read.csv(path)
      # Only Run protocol (RPID) type 101 is standard. See RunProtocolID.txt
      df[df$year == year & df$RPID == 101, ]
    }
  )
)
mode(stop.data$AOU) = "character"

# eliminate invalid species.
valid.AOU = rownames(valid.species.df)
stop.data = stop.data[stop.data$AOU %in% valid.AOU, ]

# eliminate runs deemed unacceptable above
stop.data = stop.data[stop.data$RouteDataID %in% runs$RouteDataId, ] 


routeDataIDs = unique(stop.data$RouteDataID)

makeRouteID = function(mat) apply(
  mat[,c("countrynum", "statenum", "Route")], 
  1,
  function(x) paste(x, collapse = "-")
)

routes = read.csv("proprietary.data/BBS/routes.csv", header = TRUE)

# Remove bad routes:
# only RouteTypeID 1 is roadside
# only RouteTypeDetailID 1 and 2 are random
routes = with(
  routes, 
  routes[RouteTypeID == 1 & RouteTypeDetailId %in% c(1,2), ]
)

# only keep routes used in this year's data set
routes = routes[
  match(
    makeRouteID(runs[match(routeDataIDs, runs$RouteDataId), ]),
    makeRouteID(routes)
  ),
  ]

latlon = routes[,c("Longi", "Lati")]


# final -------------------------------------------------------------------

# produce a site by species matrix of presence-absence
route.presence.absence = sapply(
  sort(unique(stop.data$AOU)),
  function(species){
    routeDataIDs %in% stop.data$RouteDataID[species == stop.data$AOU]
  }
)

row.names(route.presence.absence) = routeDataIDs
colnames(route.presence.absence) = valid.species.df[
  sort(unique(stop.data$AOU)), 
  "English_Common_Name"
  ]

stop.array = array(
  NA, 
  dim = c(nrow(route.presence.absence), ncol(route.presence.absence), 50)
)

for(i in 1:50){
  print(i)
  observed = stop.data[ , paste0("Stop", i)] > 0
  stop.array[ , , i] = sapply(
    sort(unique(stop.data$AOU)),
    function(species){
      routeDataIDs %in% stop.data$RouteDataID[(species == stop.data$AOU) & observed]
    }
  )
}

dimnames(stop.array) = list(
  row.names(route.presence.absence),
  colnames(route.presence.absence),
  paste0("Stop", 1:50)
)

save(stop.array, file = "stop.array.Rdata")

