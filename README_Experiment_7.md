# Experiment 7 — Functional Dependencies and Normalization

## Aim

To identify functional dependencies in a denormalized Sales dataset and normalize it through 1NF, 2NF and 3NF, then reconstruct the data using joins to check lossless decomposition. Under the stated dependencies, the decomposed relations are also checked conceptually for BCNF and dependency preservation.

## Software / Requirements

- MySQL 8.0 or later
- MySQL Workbench or MySQL command-line client
- InnoDB storage engine for transaction examples

## Source Code

The complete SQL source is also available as [`experiment_7.sql`](./experiment_7.sql).

```sql
-- EXPERIMENT 7: Functional Dependencies and Normalization (MySQL 8.0+)
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders_3NF;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Sales_1NF;
DROP TABLE IF EXISTS Sales_UNF;

-- UNF: repeating groups stored in comma-separated columns
CREATE TABLE Sales_UNF (
 order_id INT, order_date DATE, customer_id INT, customer_name VARCHAR(50),
 product_ids VARCHAR(100), product_names VARCHAR(200), quantities VARCHAR(100)
);
INSERT INTO Sales_UNF VALUES
(101,'2026-01-10',1,'Aman','P1,P2','Laptop,Mouse','1,2'),
(102,'2026-01-11',2,'Riya','P2,P3','Mouse,Keyboard','1,1'),
(103,'2026-01-12',1,'Aman','P3','Keyboard','2');
SELECT * FROM Sales_UNF;

-- Functional dependencies:
-- order_id -> order_date, customer_id
-- customer_id -> customer_name
-- product_id -> product_name
-- (order_id, product_id) -> quantity

-- 1NF: atomic values; one product per row
CREATE TABLE Sales_1NF (
 order_id INT, order_date DATE, customer_id INT, customer_name VARCHAR(50),
 product_id VARCHAR(10), product_name VARCHAR(50), quantity INT,
 PRIMARY KEY(order_id, product_id)
);
INSERT INTO Sales_1NF VALUES
(101,'2026-01-10',1,'Aman','P1','Laptop',1),
(101,'2026-01-10',1,'Aman','P2','Mouse',2),
(102,'2026-01-11',2,'Riya','P2','Mouse',1),
(102,'2026-01-11',2,'Riya','P3','Keyboard',1),
(103,'2026-01-12',1,'Aman','P3','Keyboard',2);
SELECT * FROM Sales_1NF;

-- 2NF: split order-level, product-level and order-product data
CREATE TABLE Orders (
 order_id INT PRIMARY KEY, order_date DATE, customer_id INT, customer_name VARCHAR(50)
);
CREATE TABLE Products (
 product_id VARCHAR(10) PRIMARY KEY, product_name VARCHAR(50)
);
CREATE TABLE OrderDetails (
 order_id INT, product_id VARCHAR(10), quantity INT,
 PRIMARY KEY(order_id, product_id),
 FOREIGN KEY(order_id) REFERENCES Orders(order_id),
 FOREIGN KEY(product_id) REFERENCES Products(product_id)
);
INSERT INTO Orders VALUES
(101,'2026-01-10',1,'Aman'),(102,'2026-01-11',2,'Riya'),(103,'2026-01-12',1,'Aman');
INSERT INTO Products VALUES ('P1','Laptop'),('P2','Mouse'),('P3','Keyboard');
INSERT INTO OrderDetails VALUES (101,'P1',1),(101,'P2',2),(102,'P2',1),(102,'P3',1),(103,'P3',2);

-- 3NF: remove transitive dependency order_id -> customer_id -> customer_name
CREATE TABLE Customers (
 customer_id INT PRIMARY KEY, customer_name VARCHAR(50)
);
INSERT INTO Customers VALUES (1,'Aman'),(2,'Riya');
CREATE TABLE Orders_3NF (
 order_id INT PRIMARY KEY, order_date DATE, customer_id INT,
 FOREIGN KEY(customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO Orders_3NF VALUES
(101,'2026-01-10',1),(102,'2026-01-11',2),(103,'2026-01-12',1);

-- Lossless reconstruction check
SELECT o.order_id,o.order_date,c.customer_name,p.product_name,od.quantity
FROM Orders_3NF o
JOIN Customers c ON c.customer_id=o.customer_id
JOIN OrderDetails od ON od.order_id=o.order_id
JOIN Products p ON p.product_id=od.product_id
ORDER BY o.order_id,p.product_id;

-- Dependency preservation / BCNF:
-- Customers: customer_id -> customer_name
-- Orders_3NF: order_id -> order_date, customer_id
-- Products: product_id -> product_name
-- OrderDetails: (order_id, product_id) -> quantity
-- Each determinant is a candidate key in its relation; these relations satisfy BCNF
-- under the dependencies stated above.
```

## Output / Observations

- `Sales_UNF` contains 3 rows with comma-separated repeating groups.
- `Sales_1NF` contains 5 rows, with one product per row.
- The normalized reconstruction query returns 5 order-product combinations, including order date, customer, product and quantity.
- Each normalized relation stores one kind of fact; the join reconstructs the sample sales records.

## Result

The Sales data is decomposed into normalized relations and reconstructed using joins. The decomposition is lossless for the sample data, and the stated dependencies are preserved across the relations.

## How to Run

1. Connect to MySQL using Workbench or the command-line client.
2. Run `experiment_7.sql`.
3. Review the result grids and EXPLAIN output.
4. Capture screenshots of your actual output if required for practical submission.

