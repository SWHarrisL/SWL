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

# Function to get all tables names
# The purpose is to get all tables name from db like Incidents, Flights, etc.
get_tables <- function(db) {
  
  # Get all table names in cloud DB
  tables_query <- "SHOW TABLES"
  result <- dbGetQuery(db, tables_query)
  
  # Extract table names from the result if there is any
  if (nrow(result) > 0) {
    table_names <- result[[1]]
    cat("There are", length(table_names), "table(s).\n")
    return(table_names)
    
  # If not return 0
  } else {
    cat("No tables found.\n")
    return(character(0))
  }
}

# Function to get all view names
# The purpose is to get all views name from db like AirlineIncidentSummary in Part G
get_views <- function(db) {
  
  # Get all view names in DB
  views_query <- "SHOW FULL TABLES WHERE Table_type = 'VIEW'"
  result <- dbGetQuery(db, views_query)
  
  # Get view names from the result if there is any
  if (nrow(result) > 0) {
    view_names <- result[[1]]
    cat("There are", length(view_names), "view(s).\n")
    return(view_names)
    
    # If not return 0
  } else {
    cat("No views found.\n")
    return(character(0))
  }
}

# Function to Drop all tables
# The purpose for this is to drop all table from the previous function
drop_all_tables <- function(db, table_names) {
  
  # If no table found return true
  if (length(table_names) == 0) {
    return(TRUE)
  }
  
  # Disable FK to allow us to drop table with constraint
  dbExecute(db, "SET FOREIGN_KEY_CHECKS = 0")
  
  # Drop all tables if there are any
  for (table in table_names) {
    drop_query <- paste0("DROP TABLE IF EXISTS ", table, "")
    dbExecute(db, drop_query)
  }
  cat("Dropped", table_names, ".\n")
  return(TRUE)
}

# Function to Drop all views
# The purpose for this is to drop all view from the previous function
drop_all_views <- function(db, view_names) {
  
  # If no view found return true
  if (length(view_names) == 0) {
    return(TRUE)
  }
  
  # Drop all views if there are any
  for (view in view_names) {
    drop_query <- paste0("DROP VIEW IF EXISTS ", view, "")
    dbExecute(db, drop_query)
  }
  cat("Dropped", view_names, ".\n")
  return(TRUE)
}
  
# Get the list tables and view if any
table_names <- get_tables(mydb.aiven)
view_names <- get_views(mydb.aiven)

# Drop all tables and views if any
drop_all_tables(mydb.aiven, table_names)
drop_all_views(mydb.aiven, view_names)

# Disconnect DB
dbDisconnect(mydb.aiven)
  
  
  
  