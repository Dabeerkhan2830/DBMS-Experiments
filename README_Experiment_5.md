# Experiment 5 — Views and Recursive CTE

## Aim

To create views for salary summaries and employee hierarchy, examine view behavior, and use a recursive common table expression to display reporting chains.

## Source Code

Run the following SQL in MySQL 8.0+ (Workbench or command-line client).

```sql
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
CREATE TABLE IF NOT EXISTS Staff5 (
 emp_id INT PRIMARY KEY, emp_name VARCHAR(50), manager_id INT NULL,
 dept_name VARCHAR(50), salary DECIMAL(10,2)
);
INSERT INTO Staff5 VALUES (1,'Aman',NULL,'IT',70000),(2,'Riya',1,'IT',50000),(3,'Kabir',2,'IT',40000),(4,'Meera',NULL,'HR',55000)
ON DUPLICATE KEY UPDATE emp_name=VALUES(emp_name),manager_id=VALUES(manager_id),dept_name=VALUES(dept_name),salary=VALUES(salary);
CREATE OR REPLACE VIEW Department_Salary_Summary AS
SELECT dept_name,COUNT(*) AS employee_count,AVG(salary) AS avg_salary
FROM Staff5 GROUP BY dept_name;
CREATE OR REPLACE VIEW Employee_Hierarchy AS
SELECT e.emp_id,e.emp_name,e.manager_id,m.emp_name AS manager_name
FROM Staff5 e LEFT JOIN Staff5 m ON e.manager_id=m.emp_id;
SELECT * FROM Department_Salary_Summary;
SELECT * FROM Employee_Hierarchy;
-- Recursive reporting chain starting from top-level employees
WITH RECURSIVE Reporting AS (
 SELECT emp_id,emp_name,manager_id,0 AS level_no,CAST(emp_name AS CHAR(500)) AS chain
 FROM Staff5 WHERE manager_id IS NULL
 UNION ALL
 SELECT e.emp_id,e.emp_name,e.manager_id,r.level_no+1,CONCAT(r.chain,' -> ',e.emp_name)
 FROM Staff5 e JOIN Reporting r ON e.manager_id=r.emp_id
)
SELECT emp_id,emp_name,level_no,chain FROM Reporting ORDER BY chain;
```

## Output / Observations

The salary-summary view shows employee count and average salary by department. The hierarchy view shows each employee with their manager. The recursive CTE displays reporting paths.

## Result

Views and a recursive CTE are used to summarize salaries and display employee reporting chains.

## Note

Output descriptions are expected observations for the sample data. Run the SQL in your own MySQL environment and capture actual result-grid screenshots if your practical submission requires them.
