# Experiment 2 — SQL Data Types, Constraints and Filtering

## Aim

To demonstrate table constraints, data insertion, WHERE filtering, sorting, limiting results, and common database inspection commands.

## Source Code

Run the following SQL in MySQL 8.0+ (Workbench or command-line client).

```sql
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
CREATE TABLE IF NOT EXISTS Movies (
  movie_id INT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  genre VARCHAR(40),
  release_year YEAR,
  rating DECIMAL(3,1) CHECK (rating BETWEEN 0 AND 10)
);
INSERT INTO Movies VALUES
(1,'Example Film','Drama',2022,8.1),
(2,'Space Journey','Sci-Fi',2024,7.6),
(3,'Laugh Out','Comedy',2021,7.2)
ON DUPLICATE KEY UPDATE title=VALUES(title),genre=VALUES(genre),release_year=VALUES(release_year),rating=VALUES(rating);
SHOW DATABASES;
SHOW TABLES;
SELECT * FROM Movies WHERE rating >= 7.5 ORDER BY rating DESC LIMIT 2;
```

## Output / Observations

The filtered query returns movies rated 7.5 or above, sorted by rating, limited to two rows.

## Result

Constraints and filtering, sorting, and limiting are demonstrated.

## Note

Output descriptions are expected observations for the sample data. Run the SQL in your own MySQL environment and capture actual result-grid screenshots if your practical submission requires them.
