# Lesson 15: Creating & Using Indexes

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 1:00:00 – 1:30:00 | 30 min |

## 📖 Theory

### Creating Indexes

```sql
-- Basic index
CREATE INDEX index_name ON table_name(column_name);

-- Unique index (also enforces uniqueness)
CREATE UNIQUE INDEX index_name ON table_name(column_name);

-- Composite (multi-column) index
CREATE INDEX index_name ON table_name(column1, column2, column3);

-- Index with custom sort order
CREATE INDEX index_name ON table_name(column1 ASC, column2 DESC);
```

### Index at Table Creation

```sql
CREATE TABLE users (
    id INT PRIMARY KEY,
    email VARCHAR(100),
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    created_at DATETIME,

    INDEX idx_email (email),
    INDEX idx_name (last_name, first_name),
    INDEX idx_created (created_at DESC)
);
```

### Dropping Indexes

```sql
DROP INDEX index_name ON table_name;
```

### When to Create Indexes

| Situation | Create Index? | Reason |
|-----------|--------------|--------|
| Column in WHERE clause frequently | ✅ Yes | Speeds up filtering |
| Column in JOIN condition | ✅ Yes | Speeds up joins |
| Column in ORDER BY | ✅ Yes | Avoids filesort |
| Column in GROUP BY | ✅ Yes | Speeds up grouping |
| Column only in INSERT | ❌ No | Unnecessary write overhead |
| Low-selectivity column (2-3 values) | ❌ No | Index provides little benefit |
| Very small table (< 1000 rows) | ❌ No | Full scan is fast enough |

### Composite Index Rules

A composite index on `(A, B, C)` supports queries on:
- `(A)` ✅
- `(A, B)` ✅
- `(A, B, C)` ✅
- `(A, C)` ⚠️ (uses A, skips B — partial use)
- `(B)` ❌ (leftmost rule violated)
- `(B, C)` ❌
- `(C)` ❌

### EXPLAIN Basics

```sql
EXPLAIN SELECT * FROM users WHERE email = 'test@test.com';
```

Key columns in EXPLAIN output:
- **type**: `const` > `ref` > `range` > `index` > `ALL` (ALL = worst, full scan)
- **possible_keys**: Which indexes MySQL could use
- **key**: Which index MySQL actually chose
- **rows**: Estimated rows to examine
- **Extra**: `Using index` = covering index (fastest)

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS index_practice;
USE index_practice;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    city VARCHAR(50)
);

-- Insert 100 sample rows
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date, city)
VALUES
    ('Alice', 'Smith', 'alice@company.com', 'Engineering', 95000, '2020-01-15', 'New York'),
    ('Bob', 'Johnson', 'bob@company.com', 'Marketing', 72000, '2021-03-10', 'London'),
    ('Carol', 'Williams', 'carol@company.com', 'Engineering', 88000, '2019-07-20', 'New York'),
    ('David', 'Brown', 'david@company.com', 'Sales', 68000, '2022-01-05', 'Tokyo'),
    ('Eve', 'Davis', 'eve@company.com', 'Engineering', 105000, '2018-05-12', 'London'),
    ('Frank', 'Miller', 'frank@company.com', 'HR', 60000, '2023-02-28', 'New York'),
    ('Grace', 'Wilson', 'grace@company.com', 'Sales', 75000, '2020-11-15', 'Tokyo'),
    ('Henry', 'Taylor', 'henry@company.com', 'Finance', 78000, '2021-06-01', 'London'),
    ('Ivy', 'Anderson', 'ivy@company.com', 'Marketing', 69000, '2022-09-10', 'New York'),
    ('Jack', 'Thomas', 'jack@company.com', 'Finance', 82000, '2019-12-20', 'Tokyo');
```

### Example 1: Create and Use a Single-Column Index

```sql
-- Before: Full table scan
EXPLAIN SELECT * FROM employees WHERE email = 'alice@company.com';
-- type: ALL (full scan), rows: 10

-- Create index
CREATE INDEX idx_email ON employees(email);

-- After: Index lookup
EXPLAIN SELECT * FROM employees WHERE email = 'alice@company.com';
-- type: const (direct lookup), rows: 1
```

### Example 2: Composite Index

```sql
-- Composite index for department + city lookups
CREATE INDEX idx_dept_city ON employees(department, city);

-- ✅ Uses full composite index
EXPLAIN SELECT * FROM employees WHERE department = 'Engineering' AND city = 'New York';
-- type: ref, rows: 1 (uses both columns)

-- ✅ Uses leftmost prefix (department only)
EXPLAIN SELECT * FROM employees WHERE department = 'Engineering';
-- type: ref, rows: 3

-- ❌ Cannot use index (skips leftmost column)
EXPLAIN SELECT * FROM employees WHERE city = 'New York';
-- type: ALL (full scan)
```

### Example 3: Index for ORDER BY

```sql
-- Without index: filesort required
EXPLAIN SELECT * FROM employees ORDER BY hire_date;
-- Extra: Using filesort

-- Create index on hire_date
CREATE INDEX idx_hire_date ON employees(hire_date);

-- With index: uses index order
EXPLAIN SELECT * FROM employees ORDER BY hire_date;
-- Extra: (no filesort — uses index order)
```

### Example 4: Covering Index

```sql
-- Covering index: all columns in SELECT are in the index
CREATE INDEX idx_dept_salary ON employees(department, salary);

-- This query is served entirely from the index
EXPLAIN SELECT department, salary FROM employees WHERE department = 'Engineering';
-- Extra: Using index (covering index — fastest!)

-- But this needs the table (email not in index)
EXPLAIN SELECT department, salary, email FROM employees WHERE department = 'Engineering';
-- Extra: (no "Using index" — must look up rows in table)
```

### Example 5: Unique Index

```sql
-- UNIQUE index enforces uniqueness AND creates an index
CREATE UNIQUE INDEX idx_unique_email ON employees(email);

-- This fails:
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date, city)
VALUES ('Duplicate', 'Person', 'alice@company.com', 'HR', 50000, '2024-01-01', 'NY');
-- ERROR: Duplicate entry 'alice@company.com'
```

### Example 6: Index on Expression (MySQL 8.0.13+)

```sql
-- Functional index: index on an expression
CREATE INDEX idx_last_lower ON employees((LOWER(last_name)));

-- This can now use the index
EXPLAIN SELECT * FROM employees WHERE LOWER(last_name) = 'smith';
-- type: ref, uses idx_last_lower
```

### Example 7: Drop and Recreate Index

```sql
-- Check existing indexes
SHOW INDEX FROM employees;

-- Drop an index
DROP INDEX idx_dept_city ON employees;

-- Verify it's gone
SHOW INDEX FROM employees;

-- Recreate with different column order
CREATE INDEX idx_city_dept ON employees(city, department);
```

### Example 8: Performance Comparison

```sql
-- Create a larger table for comparison
CREATE TABLE large_table AS
SELECT
    ROW_NUMBER() OVER () AS id,
    CONCAT('user_', ROW_NUMBER() OVER ()) AS username,
    FLOOR(RAND() * 10000) AS score,
    NOW() - INTERVAL FLOOR(RAND() * 3650) DAY AS created_at
FROM
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) e,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) f;
-- Creates 15,625 rows

-- Before index
EXPLAIN SELECT * FROM large_table WHERE username = 'user_5000';
-- type: ALL, rows: ~15,625

-- Add index
CREATE INDEX idx_username ON large_table(username);

-- After index
EXPLAIN SELECT * FROM large_table WHERE username = 'user_5000';
-- type: ref, rows: 1
```

---

## ⚠️ Common Mistakes

### Mistake 1: Wrong Column Order in Composite Index

```sql
-- ❌ SUBOPTIMAL: High-cardinality column first wastes the second column
CREATE INDEX idx_score_dept ON employees(score, department);
-- score has many values → narrow range → department index is barely used

-- ✅ BETTER: Lower-cardinality column first, then narrow down
CREATE INDEX idx_dept_score ON employees(department, score);
-- Filter by department first (fewer rows), then by score within department
```

### Mistake 2: Redundant Indexes

```sql
-- ❌ REDUNDANT: idx_a is a prefix of idx_a_b — idx_a is unnecessary
CREATE INDEX idx_a ON employees(department);
CREATE INDEX idx_a_b ON employees(department, salary);
-- The composite index already supports department-only lookups

-- ✅ CORRECT: Just the composite index
CREATE INDEX idx_dept_salary ON employees(department, salary);
```

### Mistake 3: Forgetting to Analyze Tables

```sql
-- After bulk inserts, index statistics may be stale
INSERT INTO large_table ... (100,000 rows);

-- MySQL may use wrong index because statistics are outdated
EXPLAIN SELECT * FROM large_table WHERE username = 'user_100000';

-- ✅ Fix: Update statistics
ANALYZE TABLE large_table;
-- Now MySQL has accurate cardinality info
```

### Mistake 4: Creating Index on Wrong Type

```sql
-- ❌ WRONG: Can't index a TEXT/BLOB column without prefix length
CREATE INDEX idx_desc ON products(description);
-- ERROR: BLOB/TEXT column used in key specification without a key length

-- ✅ CORRECT: Specify prefix length
CREATE INDEX idx_desc_prefix ON products(description(50));
-- Indexes first 50 characters — enough for most lookups
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS index_exercises;
USE index_exercises;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    total DECIMAL(10,2),
    shipping_city VARCHAR(50),
    INDEX idx_customer (customer_id)
);

-- Insert sample data
INSERT INTO orders (customer_id, order_date, status, total, shipping_city)
VALUES
    (1, '2024-01-15', 'completed', 150.00, 'New York'),
    (2, '2024-01-20', 'completed', 75.50, 'London'),
    (1, '2024-02-10', 'pending', 200.00, 'New York'),
    (3, '2024-02-15', 'shipped', 50.00, 'Tokyo'),
    (2, '2024-03-01', 'completed', 300.00, 'London'),
    (4, '2024-03-10', 'pending', 120.00, 'New York'),
    (1, '2024-03-15', 'completed', 85.00, 'Paris'),
    (5, '2024-04-01', 'shipped', 250.00, 'Tokyo'),
    (3, '2024-04-10', 'pending', 175.00, 'London'),
    (2, '2024-04-15', 'completed', 90.00, 'Paris');
```

### Exercise 1: Basic Index Creation
1. Check existing indexes on the orders table
2. Create an index on `order_date`
3. Create a composite index on `(status, order_date)`
4. Verify with `SHOW INDEX`

### Exercise 2: EXPLAIN Practice
For each query, run EXPLAIN and note the `type` and `rows`:
1. `SELECT * FROM orders WHERE customer_id = 1;` (uses existing idx_customer)
2. `SELECT * FROM orders WHERE order_date = '2024-03-01';` (should use new index)
3. `SELECT * FROM orders WHERE status = 'completed' ORDER BY order_date;` (composite)
4. `SELECT * FROM orders WHERE total > 100;` (no index — observe full scan)

### Exercise 3: Design Indexes
Create indexes for these common queries:
1. "Find all completed orders for a specific customer, sorted by date"
2. "Find all orders shipped to a specific city in a date range"
3. "Get the total revenue per status"

### Exercise 4: Covering Index
1. Create a covering index for: `SELECT customer_id, order_date FROM orders WHERE status = 'completed'`
2. Verify with EXPLAIN that it shows "Using index"

---

## 🧠 Key Takeaways

- **CREATE INDEX** adds an index to an existing table
- **Composite indexes** follow the **leftmost prefix rule** — order matters
- **EXPLAIN** shows which index MySQL uses and how many rows it examines
- **Covering index** (Extra: "Using index") = query served from index alone (fastest)
- **UNIQUE index** enforces uniqueness + provides fast lookup
- Avoid **redundant indexes** — a composite `(A, B)` already supports `A`-only queries
- Run **ANALYZE TABLE** after bulk data changes to update index statistics
- Index **TEXT/BLOB** columns with a prefix length: `INDEX(col(50))`

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 14: How Indexes Work (Theory) →](./lesson-14-indexes-theory.md)
**Next:** [Lesson 16: Transactions & ACID →](./lesson-16-transactions.md)
