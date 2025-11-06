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


# Load data using url
url <- "https://s3.us-east-2.amazonaws.com/artificium.us/datasets/incidents-v2.csv"
incidents_data <- read.csv(url, header = T, stringsAsFactors = F)

# Filter column we need
incidents_data <- incidents_data[, c("iid", "date", "airline", "flightNumber", 
                                     "dep.airport", "incidentType", "severity", 
                                     "delay", "num.injuries", "reported.by", "aircraft")]
# Change date format to match mysql
# Display dataset information
incidents_data$date <- as.Date(incidents_data$date, format = "%d.%m.%Y")
cat("Dataset contains", nrow(incidents_data), "rows and", ncol(incidents_data), "columns\n")

# Function to execute SQL query and return single value
get_db_value <- function(query) {
  # Execute query and return a df
  # Use suppressWarning to not shown the warning during knit
  result <- suppressWarnings(dbGetQuery(mydb.aiven, query))
  
  # Get value from row 1 col 1. Ex: count(*) output is 1 18042
  # But in this case the output will be 18042
  return(result[1,1])
}

# Test: Count unique airlines
# Function to test the unique count airline between db and csv
# Expected result is: 40
test_unique_airlines <- function() {
  # Calculate csv and db count
  csv_count <- length(unique(incidents_data$airline))
  db_count <- get_db_value("SELECT COUNT(DISTINCT airline_name) FROM Airlines")
  
  # Test the result if they align
  test_passed <- csv_count == db_count
  status <- if(test_passed) "PASSED" else "FAILED"
  
  # Display the result
  cat("Unique Airlines: CSV Result =", csv_count, ", DB Result =", db_count, "-", status, "\n")
  return(test_passed)
}

# Test: Count unique flights
# Function to test the count of unique flights number between db and csv
# Expected result: 8303
test_unique_flights <- function() {
  
  # Calculate csv and db count
  csv_count <- length(unique(incidents_data$flightNumber))
  db_count <- get_db_value("SELECT COUNT(DISTINCT flightNumber) FROM Flights")
  
  # Test the result if they align
  test_passed <- csv_count == db_count
  status <- if(test_passed) "PASSED" else "FAILED"
  cat("Unique Flights: CSV Result =", csv_count, ", DB Result =", db_count, "-", status, "\n")
  return(test_passed)
}

# Test: Count total incidents
# Function to test toal incident count between db and csv
# Expected result: 18042
test_total_incidents <- function() {
  
  # Calculate csv and db count
  csv_count <- nrow(incidents_data)
  db_count <- get_db_value("SELECT COUNT(*) FROM Incidents")
  
  # Test the result if they align
  test_passed <- csv_count == db_count
  status <- if(test_passed) "PASSED" else "FAILED"
  
  # Display the result
  cat("Total Incidents: CSV Result =", csv_count, ", DB Result =", db_count, "-", status, "\n")
  return(test_passed)
}

# Test: First and last dates
# Function to test the date range ie start and end date
# Expected result: start date: 2008-1-5 End date: 2024-12-28
test_date_range <- function() {
  # Get date data and find first and last date from csv and db
  dates <- incidents_data$date
  csv_first_date <- min(dates)
  csv_last_date <- max(dates)
  
  db_first_date <- as.Date(get_db_value("SELECT MIN(incidentDate) FROM Incidents"))
  db_last_date <- as.Date(get_db_value("SELECT MAX(incidentDate) FROM Incidents"))
  
  # Test if the result match from csv and db
  test_passed <- (csv_first_date == db_first_date) && (csv_last_date == db_last_date)
  status <- if(test_passed) "PASSED" else "FAILED"
  
  # Print out the result
  cat("First Date: CSV Result =", as.character(csv_first_date), ", DB Result =",
      as.character(db_first_date), "\n")
  cat("Last Date: CSV Result =", as.character(csv_last_date), ", DB Result =",
      as.character(db_last_date), "\n")
  cat("Date Test -", status, "\n")
  return(test_passed)
}

# Test: Sum of delays
# Function to test total delay minutes between db and csv
# Expected result: 1327309 Min
test_sum_delays <- function() {
  
  # Calculate csv and db count
  csv_sum <- sum(incidents_data$delay)
  db_sum <- get_db_value("SELECT SUM(delayMinute) FROM Incidents")
  
  # Test if the result matches between csv and db
  test_passed <- csv_sum == db_sum
  status <- if(test_passed) "PASSED" else "FAILED"
  
  # Display result
  cat("Sum of Delays: CSV Result =", csv_sum, ", DB Result =", db_sum, "-", status, "\n")
  return(test_passed)
}

# Test: Sum of injuries
# Function to test total number of injuries between db and csv
# Expected result: 2064
test_sum_injuries <- function() {
  
  # Calculate csv and db count
  csv_sum <- sum(incidents_data$num.injuries)
  db_sum <- get_db_value("SELECT SUM(numInjuries) FROM Incidents")
  
  # Test if the result matches between csv and db
  test_passed <- csv_sum == db_sum
  status <- if(test_passed) "PASSED" else "FAILED"
  
  # Display result
  cat("Sum of Injuries: CSV Result =", csv_sum, ", DB Result =", db_sum, "-", status, "\n")
  return(test_passed)
}

# Test: Average delay
# Function to test average delay between db and csv
# Expected result: 73.57
test_average_delay <- function() {
  
  # Calculate csv and db count
  csv_avg <- round(mean(incidents_data$delay), 2)
  db_avg <- round(get_db_value("SELECT AVG(delayMinute) FROM Incidents"), 2)
  
  # Test if the result matches between csv and db
  test_passed <- abs(csv_avg - db_avg) < 0.01
  status <- if(test_passed) "PASSED" else "FAILED"
  
  # Display result
  cat("Average Delay: CSV Result =", csv_avg, ", DB Result =", db_avg, "-", status, "\n")
  return(test_passed)
}

# Function to run every test function we previously make and return result for each fo them
run_all_tests <- function() {
  
  # Execute all test function
  test1 <- test_unique_airlines()
  test2 <- test_unique_flights()
  test3 <- test_total_incidents()
  test4 <- test_date_range()
  test5 <- test_sum_delays()
  test6 <- test_sum_injuries()
  test7 <- test_average_delay()
  
  # Display Summary Report
  tests <- c(test1, test2, test3, test4, test5, test6, test7)
  total_tests <- length(tests)
  tests_passed <- sum(tests)
  tests_failed <- total_tests - tests_passed
  
  cat("Total Tests:", total_tests, "\n")
  cat("Passed:", tests_passed, "\n")
  cat("Failed:", tests_failed, "\n")
  
}

# Run all the tests
run_all_tests()

# Disconnect from DB
dbDisconnect(mydb.aiven)