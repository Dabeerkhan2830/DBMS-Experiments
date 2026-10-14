# Experiment 3 — Employee, Department and Project Schema

## Aim

To create a relational schema for employees, departments and projects, insert sample records, and demonstrate selection, projection, aggregation, GROUP BY, HAVING, CASE and ORDER BY.

## Source Code

Run the following SQL in MySQL 8.0+ (Workbench or command-line client).

```sql
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
CREATE TABLE IF NOT EXISTS Department (
 dept_id INT PRIMARY KEY, dept_name VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS Employee (
 emp_id INT PRIMARY KEY, emp_name VARCHAR(60) NOT NULL,
 salary DECIMAL(10,2), dept_id INT,
 FOREIGN KEY(dept_id) REFERENCES Department(dept_id)
);
CREATE TABLE IF NOT EXISTS Project (
 project_id INT PRIMARY KEY, project_name VARCHAR(80) NOT NULL
);
INSERT INTO Department VALUES (1,'IT'),(2,'HR') ON DUPLICATE KEY UPDATE dept_name=VALUES(dept_name);
INSERT INTO Employee VALUES (101,'Aman',50000,1),(102,'Riya',62000,1),(103,'Kabir',42000,2)
ON DUPLICATE KEY UPDATE emp_name=VALUES(emp_name),salary=VALUES(salary),dept_id=VALUES(dept_id);
INSERT INTO Project VALUES (201,'Portal'),(202,'Recruitment') ON DUPLICATE KEY UPDATE project_name=VALUES(project_name);
SELECT emp_name,salary FROM Employee;
SELECT dept_id,AVG(salary) AS average_salary FROM Employee GROUP BY dept_id HAVING AVG(salary)>45000;
SELECT emp_name,CASE WHEN salary>=60000 THEN 'High' ELSE 'Standard' END AS salary_band FROM Employee ORDER BY salary DESC;
```

## Output / Observations

The first query projects employee names and salaries. The grouped query returns departments whose average salary exceeds 45,000. CASE labels salaries as High or Standard.

## Result

The schema and required SQL query types are demonstrated with sample data.

## Note

Output descriptions are expected observations for the sample data. Run the SQL in your own MySQL environment and capture actual result-grid screenshots if your practical submission requires them.
