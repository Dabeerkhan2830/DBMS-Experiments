# Experiment 6 — Stored Procedure, Triggers and Audit Logging

## Aim

To implement a stored procedure for transferring an employee between departments with validation and error handling, and to create triggers for salary validation and audit logging.

## Source Code

Run the following SQL in MySQL 8.0+ (Workbench or command-line client).

```sql
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
CREATE TABLE IF NOT EXISTS Dept6 (dept_id INT PRIMARY KEY, dept_name VARCHAR(50));
CREATE TABLE IF NOT EXISTS Emp6 (emp_id INT PRIMARY KEY, emp_name VARCHAR(50), dept_id INT, salary DECIMAL(10,2), FOREIGN KEY(dept_id) REFERENCES Dept6(dept_id));
CREATE TABLE IF NOT EXISTS Salary_Audit6 (audit_id INT AUTO_INCREMENT PRIMARY KEY, emp_id INT, old_salary DECIMAL(10,2), new_salary DECIMAL(10,2), changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
INSERT INTO Dept6 VALUES (1,'IT'),(2,'HR') ON DUPLICATE KEY UPDATE dept_name=VALUES(dept_name);
INSERT INTO Emp6 VALUES (1,'Aman',1,50000),(2,'Riya',2,45000) ON DUPLICATE KEY UPDATE emp_name=VALUES(emp_name),dept_id=VALUES(dept_id),salary=VALUES(salary);
DELIMITER $$
CREATE PROCEDURE transfer_employee(IN p_emp_id INT, IN p_new_dept_id INT)
BEGIN
 IF NOT EXISTS (SELECT 1 FROM Emp6 WHERE emp_id=p_emp_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Employee does not exist';
 ELSEIF NOT EXISTS (SELECT 1 FROM Dept6 WHERE dept_id=p_new_dept_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Department does not exist';
 ELSE
  UPDATE Emp6 SET dept_id=p_new_dept_id WHERE emp_id=p_emp_id;
 END IF;
END$$
CREATE TRIGGER validate_salary6 BEFORE UPDATE ON Emp6 FOR EACH ROW
BEGIN
 IF NEW.salary < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Salary cannot be negative'; END IF;
END$$
CREATE TRIGGER audit_salary6 AFTER UPDATE ON Emp6 FOR EACH ROW
BEGIN
 IF OLD.salary <> NEW.salary THEN
  INSERT INTO Salary_Audit6(emp_id,old_salary,new_salary) VALUES(OLD.emp_id,OLD.salary,NEW.salary);
 END IF;
END$$
DELIMITER ;
CALL transfer_employee(1,2);
SELECT * FROM Emp6;
UPDATE Emp6 SET salary=52000 WHERE emp_id=1;
SELECT * FROM Salary_Audit6;
```

## Output / Observations

The procedure moves employee 1 to department 2. Updating the salary from 50,000 to 52,000 adds a row to Salary_Audit6. A negative salary update raises an error from the validation trigger.

## Result

Stored procedure validation, trigger-based salary checks and audit logging are demonstrated.

## Note

Output descriptions are expected observations for the sample data. Run the SQL in your own MySQL environment and capture actual result-grid screenshots if your practical submission requires them.
