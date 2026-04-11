# Lesson 05: INSERT Advanced

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟧 Bro Code | 50:00 – 1:10:00 | 20 min |
| 🟩 Brototype | 1:00:00 – 1:20:00 | 20 min |

## 📖 Theory

In Lesson 03, you learned the basics of `INSERT` — adding one row at a time. In this lesson, we go deeper: multi-row inserts, `INSERT ... SELECT`, bulk insert performance, and advanced patterns.

### Multi-Row INSERT

You can insert multiple rows in a single `INSERT` statement by providing multiple value tuples:

```sql
INSERT INTO table_name (col1, col2, col3)
VALUES
    (val1a, val2a, val3a),
    (val1b, val2b, val3b),
    (val1c, val2c, val3c);
```

This is **significantly faster** than running multiple single-row `INSERT` statements because:
- Only **one network round-trip** instead of many
- Only **one transaction** overhead
- Only **one index rebuild** instead of one per row
- The server parses the statement **once**

### INSERT ... SELECT

You can insert the result of a `SELECT` query directly into a table:

```sql
INSERT INTO target_table (col1, col2, col3)
SELECT col1, col2, col3
FROM source_table
WHERE condition;
```

This is extremely useful for:
- **Copying data** between tables
- **Archiving** old records
- **Transforming** data before inserting
- **Populating** summary/aggregation tables

### INSERT with DEFAULT Values

When columns have `DEFAULT` values or are `AUTO_INCREMENT`, you can omit them or use the `DEFAULT` keyword:

```sql
-- Omit columns with defaults
INSERT INTO customers (first_name, last_name)
VALUES ('John', 'Doe');

-- Explicitly use DEFAULT
INSERT INTO customers (first_name, last_name, points)
VALUES ('John', 'Doe', DEFAULT);
```

### INSERT IGNORE and ON DUPLICATE KEY

When inserting, duplicate primary key or unique key values cause errors. MySQL provides ways to handle this:

```sql
-- Skip rows that would cause duplicate key errors
INSERT IGNORE INTO customers (customer_id, first_name, last_name)
VALUES (1, 'John', 'Doe');

-- Update existing row on duplicate key
INSERT INTO customers (customer_id, first_name, last_name, points)
VALUES (1, 'John', 'Doe', 100)
ON DUPLICATE KEY UPDATE points = points + 100;
```

> **Note:** `INSERT IGNORE` and `ON DUPLICATE KEY UPDATE` are MySQL-specific extensions, not standard SQL.

---

## 💻 Examples

### Setup: Create Tables

```sql
CREATE DATABASE IF NOT EXISTS store;
USE store;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    points INT DEFAULT 0,
    city VARCHAR(50),
    state VARCHAR(20),
    birth_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE archived_customers (
    archive_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    points INT,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE high_value_customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    points INT,
    state VARCHAR(20)
);
```

### Example 1: Multi-Row INSERT

```sql
-- Insert 8 customers in one statement
INSERT INTO customers (first_name, last_name, email, points, city, state, birth_date)
VALUES
    ('John', 'Smith', 'john@email.com', 100, 'New York', 'NY', '1990-01-15'),
    ('Jane', 'Doe', 'jane@email.com', 250, 'Los Angeles', 'CA', '1985-03-22'),
    ('Bob', 'Johnson', 'bob@email.com', 50, 'Chicago', 'IL', '1992-07-10'),
    ('Alice', 'Williams', 'alice@email.com', 500, 'Houston', 'TX', '1988-11-30'),
    ('Charlie', 'Brown', 'charlie@email.com', 0, 'Phoenix', 'AZ', '1995-05-18'),
    ('Diana', 'Ross', 'diana@email.com', 1000, 'Miami', 'FL', '1980-12-25'),
    ('Eve', 'Davis', 'eve@email.com', 300, 'San Francisco', 'CA', '1993-08-05'),
    ('Frank', 'Miller', 'frank@email.com', 75, 'Dallas', 'TX', '1987-04-12');

-- Verify
SELECT COUNT(*) AS 'Total Customers' FROM customers;
-- Result: 8
```

### Example 2: INSERT ... SELECT (Copy Data)

```sql
-- Archive all customers from California
INSERT INTO archived_customers (customer_id, first_name, last_name, points)
SELECT customer_id, first_name, last_name, points
FROM customers
WHERE state = 'CA';

-- Verify the archive
SELECT * FROM archived_customers;
```

### Example 3: INSERT ... SELECT with Aggregation

```sql
-- Populate high_value_customers table (points > 200)
INSERT INTO high_value_customers (customer_id, first_name, last_name, points, state)
SELECT customer_id, first_name, last_name, points, state
FROM customers
WHERE points > 200;

-- Check results
SELECT * FROM high_value_customers;
```

### Example 4: INSERT with DEFAULT Values

```sql
-- Use DEFAULT for the points column
INSERT INTO customers (first_name, last_name, email, points)
VALUES ('Grace', 'Wilson', 'grace@email.com', DEFAULT);

-- Omit columns entirely (they get their defaults)
INSERT INTO customers (first_name, last_name, email)
VALUES ('Henry', 'Taylor', 'henry@email.com');

-- Both will have points = 0 (the DEFAULT value)
SELECT first_name, last_name, points FROM customers
WHERE first_name IN ('Grace', 'Henry');
```

### Example 5: INSERT IGNORE

```sql
-- This will fail (duplicate email)
-- INSERT INTO customers (first_name, last_name, email)
-- VALUES ('Ivan', 'Test', 'john@email.com');
-- Error: Duplicate entry 'john@email.com' for key 'email'

-- INSERT IGNORE silently skips the duplicate
INSERT IGNORE INTO customers (first_name, last_name, email)
VALUES ('Ivan', 'Test', 'john@email.com');
-- Query OK, 0 rows affected, 1 warning

-- Check for warnings
SHOW WARNINGS;
```

### Example 6: ON DUPLICATE KEY UPDATE (UPSERT)

```sql
-- Insert a new customer, or update points if email already exists
INSERT INTO customers (first_name, last_name, email, points)
VALUES ('John', 'Smith-Updated', 'john@email.com', 200)
ON DUPLICATE KEY UPDATE
    first_name = VALUES(first_name),
    last_name = VALUES(last_name),
    points = points + VALUES(points);

-- Check: John's points should now be 100 + 200 = 300
SELECT * FROM customers WHERE email = 'john@email.com';
```

### Example 7: Bulk Insert Performance Demonstration

```sql
-- Method 1: Multiple single-row inserts (SLOW)
-- INSERT INTO customers (first_name, last_name, email) VALUES ('A', 'Test', 'a1@email.com');
-- INSERT INTO customers (first_name, last_name, email) VALUES ('B', 'Test', 'b2@email.com');
-- ... (repeat 100 times)

-- Method 2: Single multi-row insert (FAST)
INSERT INTO customers (first_name, last_name, email)
VALUES
    ('Bulk1', 'User', 'bulk1@email.com'),
    ('Bulk2', 'User', 'bulk2@email.com'),
    ('Bulk3', 'User', 'bulk3@email.com'),
    ('Bulk4', 'User', 'bulk4@email.com'),
    ('Bulk5', 'User', 'bulk5@email.com');
-- ... add as many as needed in one statement

-- For truly large inserts (10,000+ rows), consider:
-- 1. Disabling keys temporarily: ALTER TABLE customers DISABLE KEYS;
-- 2. Inserting in batches of 1,000-10,000 rows
-- 3. Re-enabling keys: ALTER TABLE customers ENABLE KEYS;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Forgetting Column Order in Multi-Row Inserts

```sql
-- ❌ WRONG: values don't match column order
INSERT INTO customers (first_name, last_name, email, points)
VALUES
    ('john@email.com', 'John', 'Smith', 100);

-- ✅ CORRECT: values match column order
INSERT INTO customers (first_name, last_name, email, points)
VALUES
    ('John', 'Smith', 'john@email.com', 100);
```

### Mistake 2: Exceeding max_allowed_packet with Huge Multi-Row Inserts

```sql
-- ❌ WRONG: trying to insert 100,000 rows in one statement
-- May fail with "Packet too large" error

-- ✅ CORRECT: batch into chunks of 1,000-10,000
INSERT INTO customers (first_name, last_name, email) VALUES
    ('A1', 'User', 'a1@email.com'),
    -- ... up to 1000 rows
    ('A1000', 'User', 'a1000@email.com');

-- Then run another INSERT for the next batch
```

### Mistake 3: Using INSERT IGNORE Without Checking Warnings

```sql
-- ❌ WRONG: ignoring duplicates without checking
INSERT IGNORE INTO customers (first_name, last_name, email)
VALUES ('John', 'Doe', 'existing@email.com');
-- (Silently fails, no data inserted)

-- ✅ CORRECT: check for warnings
INSERT IGNORE INTO customers (first_name, last_name, email)
VALUES ('John', 'Doe', 'existing@email.com');
SHOW WARNINGS;
```

### Mistake 4: Mismatched Columns in INSERT ... SELECT

```sql
-- ❌ WRONG: column count mismatch
INSERT INTO archived_customers (customer_id, first_name, last_name)
SELECT customer_id, first_name, last_name, points, state
FROM customers
WHERE points > 500;
-- Error: Column count doesn't match value count

-- ✅ CORRECT: match the columns
INSERT INTO archived_customers (customer_id, first_name, last_name, points)
SELECT customer_id, first_name, last_name, points
FROM customers
WHERE points > 500;
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS inventory_db;
USE inventory_db;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 0,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE discounted_products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    original_price DECIMAL(10,2),
    discount_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2)
);

CREATE TABLE product_archive (
    archive_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    name VARCHAR(100),
    price DECIMAL(10,2),
    quantity INT,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Exercise 1: Multi-Row Insert

Insert 12 products into the `products` table using a single `INSERT` statement. Include products across at least 4 different categories with varying prices and quantities.

### Exercise 2: INSERT ... SELECT with Transformation

Create a `discounted_products` entry for all products where `price > 50`. The discount should be 15% off the original price. Use `INSERT ... SELECT` to populate the table.

### Exercise 3: Conditional Archiving

Use `INSERT ... SELECT` to archive all products with `quantity < 5` into the `product_archive` table. Then verify the archive contents.

### Exercise 4: ON DUPLICATE KEY UPDATE

1. Insert a new product with `product_id = 1`.
2. Then try to insert another product with the same `product_id = 1` but different data, using `ON DUPLICATE KEY UPDATE` to update the price and quantity instead.
3. Verify the final state of the row.

### Exercise 5: Batch Insert Challenge

Generate and insert 50 products using multi-row `INSERT` statements in batches of 10 (five `INSERT` statements total). Use systematic names like 'Product-1', 'Product-2', etc.

---

## 🧠 Key Takeaways

- **Multi-row INSERT** is much faster than multiple single-row inserts due to reduced overhead
- **INSERT ... SELECT** lets you copy and transform data in a single operation
- Always **match column counts** between INSERT and SELECT — mismatches cause errors
- **INSERT IGNORE** silently skips duplicate key errors (check warnings!)
- **ON DUPLICATE KEY UPDATE** (upsert) inserts or updates in one atomic operation
- For **bulk inserts**, batch your data (1,000-10,000 rows per statement) to avoid `max_allowed_packet` errors
- Use **DEFAULT** keyword to explicitly use a column's default value
- `VALUES(col)` in `ON DUPLICATE KEY UPDATE` refers to the value that was attempted to be inserted

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 04: WHERE Clause Deep Dive →](../../week-1-sql-basics/lesson-04-where.md)
**Next:** [Lesson 06: UPDATE →](./lesson-06-update.md)
