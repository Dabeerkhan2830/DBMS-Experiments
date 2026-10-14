# Experiment 1 — Basic SQL Queries and Database Operations

## Aim

To practice basic SQL commands for creating and selecting a database, creating tables, inserting records, and retrieving data.

## Source Code

Run the following SQL in MySQL 8.0+ (Workbench or command-line client).

```sql
-- Use the database created for your earlier practical, if applicable
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
CREATE TABLE IF NOT EXISTS Students (
  student_id INT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  age INT
);
INSERT INTO Students(student_id, first_name, age) VALUES
(1,'Aman',20),(2,'Riya',21),(3,'Kabir',19)
ON DUPLICATE KEY UPDATE first_name=VALUES(first_name), age=VALUES(age);
SELECT * FROM Students;
SELECT first_name, age FROM Students;
```

## Output / Observations

The Students table contains three sample student records. The final query displays only `first_name` and `age`.

## Result

Basic database, table, insert and select operations are demonstrated.

## Note

Output descriptions are expected observations for the sample data. Run the SQL in your own MySQL environment and capture actual result-grid screenshots if your practical submission requires them.
