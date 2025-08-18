# CS3200 Introduction to Database
# SioWa Luo
# Summer 2, 2025

# Import Necessary Library
library(RMySQL)
library(DBI)

# Define Setting
db_host_aiven <- "mysql-cs3200-northeastern-cs3200.k.aivencloud.com"
db_port_aiven <- 22967
db_name_aiven <- "defaultdb"
db_user_aiven <- "avnadmin"
db_pwd_aiven <- "AVNS_b8LFfIb2ijYwEuui_FU"

# Embedded SSL certificate
db_cert <- 
  "
-----BEGIN CERTIFICATE-----
MIIEUDCCArigAwIBAgIUDSsZAl6kvMb0yrAdHFvhOPbcJ70wDQYJKoZIhvcNAQEM
BQAwQDE+MDwGA1UEAww1YzNiYTJlNTMtNDA5NS00YjM3LWEwYmUtNDllODgwODBl
ODI4IEdFTiAxIFByb2plY3QgQ0EwHhcNMjUwODAzMjE0NDEzWhcNMzUwODAxMjE0
NDEzWjBAMT4wPAYDVQQDDDVjM2JhMmU1My00MDk1LTRiMzctYTBiZS00OWU4ODA4
MGU4MjggR0VOIDEgUHJvamVjdCBDQTCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCC
AYoCggGBAL5qvx5moiDVHp44nyhjUIeYz9naW7pVPqb9ZSF+USu2IXh4zjFH24Js
hxCu/kdALiQfcgjWUisBnPmguuV+GCTqEYrmfIpD7tEmp5Zls1s4eWL4YtNYMO9p
mhHaR/mKFA9+AmDDLB13sO2+IgJxvEjDXkdDHbTnHwPgX1pUBo+d0evTZhcoqpRz
UiqvsT2pyUb8FsRH83DReyM4qaV8EzOEjM8wIZEvO29Wn6cxcRxADE7Cn1I6k3Q9
rheEYNIzU3d+vrwdQQg+fc7qTmYr6swnU7fNOGawHufkHjaXiZJZk0jztVnp/m/G
3BfenTy+UWEa3CIk5l80LRJ/QHO+kCXnlunkW5ky7DkRulcXcT30R1qF5OzQQYC1
gL4lHrd9HG6yR++3CWzwt9AxSrmbzDL2Y56wZjtJcKfNiSeHIIWZ7y1gnFHzGyJT
QTDXvETAVdNIrLbjuRWrjp11l1x4w6TgWsKoi/1sY7Wr4r+oga+UNLiQhpJJy94J
AroefkBNZwIDAQABo0IwQDAdBgNVHQ4EFgQU7X6M21DSCxWu/lDNUDII1del8YIw
EgYDVR0TAQH/BAgwBgEB/wIBADALBgNVHQ8EBAMCAQYwDQYJKoZIhvcNAQEMBQAD
ggGBAL2gxg4vYo4MVQPujzOTmrAKuRlG0uT3gwgKfyCTNbPrlQE/ux0aYdg7ZcQg
LBjHqxTJMsq7Lo/Y1c8DvqtBEcSFTfJ3A/HRJj9I5Wkuj9AzGdXX/J9RH9xdzIEU
bqxap847vC8ddrBHGD7E5K6tilRzsZe412I+ymVPylM0mDJm9YOihojfhqlBGDYR
9qDYFWcbnwsHrna/qIywLtZrJMs4xOX+Oz8LPdqGZ1+TPEahEUl6WxH0ivggorFw
lx69r+wQN6x/ETrbXLj5AkwUo0LcQi/RXN5Vis9VQcVtWUrz6Tt96k0q8x1WsR7M
93lnSusJEOn7d8NhuQ7iZdGv4qy7h1J92iWVxswYvAV15AmOOzmuFlQxBfkviFH/
KCq03oic8tsZadXAtapY4MHo6dqtHQw1Zc1e27+X4p2qOzwBK94UQlhUeTCrALXq
187ebDb5S0ZRCvxBTgzThxgfgg00jcjNr+wxkQBzf5xPkpy4nQ9qtEndZ4zJOTgh
Ac412g==
-----END CERTIFICATE-----
"

# connect to remote MySQL server and database
mydb.aiven <-  dbConnect(RMySQL::MySQL(), 
                         user = db_user_aiven, 
                         password = db_pwd_aiven,
                         dbname = db_name_aiven, 
                         host = db_host_aiven, 
                         port = db_port_aiven,
                         sslmode = "require",
                         sslcert = db_cert)

# Part E Question 2:
# Load data using url
url <- "https://s3.us-east-2.amazonaws.com/artificium.us/datasets/incidents-v2.csv"
incidents_data <- read.csv(url, header = T, stringsAsFactors = F)

# Filter column we need
incidents_data <- incidents_data[, c("iid", "date", "airline", "flightNumber", 
                                     "dep.airport", "incidentType", "severity", 
                                     "delay", "num.injuries", "reported.by", "aircraft")]

# Change date format to match mysql
incidents_data$date <- as.Date(incidents_data$date, format = "%d.%m.%Y")

# Function to analyze missing values
# Purpose is to get all missing value from the csv file by column
check_na <- function(data) {
  
  # Calculate sum na value from each col
  missing <- colSums(is.na(data))
  
  # Create data frame to better visualize the result
  data.frame(
    Missing_data = missing
  )
}

# print result from check_na function - no missing value expected
print(check_na(incidents_data))
cat("Dataset contains", nrow(incidents_data), "rows and", ncol(incidents_data), "columns\n")

# Part E Question 3:
# Function to clear all data from tables in proper order
# Purpose is to remove all data from the table in db
clear_all_tables <- function(connection) {
  
  # List of tables created
  tables_to_clear <- c("Incidents", "Flights", "IncidentTypes", "Severity", 
                       "ReportedBy", "Aircraft", "Airlines", "Airports")
  
  # Query to delete all data that current exist
  for (table in tables_to_clear) {
    dbExecute(connection, paste0("DELETE FROM ", table))
  }
}

# Function for load data for all lookup tables
# Purpose is to populate lookup table with unique categorical value from csv
load_lookup_table <- function(connection, table_name, unique_values, column_name) {
  
  # Create foundation of insert query 
  insert_query <- paste0("INSERT INTO ", table_name, " (", column_name, ") VALUES ")
  
  # Create value clause by looping through each unique value
  for (i in 1:length(unique_values)) {
    insert_query <- paste0(insert_query, "('", unique_values[i], "')")
    
    # Add comma separator except for the last value
    if (i < length(unique_values)) {
      insert_query <- paste0(insert_query, ",")
    }
  }
  
  # Execute the insert statement
  result <- dbExecute(connection, insert_query)
  
}

# Function to load look up tables
# Purpose is use previous function to help the loading process for lookup table in correct order
load_lookup_data <- function(connection, incidents_data) {
  # Load in order that avoids dependencies
  load_lookup_table(connection, "IncidentTypes", unique(incidents_data$incidentType), "incidentTypeName")
  load_lookup_table(connection, "Severity", unique(incidents_data$severity), "severityLevel")
  load_lookup_table(connection, "ReportedBy", unique(incidents_data$reported.by), "reporterRole")
  load_lookup_table(connection, "Aircraft", unique(incidents_data$aircraft), "aircraftModel")
  load_lookup_table(connection, "Airlines", unique(incidents_data$airline), "airline_name")
  load_lookup_table(connection, "Airports", unique(incidents_data$dep.airport), "airport_code")
}

# Function to create mapping between values and their db ids
# Purpose is to create mapping dictionary between text val and ids
get_lookup_mapping <- function(connection, table_name, id_column, value_column) {
  
  # Get ids and value then execute the result
  mapping_query <- paste0("SELECT ", id_column, ", ", value_column, " FROM ", table_name)
  result <- dbGetQuery(connection, mapping_query)
  
  # Loop through each result and build mapping vector
  mapping <- c()
  for(i in 1:nrow(result)) {
    mapping[result[[value_column]][i]] <- result[[id_column]][i]
  }
  return(mapping)
}

# Function to load data to flight table
# load flight data by comming csv cols and link to lookup table using mapping function
load_flights <- function(connection, incidents_data) {
  
  # Get mapping vector for FK lookup from the related table lookup tables
  airline_mapping <- get_lookup_mapping(connection, "Airlines", "airlineId", "airline_name")
  airport_mapping <- get_lookup_mapping(connection, "Airports", "airportId", "airport_code")
  aircraft_mapping <- get_lookup_mapping(connection, "Aircraft", "aircraftId", "aircraftModel")
  
  # Get data from csv and filter to flight table col combination
  flight_combinations <- unique(incidents_data[, c("airline", "flightNumber", "dep.airport", "aircraft")])
  
  # Try use batch to enhance efficiency of loading data
  batch_size <- 500
  total_batches <- ceiling(nrow(flight_combinations) / batch_size)
  
  # Use for loop to get start and end idx for current batch and extract current batch data
  for (batch_idx in 1:total_batches) {
    start_idx <- (batch_idx - 1) * batch_size + 1
    end_idx <- min(batch_idx * batch_size, nrow(flight_combinations))
    
    batch_data <- flight_combinations[start_idx:end_idx, ]
    
    # Create base insert query for insert data into flight table
    insert_query <- "INSERT INTO Flights (flightNumber, aircraftId, airlineId, airportId) VALUES "
    
    # Look up FK ids using the mapping we created before
    for (i in 1:nrow(batch_data)) {
      airline_id <- airline_mapping[batch_data$airline[i]]
      airport_id <- airport_mapping[batch_data$dep.airport[i]]
      
      # Handle aircraft id that is missing with null - since we can not make up a random data
      if (!is.na(batch_data$aircraft[i]) && batch_data$aircraft[i] %in% names(aircraft_mapping)) {
        aircraft_id <- aircraft_mapping[batch_data$aircraft[i]]
      } else {
        aircraft_id <- "NULL"
      }
      
      # Combine the flight value into the insert query
      insert_query <- paste0(insert_query, "(", batch_data$flightNumber[i], ",", aircraft_id, ",", airline_id, ",", airport_id, ")")
      
      # Add comma except for last row
      if (i < nrow(batch_data)) {
        insert_query <- paste0(insert_query, ",")
      }
    }
    
    # Execute the INSERT statement
    dbExecute(connection, insert_query)
  }
  
}

# Function to load data to incident table
# Purpose is to load the incidents data with all FK relationship using mapping function
# (Flight table and all fk in flight table)
load_incidents <- function(connection, incidents_data) {
  
  # Get mapping vector for FK lookup from the related table lookup tables
  incident_type_mapping <- get_lookup_mapping(connection, "IncidentTypes", "incidentTypeId", "incidentTypeName")
  severity_mapping <- get_lookup_mapping(connection, "Severity", "severityId", "severityLevel")
  reported_by_mapping <- get_lookup_mapping(connection, "ReportedBy", "reportedById", "reporterRole")
  
  # Build JOIN query to get flightId with flight data information
  flight_query <- paste0("SELECT f.flightId, f.flightNumber, a.airline_name, ap.airport_code ",
                         "FROM Flights f ",
                         "JOIN Airlines a ON f.airlineId = a.airlineId ",
                         "JOIN Airports ap ON f.airportId = ap.airportId")
  
  # Execute query to get flight data for mapping
  flight_data <- dbGetQuery(connection, flight_query)
  
  # Create mapping vector from composite keys to flight IDs
  flight_mapping <- c()
  for(i in 1:nrow(flight_data)) {
    flight_mapping[paste0(flight_data$airline_name[i], "|", 
                          flight_data$flightNumber[i], "|", 
                          flight_data$airport_code[i])] <- flight_data$flightId[i]
  }
  
  # Try use batch to enhance efficiency of loading data
  batch_size <- 500
  total_batches <- ceiling(nrow(incidents_data) / batch_size)
  
  # Use for loop to get start and end idx for current batch and extract current batch data
  for (batch_idx in 1:total_batches) {
    start_idx <- (batch_idx - 1) * batch_size + 1
    end_idx <- min(batch_idx * batch_size, nrow(incidents_data))
    
    batch_data <- incidents_data[start_idx:end_idx, ]
    
    # Create base query for incident table
    insert_query <- "INSERT INTO Incidents (iid, incidentDate, incidentTypeId, severityId, delayMinute, numInjuries, reportedById, flightId) VALUES "
    
    # For each incident Get foreign key IDs with proper mapping
    for (i in 1:nrow(batch_data)) {
      incident_type_id <- incident_type_mapping[batch_data$incidentType[i]]
      severity_id <- severity_mapping[batch_data$severity[i]]
      
      # Set missing value if any to Null since we can not make up any data for reported by
      if (!is.na(batch_data$reported.by[i]) && batch_data$reported.by[i] %in% names(reported_by_mapping)) {
        reported_by_id <- reported_by_mapping[batch_data$reported.by[i]]
      } else {
        reported_by_id <- "NULL"
      }
      
      # Create flight lookup key to find and match the targeted flightId
      flight_key <- paste(batch_data$airline[i], batch_data$flightNumber[i], batch_data$dep.airport[i], sep = "|")
      flight_id <- flight_mapping[flight_key]
      
      # Set numinjuries and delay min to default 0 when we create table
      # Because some incident might not experience in injuries or delay
      delay_val <- ifelse(is.na(batch_data$delay[i]), 0, batch_data$delay[i])
      injuries_val <- ifelse(is.na(batch_data$num.injuries[i]), 0, batch_data$num.injuries[i])
      
      # Combine the base query with proper incident value with correct datatype
      insert_query <- paste0(insert_query, "('", batch_data$iid[i], "','", as.character(batch_data$date[i]), "',", 
                             incident_type_id, ",", severity_id, ",", delay_val, ",", 
                             injuries_val, ",", reported_by_id, ",", flight_id, ")")
      
      # Add comma except for last row
      if (i < nrow(batch_data)) {
        insert_query <- paste0(insert_query, ",")
      }
    }
    
    # Execute the INSERT statement
    dbExecute(connection, insert_query)
  }
  
}

# Function to verify row counts for all tables:
display_table_counts <- function(connection) {
  cat("\nVerify Data loading progress:\n")
  
  # List of all tables
  tables <- c("IncidentTypes", "Severity", "ReportedBy", "Aircraft", 
              "Airlines", "Airports", "Flights", "Incidents")
  
  # Get count for each table
  for (table in tables) {
    count_query <- paste0("SELECT COUNT(*) as count FROM ", table)
    result <- dbGetQuery(connection, count_query)
    cat(table, ":", result$count, "rows\n")
  }
}

# Clear all data from tables
clear_all_tables(mydb.aiven)

# Load data into tables
load_lookup_data(mydb.aiven, incidents_data)
load_flights(mydb.aiven, incidents_data)
load_incidents(mydb.aiven, incidents_data)

# Verify data loading
display_table_counts(mydb.aiven)

# Disconnect DB
dbDisconnect(mydb.aiven)