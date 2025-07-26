library(maps)
library(dplyr)
library(geosphere)
library(readr)
library(igraph)

#####Maps#####

# A function to plot connections

#####Data####

# Download the data from the World Bank table to understand the ease of unloading in each country
performance <- read_csv("API_LP.LPI.OVRL.XQ_DS2_es_csv_v2_30515/competitividad.csv")
# Remove empty columns (1960–2006)
performance <- performance[, -(5:51)]

# Create a new column 'latest'
performance$latest <- apply(performance, 1, function(row) {
  # Get the numeric values from the year columns (assuming they are from column 5 onwards)
  numeric_values <- as.numeric(row[5:ncol(performance)])

  # Find the last non-NA value
  last_value <- tail(numeric_values[!is.na(numeric_values)], 1)

  # If no numeric value is found, return NA
  if (length(last_value) == 0) {
    return(NA)
  } else {
    return(last_value)
  }
})

# Remove rows with NA in the 'latest' column
performance <- performance[!is.na(performance$latest), ]

# Display the head of the dataframe with the new 'latest' column and without empty countries and since 2006
View(performance)

worldcities <- read_csv("simplemaps_worldcities_basicv1.901/worldcities.csv")

# Remove duplicate rows from worldcities based on the 'Iso3' column, keeping the first occurrence
# Assuming the 'Iso3' column is the 7th column (index 7)
worldcities_unique <- worldcities[!duplicated(worldcities[, 7]), ]

performance <- merge(performance, worldcities_unique[, c(3, 4, 7)], by.x = names(performance)[2], by.y = names(worldcities_unique)[7], all.x = TRUE)

# Rename the merged columns to Lat and Lng
# The column names after merging might be different, you may need to adjust these based on the merge output
names(performance)[(ncol(performance)-1):ncol(performance)] <- c("Lat", "Lng")

# Remove rows without coords
performance <- performance[!is.na(performance$Lat), ]

# Display the head of the updated performance dataframe
View(performance)

all_pairs <- cbind(t(combn(performance$Lng, 2)), t(combn(performance$Lat, 2))) %>% as.data.frame()
colnames(all_pairs) <- c("long1", "long2", "lat1", "lat2")

View(all_pairs)

# Map background
par(mar = c(0, 0, 0, 0))
map('world', col = "#808080", fill = TRUE, bg = "white", lwd = 0.05, mar = rep(0, 4), border = 0, ylim = c(-80, 80))

# Add points and city names
points(x = performance$Lng, y = performance$Lat, col = "slateblue", cex = 2, pch = 20)

#####Distances#####

# Function to calculate the haversine distance between two points on Earth
haversine_distance <- function(lat1, lon1, lat2, lon2) {
  earth_radius <- 6371.0
  lat1_rad <- deg2rad(lat1)
  lon1_rad <- deg2rad(lon1)
  lat2_rad <- deg2rad(lat2)
  lon2_rad <- deg2rad(lon2)
  dlat <- lat2_rad - lat1_rad
  dlon <- lon2_rad - lon1_rad
  a <- sin(dlat/2)^2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon/2)^2
  c <- 2 * atan2(sqrt(a), sqrt(1-a))
  distance <- earth_radius * c
  return(distance)
}

# Helper function to convert degrees to radians
deg2rad <- function(deg) {
  return(deg * pi / 180)
}

# Knowing that in the end we are left with 169 countries
distancias <- matrix(0, nrow = 169, ncol = 169, dimnames = list(performance$`Country Name`, performance$`Country Name`))

# Calculate the distances and fill the matrix
for (i in 1:(169 - 1)) {
  for (j in (i + 1):169) {
    distancias[i, j] <- haversine_distance(performance$Lat[i], performance$Lng[i], performance$Lat[j], performance$Lng[j])
    distancias[j, i] <- distancias[i, j]  # The matrix is symmetric
  }
}

write.csv(distancias, file = "real_distances.csv")

# Divide each column by its corresponding element in index_comp
distancias_ajustadas <- distancias / performance$latest**3

# Save the distance matrix in a CSV file
write.csv(distancias_ajustadas, file = "adjusted_distances.csv")

#####Djistrak#####

# Function to find the shortest path between two countries
find_shortest_path <- function(adjacency, origin, destination) {
  # Create a weighted graph object from the adjacency matrix
  graph <- graph_from_adjacency_matrix(adjacency, mode = "undirected", weighted = TRUE)

  # Find the index of the nodes corresponding to the origin and destination countries
  origin_node <- which(V(graph)$name == origin)
  destination_node <- which(V(graph)$name == destination)

  # Apply Dijkstra's algorithm to find the shortest path
  short_path <- shortest_paths(graph, from = origin_node, to = destination_node, output = 'vpath', algorithm = 'dijkstra')
  short_path <- short_path[[1]]
  path_nodes <- V(graph)$name[(short_path[[1]])]

  return(path_nodes)
}

#####Mapping#####

get_indices_from_names <- function(country_names) {
  indices <- match(country_names, performance$`Country Name`)
  return(indices)
}

plot_my_connection = function(dep_lon, dep_lat, arr_lon, arr_lat, ...) {
  inter <- gcIntermediate(c(dep_lon, dep_lat), c(arr_lon, arr_lat), n=50, addStartEnd=TRUE, breakAtDateLine=F)
  inter = data.frame(inter)
  diff_of_lon = abs(dep_lon) + abs(arr_lon)
  if (diff_of_lon > 180) {
    lines(subset(inter, lon>=0), ...)
    lines(subset(inter, lon<0), ...)
  } else {
    lines(inter, ...)
  }
}

# Function to plot the map with a sequence of city names
plot_map_for_city_names <- function(city_names) {
  # Get the indices of the city names
  indices <- get_indices_from_names(city_names)

  # Select countries corresponding to the sequence of indices
  selected_countries <- performance$`Country Name`[indices]
  selected_latitudes <- performance$Lat[indices]
  selected_longitudes <- performance$Lng[indices]

  # Create a dataframe with the selected cities
  data <- data.frame(long = selected_longitudes, lat = selected_latitudes, row.names = selected_countries)

  # Earth tone map background
  par(mar = c(0, 0, 0, 0))
  map('world', col = "#4A5C6A", fill = TRUE, bg = "#9BA8AB", lwd = 0.05, mar = rep(0, 4), border = 0, ylim = c(-80, 80))

  # Add connections in earth tone
  for (i in 1:(length(indices) - 1)) {
    city1 <- performance$`Country Name`[indices[i]]
    city2 <- performance$`Country Name`[indices[i + 1]]
    lon1 <- performance$Lng[indices[i]]
    lat1 <- performance$Lat[indices[i]]
    lon2 <- performance$Lng[indices[i + 1]]
    lat2 <- performance$Lat[indices[i + 1]]
    plot_my_connection(lon1, lat1, lon2, lat2, col = "#06141B", lwd = 1)
  }

  # Add points in earth tone
  points(x = data$long, y = data$lat, col = "#11212D", cex = 2, pch = 20)
}

#####Example#####

adyacencias <- as.matrix(distancias_ajustadas, row.names = 1)
origin_country <- "China"
destination_country <- "Argentina"

# Find the shortest path
city_names <- find_shortest_path(adyacencias, origin_country, destination_country)

# Show the result
print(city_names)

# Mapping
plot_map_for_city_names(city_names)
