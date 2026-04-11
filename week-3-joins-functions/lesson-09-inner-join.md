# Lesson 09: INNER JOIN

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 2:20:00 – 2:50:00 | 30 min |
| 🟧 Bro Code | 2:40:00 – 3:10:00 | 30 min |
| 🟩 Brototype | 1:50:00 – 2:15:00 | 25 min |

## 📖 Theory

### What is a JOIN?

A **JOIN** combines rows from two or more tables based on a related column between them. It is the most powerful feature of relational databases — it lets you reconstruct relationships that were split across tables for normalization.

### INNER JOIN

An **INNER JOIN** returns only the rows where **there is a match in BOTH tables**. It is the most commonly used join type.

```
Table A          Table B
┌────┬──────┐    ┌────┬──────┐
│ id │ name │    │ id │ city │
├────┼──────┤    ├────┼──────┤
│ 1  │ John │    │ 1  │ NY   │
│ 2  │ Jane │    │ 3  │ LA   │
│ 3  │ Bob  │    │ 4  │ SF   │
└────┴──────┘    └────┴──────┘

INNER JOIN on id → Returns only id=1 and id=3
(Rows 2 from A and 4 from B have no match, so excluded)
```

### JOIN Syntax

```sql
SELECT columns
FROM table1
INNER JOIN table2
    ON table1.join_column = table2.join_column;
```

- `INNER` keyword is optional (just `JOIN` works the same)
- The `ON` clause specifies the relationship between tables
- You can use table aliases (`t1`, `t2`) to shorten queries

### Using Table Aliases

```sql
SELECT c.first_name, c.last_name, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
```

Aliases make queries shorter and more readable, especially with long table names.

### JOIN with Multiple Conditions

```sql
SELECT e.name, d.department_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
    AND e.active = 1;
```

You can add additional conditions in the `ON` clause beyond the foreign key relationship.

### The USING Clause

When the join column has the **same name** in both tables, you can use `USING` as shorthand:

```sql
-- Instead of:
SELECT * FROM customers c JOIN orders o ON c.customer_id = o.customer_id;

-- Use:
SELECT * FROM customers c JOIN orders o USING (customer_id);
```

`USING` is cleaner but less flexible than `ON` (only works when column names match exactly).

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS store_db;
USE store_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, city)
VALUES
    ('John', 'Smith', 'john@email.com', 'New York'),
    ('Jane', 'Doe', 'jane@email.com', 'Los Angeles'),
    ('Bob', 'Johnson', 'bob@email.com', 'Chicago'),
    ('Alice', 'Williams', 'alice@email.com', 'Houston'),
    ('Charlie', 'Brown', 'charlie@email.com', 'Phoenix');

-- Insert sample orders
INSERT INTO orders (customer_id, order_date, total, status)
VALUES
    (1, '2024-01-15', 150.00, 'completed'),
    (1, '2024-03-20', 75.50, 'completed'),
    (2, '2024-02-10', 200.00, 'shipped'),
    (3, '2024-04-05', 50.00, 'pending'),
    (4, '2024-05-12', 300.00, 'completed'),
    (4, '2024-06-01', 120.00, 'pending');

-- Insert sample products
INSERT INTO products (name, price, category)
VALUES
    ('Laptop', 999.99, 'Electronics'),
    ('Mouse', 29.99, 'Electronics'),
    ('Keyboard', 79.99, 'Electronics'),
    ('Desk Chair', 249.99, 'Furniture'),
    ('Monitor', 399.99, 'Electronics');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity)
VALUES
    (1, 1, 1),
    (1, 2, 2),
    (2, 3, 1),
    (3, 4, 1),
    (4, 2, 1),
    (5, 5, 1),
    (5, 1, 1),
    (6, 3, 2);
```

### Example 1: Basic INNER JOIN

```sql
-- Get all customers who have placed orders
SELECT c.first_name, c.last_name, o.order_id, o.order_date, o.total
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;
```

### Example 2: JOIN with SELECT

```sql
-- Show order details with customer names
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.total,
    o.status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed';
```

### Example 3: Joining 3 Tables

```sql
-- Get customer → order → order items
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    o.order_id,
    o.order_date,
    p.name AS product_name,
    oi.quantity,
    p.price
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY c.customer_id, o.order_id;
```

### Example 4: Using USING

```sql
-- When column names match, use USING
SELECT c.first_name, o.order_date, o.total
FROM customers c
JOIN orders USING (customer_id);
```

### Example 5: JOIN with Aggregation

```sql
-- Total spent per customer
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    COUNT(o.order_id) AS order_count,
    SUM(o.total) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_spent > 100
ORDER BY total_spent DESC;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Forgetting the ON Condition

```sql
-- ❌ WRONG: Missing ON clause — creates a CROSS JOIN (Cartesian product!)
SELECT * FROM customers c JOIN orders o;

-- ✅ CORRECT: Always specify the relationship
SELECT * FROM customers c JOIN orders o ON c.customer_id = o.customer_id;
```

### Mistake 2: Using Wrong Column in ON

```sql
-- ❌ WRONG: Joining on non-key columns can produce wrong matches
SELECT * FROM customers c JOIN orders o ON c.first_name = o.status;

-- ✅ CORRECT: Always join on the foreign key relationship
SELECT * FROM customers c JOIN orders o ON c.customer_id = o.customer_id;
```

### Mistake 3: SELECT * with JOINs

```sql
-- ❌ WRONG: Returns duplicate columns (customer_id from both tables)
SELECT * FROM customers c JOIN orders o ON c.customer_id = o.customer_id;

-- ✅ CORRECT: Specify only the columns you need
SELECT c.customer_id, c.first_name, c.last_name, o.order_id, o.total
FROM customers c JOIN orders o ON c.customer_id = o.customer_id;
```

### Mistake 4: Not Using Table Aliases

```sql
-- ❌ WRONG: Verbose, hard to read
SELECT customers.first_name, customers.last_name, orders.order_date
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id;

-- ✅ CORRECT: Clean and readable with aliases
SELECT c.first_name, c.last_name, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100),
    dept_id INT,
    budget DECIMAL(12,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments (dept_name)
VALUES ('Engineering'), ('Marketing'), ('Sales'), ('HR'), ('Finance');

INSERT INTO employees (first_name, last_name, dept_id, salary)
VALUES
    ('Alice', 'Smith', 1, 95000),
    ('Bob', 'Johnson', 1, 88000),
    ('Carol', 'Williams', 2, 72000),
    ('David', 'Brown', 3, 68000),
    ('Eve', 'Davis', NULL, 60000),
    ('Frank', 'Miller', 5, 78000);

INSERT INTO projects (project_name, dept_id, budget)
VALUES
    ('App Redesign', 1, 50000),
    ('SEO Campaign', 2, 20000),
    ('Sales Portal', 3, 35000),
    ('Budget Audit', 5, 15000);
```

### Exercise 1: Basic INNER JOIN
1. List all employees with their department name
2. Show all projects with their department name
3. Find employees who belong to a department (exclude NULL dept_id)

### Exercise 2: Multi-Table JOIN
1. Show employees name, department, and salary for Engineering department only
2. List all projects with department name and budget > $20,000

### Exercise 3: JOIN with Aggregation
1. Count the number of employees per department
2. Calculate the total salary budget per department
3. Find departments that have at least 2 employees
4. Find the department with the highest average salary

---

## 🧠 Key Takeaways

- **INNER JOIN** returns only matching rows from both tables
- Always use the **ON clause** to specify the join condition
- Use **table aliases** (`c`, `o`) to make queries shorter and clearer
- **USING(column)** is shorthand when the join column name is identical in both tables
- You can join **3+ tables** by chaining multiple JOIN clauses
- Avoid `SELECT *` with JOINs — it returns duplicate columns
- INNER JOIN **excludes** rows without a match — use OUTER JOINs when you need them

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 08: Data Types Deep Dive →](../week-2-dml-data-types/lesson-08-data-types.md)
**Next:** [Lesson 10: LEFT JOIN & RIGHT JOIN →](./lesson-10-outer-joins.md)
