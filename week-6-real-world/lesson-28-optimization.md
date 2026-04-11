# Lesson 28: Query Optimization Techniques

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 10:00:00 – 10:45:00 | 45 min |

## 📖 Theory

### Query Optimization Principles

Writing fast SQL queries is both an art and a science. The goal is to get the correct result while minimizing the work MySQL has to do.

### Key Principles

| Principle | Description |
|-----------|-------------|
| **Use indexes** | The #1 way to speed up queries |
| **Select only needed columns** | `SELECT *` wastes I/O and memory |
| **Filter early** | WHERE before JOIN when possible |
| **Avoid functions on indexed columns** | Prevents index usage |
| **Use LIMIT** | Don't fetch more rows than needed |
| **Prefer JOINs to subqueries** | MySQL optimizes JOINs better |
| **Use EXISTS instead of IN** | For existence checks, EXISTS is faster |
| **Avoid SELECT DISTINCT unless needed** | DISTINCT requires sorting/dedup |

### The Query Execution Order

```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

MySQL does NOT execute in the order you write. It:
1. Gets tables and joins them
2. Filters rows (WHERE)
3. Groups rows (GROUP BY)
4. Filters groups (HAVING)
5. Computes SELECT expressions
6. Sorts (ORDER BY)
7. Truncates (LIMIT)

### Index Strategy for Queries

| Query Pattern | Best Index |
|--------------|-----------|
| `WHERE a = ?` | `(a)` |
| `WHERE a = ? AND b = ?` | `(a, b)` or `(b, a)` |
| `WHERE a = ? ORDER BY b` | `(a, b)` |
| `WHERE a > ? AND a < ?` | `(a)` |
| `WHERE a = ? AND b > ?` | `(a, b)` |
| `GROUP BY a` | `(a)` |
| `ORDER BY a DESC LIMIT 10` | `(a)` |

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS optimization_db;
USE optimization_db;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20),
    total DECIMAL(10,2),
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(20),
    notes TEXT
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(20),
    signup_date DATE
);

-- Generate larger dataset
INSERT INTO customers (first_name, last_name, email, city, state, signup_date)
SELECT
    CONCAT('User', seq),
    CONCAT('Lastname', seq),
    CONCAT('user', seq, '@email.com'),
    ELT(1 + (seq % 5), 'New York', 'London', 'Tokyo', 'Paris', 'Berlin'),
    ELT(1 + (seq % 5), 'NY', 'UK', 'JP', 'FR', 'DE'),
    DATE_SUB(CURDATE(), INTERVAL (seq * 3) DAY)
FROM (
    SELECT @row := @row + 1 AS seq
    FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a,
         (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b,
         (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c,
         (SELECT @row := 0) init
) nums;
-- 125 customers

INSERT INTO orders (customer_id, order_date, status, total, shipping_city, shipping_state)
SELECT
    1 + (seq % 125),
    DATE_SUB(CURDATE(), INTERVAL (seq * 2) DAY),
    ELT(1 + (seq % 4), 'pending', 'completed', 'shipped', 'delivered'),
    ROUND(10 + RAND() * 990, 2),
    ELT(1 + (seq % 5), 'New York', 'London', 'Tokyo', 'Paris', 'Berlin'),
    ELT(1 + (seq % 5), 'NY', 'UK', 'JP', 'FR', 'DE')
FROM (
    SELECT @row := @row + 1 AS seq
    FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a,
         (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b,
         (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c,
         (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d,
         (SELECT @row := 0) init
) nums;
-- 625 orders
```

### Example 1: SELECT * vs Specific Columns

```sql
-- ❌ SLOW: Fetches all columns including TEXT notes
EXPLAIN SELECT * FROM orders WHERE status = 'completed' LIMIT 10;
-- All columns read from disk

-- ✅ FAST: Only fetch what you need
EXPLAIN SELECT order_id, order_date, total FROM orders WHERE status = 'completed' LIMIT 10;
-- Less I/O, less memory, less network
```

### Example 2: Function on Indexed Column

```sql
-- Without index on YEAR(order_date) — can't index a function
CREATE INDEX idx_order_date ON orders(order_date);

-- ❌ SLOW: YEAR() prevents index usage
EXPLAIN SELECT * FROM orders WHERE YEAR(order_date) = 2024;
-- type: ALL (full scan)

-- ✅ FAST: Use range comparison on the raw column
EXPLAIN SELECT * FROM orders
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';
-- type: range (uses index)
```

### Example 3: EXISTS vs IN

```sql
-- IN: Subquery runs first, creates a list, then checks
EXPLAIN SELECT * FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE total > 500);

-- EXISTS: Stops at first match (short-circuits)
EXPLAIN SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.total > 500);

-- EXISTS is typically faster for large subquery results
```

### Example 4: JOIN vs Subquery

```sql
-- ❌ SLOWER: Subquery in SELECT (runs for every row)
EXPLAIN SELECT
    c.first_name,
    (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count
FROM customers c;

-- ✅ FASTER: JOIN with GROUP BY
EXPLAIN SELECT
    c.first_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name;
```

### Example 5: Composite Index for Multi-Condition Query

```sql
-- Common query:
EXPLAIN SELECT order_id, total, order_date
FROM orders
WHERE status = 'completed' AND shipping_state = 'NY'
ORDER BY order_date DESC;
-- Without proper index: type: ALL, Extra: Using filesort

-- Optimal index:
CREATE INDEX idx_status_state_date ON orders(status, shipping_state, order_date);

EXPLAIN SELECT order_id, total, order_date
FROM orders
WHERE status = 'completed' AND shipping_state = 'NY'
ORDER BY order_date DESC;
-- type: ref, Extra: Using index (if covering) or Using where (filtering)
```

### Example 6: LIMIT Optimization

```sql
-- ❌ SLOW: Fetches all matching rows, then sorts, then returns 10
EXPLAIN SELECT order_id, total FROM orders ORDER BY total DESC;
-- Examines all 625 rows

-- ✅ FAST: Uses index + LIMIT
EXPLAIN SELECT order_id, total FROM orders ORDER BY total DESC LIMIT 10;
-- MySQL stops after finding 10 rows

-- Best: with index
CREATE INDEX idx_total ON orders(total DESC);
EXPLAIN SELECT order_id, total FROM orders ORDER BY total DESC LIMIT 10;
-- Uses index, no filesort needed
```

### Example 7: Avoiding OR — Use UNION

```sql
-- ❌ SLOWER: OR can prevent index usage
EXPLAIN SELECT * FROM orders WHERE status = 'completed' OR shipping_city = 'New York';
-- MySQL may do full scan because of OR

-- ✅ FASTER: UNION of two indexed queries
EXPLAIN
SELECT * FROM orders WHERE status = 'completed'
UNION
SELECT * FROM orders WHERE shipping_city = 'New York';
-- Each part can use its own index
```

---

## ⚠️ Common Mistakes

### Mistake 1: SELECT * in Production

```sql
-- ❌ WRONG: Wasteful, especially with TEXT/BLOB columns
SELECT * FROM orders WHERE order_id = 1;

-- ✅ CORRECT: Only select what you need
SELECT order_id, order_date, total, status FROM orders WHERE order_id = 1;
```

### Mistake 2: Wildcard LIKE at Start

```sql
-- ❌ SLOW: Leading wildcard prevents index use
SELECT * FROM customers WHERE email LIKE '%@gmail.com';
-- Full scan: must check every email

-- ✅ CORRECT: Prefix match uses index
SELECT * FROM customers WHERE email LIKE 'john@%';
-- Index can start from 'john@'
```

### Mistake 3: Using IN with Too Many Values

```sql
-- ❌ SLOW: IN with hundreds of values
SELECT * FROM orders WHERE customer_id IN (1, 2, 3, ..., 500);

-- ✅ BETTER: Use a temp table or JOIN
CREATE TEMPORARY TABLE target_customers (customer_id INT PRIMARY KEY);
INSERT INTO target_customers VALUES (1), (2), (3), ..., (500);

SELECT o.* FROM orders o
JOIN target_customers t ON o.customer_id = t.customer_id;
```

### Mistake 4: Not Using LIMIT

```sql
-- ❌ DANGEROUS: Could return millions of rows
SELECT * FROM orders WHERE status = 'completed';

-- ✅ SAFE: Always limit results
SELECT * FROM orders WHERE status = 'completed' LIMIT 1000;
```

---

## ✅ Exercises

### Exercise 1: Optimize These Queries
For each slow query, identify the problem and fix it:
1. `SELECT * FROM orders WHERE DATE(order_date) = '2024-06-01';`
2. `SELECT first_name, last_name FROM customers WHERE CONCAT(first_name, ' ', last_name) = 'Alice Smith';`
3. `SELECT * FROM orders WHERE total + 10 > 500;`

### Exercise 2: Index Design
Design the optimal index for:
1. `WHERE status = 'completed' ORDER BY order_date DESC LIMIT 10`
2. `WHERE shipping_city = 'New York' AND shipping_state = 'NY'`
3. `WHERE customer_id = 5 AND status = 'completed' ORDER BY order_date`

### Exercise 3: Rewrite Queries
Rewrite these for better performance:
1. A query using IN with a large subquery → use EXISTS
2. A query with subquery in SELECT → use JOIN
3. A query with OR → use UNION

---

## 🧠 Key Takeaways

- **Select only needed columns** — avoid SELECT *
- **Never use functions on indexed columns** in WHERE — rewrite as range queries
- **EXISTS** is faster than IN for existence checks
- **JOINs** are faster than subqueries in SELECT
- **Composite indexes** should match the WHERE + ORDER BY pattern
- **UNION** can be faster than OR (each part uses its own index)
- **Always use LIMIT** — especially on user-facing queries
- **Leading wildcards** (`%abc`) prevent index usage
- **EXPLAIN** before and after optimization to measure improvement
- **Test with realistic data volumes** — 100 rows behave differently than 1 million

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 27: EXPLAIN & Query Performance →](./lesson-27-explain.md)
**Next:** [Lesson 29: Storage Engines & Architecture →](./lesson-29-storage-engines.md)
