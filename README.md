# DBMS SQL Experiments 3-6

SQL source code extracted from the uploaded experiment PDFs.

## Files
- `experiment_3.sql` - Selection, Projection, Aggregates, GROUP BY, HAVING, CASE, ORDER BY
- `experiment_4.sql` - INNER JOIN, LEFT JOIN, Self JOIN, 3-way JOIN, Correlated Subquery, EXISTS, simulated INTERSECT/EXCEPT
- `experiment_5.sql` - Views, employee hierarchy, recursive CTE
- `experiment_6.sql` - Salary validation trigger and audit logging trigger

## Database
The experiments use MySQL-style SQL.

## Important
The Experiment 4 PDF says the aim includes comparing execution plans using `EXPLAIN`, but the provided source-code section does not contain an `EXPLAIN` query.

The Experiment 6 PDF says the aim includes a stored procedure `transfer_employee(emp_id, new_dept_id)`, but the provided source-code section contains the trigger/audit implementation and does not contain that stored procedure.
