# Experiment 4 — SQL Joins and Subqueries

## Aim

To demonstrate INNER JOIN, LEFT JOIN, self-join, multi-table joins, correlated subqueries, EXISTS, and set-operation alternatives using an employee schema.

## Source Code

Run the following SQL in MySQL 8.0+ (Workbench or command-line client).

```sql
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
CREATE TABLE IF NOT EXISTS Dept4 (dept_id INT PRIMARY KEY, dept_name VARCHAR(50));
CREATE TABLE IF NOT EXISTS Emp4 (emp_id INT PRIMARY KEY, emp_name VARCHAR(50), manager_id INT NULL, dept_id INT NULL, salary DECIMAL(10,2), FOREIGN KEY(dept_id) REFERENCES Dept4(dept_id));
INSERT INTO Dept4 VALUES (1,'IT'),(2,'HR'),(3,'Sales') ON DUPLICATE KEY UPDATE dept_name=VALUES(dept_name);
INSERT INTO Emp4 VALUES (1,'Aman',NULL,1,70000),(2,'Riya',1,1,50000),(3,'Kabir',1,2,45000),(4,'Meera',NULL,3,48000)
ON DUPLICATE KEY UPDATE emp_name=VALUES(emp_name),manager_id=VALUES(manager_id),dept_id=VALUES(dept_id),salary=VALUES(salary);
-- INNER JOIN
SELECT e.emp_name,d.dept_name FROM Emp4 e INNER JOIN Dept4 d ON e.dept_id=d.dept_id;
-- LEFT JOIN
SELECT e.emp_name,d.dept_name FROM Emp4 e LEFT JOIN Dept4 d ON e.dept_id=d.dept_id;
-- Self-join: employee and manager
SELECT e.emp_name AS employee,m.emp_name AS manager FROM Emp4 e LEFT JOIN Emp4 m ON e.manager_id=m.emp_id;
-- Correlated subquery
SELECT e.emp_name,e.salary FROM Emp4 e WHERE e.salary>(SELECT AVG(x.salary) FROM Emp4 x WHERE x.dept_id=e.dept_id);
-- EXISTS
SELECT d.dept_name FROM Dept4 d WHERE EXISTS (SELECT 1 FROM Emp4 e WHERE e.dept_id=d.dept_id);
-- EXPLAIN a join plan
EXPLAIN SELECT e.emp_name,d.dept_name FROM Emp4 e JOIN Dept4 d ON e.dept_id=d.dept_id;
```

## Output / Observations

Join queries combine employee and department details; the self-join lists managers; the correlated query finds employees earning above their department average; EXISTS lists departments with employees.

## Result

Common join and subquery patterns are demonstrated.

## Note

Output descriptions are expected observations for the sample data. Run the SQL in your own MySQL environment and capture actual result-grid screenshots if your practical submission requires them.
