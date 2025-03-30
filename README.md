# Too Fast Too Furious
An SQL-driven analysis of car rental data for safety and sustainability.

## 📌 Overview
This project analyses driving behavior, rental patterns, and carbon emissions using SQL queries on a car rental dataset from Singapore. This project answers the following queries:
| No. | Query | Database Tables Considered |
|-----|------------------|--------------------------|
| 1 | What are the unique `[generalLoc]`? | `postalCodeTBL` |
| 2 | How many incident types are related to speed limit issues? | `incidentTypeTBL` |
| 3 | For each `[year]`, on each `[incidentType]`, how many incidents are recorded? | `incidentTBL` |
| 4 | For each year (2010 to 2018), on each issue category, display the total number of complaints, and the respective breakdowns between females and males | `complaintTBL` + `customerTBL` |
| 5 | For each year, on each `generalLoc`, display the total customer value (total rental fees recorded for the year). Note: Sum values for the same `generalLoc` (under different `postalCode`). | `vehicleTBL` + `orderTBL` + `customerTBL` + `postalcodeTBL` |
| 6 | For each year, on each vehicle, display the average traveled distance for a complaint. Note: Include data issues and workarounds if encountered. | `complaintTBL` + `orderTBL` + `vehicleTBL` |
| 7 | For each gender and age group (21-30, 31-50, ≥51), display the percentage of rentals for each vehicle brand and model. | `customerTBL` + `orderTBL` + `vehicleTBL` |
| 8 | Display customers (and corresponding vehicle) who used the same vehicle more than once. | `customerTBL` + `orderTBL` |
| 9 | For each customer, on each starting and ending location pair, display the number of rentals and the average distance. | `customerTBL` + `orderTBL` |
| 10 | For each order year and customer, display the total carbon footprint in both standards (WLTP/NEDC). | `customerTBL` + `orderTBL` + `vehicleTBL` |

## 🛢 Database Description
| Table Name       | Primary Key | Description | Key Fields |
|------------------|-------------|-------------|------------|
| **customerTBL**  | customerID  | Customer information | <ul><li>name (first 4 chars)</li><li>gender (0=F, 1=M)</li><li>member_since</li><li>driving_age_yr</li><li>postal (first 2 digits)</li></ul> |
| **vehicleTBL**   | vehicleID   | Rental vehicle details | <ul><li>type</li><li>brand</li><li>model</li><li>age</li><li>total_distance_km</li><li>fuel_efficiency (city/highway)</li><li>CO2 emissions (WLTP/NEDC)</li><li>fee_per_hour</li></ul> |
| **orderTBL**     | orderID     | Rental transactions | <ul><li>customerID</li><li>vehicleID</li><li>start/end datetime</li><li>start/end location</li><li>start/end fuel levels</li></ul> |
| **complaintTBL** | complaintID | Customer complaints | <ul><li>customerID</li><li>date</li><li>issue category</li><li>severity (1-5)</li><li>resolved (0/1)</li></ul> |
| **incidentTBL**  | incidentID  | Traffic violations | <ul><li>vehicleID</li><li>date</li><li>incidentType</li></ul> |
| **incidentTypeTBL** | incidentTypeID | Incident categories | <ul><li>detail (13 violation types)</li></ul> |
| **vehicleTypeTBL** | vehicleTypeID | Vehicle classifications | <ul><li>type</li></ul> |
| **postalCodeTBL** | postalCode | Location mapping | <ul><li>generalLoc</li></ul> |
