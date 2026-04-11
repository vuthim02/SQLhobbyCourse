# Lesson 29: Storage Engines & Architecture

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 10:45:00 – 11:15:00 | 30 min |

## 📖 Theory

### What is a Storage Engine?

A **storage engine** is the component of MySQL that handles how data is stored, indexed, and retrieved on disk. MySQL is unique among databases in supporting **pluggable storage engines** — different tables in the same database can use different engines.

### Available Storage Engines

| Engine | Transactions | Locking | Foreign Keys | Full-Text | Use Case |
|--------|-------------|---------|-------------|-----------|----------|
| **InnoDB** | ✅ Yes | Row-level | ✅ Yes | ✅ Yes (5.6+) | **Default — use this** |
| **MyISAM** | ❌ No | Table-level | ❌ No | ✅ Yes | Legacy, read-heavy |
| **MEMORY** | ❌ No | Table-level | ❌ No | ❌ No | Temporary, caching |
| **CSV** | ❌ No | — | ❌ No | ❌ No | Import/export CSV files |
| **ARCHIVE** | ❌ No | Row-level | ❌ No | ❌ No | Log data, archival |
| **BLACKHOLE** | ❌ No | — | ❌ No | ❌ No | Replication, testing |

### InnoDB (Default Since MySQL 5.5)

**Features:**
- **ACID-compliant transactions** — full COMMIT/ROLLBACK support
- **Row-level locking** — multiple users can modify different rows simultaneously
- **Foreign key support** — referential integrity enforcement
- **Crash recovery** — auto-recovers after server failure
- **Clustered index** — data organized by primary key
- **MVCC** (Multi-Version Concurrency Control) — readers don't block writers

**Data Structure:**
- Data stored in **16KB pages**
- Pages organized in **B+ trees** (clustered index by PK)
- **Doublewrite buffer** — prevents partial page writes during crashes
- **Redo log** — records changes before they're written to data files
- **Undo log** — stores old values for rollback and MVCC

### MyISAM (Legacy)

**Features:**
- **No transactions** — no COMMIT/ROLLBACK
- **Table-level locking** — only one writer at a time (entire table locked)
- **No foreign keys** — no referential integrity
- **FULLTEXT indexes** (historically — InnoDB supports them now too)
- **Compressed tables** — compressed storage for read-only data
- **Faster for read-heavy workloads** — less overhead than InnoDB

**Data Structure:**
- `.MYD` — data file
- `.MYI` — index file
- `.frm` — table definition

### InnoDB vs MyISAM: Detailed Comparison

| Feature | InnoDB | MyISAM | Winner |
|---------|--------|--------|--------|
| **Transactions** | ✅ Full ACID | ❌ | InnoDB |
| **Row-level locking** | ✅ | ❌ (table-level) | InnoDB |
| **Foreign keys** | ✅ | ❌ | InnoDB |
| **Crash recovery** | ✅ Automatic | ❌ Manual repair | InnoDB |
| **MVCC** | ✅ | ❌ | InnoDB |
| **FULLTEXT index** | ✅ (5.6+) | ✅ | Tie |
| **COUNT(*) speed** | ⚠️ Scans rows | ✅ Instant (stored) | MyISAM |
| **Read-only speed** | Fast | Faster | MyISAM |
| **Space usage** | Higher | Lower | MyISAM |
| **Compression** | Page-level | Table-level | MyISAM |

> **Bottom line: Use InnoDB for almost everything.** MyISAM is only for specific read-heavy, non-transactional use cases or legacy compatibility.

### MEMORY Engine

Tables stored entirely in RAM:
- Extremely fast reads and writes
- Data lost on server restart (or crash)
- Good for: temporary working sets, caching, session storage

```sql
CREATE TABLE session_cache (
    session_id VARCHAR(64) PRIMARY KEY,
    data TEXT,
    expires_at INT
) ENGINE = MEMORY;
```

### Checking and Changing Engine

```sql
-- Check engine of all tables
SELECT table_name, engine, table_rows
FROM information_schema.tables
WHERE table_schema = 'your_database';

-- Check default engine
SHOW VARIABLES LIKE 'default_storage_engine';

-- Change engine of existing table
ALTER TABLE my_table ENGINE = InnoDB;
ALTER TABLE my_table ENGINE = MyISAM;

-- Create table with specific engine
CREATE TABLE my_table (
    id INT PRIMARY KEY
) ENGINE = InnoDB;
```

---

## 💻 Examples

### Example 1: InnoDB Transaction Demo

```sql
-- InnoDB supports transactions:
CREATE TABLE innodb_test (
    id INT PRIMARY KEY,
    value VARCHAR(50)
) ENGINE = InnoDB;

START TRANSACTION;
INSERT INTO innodb_test VALUES (1, 'hello');
INSERT INTO innodb_test VALUES (2, 'world');
SELECT * FROM innodb_test;  -- Sees uncommitted data
ROLLBACK;
SELECT * FROM innodb_test;  -- Empty (rolled back)
```

### Example 2: MyISAM No Transactions

```sql
CREATE TABLE myisam_test (
    id INT PRIMARY KEY,
    value VARCHAR(50)
) ENGINE = MyISAM;

START TRANSACTION;
INSERT INTO myisam_test VALUES (1, 'hello');
INSERT INTO myisam_test VALUES (2, 'world');
SELECT * FROM myisam_test;  -- Sees data
ROLLBACK;
SELECT * FROM myisam_test;  -- DATA STILL THERE! MyISAM ignores ROLLBACK
```

### Example 3: Row-Level vs Table-Level Locking

```sql
-- InnoDB: Two sessions can update different rows simultaneously
-- Session 1: UPDATE innodb_test SET value = 'a' WHERE id = 1;
-- Session 2: UPDATE innodb_test SET value = 'b' WHERE id = 2;
-- Both proceed in parallel

-- MyISAM: Session 1 locks the entire table
-- Session 1: UPDATE myisam_test SET value = 'a' WHERE id = 1;
-- Session 2: UPDATE myisam_test SET value = 'b' WHERE id = 2;
-- Session 2 WAITS until Session 1 commits (table-level lock)
```

### Example 4: COUNT(*) Performance

```sql
-- MyISAM: Instant (row count stored in metadata)
SELECT COUNT(*) FROM myisam_table;  -- O(1)

-- InnoDB: Must scan the clustered index
SELECT COUNT(*) FROM innodb_table;  -- O(n)

-- InnoDB optimization: If you only need an estimate:
SELECT TABLE_ROWS FROM information_schema.tables
WHERE table_name = 'innodb_table' AND table_schema = 'your_db';
```

### Example 5: MEMORY Engine for Caching

```sql
-- Fast in-memory lookup table
CREATE TABLE ip_blacklist (
    ip VARCHAR(45) PRIMARY KEY,
    reason VARCHAR(200),
    blocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = MEMORY;

-- Blazing fast lookups
SELECT * FROM ip_blacklist WHERE ip = '192.168.1.100';

-- But: data lost on restart! Repopulate from persistent table:
INSERT INTO ip_blacklist SELECT ip, reason, blocked_at FROM ip_blacklist_persistent;
```

### Example 6: Converting MyISAM to InnoDB

```sql
-- Convert a MyISAM table to InnoDB
ALTER TABLE old_myisam_table ENGINE = InnoDB;

-- What changes:
-- 1. Transactions now work
-- 2. Foreign keys can be added
-- 3. Row-level locking (better concurrency)
-- 4. Slightly more disk space
-- 5. COUNT(*) becomes slower
```

---

## ⚠️ Common Mistakes

### Mistake 1: Using MyISAM by Default

```sql
-- ❌ WRONG (in older MySQL versions):
CREATE TABLE logs (message TEXT, created_at TIMESTAMP);
-- Before MySQL 5.5, default was MyISAM — no transactions, no FKs

-- ✅ CORRECT: Always specify InnoDB
CREATE TABLE logs (message TEXT, created_at TIMESTAMP) ENGINE = InnoDB;
-- MySQL 5.5+ defaults to InnoDB
```

### Mistake 2: Mixing Engines in a Join

```sql
-- ⚠️ PROBLEMATIC: Joining InnoDB and MyISAM tables
SELECT * FROM innodb_table i JOIN myisam_table m ON i.id = m.id;
-- Different locking mechanisms can cause unexpected behavior
-- Best: use the same engine for related tables
```

### Mistake 3: MEMORY for Critical Data

```sql
-- ❌ DANGEROUS: Storing important data in MEMORY
CREATE TABLE payments (id INT, amount DECIMAL) ENGINE = MEMORY;
-- Server crashes → all payment data lost!

-- ✅ CORRECT: Use InnoDB for persistent data
CREATE TABLE payments (id INT, amount DECIMAL) ENGINE = InnoDB;
```

### Mistake 4: Not Tuning InnoDB Settings

```
# ❌ Default settings may not be optimal for production
# In my.cnf / my.ini:

# ✅ Recommended for dedicated MySQL server:
innodb_buffer_pool_size = 70% of RAM    -- Cache data and indexes
innodb_log_file_size = 256M             -- Larger redo logs
innodb_flush_log_at_trx_commit = 1      -- Full durability (ACID)
innodb_flush_method = O_DIRECT          -- Avoid double buffering
```

---

## ✅ Exercises

### Exercise 1: Check Your Server
1. What is the default storage engine?
2. List all tables in a database and their engines
3. How many InnoDB vs MyISAM tables exist?

### Exercise 2: Engine Comparison
1. Create the same table with InnoDB and MyISAM
2. Test transactions on both — observe the difference
3. Test concurrent updates — observe the locking difference

### Exercise 3: Migration
1. Convert a MyISAM table to InnoDB
2. Add a foreign key to the converted table
3. Test that transactions now work

### Exercise 4: MEMORY Engine
1. Create a MEMORY table for caching
2. Insert data, verify it's fast
3. Restart MySQL (or note that data is lost on disconnect)

---

## 🧠 Key Takeaways

- **InnoDB** is the default and recommended engine for almost all use cases
- **MyISAM** is legacy — no transactions, no FKs, table-level locking
- **MEMORY** is extremely fast but data is lost on restart
- Different tables can use different engines (but related tables should match)
- InnoDB supports: ACID, row-level locking, FKs, crash recovery, MVCC
- MyISAM only advantage: faster COUNT(*) and read-only performance
- Check engine with `SHOW TABLE STATUS` or `information_schema.tables`
- Convert engine with `ALTER TABLE ... ENGINE = InnoDB`
- Tune InnoDB settings (`innodb_buffer_pool_size`) for production performance

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 28: Query Optimization Techniques →](./lesson-28-optimization.md)
**Next:** [Lesson 30: Backup, Restore & Connecting to Apps →](./lesson-30-apps-apis.md)
