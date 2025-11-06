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


# Function to create IncidentTypes lookup table
create_incident_types_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS IncidentTypes")
  
  # Query to create IncidentType look up table
  create_incident_types_query <- paste0(
    "CREATE TABLE IncidentTypes (",
    "incidentTypeId INTEGER PRIMARY KEY AUTO_INCREMENT,",
    "incidentTypeName VARCHAR(50) NOT NULL UNIQUE",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_incident_types_query)
}

# Function to create Severity lookup table
create_severity_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS Severity")
  
  # Query to create severity look up table
  create_severity_query <- paste0(
    "CREATE TABLE Severity (",
    "severityId INTEGER PRIMARY KEY AUTO_INCREMENT,",
    "severityLevel VARCHAR(50) NOT NULL UNIQUE",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_severity_query)
}

# Function to create ReportedBy lookup table
create_reported_by_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS ReportedBy")
  
  # Query to create ReportedBy look up table
  create_reported_by_query <- paste0(
    "CREATE TABLE ReportedBy (",
    "reportedById INTEGER PRIMARY KEY AUTO_INCREMENT,",
    "reporterRole VARCHAR(50) NOT NULL UNIQUE",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_reported_by_query)
}

# Function to create Aircraft lookup table
create_aircraft_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS Aircraft")
  
  # Query to create Aircraft lookup table
  create_aircraft_query <- paste0(
    "CREATE TABLE Aircraft (",
    "aircraftId INTEGER PRIMARY KEY AUTO_INCREMENT,",
    "aircraftModel VARCHAR(50) NOT NULL UNIQUE",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_aircraft_query)
}

# Function to create Airlines table
create_airlines_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS Airlines")
  
  # Query to create Airlines table
  create_airlines_query <- paste0(
    "CREATE TABLE Airlines (",
    "airlineId INTEGER PRIMARY KEY AUTO_INCREMENT,",
    "airline_name VARCHAR(3) NOT NULL",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_airlines_query)
}

# Function to create Airports table
create_airports_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS Airports")
  
  # Query to create Airports table
  create_airports_query <- paste0(
    "CREATE TABLE Airports (",
    "airportId INTEGER PRIMARY KEY AUTO_INCREMENT,",
    "airport_code VARCHAR(4) NOT NULL",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_airports_query)
}

# Function to create Flights table
create_flights_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS Flights")
  
  # Query to create Flights table
  create_flights_query <- paste0(
    "CREATE TABLE Flights (",
    "flightId INTEGER PRIMARY KEY AUTO_INCREMENT,",
    "flightNumber INTEGER NOT NULL,",
    "aircraftId INTEGER DEFAULT NULL,",
    "airlineId INTEGER NOT NULL,",
    "airportId INTEGER NOT NULL,",
    "FOREIGN KEY (airlineId) REFERENCES Airlines(airlineId),",
    "FOREIGN KEY (airportId) REFERENCES Airports(airportId),",
    "FOREIGN KEY (aircraftId) REFERENCES Aircraft(aircraftId)",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_flights_query)
}

# Function to create Incidents table with foreign keys to lookup tables
# Default value 0 because it is likely for the flights to not delay or have no injuries
create_incidents_table <- function(connection) {
  
  # Drop table if it is already there
  dbExecute(connection, "DROP TABLE IF EXISTS Incidents")
  
  # Query to create Incidents table
  create_incidents_query <- paste0(
    "CREATE TABLE Incidents (",
    "iid Varchar (10) PRIMARY KEY,",
    "incidentDate DATE NOT NULL,",
    "incidentTypeId INTEGER NOT NULL,",
    "severityId INTEGER NOT NULL,",
    "delayMinute INTEGER DEFAULT 0,",
    "numInjuries INTEGER DEFAULT 0,",
    "reportedById INTEGER DEFAULT NULL,",
    "flightId INTEGER NOT NULL,",
    "FOREIGN KEY (flightId) REFERENCES Flights(flightId),",
    "FOREIGN KEY (incidentTypeId) REFERENCES IncidentTypes(incidentTypeId),",
    "FOREIGN KEY (severityId) REFERENCES Severity(severityId),",
    "FOREIGN KEY (reportedById) REFERENCES ReportedBy(reportedById)",
    ")"
  )
  
  # Execute the query
  dbExecute(connection, create_incidents_query)
}

# Function to create all tables in cloud db
create_table_db <- function(connection) {
  
  # Drop dependent table (just in case) to avoid FK error message
  dbExecute(connection, "DROP TABLE IF EXISTS Incidents")
  dbExecute(connection, "DROP TABLE IF EXISTS Flights")
  
  # Create lookup tables first
  create_incident_types_table(connection)
  create_severity_table(connection)
  create_reported_by_table(connection)
  create_aircraft_table(connection)
  
  # Create main tables in proper order (referenced tables first)
  create_airlines_table(connection)
  create_airports_table(connection)
  create_flights_table(connection)
  create_incidents_table(connection)
}

# Create table to cloud db
create_table_db(mydb.aiven)

# Disconnect from the DB
dbDisconnect(mydb.aiven)
