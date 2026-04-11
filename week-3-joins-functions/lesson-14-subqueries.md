# Lesson 14: Subqueries

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 3:40:00 – 4:00:00 | 20 min |
| 🟧 Bro Code | 4:40:00 – 5:05:00 | 25 min |
| 🟩 Brototype | 3:10:00 – 3:30:00 | 20 min |

## 📖 Theory

### What is a Subquery?

A **subquery** (also called a **nested query** or **inner query**) is a `SELECT` statement embedded inside another SQL statement. The outer query is called the **main query**.

```sql
SELECT * FROM table
WHERE column = (SELECT column FROM other_table WHERE condition);
         └─ subquery ─┘
```

Subqueries let you use the **result of one query** as input to another query. They are evaluated first, and their result is passed to the outer query.

### Types of Subqueries

| Type | Returns | Used With |
|------|---------|-----------|
| **Scalar** | Single value (1 row, 1 column) | `=`, `<>`, `>`, `<`, etc. |
| **Multi-row** | Multiple rows (1 column) | `IN`, `ANY`, `ALL` |
| **Multi-column** | Multiple columns | `IN` with row comparison |
| **Correlated** | Depends on outer query | Re-evaluated for each row |
| **Derived Table** | A table result | `FROM` clause |

### Subqueries in WHERE

The most common use — filtering based on data from another table.

```sql
-- Scalar: Returns a single value
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Multi-row: Returns multiple values
SELECT * FROM products
WHERE category_id IN (SELECT id FROM categories WHERE active = 1);
```

### Subqueries in FROM (Derived Tables)

A subquery in the `FROM` clause acts as a temporary table.

```sql
SELECT dept, avg_salary
FROM (
    SELECT department AS dept, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) AS dept_stats
WHERE avg_salary > 50000;
```

**Important:** Derived tables **must** have an alias (`AS alias_name`).

### Subqueries in SELECT

A scalar subquery can appear in the SELECT list to compute a value per row.

```sql
SELECT
    name,
    salary,
    (SELECT AVG(salary) FROM employees) AS company_avg,
    salary - (SELECT AVG(salary) FROM employees) AS diff_from_avg
FROM employees;
```

### Correlated Subqueries

A **correlated subquery** references a column from the outer query. It is re-evaluated **for every row** of the outer query.

```sql
SELECT e.name, e.salary, e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id  -- References outer query!
);
-- Finds employees earning above their department's average
```

> ⚠️ Correlated subqueries can be slow on large tables. Consider rewriting as JOINs when possible.

### Subqueries with IN, ANY, ALL

```sql
-- IN: Match any value from subquery
SELECT * FROM products
WHERE category_id IN (SELECT id FROM categories WHERE type = 'Electronics');

-- ANY: Compare to any value returned by subquery
SELECT * FROM products
WHERE price > ANY (SELECT price FROM products WHERE category = 'Electronics');
-- True if price is greater than at least one electronics price

-- ALL: Compare to all values returned by subquery
SELECT * FROM products
WHERE price > ALL (SELECT price FROM products WHERE category = 'Electronics');
-- True if price is greater than ALL electronics prices (i.e., the maximum)
```

### EXISTS and NOT EXISTS

```sql
-- EXISTS: Returns true if subquery returns at least one row
SELECT * FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);
-- Finds customers who have at least one order

-- NOT EXISTS: Returns true if subquery returns zero rows
SELECT * FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
);
-- Finds products that have never been ordered
```

`EXISTS` stops evaluating as soon as it finds a match, making it very efficient for checking existence.

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS subquery_db;
USE subquery_db;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department_id INT,
    salary DECIMAL(10,2),
    hire_date DATE
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT
);

INSERT INTO departments (dept_name, location)
VALUES ('Engineering', 'New York'), ('Marketing', 'London'),
       ('Sales', 'Tokyo'), ('HR', 'New York'), ('Finance', 'London');

INSERT INTO employees (name, department_id, salary, hire_date)
VALUES
    ('Alice', 1, 95000, '2020-01-15'),
    ('Bob', 1, 88000, '2021-03-10'),
    ('Carol', 2, 72000, '2019-07-20'),
    ('David', 3, 68000, '2022-01-05'),
    ('Eve', 1, 105000, '2018-05-12'),
    ('Frank', 4, 60000, '2023-02-28'),
    ('Grace', 3, 75000, '2020-11-15'),
    ('Henry', 5, 78000, '2021-06-01'),
    ('Ivy', 2, 69000, '2022-09-10'),
    ('Jack', 5, 82000, '2019-12-20');

INSERT INTO projects (project_name, budget, dept_id)
VALUES
    ('App Redesign', 50000, 1),
    ('SEO Campaign', 20000, 2),
    ('Sales Portal', 35000, 3),
    ('Budget Audit', 15000, 5),
    ('HR System', 25000, 4),
    ('Data Pipeline', 80000, 1);
```

### Example 1: Scalar Subquery in WHERE

```sql
-- Employees earning more than the company average
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;
```

### Example 2: Multi-Row Subquery with IN

```sql
-- Employees in departments located in New York
SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT dept_id FROM departments WHERE location = 'New York'
);
```

### Example 3: Correlated Subquery

```sql
-- Employees earning more than their department's average
SELECT e.name, e.salary, e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
)
ORDER BY e.department_id, e.salary DESC;
```

### Example 4: Subquery in SELECT

```sql
-- Each employee with their salary relative to company average
SELECT
    name,
    salary,
    department_id,
    (SELECT AVG(salary) FROM employees) AS company_avg,
    salary - (SELECT AVG(salary) FROM employees) AS diff_from_avg
FROM employees
ORDER BY diff_from_avg DESC;
```

### Example 5: Derived Table (Subquery in FROM)

```sql
-- Department average salaries, filtered
SELECT dept_name, avg_salary
FROM (
    SELECT
        e.department_id,
        AVG(e.salary) AS avg_salary
    FROM employees e
    GROUP BY e.department_id
) AS dept_avg
JOIN departments d ON dept_avg.department_id = d.dept_id
WHERE avg_salary > 75000
ORDER BY avg_salary DESC;
```

### Example 6: EXISTS / NOT EXISTS

```sql
-- Departments that have at least one employee
SELECT dept_name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.dept_id
);

-- Departments with no employees
SELECT dept_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.dept_id
);

-- Projects with budget above department's average project budget
SELECT project_name, budget
FROM projects p
WHERE budget > (
    SELECT AVG(budget)
    FROM projects
    WHERE dept_id = p.dept_id
);
```

### Example 7: ALL / ANY

```sql
-- Employees earning more than ALL Marketing employees
SELECT name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary FROM employees WHERE department_id = (
        SELECT dept_id FROM departments WHERE dept_name = 'Marketing'
    )
);

-- Employees earning more than ANY Sales employee
SELECT name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary FROM employees WHERE department_id = (
        SELECT dept_id FROM departments WHERE dept_name = 'Sales'
    )
);
```

---

## ⚠️ Common Mistakes

### Mistake 1: Subquery Returns Multiple Rows When Scalar Expected

```sql
-- ❌ WRONG: Subquery returns multiple rows, = expects one
SELECT * FROM employees
WHERE department_id = (SELECT dept_id FROM departments WHERE location = 'New York');
-- Error: Subquery returns more than 1 row

-- ✅ CORRECT: Use IN for multiple values
SELECT * FROM employees
WHERE department_id IN (SELECT dept_id FROM departments WHERE location = 'New York');
```

### Mistake 2: Forgetting Derived Table Alias

```sql
-- ❌ WRONG: Missing alias for derived table
SELECT * FROM (
    SELECT department_id, AVG(salary) AS avg_sal FROM employees GROUP BY department_id
);
-- Error: Every derived table must have its own alias

-- ✅ CORRECT: Add an alias
SELECT * FROM (
    SELECT department_id, AVG(salary) AS avg_sal FROM employees GROUP BY department_id
) AS dept_avg;
```

### Mistake 3: Correlated Subquery Performance

```sql
-- ❌ INEFFICIENT: Correlated subquery re-evaluated for every row
SELECT name FROM employees e
WHERE salary > (
    SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
);

-- ✅ MORE EFFICIENT: Rewrite as JOIN with derived table
SELECT e.name
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_sal
    FROM employees GROUP BY department_id
) AS dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_sal;
```

### Mistake 4: NULL Handling in NOT IN

```sql
-- ❌ DANGEROUS: If subquery returns any NULL, NOT IN returns nothing
SELECT * FROM products
WHERE product_id NOT IN (SELECT product_id FROM order_items);
-- If order_items has a NULL product_id, this returns empty!

-- ✅ SAFE: Use NOT EXISTS instead
SELECT * FROM products p
WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id);
```

---

## ✅ Exercises

### Setup (using subquery_db from above)

### Exercise 1: Scalar Subqueries
1. Find employees earning more than the overall average salary
2. Find the employee(s) with the highest salary
3. Find employees hired after the average hire date

### Exercise 2: Multi-Row Subqueries
1. Find all employees in departments located in London
2. Find employees in departments that have at least one project with budget > $30,000
3. Find all projects in departments with average salary above $80,000

### Exercise 3: Correlated Subqueries
1. Find employees earning more than their department's average
2. For each department, find the highest-paid employee (use correlated subquery)
3. Find employees whose salary is above the average of employees hired before them

### Exercise 4: EXISTS / NOT EXISTS
1. Find departments that have no employees
2. Find departments that have at least 2 employees
3. Find projects in departments where the total salary budget exceeds $200,000

### Exercise 5: Derived Tables
1. Create a derived table of department average salaries, then join with departments to find the department name and location for each
2. Find the average of department averages (average of averages)

---

## 🧠 Key Takeaways

- **Subqueries** let you nest a SELECT inside another statement
- **Scalar subqueries** return one value — used with `=`, `>`, `<`
- **Multi-row subqueries** return many values — used with `IN`, `ANY`, `ALL`
- **Derived tables** are subqueries in the FROM clause — **must** have an alias
- **Correlated subqueries** reference the outer query — re-evaluated per row (can be slow)
- **EXISTS / NOT EXISTS** are efficient for checking existence (stop at first match)
- **NOT IN** with NULLs in the subquery returns unexpected results — prefer NOT EXISTS
- Subqueries can often be rewritten as **JOINs** for better performance

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 13: HAVING & Filtering Aggregates →](./lesson-13-having.md)
**Next:** [Lesson 15: String, Date Functions & CASE →](./lesson-15-string-date-functions.md)
