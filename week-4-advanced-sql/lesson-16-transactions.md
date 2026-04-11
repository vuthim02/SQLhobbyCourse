# Lesson 16: Transactions & ACID

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 1:30:00 – 2:15:00 | 45 min |

## 📖 Theory

### What is a Transaction?

A **transaction** is a sequence of one or more SQL operations that are executed as a **single unit of work**. Either all operations succeed (COMMIT), or all are undone (ROLLBACK).

### Real-World Example: Bank Transfer

Transferring $100 from Alice to Bob requires **two** operations:
1. Subtract $100 from Alice's account
2. Add $100 to Bob's account

If step 2 fails after step 1 succeeds, $100 disappears. A **transaction** ensures both succeed or both fail.

```sql
START TRANSACTION;
    UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
    UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
COMMIT;  -- Both changes saved, or both undone with ROLLBACK
```

### ACID Properties

| Property | Meaning | Example |
|----------|---------|---------|
| **A**tomicity | All or nothing — transaction is indivisible | If one operation fails, the entire transaction is rolled back |
| **C**onsistency | Database moves from one valid state to another | Constraints are never violated mid-transaction |
| **I**solation | Concurrent transactions don't interfere | Two transfers at the same time produce correct results |
| **D**urability | Once committed, changes survive failures | After COMMIT, data persists even if the server crashes |

### Transaction Control Statements

| Statement | Purpose |
|-----------|---------|
| `START TRANSACTION` or `BEGIN` | Start a new transaction |
| `COMMIT` | Save all changes permanently |
| `ROLLBACK` | Undo all changes since START TRANSACTION |
| `SAVEPOINT name` | Set a checkpoint within the transaction |
| `ROLLBACK TO SAVEPOINT name` | Undo to a specific savepoint |
| `RELEASE SAVEPOINT name` | Remove a savepoint |
| `SET autocommit = 0` | Disable auto-commit for session |

### Isolation Levels

Isolation levels control how visible uncommitted changes are between concurrent transactions.

| Level | Dirty Read | Non-Repeatable Read | Phantom Read | Performance |
|-------|-----------|---------------------|--------------|-------------|
| **READ UNCOMMITTED** | Possible | Possible | Possible | Fastest |
| **READ COMMITTED** | Prevented | Possible | Possible | Fast |
| **REPEATABLE READ** (MySQL default) | Prevented | Prevented | Possible | Medium |
| **SERIALIZABLE** | Prevented | Prevented | Prevented | Slowest |

### Concurrency Problems

| Problem | Description | Example |
|---------|-------------|---------|
| **Dirty Read** | Reading uncommitted data from another transaction | T1 updates a row, T2 reads it, T1 rolls back → T2 read garbage |
| **Non-Repeatable Read** | Getting different values when reading the same row twice | T1 reads row = 100, T2 updates to 200, T1 reads again → 200 |
| **Phantom Read** | New rows appear in a range query between two reads | T1 counts rows WHERE age > 20 → 5, T2 inserts row age=25, T1 counts → 6 |

### Locking

- **Shared lock (S)**: Multiple transactions can read, none can write
- **Exclusive lock (X)**: Only one transaction can write, others blocked
- `SELECT ... LOCK IN SHARE MODE` — acquires shared lock
- `SELECT ... FOR UPDATE` — acquires exclusive lock

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS transactions_db;
USE transactions_db;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    CHECK (balance >= 0)
);

INSERT INTO accounts (name, balance)
VALUES ('Alice', 1000.00), ('Bob', 500.00), ('Carol', 750.00);

CREATE TABLE transactions_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    from_account INT,
    to_account INT,
    amount DECIMAL(12,2),
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Example 1: Basic Transaction

```sql
-- Start transaction
START TRANSACTION;

-- Debit Alice
UPDATE accounts SET balance = balance - 200 WHERE name = 'Alice';

-- Credit Bob
UPDATE accounts SET balance = balance + 200 WHERE name = 'Bob';

-- Commit both changes
COMMIT;

-- Verify
SELECT * FROM accounts;
-- Alice: 800.00, Bob: 700.00
```

### Example 2: ROLLBACK — Undoing Changes

```sql
-- Check current balances
SELECT * FROM accounts WHERE name = 'Carol';
-- Carol: 750.00

START TRANSACTION;

UPDATE accounts SET balance = balance - 500 WHERE name = 'Carol';
SELECT balance FROM accounts WHERE name = 'Carol';
-- 250.00 (not yet permanent)

-- Oops, mistake! Rollback
ROLLBACK;

-- Verify Carol's balance is unchanged
SELECT balance FROM accounts WHERE name = 'Carol';
-- 750.00 (rolled back!)
```

### Example 3: SAVEPOINT

```sql
START TRANSACTION;

-- Operation 1
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
SAVEPOINT step1;

-- Operation 2
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
SAVEPOINT step2;

-- Operation 3
UPDATE accounts SET balance = balance - 50 WHERE name = 'Carol';

-- Oops, undo only step 3
ROLLBACK TO SAVEPOINT step2;

-- Alice and Bob changes remain, Carol's is undone
COMMIT;
```

### Example 4: Transaction with Error (Automatic Rollback)

```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
-- This will fail: balance would go negative (CHECK constraint)
UPDATE accounts SET balance = balance - 999999 WHERE name = 'Bob';
-- ERROR: Check constraint violated

-- In MySQL (InnoDB), the single statement rolls back, but the transaction continues
-- Check Alice: her -100 was applied
SELECT * FROM accounts WHERE name = 'Alice';

-- To fully undo:
ROLLBACK;
-- Alice's balance restored
```

### Example 5: Transfer with Logging (Atomicity)

```sql
DELIMITER //
CREATE PROCEDURE transfer_funds(
    IN from_id INT,
    IN to_id INT,
    IN amount DECIMAL(12,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Debit
    UPDATE accounts SET balance = balance - amount WHERE account_id = from_id;

    -- Credit
    UPDATE accounts SET balance = balance + amount WHERE account_id = to_id;

    -- Log
    INSERT INTO transactions_log (from_account, to_account, amount)
    VALUES (from_id, to_id, amount);

    COMMIT;
END //
DELIMITER ;

-- Use it:
CALL transfer_funds(1, 2, 150.00);
SELECT * FROM accounts;
SELECT * FROM transactions_log;
```

### Example 6: SELECT ... FOR UPDATE (Locking)

```sql
-- Session 1:
START TRANSACTION;
SELECT balance FROM accounts WHERE name = 'Alice' FOR UPDATE;
-- This locks Alice's row — no other transaction can modify it

-- Session 2 (while Session 1's transaction is open):
START TRANSACTION;
UPDATE accounts SET balance = balance + 50 WHERE name = 'Alice';
-- This WAITS (blocks) until Session 1 commits or rolls back

-- Session 1:
COMMIT;
-- Session 2's UPDATE now proceeds
```

### Example 7: Isolation Level Demonstration

```sql
-- Check current isolation level
SELECT @@transaction_isolation;
-- In MySQL: REPEATABLE-READ (default)

-- Change isolation level (must be done before starting transactions)
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- With SERIALIZABLE:
-- No other transaction can modify rows you've read until you commit
```

---

## ⚠️ Common Mistakes

### Mistake 1: Forgetting to COMMIT

```sql
-- ❌ WRONG: Starting a transaction but never committing
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
-- Connection closes without COMMIT or ROLLBACK
-- Changes may or may not be saved depending on MySQL config

-- ✅ CORRECT: Always COMMIT or ROLLBACK
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
COMMIT;
```

### Mistake 2: DDL in Transactions

```sql
-- ❌ WRONG: DDL statements cause implicit COMMIT
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
CREATE TABLE audit_log (id INT PRIMARY KEY);  -- IMPLICIT COMMIT!
ROLLBACK;  -- Won't undo the CREATE TABLE or the UPDATE

-- ✅ CORRECT: Keep transactions DML-only (INSERT, UPDATE, DELETE, SELECT)
```

### Mistake 3: Long-Running Transactions

```sql
-- ❌ DANGEROUS: Transaction holds locks for too long
START TRANSACTION;
UPDATE accounts SET balance = balance - 1 WHERE name = 'Alice';
-- ... do other work for 10 minutes ...
COMMIT;
-- All other transactions waiting to update Alice's row are blocked!

-- ✅ CORRECT: Keep transactions short
START TRANSACTION;
UPDATE accounts SET balance = balance - 1 WHERE name = 'Alice';
COMMIT;
-- Lock held for milliseconds
```

### Mistake 4: Ignoring Deadlocks

```sql
-- Deadlock scenario:
-- Session 1: UPDATE accounts WHERE account_id = 1; (locks row 1)
-- Session 2: UPDATE accounts WHERE account_id = 2; (locks row 2)
-- Session 1: UPDATE accounts WHERE account_id = 2; (waits for Session 2)
-- Session 2: UPDATE accounts WHERE account_id = 1; (waits for Session 1)
-- → DEADLOCK!

-- MySQL automatically kills one transaction
-- ERROR 1213 (40001): Deadlock found when trying to get lock

-- ✅ CORRECT: Always access rows in consistent order, handle deadlock errors in application
```

---

## ✅ Exercises

### Exercise 1: Basic Transactions
1. Start a transaction, update two account balances, COMMIT
2. Start a transaction, update a balance, verify with SELECT, ROLLBACK
3. Verify the rollback restored original values

### Exercise 2: SAVEPOINT Practice
1. Start a transaction
2. Update Alice's balance → SAVEPOINT after_alice
3. Update Bob's balance → SAVEPOINT after_bob
4. Update Carol's balance
5. ROLLBACK TO after_bob (undo Carol's change)
6. COMMIT (keep Alice and Bob's changes)

### Exercise 3: Bank Transfer Procedure
Create a stored procedure `safe_transfer(from_id, to_id, amount)` that:
1. Starts a transaction
2. Checks that the sender has sufficient balance
3. Debits sender, credits receiver
4. Logs the transaction
5. Commits on success, rolls back on any error

### Exercise 4: Locking
1. In one session, start a transaction and SELECT ... FOR UPDATE on a row
2. In another session, try to UPDATE that row — observe it blocks
3. COMMIT in session 1 — observe session 2 proceeds

---

## 🧠 Key Takeaways

- **Transactions** group operations into atomic units — all succeed or all fail
- **ACID**: Atomicity, Consistency, Isolation, Durability
- **START TRANSACTION / COMMIT / ROLLBACK** are the core commands
- **SAVEPOINT** allows partial rollbacks within a transaction
- **Isolation levels** control concurrency trade-offs (performance vs consistency)
- MySQL default: **REPEATABLE READ** (prevents dirty and non-repeatable reads)
- **SELECT ... FOR UPDATE** acquires exclusive locks for safe concurrent updates
- DDL statements (CREATE, ALTER, DROP) cause **implicit COMMIT**
- Keep transactions **short** to minimize lock contention
- **Deadlocks** are resolved automatically by MySQL (kills one transaction)

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 15: Creating & Using Indexes →](./lesson-15-indexes-practice.md)
**Next:** [Lesson 17: Views →](./lesson-17-views.md)
