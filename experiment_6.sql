-- EXPERIMENT 6
-- Stored procedure transfer_employee and triggers for salary validation/audit logging

CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    budget DECIMAL(12,2)
);

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id)
);

CREATE TABLE Employee_Project (
    emp_id INT,
    project_id INT,
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

INSERT INTO Department VALUES
(1, 'IT', 'Delhi'),
(2, 'HR', 'Gurgaon'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Bangalore'),
(5, 'Sales', 'Hyderabad');

INSERT INTO Project VALUES
(101, 'Cloud Migration', 500000),
(102, 'E-Commerce Website', 350000),
(103, 'Mobile Application', 250000),
(104, 'HR Automation', 150000),
(105, 'Financial Analytics', 450000),
(106, 'Marketing Campaign', 200000),
(107, 'CRM Development', 300000),
(108, 'Cyber Security', 600000);

INSERT INTO Employee VALUES
(1, 'Amit', 'IT Manager', 90000, '2018-01-10', 1, NULL),
(2, 'Neha', 'HR Manager', 85000, '2018-03-15', 2, NULL),
(3, 'Rahul', 'Finance Manager', 95000, '2017-06-20', 3, NULL),
(4, 'Priya', 'Marketing Manager', 88000, '2019-02-12', 4, NULL),
(5, 'Arjun', 'Sales Manager', 92000, '2017-09-25', 5, NULL);

INSERT INTO Employee VALUES
(6, 'Ravi', 'Software Engineer', 60000, '2020-01-10', 1, 1),
(7, 'Simran', 'Software Engineer', 65000, '2021-04-15', 1, 1),
(8, 'Karan', 'Database Developer', 70000, '2020-07-20', 1, 1),
(9, 'Pooja', 'Cloud Engineer', 75000, '2022-01-12', 1, 1),
(10, 'Vikas', 'System Engineer', 58000, '2021-09-25', 1, 1),
(11, 'Anjali', 'HR Executive', 55000, '2020-02-10', 2, 2),
(12, 'Rohit', 'Recruiter', 50000, '2021-05-15', 2, 2),
(13, 'Kavya', 'HR Executive', 52000, '2022-06-20', 2, 2),
(14, 'Manish', 'Training Officer', 60000, '2020-08-12', 2, 2),
(15, 'Sneha', 'HR Analyst', 58000, '2021-10-25', 2, 2),
(16, 'Deepak', 'Financial Analyst', 70000, '2019-02-10', 3, 3),
(17, 'Nisha', 'Accountant', 62000, '2020-05-15', 3, 3),
(18, 'Varun', 'Financial Analyst', 68000, '2021-06-20', 3, 3),
(19, 'Meena', 'Accountant', 60000, '2022-08-12', 3, 3),
(20, 'Sahil', 'Finance Executive', 57000, '2021-11-25', 3, 3),
(21, 'Tanya', 'Marketing Executive', 55000, '2020-03-10', 4, 4),
(22, 'Mohit', 'SEO Specialist', 60000, '2021-05-15', 4, 4),
(23, 'Isha', 'Content Manager', 65000, '2022-07-20', 4, 4),
(24, 'Akash', 'Marketing Analyst', 58000, '2020-09-12', 4, 4),
(25, 'Riya', 'Social Media Manager', 62000, '2021-12-25', 4, 4),
(26, 'Naveen', 'Sales Executive', 55000, '2020-04-10', 5, 5),
(27, 'Komal', 'Sales Executive', 57000, '2021-06-15', 5, 5),
(28, 'Yash', 'Sales Analyst', 60000, '2022-07-20', 5, 5),
(29, 'Pankaj', 'Business Executive', 65000, '2020-10-12', 5, 5),
(30, 'Divya', 'Sales Executive', 58000, '2022-01-25', 5, 5);

INSERT INTO Employee_Project VALUES
(1,101,100),
(6,101,120),
(7,102,100),
(8,101,90),
(9,108,130),
(10,103,80),
(2,104,100),
(11,104,90),
(12,104,80),
(13,104,70),
(14,104,100),
(15,104,75),
(3,105,100),
(16,105,120),
(17,105,100),
(18,105,90),
(19,105,80),
(20,105,70),
(4,106,100),
(21,106,120),
(22,106,100),
(23,106,90),
(24,106,80),
(25,107,100),
(5,107,100),
(26,107,110),
(27,107,90),
(28,107,80),
(29,107,100),
(30,107,90);

CREATE TABLE Employee_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    action_type VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER before_employee_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary cannot be negative';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_salary_update
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO Employee_Audit
        (emp_id, old_salary, new_salary, action_type)
        VALUES
        (OLD.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATED');
    END IF;
END //

DELIMITER ;

UPDATE Employee
SET salary = 65000
WHERE emp_id = 6;

-- Check audit
SELECT *
FROM Employee_Audit;
