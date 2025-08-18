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


# Question 2:
# Create storeIncident procedure to assumes that airline, airport, aircraft already exist
# and takes PK as parameters
# https://www.sqlservertutorial.net/sql-server-stored-procedures/variables/
store_incident_procedure <- function() {
  # Drop procedure if it exists
  dbExecute(mydb.aiven, "DROP PROCEDURE IF EXISTS storeIncident")
  
  # Create the stored procedure that assumes all lookup values already exist
  procedure_query <- paste0(
    
    # Define procedure and input param
    "CREATE PROCEDURE storeIncident (",
    "  IN p_iid VARCHAR(10),",
    "  IN p_incident_date DATE,",
    "  IN p_flight_number INT,",
    "  IN p_airline_id INT,",
    "  IN p_airport_id INT,",
    "  IN p_aircraft_id INT,",
    "  IN p_incident_type_id INT,",
    "  IN p_severity_id INT,",
    "  IN p_delay_minute INT,",
    "  IN p_num_injuries INT,",
    "  IN p_reported_by_id INT",
    ") ",
    
    # Declare local variable to store flight id initiate to 0
    # Try to find exist flight with flight number, airline, airport, and aircraft
    # Handle null value
    "BEGIN ",
    "  DECLARE v_flight_id INT DEFAULT 0;",
    "  ",
    "  SELECT flightId INTO v_flight_id FROM Flights ",
    "  WHERE flightNumber = p_flight_number AND airlineId = p_airline_id AND airportId = p_airport_id ",
    "  AND (aircraftId = p_aircraft_id OR (aircraftId IS NULL AND p_aircraft_id IS NULL)) LIMIT 1;",
    "  ",
    
    # If not matching we will create new flight record
    "  IF v_flight_id = 0 THEN",
    "    INSERT INTO Flights (flightNumber, aircraftId, airlineId, airportId) ",
    "    VALUES (p_flight_number, p_aircraft_id, p_airline_id, p_airport_id);",
    "    SET v_flight_id = LAST_INSERT_ID();",
    "  END IF;",
    "  ",
    
    # Insert Incident record using flightid
    "  INSERT INTO Incidents (",
    "    iid, incidentDate, incidentTypeId, severityId, ",
    "    delayMinute, numInjuries, reportedById, flightId",
    "  ) VALUES (",
    "    p_iid, p_incident_date, p_incident_type_id, p_severity_id,",
    "    p_delay_minute, p_num_injuries, p_reported_by_id, v_flight_id",
    "  );",
    "  ",
    "END"
  )
  
  # Execute the procedure query and display the result
  dbExecute(mydb.aiven, procedure_query)
  cat("storeIncident procedure is created.\n")
}

# Test function for storeIncident
test_store_incident <- function() {

  # Get existing IDs from DB
  airline_result <- dbGetQuery(mydb.aiven, "SELECT airlineId FROM Airlines LIMIT 1")
  airport_result <- dbGetQuery(mydb.aiven, "SELECT airportId FROM Airports LIMIT 1") 
  aircraft_result <- dbGetQuery(mydb.aiven, "SELECT aircraftId FROM Aircraft LIMIT 1")
  incident_type_result <- dbGetQuery(mydb.aiven, "SELECT incidentTypeId FROM IncidentTypes LIMIT 1")
  severity_result <- dbGetQuery(mydb.aiven, "SELECT severityId FROM Severity LIMIT 1")
  reported_by_result <- dbGetQuery(mydb.aiven, "SELECT reportedById FROM ReportedBy LIMIT 1")
  
  # Extract IDs directly since they should be there
  airline_id <- airline_result$airlineId[1]
  airport_id <- airport_result$airportId[1]
  aircraft_id <- aircraft_result$aircraftId[1]
  incident_type_id <- incident_type_result$incidentTypeId[1]
  severity_id <- severity_result$severityId[1]
  reported_by_id <- reported_by_result$reportedById[1]
  
  # Build call query with actual existing IDs
  call_query <- paste0("CALL storeIncident('TEST001', '2025-08-12', 5555, ", 
                       airline_id, ", ", airport_id, ", ", aircraft_id, ", ",
                       incident_type_id, ", ", severity_id, ", 15, 0, ", reported_by_id, ")")
  
  cat("Testing storeIncident with actual db IDs...\n")
  cat("Call query:", call_query, "\n")
  
  rs <- dbSendQuery(mydb.aiven, call_query)
  data <- fetch(rs, n = -1)
  
  # Work on additional result sets
  while(dbMoreResults(mydb.aiven) == TRUE) {
    dbNextResult(mydb.aiven)
  }
  
  cat("Test incident stored successfully.\n")
  
  # Get the test new incident line and display the result
  verify_query <- "SELECT * FROM Incidents WHERE iid = 'TEST001'"
  result <- dbGetQuery(mydb.aiven, verify_query)
  print("New test incident result:")
  print(result)
}

# Question 3:
# Create storeNewIncident procedure that handle new airlines, airports, aircraft, and other lookup values
store_new_incident_procedure <- function() {
  # Drop procedure if it exists
  dbExecute(mydb.aiven, "DROP PROCEDURE IF EXISTS storeNewIncident")
  
  # Create the more complex stored procedure that can create new lookup values
  new_procedure_query <- paste0(
    
    # Define procedure and input param
    "CREATE PROCEDURE storeNewIncident (",
    "  IN p_iid VARCHAR(10),",
    "  IN p_incident_date DATE,",
    "  IN p_flight_number INT,",
    "  IN p_airline_name VARCHAR(3),",
    "  IN p_airport_code VARCHAR(4),",
    "  IN p_aircraft_model VARCHAR(50),",
    "  IN p_incident_type_name VARCHAR(50),",
    "  IN p_severity_level VARCHAR(50),",
    "  IN p_delay_minute INT,",
    "  IN p_num_injuries INT,",
    "  IN p_reporter_role VARCHAR(50)",
    ") ",
    
    # Declare local variable to store lookup tables id we will find or create 
    # If no value found var stay null
    "BEGIN ",
    "  DECLARE v_airline_id INT DEFAULT NULL;",
    "  DECLARE v_airport_id INT DEFAULT NULL;",
    "  DECLARE v_aircraft_id INT DEFAULT NULL;",
    "  DECLARE v_incident_type_id INT DEFAULT NULL;",
    "  DECLARE v_severity_id INT DEFAULT NULL;",
    "  DECLARE v_reported_by_id INT DEFAULT NULL;",
    "  DECLARE v_flight_id INT DEFAULT NULL;",
    "  ",
    
    # Check if variable exist in the table
    # If yes create new row with provided variable name
    # If not return no row and set to null
    "  SELECT airlineId INTO v_airline_id FROM Airlines ",
    "  WHERE airline_name = p_airline_name LIMIT 1;",
    "  ",
    "  IF v_airline_id IS NULL THEN",
    "    INSERT INTO Airlines (airline_name) VALUES (p_airline_name);",
    "    SET v_airline_id = LAST_INSERT_ID();",
    "  END IF;",
    "  ",
    "  SELECT airportId INTO v_airport_id FROM Airports ",
    "  WHERE airport_code = p_airport_code LIMIT 1;",
    "  ",
    "  IF v_airport_id IS NULL THEN",
    "    INSERT INTO Airports (airport_code) VALUES (p_airport_code);",
    "    SET v_airport_id = LAST_INSERT_ID();",
    "  END IF;",
    "  ",
    "  IF p_aircraft_model IS NOT NULL THEN",
    "    SELECT aircraftId INTO v_aircraft_id FROM Aircraft ",
    "    WHERE aircraftModel = p_aircraft_model LIMIT 1;",
    "    ",
    "    IF v_aircraft_id IS NULL THEN",
    "      INSERT INTO Aircraft (aircraftModel) VALUES (p_aircraft_model);",
    "      SET v_aircraft_id = LAST_INSERT_ID();",
    "    END IF;",
    "  ELSE",
    "    SET v_aircraft_id = NULL;",
    "  END IF;",
    "  ",
    "  SELECT incidentTypeId INTO v_incident_type_id FROM IncidentTypes ",
    "  WHERE incidentTypeName = p_incident_type_name LIMIT 1;",
    "  ",
    "  IF v_incident_type_id IS NULL THEN",
    "    INSERT INTO IncidentTypes (incidentTypeName) VALUES (p_incident_type_name);",
    "    SET v_incident_type_id = LAST_INSERT_ID();",
    "  END IF;",
    "  ",
    "  SELECT severityId INTO v_severity_id FROM Severity ",
    "  WHERE severityLevel = p_severity_level LIMIT 1;",
    "  ",
    "  IF v_severity_id IS NULL THEN",
    "    INSERT INTO Severity (severityLevel) VALUES (p_severity_level);",
    "    SET v_severity_id = LAST_INSERT_ID();",
    "  END IF;",
    "  ",
    "  IF p_reporter_role IS NOT NULL THEN",
    "    SELECT reportedById INTO v_reported_by_id FROM ReportedBy ",
    "    WHERE reporterRole = p_reporter_role LIMIT 1;",
    "    ",
    "    IF v_reported_by_id IS NULL THEN",
    "      INSERT INTO ReportedBy (reporterRole) VALUES (p_reporter_role);",
    "      SET v_reported_by_id = LAST_INSERT_ID();",
    "    END IF;",
    "  ELSE",
    "    SET v_reported_by_id = NULL;",
    "  END IF;",
    "  ",
    
    # Look for exist flight that match all criteria before
    # Create flight if not already exist
    "  SELECT flightId INTO v_flight_id FROM Flights ",
    "  WHERE flightNumber = p_flight_number AND airlineId = v_airline_id AND airportId = v_airport_id ",
    "  AND (aircraftId = v_aircraft_id OR (aircraftId IS NULL AND v_aircraft_id IS NULL)) LIMIT 1;",
    "  ",
    "  IF v_flight_id IS NULL THEN",
    "    INSERT INTO Flights (flightNumber, aircraftId, airlineId, airportId) ",
    "    VALUES (p_flight_number, v_aircraft_id, v_airline_id, v_airport_id);",
    "    SET v_flight_id = LAST_INSERT_ID();",
    "  END IF;",
    "  ",
    
    # Insert incident record using input data and new dk we created above 
    # (flightID along with other lookup tableid)
    # Return value and end procedure
    "  INSERT INTO Incidents (",
    "    iid, incidentDate, incidentTypeId, severityId, ",
    "    delayMinute, numInjuries, reportedById, flightId",
    "  ) VALUES (",
    "    p_iid, p_incident_date, v_incident_type_id, v_severity_id,",
    "    p_delay_minute, p_num_injuries, v_reported_by_id, v_flight_id",
    "  );",
    "  ",
    "  SELECT 'New incident stored successfully' as message, p_iid as incident_id;",
    "  ",
    "END"
  )
  
  # Execute the procedure query and display the result
  dbExecute(mydb.aiven, new_procedure_query)
  cat("storeNewIncident procedure is created.\n")
}

# Test function for storeNewIncident
test_store_new_incident <- function() {
  # Test with new entities that may not exist
  # iid, date, flight num, airline name/code, airport code, aircraft model, 
  # incident type, severity, delay minutes, injuries, reported by
  call_query <- paste0(
    "CALL storeNewIncident(",
    "'TEST002', ",          
    "'2025-08-12', ",        
    "9999, ",             
    "'XY', ",             
    "'ABC', ",           
    "'Boeing 737', ",     
    "'Bird Strike', ",   
    "'Moderate', ",      
    "45, ",               
    "0, ",                 
    "'ATC'",              
    ")"
  )
  
  rs <- dbSendQuery(mydb.aiven, call_query)
  data <- fetch(rs, n = -1)
  
  # Work on additional result sets
  while(dbMoreResults(mydb.aiven) == TRUE) {
    dbNextResult(mydb.aiven)
  }
  
  cat("Test incident with new entities stored successfully.\n")
  print(data)
  
  # Get the test new incident line and display the result
  verify_query <- "SELECT * FROM Incidents WHERE iid = 'TEST002'"
  result <- dbGetQuery(mydb.aiven, verify_query)
  print("New test incident result:")
  print(result)
}

# Function to clean up the test incident data
# Purpose is to remove Test iid in incident so that we can run the program multiple time
# Please do not run code from other R script and rmd file after running this one
cleanup_test_incidents <- function() {
  # Only delete iid that start with "TEST"
  dbExecute(mydb.aiven, "DELETE FROM Incidents WHERE iid LIKE 'TEST%'")

}

# Execute the function
# Create both procedures
store_incident_procedure()
store_new_incident_procedure()

# Test procedures
# Clean data in the beginning and the end to keep the original data clean
test_store_incident()
test_store_new_incident()
cleanup_test_incidents()

# Disconnect from DB
dbDisconnect(mydb.aiven)
