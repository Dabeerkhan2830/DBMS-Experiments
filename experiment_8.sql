-- EXPERIMENT 8: Transactions and Concurrency (MySQL 8.0+, InnoDB)
CREATE DATABASE IF NOT EXISTS DBMS_Practicals;
USE DBMS_Practicals;
CREATE TABLE IF NOT EXISTS Bank (
 account_id INT PRIMARY KEY, account_name VARCHAR(50) NOT NULL,
 balance DECIMAL(10,2) NOT NULL, CHECK(balance >= 0)
) ENGINE=InnoDB;
INSERT INTO Bank(account_id,account_name,balance) VALUES
(1,'Aman',10000),(2,'Riya',5000)
ON DUPLICATE KEY UPDATE account_name=VALUES(account_name);

-- BEGIN / COMMIT: transfer 1,000
START TRANSACTION;
UPDATE Bank SET balance=balance-1000 WHERE account_id=1 AND balance>=1000;
SELECT ROW_COUNT() AS debit_rows;
UPDATE Bank SET balance=balance+1000 WHERE account_id=2;
COMMIT;
SELECT * FROM Bank ORDER BY account_id;

-- ROLLBACK: changes are cancelled
START TRANSACTION;
UPDATE Bank SET balance=balance-2000 WHERE account_id=1;
ROLLBACK;
SELECT * FROM Bank ORDER BY account_id;

-- SAVEPOINT: partial rollback example; intentionally not a completed bank transfer
START TRANSACTION;
UPDATE Bank SET balance=balance-500 WHERE account_id=1 AND balance>=500;
SAVEPOINT sp1;
UPDATE Bank SET balance=balance+500 WHERE account_id=2;
ROLLBACK TO SAVEPOINT sp1;
COMMIT;
SELECT * FROM Bank ORDER BY account_id;

-- Insufficient balance: guarded update affects zero rows
START TRANSACTION;
UPDATE Bank SET balance=balance-20000 WHERE account_id=1 AND balance>=20000;
SELECT ROW_COUNT() AS rows_updated;
ROLLBACK;

-- Isolation level example
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM Bank WHERE account_id=1;
COMMIT;

-- TWO-SESSION DIRTY READ DEMO:
-- Session A: START TRANSACTION;
-- UPDATE Bank SET balance=balance+100 WHERE account_id=1; (do not commit yet)
-- Session B: SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- START TRANSACTION; SELECT balance FROM Bank WHERE account_id=1; COMMIT;
-- Session B may see the uncommitted value. Then Session A runs ROLLBACK.

-- TWO-SESSION REPEATABLE READ DEMO:
-- Session B: SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION; SELECT balance FROM Bank WHERE account_id=1;
-- Session A: START TRANSACTION; UPDATE Bank SET balance=balance+200
-- WHERE account_id=1; COMMIT;
-- Session B: SELECT balance FROM Bank WHERE account_id=1; COMMIT;
-- In InnoDB consistent reads, both Session B reads normally show the same snapshot.