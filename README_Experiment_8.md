# Experiment 8 — Transaction Management and Concurrency

## Aim

To demonstrate transaction control using START TRANSACTION, COMMIT, ROLLBACK and SAVEPOINT, handle an insufficient-balance update, and illustrate transaction isolation/concurrency anomalies with two MySQL sessions.

## Software / Requirements

- MySQL 8.0 or later
- MySQL Workbench or MySQL command-line client
- InnoDB storage engine for transaction examples

## Source Code

The complete SQL source is also available as [`experiment_8.sql`](./experiment_8.sql).

```sql
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
```

## Output / Observations

- After the committed transfer of 1,000 on a fresh table: Aman = 9,000.00 and Riya = 6,000.00.
- The 2,000 debit followed by `ROLLBACK` is cancelled.
- In the SAVEPOINT example, the 500 debit occurs before the savepoint; rolling back to `sp1` cancels the credit but retains the debit. Aman becomes 8,500.00 and Riya remains 6,000.00. This intentionally demonstrates partial rollback, not a completed transfer.
- The guarded 20,000 debit affects 0 rows when the balance is insufficient.
- Dirty-read and repeatable-read demonstrations require two separate sessions and the steps in the SQL comments.

## Result

COMMIT saves changes, ROLLBACK cancels an active transaction, SAVEPOINT enables partial rollback, and isolation levels control what concurrent transactions can observe.

## How to Run

1. Connect to MySQL using Workbench or the command-line client.
2. Run `experiment_8.sql`.
3. Review the result grids and EXPLAIN output.
4. Capture screenshots of your actual output if required for practical submission.

