# Experiment 9 — Railway Booking Index Benchmark

## Aim

To create a Railway_Booking table with at least 5,000 records and compare query execution plans and measured execution times before and after adding a single-column index and a composite index.

## Software / Requirements

- MySQL 8.0 or later
- MySQL Workbench or MySQL command-line client
- InnoDB storage engine for transaction examples

## Source Code

The complete SQL source is also available as [`experiment_9.sql`](./experiment_9.sql).

```sql
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
```

## Output / Observations

- `SELECT COUNT(*)` returns **5000**.
- Before indexing, EXPLAIN may show a table scan for `train_no=12005`.
- After `idx_train` is created, the optimizer may use it for the train-number filter.
- After `idx_train_date` is created, the optimizer may use the composite index for a query filtering by both `train_no` and `journey_date`.
- The SQL script displays elapsed time in milliseconds. Record your own actual timings; results vary by machine, cache, optimizer and data distribution.

## Result

Single-column and composite indexes are created and compared using EXPLAIN and elapsed-time queries. Actual plan and speed depend on the database environment.

## How to Run

1. Connect to MySQL using Workbench or the command-line client.
2. Run `experiment_9.sql`.
3. Review the result grids and EXPLAIN output.
4. Capture screenshots of your actual output if required for practical submission.

