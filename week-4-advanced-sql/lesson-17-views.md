# Lesson 17: Views

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 2:15:00 – 2:45:00 | 30 min |

## 📖 Theory

### What is a View?

A **view** is a virtual table defined by a `SELECT` query. It does not store data itself — it runs the underlying query each time you reference it.

```
View: customer_orders
┌──────────┬──────────┬───────┐
│ customer │ order_id │ total │  ← This is really:
├──────────┼──────────┼───────┤
│ Alice    │ 1        │ 150   │     SELECT c.name AS customer, o.order_id, o.total
│ Bob      │ 2        │ 200   │     FROM customers c JOIN orders o ON c.id = o.customer_id
└──────────┴──────────┴───────┘
```

### Why Use Views?

| Benefit | Description |
|---------|-------------|
| **Simplification** | Hide complex JOINs behind a simple name |
| **Security** | Expose only specific columns (hide sensitive data) |
| **Consistency** | Centralize business logic — one view, many consumers |
| **Readability** | `SELECT * FROM active_customers` vs a 10-line JOIN |
| **Abstraction** | Change underlying tables without breaking applications |

### Types of Views in MySQL

| Type | Description | Supported in MySQL? |
|------|-------------|---------------------|
| **Standard View** | Virtual — runs query each time | ✅ Yes |
| **Updatable View** | Can INSERT/UPDATE/DELETE through view | ✅ Yes (with restrictions) |
| **Materialized View** | Stores results physically | ❌ No (use triggers or summary tables) |
| **Indexed View** | View with indexes on it | ❌ No (not directly in MySQL) |

### View Syntax

```sql
-- Create
CREATE [OR REPLACE] VIEW view_name [(col_aliases)] AS
    select_statement
[WITH CHECK OPTION];

-- Query
SELECT * FROM view_name;

-- Alter
ALTER VIEW view_name AS select_statement;

-- Drop
DROP VIEW [IF EXISTS] view_name;
```

### Updatable View Restrictions

A view is updatable (you can INSERT/UPDATE/DELETE through it) only if:
- It references **one table** (no JOINs)
- No aggregate functions (COUNT, SUM, AVG)
- No DISTINCT, GROUP BY, HAVING
- No subqueries in SELECT
- All NOT NULL columns of the base table are included in the view
- No UNION

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS views_db;
USE views_db;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    salary DECIMAL(10,2),
    ssn CHAR(11),           -- Sensitive!
    department_id INT,
    is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total DECIMAL(10,2),
    status VARCHAR(20)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50)
);

INSERT INTO departments (dept_name, location)
VALUES ('Engineering', 'New York'), ('Marketing', 'London'),
       ('Sales', 'Tokyo'), ('HR', 'New York');

INSERT INTO employees (first_name, last_name, email, salary, ssn, department_id)
VALUES
    ('Alice', 'Smith', 'alice@company.com', 95000, '123-45-6789', 1),
    ('Bob', 'Johnson', 'bob@company.com', 72000, '234-56-7890', 2),
    ('Carol', 'Williams', 'carol@company.com', 88000, '345-67-8901', 1),
    ('David', 'Brown', 'david@company.com', 68000, '456-78-9012', 3),
    ('Eve', 'Davis', 'eve@company.com', 105000, '567-89-0123', 1);

INSERT INTO customers (first_name, last_name, email, city)
VALUES ('John', 'Doe', 'john@email.com', 'New York'), ('Jane', 'Smith', 'jane@email.com', 'London');

INSERT INTO orders (customer_id, order_date, total, status)
VALUES (1, '2024-01-15', 150.00, 'completed'), (1, '2024-03-20', 75.50, 'completed'),
       (2, '2024-02-10', 200.00, 'shipped');
```

### Example 1: Simple View

```sql
-- Create a view for active employees (hide sensitive data)
CREATE VIEW active_employees AS
SELECT
    emp_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    department_id
FROM employees
WHERE is_active = 1;

-- Use it like a table
SELECT * FROM active_employees;
SELECT full_name, email FROM active_employees WHERE department_id = 1;

-- No SSN or salary exposed!
```

### Example 2: View with JOINs

```sql
-- Employee details view
CREATE VIEW employee_details AS
SELECT
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    e.email,
    d.dept_name,
    d.location
FROM employees e
JOIN departments d ON e.department_id = d.dept_id;

SELECT * FROM employee_details;
SELECT name, dept_name FROM employee_details WHERE location = 'New York';
```

### Example 3: View with Aggregation

```sql
-- Department summary view
CREATE VIEW department_summary AS
SELECT
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.department_id
GROUP BY d.dept_id, d.dept_name, d.location;

SELECT * FROM department_summary ORDER BY avg_salary DESC;
```

### Example 4: OR REPLACE — Updating a View

```sql
-- Modify the active_employees view to include salary
CREATE OR REPLACE VIEW active_employees AS
SELECT
    emp_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    department_id,
    salary
FROM employees
WHERE is_active = 1;

SELECT full_name, salary FROM active_employees WHERE salary > 80000;
```

### Example 5: Updatable View

```sql
-- Simple view on one table — updatable
CREATE VIEW employee_public AS
SELECT emp_id, first_name, last_name, email, department_id
FROM employees;

-- ✅ UPDATE through view works
UPDATE employee_public SET email = 'alice.new@company.com' WHERE emp_id = 1;

-- ✅ INSERT through view works (all NOT NULL columns included)
INSERT INTO employee_public (emp_id, first_name, last_name, email, department_id)
VALUES (6, 'Frank', 'Miller', 'frank@company.com', 4);

-- ❌ Can't INSERT through aggregated/joined views
INSERT INTO employee_details (emp_id, name, email, dept_name, location)
VALUES (7, 'Test', 'test@x.com', 'HR', 'NY');
-- ERROR: The target table employee_details of the INSERT is not insertable-into
```

### Example 6: WITH CHECK OPTION

```sql
-- View for high-earning employees
CREATE OR REPLACE VIEW high_earners AS
SELECT emp_id, first_name, last_name, salary, department_id
FROM employees
WHERE salary > 80000
WITH CHECK OPTION;

-- ✅ OK: New row satisfies the condition
UPDATE high_earners SET salary = 90000 WHERE emp_id = 1;

-- ❌ FAIL: Would violate the view's WHERE condition
UPDATE high_earners SET salary = 50000 WHERE emp_id = 1;
-- ERROR: CHECK OPTION failed
```

### Example 7: View of a View (Layering)

```sql
-- Base view
CREATE VIEW employee_details AS
SELECT e.emp_id, CONCAT(e.first_name, ' ', e.last_name) AS name,
       e.email, d.dept_name, d.location, e.salary
FROM employees e JOIN departments d ON e.department_id = d.dept_id;

-- View on top of view
CREATE VIEW ny_employees AS
SELECT name, email, dept_name, salary
FROM employee_details
WHERE location = 'New York';

SELECT * FROM ny_employees;
```

### Example 8: Security View — Hide Sensitive Columns

```sql
-- Hide SSN and salary from general access
CREATE VIEW employee_directory AS
SELECT
    emp_id,
    CONCAT(first_name, ' ', last_name) AS name,
    email,
    dept_name
FROM employees e
JOIN departments d ON e.department_id = d.dept_id;

-- Grant access to this view (but not the underlying table)
-- GRANT SELECT ON views_db.employee_directory TO 'analyst'@'localhost';
```

---

## ⚠️ Common Mistakes

### Mistake 1: Treating Views as Performance Optimization

```sql
-- ❌ WRONG: Views don't make queries faster — they're just saved queries
CREATE VIEW slow_view AS
SELECT * FROM orders WHERE customer_id IN (
    SELECT customer_id FROM customers WHERE city = 'New York'
);
-- This runs the full subquery every time you SELECT from slow_view

-- ✅ CORRECT: Use views for abstraction, indexes for performance
CREATE INDEX idx_customer_city ON customers(city);
CREATE INDEX idx_order_customer ON orders(customer_id);
```

### Mistake 2: Updating Through a Complex View

```sql
-- ❌ WRONG: Can't update through JOINed/aggregated views
CREATE VIEW dept_summary AS
SELECT dept_name, COUNT(*) AS cnt, AVG(salary) AS avg_sal
FROM employees e JOIN departments d ON e.department_id = d.dept_id
GROUP BY d.dept_id;

UPDATE dept_summary SET avg_sal = 80000 WHERE dept_name = 'Engineering';
-- ERROR: The target table dept_summary of the UPDATE is not updatable

-- ✅ CORRECT: Update the base table
UPDATE employees SET salary = 80000 WHERE department_id = 1;
```

### Mistake 3: Forgetting Views Are Dynamic

```sql
-- ⚠️ TRAP: Views reflect current data — they're not snapshots
CREATE VIEW active_employees AS SELECT * FROM employees WHERE is_active = 1;

-- If you deactivate an employee:
UPDATE employees SET is_active = 0 WHERE emp_id = 3;

-- The view automatically excludes them
SELECT * FROM active_employees;  -- Carol is gone
```

### Mistake 4: View Column Name Collisions

```sql
-- ❌ WRONG: Ambiguous column names
CREATE VIEW bad_view AS
SELECT e.name, d.name  -- Both columns named 'name'!
FROM employees e JOIN departments d ON e.dept_id = d.dept_id;

-- ✅ CORRECT: Use aliases
CREATE VIEW good_view AS
SELECT e.name AS employee_name, d.name AS department_name
FROM employees e JOIN departments d ON e.dept_id = d.dept_id;
```

---

## ✅ Exercises

### Setup (using views_db from above)

### Exercise 1: Create Views
1. Create a view `customer_orders` that shows customer name, order_id, order_date, total, and status
2. Create a view `dept_salary_stats` showing department name, count, avg, min, max salary
3. Create a view `high_value_orders` showing orders with total > $150, including customer name

### Exercise 2: Use Views
1. Query `customer_orders` for all completed orders
2. Query `dept_salary_stats` to find the department with the highest average salary
3. Query `high_value_orders` sorted by total descending

### Exercise 3: Modify and Drop
1. Use `CREATE OR REPLACE` to add customer city to `customer_orders`
2. Drop `high_value_orders`
3. Create a new view `pending_orders` that shows only pending orders with customer info

### Exercise 4: Updatable View
1. Create a simple updatable view on the `customers` table showing only id, name, email
2. Update a customer's email through the view
3. Try to insert a new customer through the view

---

## 🧠 Key Takeaways

- **Views** are virtual tables — saved SELECT queries
- They **simplify** complex queries, **hide** sensitive columns, **centralize** logic
- Views are **dynamic** — they always reflect current underlying data
- **CREATE OR REPLACE VIEW** updates an existing view definition
- **Updatable views** require: single table, no aggregates, no GROUP BY/DISTINCT
- **WITH CHECK OPTION** ensures updates through the view satisfy the view's WHERE clause
- Views do **not improve performance** — they're abstraction, not optimization
- Use `DROP VIEW IF EXISTS` for safe deletion
- You can create **views on top of views** (layering)

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 16: Transactions & ACID →](./lesson-16-transactions.md)
**Next:** [Lesson 18: Triggers & Stored Procedures →](./lesson-18-triggers-procedures.md)
