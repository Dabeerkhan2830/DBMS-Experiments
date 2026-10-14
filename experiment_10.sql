-- EXPERIMENT 10: Query Optimization (MySQL 8.0+)
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
DROP TABLE IF EXISTS Sales_Analytics;
CREATE TABLE Sales_Analytics (
 order_id INT PRIMARY KEY, customer_id INT, product_id INT, city VARCHAR(50),
 order_date DATE, amount DECIMAL(10,2), quantity INT, status VARCHAR(20)
) ENGINE=InnoDB;
SET SESSION cte_max_recursion_depth=11000;
INSERT INTO Sales_Analytics
(order_id,customer_id,product_id,city,order_date,amount,quantity,status)
WITH RECURSIVE numbers AS (
 SELECT 1 AS n UNION ALL SELECT n+1 FROM numbers WHERE n<10000
)
SELECT n,MOD(n,1000)+1,MOD(n,100)+1,
 CASE MOD(n,4) WHEN 0 THEN 'Delhi' WHEN 1 THEN 'Mumbai'
 WHEN 2 THEN 'Pune' ELSE 'Jaipur' END,
 DATE_ADD('2025-01-01',INTERVAL MOD(n,365) DAY),
 100+MOD(n*17,5000),MOD(n,10)+1,
 CASE MOD(n,3) WHEN 0 THEN 'Completed' WHEN 1 THEN 'Pending' ELSE 'Cancelled' END
FROM numbers;
SELECT COUNT(*) AS total_records FROM Sales_Analytics;

-- QUERY 1: year search
-- Before
EXPLAIN SELECT * FROM Sales_Analytics WHERE YEAR(order_date)=2025;
-- After: index and range condition
CREATE INDEX idx_order_date ON Sales_Analytics(order_date);
EXPLAIN SELECT * FROM Sales_Analytics
WHERE order_date>='2025-01-01' AND order_date<'2026-01-01';

-- QUERY 2: city search
-- Before
EXPLAIN SELECT * FROM Sales_Analytics WHERE LOWER(city)='delhi';
-- After (default MySQL collation is commonly case-insensitive)
CREATE INDEX idx_city ON Sales_Analytics(city);
EXPLAIN SELECT * FROM Sales_Analytics WHERE city='Delhi';

-- QUERY 3: status and date
-- Before
EXPLAIN SELECT * FROM Sales_Analytics
WHERE status='Completed' AND order_date>='2025-06-01';
-- After
CREATE INDEX idx_status_date ON Sales_Analytics(status,order_date);
EXPLAIN SELECT * FROM Sales_Analytics
WHERE status='Completed' AND order_date>='2025-06-01';

-- QUERY 4: correlated total vs grouped query
-- Before
EXPLAIN SELECT DISTINCT s.customer_id FROM Sales_Analytics s
WHERE (SELECT SUM(s2.amount) FROM Sales_Analytics s2
       WHERE s2.customer_id=s.customer_id)>30000;
-- After
CREATE INDEX idx_customer_amount ON Sales_Analytics(customer_id,amount);
EXPLAIN SELECT customer_id FROM Sales_Analytics
GROUP BY customer_id HAVING SUM(amount)>30000;

-- QUERY 5: top 10 orders
-- Before
EXPLAIN SELECT order_id,amount FROM Sales_Analytics ORDER BY amount DESC LIMIT 10;
-- After
CREATE INDEX idx_amount ON Sales_Analytics(amount);
EXPLAIN SELECT order_id,amount FROM Sales_Analytics ORDER BY amount DESC LIMIT 10;

-- Timing template: repeat before and after each optimization; record actual values.
SET @start_time=NOW(6);
SELECT * FROM Sales_Analytics
WHERE order_date>='2025-01-01' AND order_date<'2026-01-01';
SELECT TIMESTAMPDIFF(MICROSECOND,@start_time,NOW(6))/1000 AS execution_time_ms;

-- Never assume index usage or invent timings. Confirm the plan and record measured times.