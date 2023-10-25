Analysis of Trip Data
1. Initial Data Exploration
To get a basic understanding of the dataset.


  -- Preview the main tables
SELECT * FROM trips;
SELECT * FROM trips_details;
SELECT * FROM loc;
SELECT * FROM duration;
SELECT * FROM payment;



2. Basic Metrics
Determine the fundamental numbers related to trips.


-- Total number of trips
SELECT COUNT(DISTINCT tripid) FROM trips;

-- Check for duplicate trip IDs
SELECT tripid, COUNT(tripid) AS cnt FROM trips GROUP BY tripid HAVING COUNT(tripid) > 1;

-- Total number of unique drivers
SELECT COUNT(DISTINCT driverid) FROM trips;

-- Total earnings across all trips
SELECT SUM(fare) AS total_earnings FROM trips;

-- Earnings per driver
SELECT driverid, SUM(fare) AS earnings FROM trips GROUP BY driverid;


3. Analysis of Trip Details
Deep dive into the details of the trips.

  
-- Total searches 
SELECT SUM(searches) AS total_searches FROM trips_details;

-- Total searches that received an estimate
SELECT SUM(searches_got_estimate) AS total_estimated_searches FROM trips_details;

-- Total driver cancellations
SELECT COUNT(*) - SUM(driver_not_cancelled) AS driver_cancellations FROM trips_details;

-- Total OTPs entered
SELECT SUM(otp_entered) AS otp_counts FROM trips_details;

-- Total trips that ended successfully
SELECT SUM(end_ride) AS successful_trips FROM trips_details;

-- Bookings cancelled by the driver
SELECT COUNT(driver_not_cancelled) AS driver_cancellations 
FROM trips_details 
WHERE driver_not_cancelled = 0 AND customer_not_cancelled = 1;

-- Bookings cancelled by the customer

SELECT COUNT(customer_not_cancelled) AS customer_cancellations 
FROM trips_details 
WHERE driver_not_cancelled = 1 AND customer_not_cancelled = 0;

-- Average distance traveled per trip
SELECT AVG(distance) AS avg_distance FROM trips;

-- Average fare amount
SELECT AVG(fare) AS avg_fare FROM trips;



4. Advanced Metrics
Deeper insights into payment methods, trip locations, durations, and conversion rates.


-- Most used payment method
SELECT p.method, a.cnt 
FROM payment p 
INNER JOIN (SELECT faremethod, COUNT(faremethod) AS cnt FROM trips GROUP BY faremethod) a 
ON p.id = a.faremethod 
ORDER BY a.cnt DESC;

-- Highest payment value and its associated payment method
SELECT p.method, a.* 
FROM payment p 
INNER JOIN (SELECT TOP 1 * FROM trips ORDER BY fare DESC) a 
ON p.id = a.faremethod;

-- Locations with the most trips
 
SELECT *, DENSE_RANK() OVER(ORDER BY trip DESC) AS rank 
FROM (SELECT loc_from, loc_to, COUNT(DISTINCT tripid) AS trip FROM trips GROUP BY loc_to, loc_from) a;

-- Top 5 earning drivers
SELECT TOP 5 *, DENSE_RANK() OVER(ORDER BY earn DESC) AS rank 
FROM (SELECT driverid, SUM(fare) AS earn FROM trips GROUP BY driverid) b;

-- Duration with the highest number of trips
SELECT duration, RANK() OVER(ORDER BY cnt DESC) AS rank 
FROM (SELECT duration, COUNT(DISTINCT tripid) AS cnt FROM trips GROUP BY duration) a;

-- Driver and customer pairs with the most trips
 
SELECT * 
FROM (SELECT driverid, custid, RANK() OVER(ORDER BY trip DESC) AS rank 
      FROM (SELECT driverid, custid, COUNT(tripid) AS trip FROM trips GROUP BY driverid, custid) a) b 
WHERE rank = 1;

-- Conversion rates
SELECT SUM(searches_got_estimate) * 100.0 / SUM(searches) AS search_to_estimate_rate FROM trips_details;
SELECT SUM(searches_for_quotes) * 100.0 / SUM(searches_got_estimate) AS estimate_to_quote_rate FROM trips_details;
SELECT SUM(searches_got_quotes) * 100.0 / SUM(searches_for_quotes) AS quote_acceptance_rate FROM trips_details;

-- Booking cancellation rate (using CTE)
WITH CancellationCounts AS (
    SELECT SUM(1 - driver_not_cancelled) AS driver_cancelled_count, COUNT(*) AS total_bookings
    FROM trips_details
)
SELECT driver_cancelled_count * 1.0 / total_bookings AS booking_cancellation_rate FROM CancellationCounts;

-- Which area had the highest trips in a particular duration
SELECT duration, loc_from, cnt, DENSE_RANK() OVER(ORDER BY cnt DESC) AS rank 
FROM (SELECT duration, loc_from, COUNT(DISTINCT tripid) AS cnt FROM trips GROUP BY duration, loc_from) b;

-- Areas with highest fares, cancellations, and trips
 SELECT *, DENSE_RANK() OVER(ORDER BY fare DESC) AS rank 
FROM (SELECT loc_from, SUM(fare) AS fare FROM trips GROUP BY loc_from) a;

SELECT *, DENSE_RANK() OVER(ORDER BY cnc DESC) AS rank 
FROM (SELECT loc_from, COUNT(*) - SUM(driver_not_cancelled) AS cnc FROM trips_details GROUP BY loc_from) a;

SELECT *, DENSE_RANK() OVER(ORDER BY trips DESC) AS rank 
FROM (SELECT loc_from, COUNT(*) AS trips FROM trips_details GROUP BY loc_from) a;

-- Duration with highest trips and fares
SELECT *, DENSE_RANK() OVER(ORDER BY trips DESC) AS rank 
FROM (SELECT duration, SUM(fare) AS fare, COUNT(DISTINCT tripid) AS trips FROM trips GROUP BY duration) a;

