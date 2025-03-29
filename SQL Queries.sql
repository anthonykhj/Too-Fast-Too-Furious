/**********************************************************
NAME: Anthony Koh Hong Ji
MATRIC NO.: U2210473D	
ASSIGNMENT: BC2402 Individual Assignment
SEMINAR: S08
PROFESSOR: Chan Wai Xin
**********************************************************/

-- Q1. What are the unique [generalLoc]?
SELECT DISTINCT
    generalLoc
FROM
    postalcodetbl
ORDER BY
	generalLoc;
    
 -- Comments for Q1: NIL
 
-- Q2. How many incident types are related to speed limit issues?
SELECT 
    COUNT(DISTINCT detail) speedlimit_issues_count
FROM
    incidenttypetbl
WHERE
    detail LIKE '%speed limit%';

 -- Comments for Q2: NIL
    
-- Q3 For each [year], on each [incidentType], how many incidents are recorded?
SELECT 
    YEAR(STR_TO_DATE(i.date, '%M %d, %Y')) year,
    i.incidentType,
    it.detail,
    COUNT(*) AS incident_count
FROM
    incidenttbl i
JOIN
    incidenttypetbl it ON i.incidentType = it.incidentTypeID
GROUP BY
	YEAR(STR_TO_DATE(i.date, '%M %d, %Y')),
    i.incidentType,
    it.detail
ORDER BY 
	year,
	i.incidentType;
    
 -- Comments for Q3: 
 -- Changed the `date` format from TEXT to DATE so I can extract the YEAR, used an explicit join

-- Q4. For each year (2010 to 2018), on each issue category, display the total number of complaints, and the respective breakdowns between females and males
SELECT 
    YEAR(STR_TO_DATE(comp.date, '%M %d, %Y')) year,
    comp.issue,
    COUNT(*) AS total,
    SUM(cust.gender = 0) female,
    SUM(cust.gender = 1) male
FROM
    complainttbl comp
JOIN
    customertbl cust ON comp.customerID = cust.customerID
WHERE
    YEAR(STR_TO_DATE(comp.date, '%M %d, %Y')) BETWEEN 2010 AND 2018
GROUP BY 
	YEAR(STR_TO_DATE(comp.date, '%M %d, %Y')), 
    comp.issue
ORDER BY 
	YEAR(STR_TO_DATE(comp.date, '%M %d, %Y')), 
	comp.issue;

 -- Comments for Q4:
 -- Since both tables started with c, I figured it would be best to type it as it is to avoid confusion
 -- Changed the `date` format from TEXT to DATE so I can extract the YEAR, used an explicit join

-- Q5. For each year, on each generalLoc, display the total customer value (i.e., total rental fees recorded for the year). 
CREATE VIEW orderTBL_with_time AS
SELECT
    *,
    STR_TO_DATE(
        CONCAT(
            startTime_hr, ':',
            startTime_min, ':',
            startTime_ss
        ),
        '%H:%i:%s'
    ) AS startTime,
    STR_TO_DATE(
        CONCAT(
            endTime_hr, ':',
            endTime_min, ':',
            endTime_ss
        ),
        '%H:%i:%s'
    ) AS endTime
FROM
    orderTBL;

SELECT * from ordertbl_with_time;

SELECT
    YEAR(STR_TO_DATE(o.startDate, '%e-%b-%Y')) year,
    p.generalLoc,
    SUM(v.fee_per_hour * CEIL(TIMESTAMPDIFF(SECOND, startTime, endTime) / 3600)) total_customer_value
FROM
    orderTBL_with_time o
JOIN
    postalcodeTBL p ON o.startLoc = p.postalCode
JOIN
    vehicleTBL v ON o.vehicleID = v.vehicleID
GROUP BY
    year,
    p.generalLoc
ORDER BY
    year,
    p.generalLoc;

-- Comments for Q5:
-- Created a VIEW: orderTBL_with_time with 2 new additional columns (startTime, endTime) instead of adding the two new columns to the existing table
-- Combined hr, min and ss by using CONCAT in order to use TIMESTAMPDIFF
-- For total_customer_value, I decided to use SECOND/3600 and then round it up to the next hour with CEIL and multiply that with the fee_per_hour

-- Q6. For each year, on each vehicle, display the average traveled distance for a complaint.
SELECT
    YEAR(STR_TO_DATE(o.startDate, '%e-%b-%Y')) year,
    v.vehicleID,
    AVG(o.distance_m) avg_distance_per_complaint
FROM
    orderTBL o
JOIN
    complaintTBL c ON o.customerID = c.customerID
JOIN
    vehicleTBL v ON o.vehicleID = v.vehicleID
GROUP BY
    YEAR(STR_TO_DATE(o.startDate, '%e-%b-%Y')),
    v.vehicleID
ORDER BY
    year,
    v.vehicleID;

 -- Comments for Q6: 
 -- Changed the `date` format from TEXT to DATE so I can extract the YEAR
    
-- Q7. Who makes the green choices? The purpose of this query is to prepare the data for analyses on green consumption.
-- For each gender and age group*, display the percentage of rentals for each vehicle brand and model.
-- *Consider 3 age groups: between 21 and 30 (both inclusive), between 31 and 50 (both inclusive), and >=51.
SELECT
    IF(c.gender = 0, 'F', 'M') gender,
    IF(c.age BETWEEN 21 AND 30, '21-30',
       IF(c.age BETWEEN 31 AND 50, '31-50', '>=51')) age_group,
    v.brand,
    v.model,
    COUNT(*) rentals,
    COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY c.gender, 
                                   IF(c.age BETWEEN 21 AND 30, '21-30',
                                      IF(c.age BETWEEN 31 AND 50, '31-50', '>=51'))) * 100 `percentage (%)`
FROM
    customerTBL c
JOIN
    orderTBL o ON c.customerID = o.customerID
JOIN
    vehicleTBL v ON o.vehicleID = v.vehicleID
GROUP BY
    gender,
    age_group,
    v.brand,
    v.model
ORDER BY
    gender,
    age_group,
    v.brand,
    v.model;
    
 -- Comments for Q7:
 -- Changed gender from 0, 1 to F, M respectively for improved readability
 -- Used nested IFs to classify the different age groups
 -- Introduced COUNT OVER (PARTITION BY) to calculate percentage of rentals of a specific gender + age group
 
-- Q8. Display a list of customers (and the corresponding vehicle) who used the same vehicle more than once.
SELECT 
    o.customerID,
    name,
    o.vehicleID,
    v.type,
    v.brand,
    v.model,
    COUNT(*) count
FROM
    orderTBL o
JOIN
    customerTBL c ON c.customerID = o.customerID
JOIN
    vehicleTBL v ON v.vehicleID = o.vehicleID
GROUP BY 
	o.customerID,
	name,
	o.vehicleID,
	v.type,
	v.brand,
	v.model
HAVING 
	count > 1
ORDER BY 
	o.customerID;
    
-- Comments for Q8:
-- Displayed the customer details + vehicle details + number of times the customer used the vehicle which is > 1
    
-- Q9. For each customer, on each starting and ending location pair, display the number of rentals and the average distance.
SELECT 
    c.customerID,
    c.name customerName,
    o.startLoc,
    o.endLoc,
    COUNT(*) rental_count,
    AVG(o.distance_m) average_distance
FROM
    orderTBL o
JOIN
    customerTBL c ON o.customerID = c.customerID
GROUP BY 
	c.customerID,
    c.name,
    o.startLoc,
    o.endLoc
ORDER BY 
	c.customerID,
    o.startLoc,
    o.endLoc;

-- Comments for Q9: NIL

-- Q10. For each order year and customer, display the total carbon footprint in both standards.
SELECT 
    YEAR(STR_TO_DATE(o.startDate, '%e-%b-%Y')) order_year,
    c.customerID,
    c.name customerName,
    SUM(v.CO2avg_WLTP) totalCO2_WLTP,
    SUM(v.CO2avg_NEDC) totalCO2_NEDC
FROM
    orderTBL o
JOIN
    customerTBL c ON o.customerID = c.customerID
JOIN
    vehicleTBL v ON o.vehicleID = v.vehicleID
GROUP BY 
	order_year,
	c.customerID, 
	customerName
ORDER BY 
	order_year,
	c.customerID;

-- Comments for Q10:
-- Changed the `date` format from TEXT to DATE so I can extract the YEAR