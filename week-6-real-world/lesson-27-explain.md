# Lesson 27: EXPLAIN & Query Performance

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 9:15:00 – 10:00:00 | 45 min |

## 📖 Theory

### What is EXPLAIN?

`EXPLAIN` shows how MySQL **executes** a query without actually running it. It reveals which indexes are used, how tables are joined, and where the bottlenecks are.

```sql
EXPLAIN SELECT * FROM users WHERE email = 'test@test.com';
```

### EXPLAIN Output Columns

| Column | Meaning | Good | Bad |
|--------|---------|------|-----|
| **id** | Query block number | — | Higher = subquery |
| **select_type** | Type of SELECT | SIMPLE | DEPENDENT SUBQUERY |
| **table** | Table being read | — | — |
| **type** | Join/access type | const, ref | ALL (full scan) |
| **possible_keys** | Indexes MySQL could use | Listed | NULL |
| **key** | Index actually used | Name shown | NULL |
| **key_len** | Length of key used | Shorter = tighter | Longer = more bytes |
| **ref** | Columns/constants compared to key | const | func |
| **rows** | Estimated rows examined | Low | High |
| **filtered** | % of rows that pass filter | High | Low |
| **Extra** | Additional info | Using index | Using filesort, Using temporary |

### Access Types (Best to Worst)

| Type | Description | When |
|------|-------------|------|
| **const** | Single row lookup (PK or UNIQUE) | `WHERE id = 5` |
| **eq_ref** | One row per row from previous table (PK/UNIQUE JOIN) | PK JOIN |
| **ref** | Index lookup, may match multiple rows | `WHERE email = 'x'` |
| **range** | Index range scan | `WHERE id BETWEEN 1 AND 100` |
| **index** | Full index scan (no WHERE, but sorted) | `SELECT * FROM t ORDER BY indexed_col` |
| **ALL** | Full table scan | No usable index |

### Extra Column Values

| Value | Meaning | Performance |
|-------|---------|-------------|
| `Using index` | Covering index — no table access | ⭐ Best |
| `Using where` | Filtering with WHERE | ✅ Good |
| `Using index condition` | Index condition pushdown | ✅ Good |
| `Using filesort` | Sorting outside index | ⚠️ Could be better |
| `Using temporary` | Temporary table created | ⚠️ Slow |
| `Using join buffer` | No index for join — buffering | ❌ Bad |
| `Select tables optimized away` | MIN/MAX from index | ⭐ Best |
| `Impossible WHERE` | No rows can match | — |

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS explain_db;
USE explain_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert sample data
INSERT INTO customers (first_name, last_name, email, city, state)
VALUES
    ('Alice', 'Smith', 'alice@email.com', 'New York', 'NY'),
    ('Bob', 'Johnson', 'bob@email.com', 'Los Angeles', 'CA'),
    ('Carol', 'Williams', 'carol@email.com', 'Chicago', 'IL'),
    ('David', 'Brown', 'david@email.com', 'Houston', 'TX'),
    ('Eve', 'Davis', 'eve@email.com', 'Phoenix', 'AZ');

INSERT INTO orders (customer_id, order_date, total, status)
VALUES
    (1, '2024-01-15', 150.00, 'completed'),
    (1, '2024-03-20', 75.50, 'completed'),
    (2, '2024-02-10', 200.00, 'shipped'),
    (3, '2024-04-05', 50.00, 'pending'),
    (4, '2024-05-12', 300.00, 'completed');
```

### Example 1: Full Table Scan vs Index Lookup

```sql
-- No index on email yet:
EXPLAIN SELECT * FROM customers WHERE email = 'alice@email.com';
-- type: ALL (full scan), rows: 5, possible_keys: NULL, key: NULL

-- Add index:
CREATE INDEX idx_email ON customers(email);

-- Same query with index:
EXPLAIN SELECT * FROM customers WHERE email = 'alice@email.com';
-- type: const, rows: 1, key: idx_email, Extra: (none)
```

### Example 2: Primary Key Lookup (Best Case)

```sql
EXPLAIN SELECT * FROM customers WHERE customer_id = 1;
-- type: const, rows: 1, key: PRIMARY
-- This is the fastest possible query
```

### Example 3: Range Scan

```sql
-- Without index on order_date:
EXPLAIN SELECT * FROM orders WHERE order_date > '2024-03-01';
-- type: ALL (full scan), rows: 5

-- Add index:
CREATE INDEX idx_order_date ON orders(order_date);

EXPLAIN SELECT * FROM orders WHERE order_date > '2024-03-01';
-- type: range, rows: 3, key: idx_order_date
```

### Example 4: JOIN Performance

```sql
-- Without index on orders.customer_id (FK has one by default):
EXPLAIN
SELECT c.first_name, c.last_name, o.order_id, o.total
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'New York';

-- Look at:
-- 1. customers: type = ALL or ref (city filter)
-- 2. orders: type = ref (customer_id FK lookup)
-- rows multiplied = total examined
```

### Example 5: Filesort and Temporary

```sql
-- Filesort: sorting without index
EXPLAIN SELECT * FROM customers ORDER BY last_name;
-- Extra: Using filesort (MySQL sorts in memory/disk)

-- Fix: Add index on sort column
CREATE INDEX idx_last_name ON customers(last_name);

EXPLAIN SELECT * FROM customers ORDER BY last_name;
-- Extra: (no filesort — uses index order)

-- Temporary: GROUP BY without index
EXPLAIN SELECT city, COUNT(*) FROM customers GROUP BY city;
-- Extra: Using temporary

-- Fix: Index the GROUP BY column
CREATE INDEX idx_city ON customers(city);
```

### Example 6: Covering Index

```sql
-- Covering index: all columns in query are in the index
CREATE INDEX idx_city_name ON customers(city, first_name, last_name);

EXPLAIN SELECT city, first_name, last_name FROM customers WHERE city = 'New York';
-- Extra: Using index  ← Covering index! No table access needed
```

### Example 7: Subquery Analysis

```sql
EXPLAIN SELECT * FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE total > 100);
-- Look for:
-- select_type: PRIMARY and DEPENDENT SUBQUERY or SUBQUERY
-- DEPENDENT SUBQUERY = re-evaluated per outer row (slow)
```

### Example 8: EXPLAIN FORMAT=JSON

```sql
-- More detailed output:
EXPLAIN FORMAT=JSON
SELECT c.first_name, COUNT(o.order_id) AS orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name;

-- Shows cost estimates, optimization details, and attached conditions
```

---

## ⚠️ Common Mistakes

### Mistake 1: Ignoring EXPLAIN

```sql
-- ❌ WRONG: Writing queries without checking performance
SELECT * FROM orders WHERE status = 'completed' AND customer_id = 1;
-- No index on (status, customer_id) — full scan

-- ✅ CORRECT: Use EXPLAIN to verify
EXPLAIN SELECT * FROM orders WHERE status = 'completed' AND customer_id = 1;
-- If type: ALL → create composite index
CREATE INDEX idx_status_customer ON orders(status, customer_id);
```

### Mistake 2: Misreading Rows Estimate

```sql
-- ⚠️ The 'rows' column is an ESTIMATE, not exact
EXPLAIN SELECT * FROM large_table WHERE id = 1;
-- rows: 1  (actual may vary)

-- Always run the actual query with timing:
SET profiling = 1;
SELECT * FROM large_table WHERE id = 1;
SHOW PROFILES;
```

### Mistake 3: Adding Indexes for Everything EXPLAIN Shows

```sql
-- ❌ WRONG: EXPLAIN says "ALL" on a 10-row table — full scan is fine!
-- EXPLAIN SELECT * FROM small_table WHERE name = 'test';
-- type: ALL

-- A table scan on 10 rows is faster than an index lookup
-- Don't optimize prematurely!
```

### Mistake 4: Not Analyzing the Full Query

```sql
-- ⚠️ EXPLAIN only analyzes the SELECT, not the actual execution
EXPLAIN SELECT * FROM orders WHERE customer_id = 1;
-- Shows index usage, but doesn't include:
-- - Network transfer time
-- - Client-side processing
-- - Lock wait time

-- For full performance profiling, use:
SET profiling = 1;
SELECT * FROM orders WHERE customer_id = 1;
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

---

## ✅ Exercises

### Exercise 1: Read EXPLAIN Output
For each EXPLAIN result, identify: access type, key used, rows examined, and any warnings.

### Exercise 2: Optimize Queries
Given these slow queries, use EXPLAIN to diagnose and add indexes:
1. `SELECT * FROM customers WHERE state = 'NY' AND city = 'New York';`
2. `SELECT * FROM orders ORDER BY order_date DESC LIMIT 10;`
3. `SELECT c.email, COUNT(o.order_id) FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.email;`

### Exercise 3: Identify Problems
Run EXPLAIN on these and identify the performance issues:
1. A query using `LIKE '%abc%'` (what type? what Extra?)
2. A subquery in WHERE (what select_type?)
3. A GROUP BY without index (what Extra?)

---

## 🧠 Key Takeaways

- **EXPLAIN** shows query execution plan without running the query
- **type**: const > ref > range > index > ALL (ALL = worst)
- **rows**: estimated rows examined — lower is better
- **Extra: Using index** = covering index (fastest)
- **Extra: Using filesort** = sorting without index benefit
- **Extra: Using temporary** = intermediate table created (slow)
- Always **EXPLAIN before and after** adding indexes
- `EXPLAIN FORMAT=JSON` gives more detail including cost estimates
- Don't over-optimize small tables — full scans on tiny tables are fine
- Run actual queries with timing for real-world performance data

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 26: SQL Injection & Prevention →](./lesson-26-sql-injection.md)
**Next:** [Lesson 28: Query Optimization Techniques →](./lesson-28-optimization.md)
