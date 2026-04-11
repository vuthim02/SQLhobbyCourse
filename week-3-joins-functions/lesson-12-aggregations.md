# Lesson 12: Aggregate Functions & GROUP BY

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 3:10:00 – 3:30:00 | 20 min |
| 🟧 Bro Code | 4:00:00 – 4:25:00 | 25 min |
| 🟩 Brototype | 2:50:00 – 3:10:00 | 20 min |

## 📖 Theory

### Aggregate Functions

**Aggregate functions** perform a calculation on a set of values and return a single result. They are essential for summarizing and analyzing data.

| Function | Description | Ignores NULL? |
|----------|-------------|---------------|
| `COUNT()` | Counts rows | Yes (COUNT(*), counts NULLs) |
| `SUM()` | Adds values | Yes |
| `AVG()` | Calculates average | Yes |
| `MIN()` | Finds minimum value | Yes |
| `MAX()` | Finds maximum value | Yes |

### Basic Aggregation

```sql
SELECT COUNT(*) AS total_customers FROM customers;
SELECT AVG(points) AS avg_points FROM customers;
SELECT MAX(points) AS highest_points FROM customers;
SELECT MIN(points) AS lowest_points FROM customers;
SELECT SUM(points) AS total_points FROM customers;
```

### GROUP BY

**GROUP BY** divides rows into groups based on column values, allowing aggregates to be calculated per group.

```sql
SELECT state, COUNT(*) AS customer_count, AVG(points) AS avg_points
FROM customers
GROUP BY state;
```

The execution order is:
1. `FROM` — get the table
2. `WHERE` — filter rows
3. `GROUP BY` — divide into groups
4. `SELECT` — compute aggregates for each group
5. `ORDER BY` — sort results
6. `HAVING` — filter groups (covered next lesson)

### Rules for GROUP BY

- Every column in the `SELECT` that is **not** inside an aggregate function **must** appear in the `GROUP BY`
- You can group by multiple columns for hierarchical grouping
- You can group by column positions: `GROUP BY 1` (1st column), `GROUP BY 1, 2` (not recommended for readability)

### Multiple Aggregates in One Query

```sql
SELECT
    state,
    COUNT(*) AS customer_count,
    SUM(points) AS total_points,
    AVG(points) AS avg_points,
    MIN(points) AS min_points,
    MAX(points) AS max_points
FROM customers
GROUP BY state
ORDER BY avg_points DESC;
```

### Aggregating with DISTINCT

```sql
-- Count unique cities (not total customers)
SELECT COUNT(DISTINCT city) AS unique_cities FROM customers;

-- Sum only distinct point values
SELECT SUM(DISTINCT points) FROM customers;
```

### Handling NULL in Aggregates

```sql
-- COUNT(*) counts ALL rows including those with NULLs
-- COUNT(column) counts only non-NULL values
SELECT
    COUNT(*) AS total_rows,
    COUNT(phone) AS customers_with_phone,
    COUNT(*) - COUNT(phone) AS customers_without_phone
FROM customers;
```

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS analytics_db;
USE analytics_db;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total DECIMAL(10,2),
    status VARCHAR(20),
    region VARCHAR(20),
    salesperson VARCHAR(50)
);

INSERT INTO orders (customer_id, order_date, total, status, region, salesperson)
VALUES
    (1, '2024-01-15', 150.00, 'completed', 'North', 'Alice'),
    (1, '2024-02-20', 75.50, 'completed', 'North', 'Alice'),
    (2, '2024-01-10', 200.00, 'completed', 'South', 'Bob'),
    (3, '2024-03-05', 50.00, 'pending', 'East', 'Carol'),
    (4, '2024-02-28', 300.00, 'completed', 'West', 'David'),
    (4, '2024-04-12', 120.00, 'completed', 'West', 'David'),
    (5, '2024-03-18', 85.00, 'cancelled', 'North', 'Alice'),
    (6, '2024-04-01', 250.00, 'completed', 'South', 'Bob'),
    (7, '2024-05-10', 175.00, 'pending', 'East', 'Carol'),
    (8, '2024-05-15', 90.00, 'completed', NULL, 'Alice'),
    (9, '2024-06-01', 310.00, 'completed', 'West', 'David'),
    (10, '2024-06-20', 45.00, 'pending', 'North', NULL);
```

### Example 1: Basic Aggregate Functions

```sql
SELECT
    COUNT(*) AS total_orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order_value,
    MIN(total) AS smallest_order,
    MAX(total) AS largest_order
FROM orders
WHERE status = 'completed';
```

### Example 2: GROUP BY Single Column

```sql
-- Orders and revenue per region
SELECT
    region,
    COUNT(*) AS order_count,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_order_value
FROM orders
WHERE region IS NOT NULL
GROUP BY region
ORDER BY total_revenue DESC;
```

### Example 3: GROUP BY Multiple Columns

```sql
-- Revenue per region per salesperson
SELECT
    region,
    salesperson,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    ROUND(AVG(total), 2) AS avg_order
FROM orders
WHERE region IS NOT NULL AND salesperson IS NOT NULL
GROUP BY region, salesperson
ORDER BY region, revenue DESC;
```

### Example 4: GROUP BY with Date

```sql
-- Monthly revenue
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS order_count,
    SUM(total) AS revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Orders per status
SELECT
    status,
    COUNT(*) AS count,
    ROUND(AVG(total), 2) AS avg_total
FROM orders
GROUP BY status
ORDER BY count DESC;
```

### Example 5: COUNT Variations

```sql
SELECT
    COUNT(*) AS total_rows,           -- All rows
    COUNT(total) AS rows_with_total,  -- Non-NULL totals
    COUNT(DISTINCT region) AS unique_regions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT salesperson) AS unique_salespeople
FROM orders;
```

### Example 6: GROUP BY with HAVING (Preview)

```sql
-- Find salespeople with total revenue > $300
SELECT
    salesperson,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
WHERE salesperson IS NOT NULL
GROUP BY salesperson
HAVING SUM(total) > 300
ORDER BY revenue DESC;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Mixing Aggregates and Non-Aggregated Columns

```sql
-- ❌ WRONG: customer_id not in GROUP BY
SELECT customer_id, COUNT(*) AS orders
FROM orders
GROUP BY region;

-- ✅ CORRECT: Group by the column you're selecting
SELECT region, COUNT(*) AS orders
FROM orders
GROUP BY region;
```

### Mistake 2: Using WHERE with Aggregates

```sql
-- ❌ WRONG: WHERE cannot filter on aggregate results
SELECT region, SUM(total) AS revenue
FROM orders
WHERE SUM(total) > 200
GROUP BY region;

-- ✅ CORRECT: Use HAVING for aggregate filtering
SELECT region, SUM(total) AS revenue
FROM orders
GROUP BY region
HAVING SUM(total) > 200;
```

### Mistake 3: Forgetting GROUP BY When Using Aggregates

```sql
-- ❌ WRONG: Can't mix non-aggregated columns without GROUP BY
SELECT region, COUNT(*) AS orders FROM orders;

-- ✅ CORRECT: Add GROUP BY
SELECT region, COUNT(*) AS orders FROM orders GROUP BY region;
```

### Mistake 4: COUNT(*) vs COUNT(column)

```sql
-- ❌ WRONG if you want to count NULLs too: COUNT(region) skips NULLs
SELECT COUNT(region) FROM orders;
-- Returns 11 (excludes the 1 row where region IS NULL)

-- ✅ CORRECT for counting ALL rows: COUNT(*)
SELECT COUNT(*) FROM orders;
-- Returns 12 (includes all rows)
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS sales_analytics;
USE sales_analytics;

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    region VARCHAR(20),
    quantity INT,
    unit_price DECIMAL(10,2),
    sale_date DATE,
    salesperson VARCHAR(50)
);

INSERT INTO sales (product_name, category, region, quantity, unit_price, sale_date, salesperson)
VALUES
    ('Laptop', 'Electronics', 'North', 2, 999.99, '2024-01-15', 'Alice'),
    ('Mouse', 'Electronics', 'North', 10, 29.99, '2024-01-20', 'Alice'),
    ('Desk Chair', 'Furniture', 'South', 3, 249.99, '2024-02-10', 'Bob'),
    ('Monitor', 'Electronics', 'East', 5, 399.99, '2024-02-15', 'Carol'),
    ('Keyboard', 'Electronics', 'West', 8, 79.99, '2024-03-01', 'David'),
    ('Laptop', 'Electronics', 'South', 1, 999.99, '2024-03-10', 'Bob'),
    ('Notebook', 'Stationery', 'North', 50, 12.99, '2024-03-15', 'Alice'),
    ('Desk Lamp', 'Furniture', 'East', 4, 45.99, '2024-04-01', 'Carol'),
    ('Monitor', 'Electronics', 'North', 2, 399.99, '2024-04-10', 'Alice'),
    ('Pen Set', 'Stationery', 'West', 20, 8.99, '2024-04-20', 'David'),
    ('Laptop', 'Electronics', 'East', 3, 999.99, '2024-05-01', 'Carol'),
    ('Desk Chair', 'Furniture', 'North', 1, 249.99, '2024-05-15', 'Alice');
```

### Exercise 1: Basic Aggregates
1. Find total revenue (quantity × unit_price), average sale value, and number of sales
2. Find the most expensive single sale and the cheapest
3. Count how many different products were sold

### Exercise 2: GROUP BY Single Column
1. Calculate total revenue per category
2. Count the number of sales per region
3. Find the average unit price per product name

### Exercise 3: GROUP BY Multiple Columns
1. Calculate revenue per category per region
2. Count sales per salesperson per month
3. Find the total quantity sold per product per region

### Exercise 4: GROUP BY with Date Functions
1. Calculate monthly revenue (group by year-month)
2. Find which month had the highest total revenue
3. Count the number of unique products sold each month

---

## 🧠 Key Takeaways

- **Aggregate functions**: COUNT, SUM, AVG, MIN, MAX — reduce many rows to a single value
- **COUNT(*)** counts ALL rows; **COUNT(column)** skips NULLs
- **GROUP BY** divides rows into groups for per-group aggregation
- Every non-aggregated column in SELECT must be in GROUP BY
- You can group by **multiple columns** for hierarchical grouping
- **COUNT(DISTINCT column)** counts unique values
- Execution order: FROM → WHERE → GROUP BY → SELECT → ORDER BY

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 11: Multiple Joins & Self Joins →](./lesson-11-multi-joins.md)
**Next:** [Lesson 13: HAVING & Filtering Aggregates →](./lesson-13-having.md)
