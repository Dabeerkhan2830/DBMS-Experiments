-- EXPERIMENT 9: Railway Booking Index Benchmark (MySQL 8.0+)
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
DROP TABLE IF EXISTS Railway_Booking;
CREATE TABLE Railway_Booking (
 booking_id INT PRIMARY KEY, passenger_name VARCHAR(100), train_no INT,
 source_station VARCHAR(50), destination_station VARCHAR(50),
 journey_date DATE, seat_no INT, fare DECIMAL(8,2), status VARCHAR(20)
) ENGINE=InnoDB;

SET SESSION cte_max_recursion_depth=6000;
INSERT INTO Railway_Booking
(booking_id,passenger_name,train_no,source_station,destination_station,journey_date,seat_no,fare,status)
WITH RECURSIVE numbers AS (
 SELECT 1 AS n UNION ALL SELECT n+1 FROM numbers WHERE n<5000
)
SELECT n,CONCAT('Passenger',n),12000+MOD(n,20),
 CASE MOD(n,5) WHEN 0 THEN 'Delhi' WHEN 1 THEN 'Mumbai' WHEN 2 THEN 'Chennai'
 WHEN 3 THEN 'Kolkata' ELSE 'Jaipur' END,
 CASE MOD(n,5) WHEN 0 THEN 'Mumbai' WHEN 1 THEN 'Delhi' WHEN 2 THEN 'Kolkata'
 WHEN 3 THEN 'Jaipur' ELSE 'Chennai' END,
 DATE_ADD('2026-01-01',INTERVAL MOD(n,365) DAY),MOD(n,100)+1,
 500+MOD(n,2000),
 CASE MOD(n,3) WHEN 0 THEN 'Confirmed' WHEN 1 THEN 'Waiting' ELSE 'Cancelled' END
FROM numbers;
SELECT COUNT(*) AS total_records FROM Railway_Booking;

-- BEFORE INDEX
EXPLAIN SELECT * FROM Railway_Booking WHERE train_no=12005;
SET @start_time=NOW(6);
SELECT * FROM Railway_Booking WHERE train_no=12005;
SELECT TIMESTAMPDIFF(MICROSECOND,@start_time,NOW(6))/1000 AS execution_time_ms;

-- SINGLE-COLUMN INDEX
CREATE INDEX idx_train ON Railway_Booking(train_no);
ANALYZE TABLE Railway_Booking;
EXPLAIN SELECT * FROM Railway_Booking WHERE train_no=12005;
SET @start_time=NOW(6);
SELECT * FROM Railway_Booking WHERE train_no=12005;
SELECT TIMESTAMPDIFF(MICROSECOND,@start_time,NOW(6))/1000 AS execution_time_ms;

-- COMPOSITE INDEX
CREATE INDEX idx_train_date ON Railway_Booking(train_no,journey_date);
ANALYZE TABLE Railway_Booking;
EXPLAIN SELECT * FROM Railway_Booking
WHERE train_no=12005 AND journey_date='2026-01-15';
SET @start_time=NOW(6);
SELECT * FROM Railway_Booking
WHERE train_no=12005 AND journey_date='2026-01-15';
SELECT TIMESTAMPDIFF(MICROSECOND,@start_time,NOW(6))/1000 AS execution_time_ms;

-- Compare EXPLAIN columns type, possible_keys, key, rows and Extra.
-- Actual plans and timings depend on the optimizer, data distribution and system load.