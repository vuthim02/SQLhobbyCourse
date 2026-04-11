# Lesson 11: Multiple Joins & Self Joins

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟧 Bro Code | 3:30:00 – 3:50:00 | 20 min |
| 🟩 Brototype | 2:30:00 – 2:50:00 | 20 min |

## 📖 Theory

### Joining 3+ Tables

Real-world queries often require joining **three or more tables**. The pattern is simple: chain JOIN clauses.

```sql
SELECT columns
FROM table_a
JOIN table_b ON a.join_col = b.join_col
JOIN table_c ON b.join_col = c.join_col
JOIN table_d ON c.join_col = d.join_col;
```

Each additional JOIN adds more context to your result set. The key is to understand the **relationship path** between tables.

### Self Joins

A **self join** is when a table is joined to itself. This is useful when a table has a **recursive relationship** — a column that references the same table's primary key.

Common use cases:
- **Employee → Manager** hierarchy (manager_id references employee_id in the same table)
- **Category → Parent Category** (nested categories)
- **User → Referred By** (referral systems)
- **Flight** routes (origin and destination in the same airports table)

```sql
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

### CROSS JOIN

A **CROSS JOIN** produces the **Cartesian product** — every row from the left table combined with every row from the right table.

```sql
SELECT * FROM table_a CROSS JOIN table_b;
-- If A has 10 rows and B has 5 rows, result has 10 × 5 = 50 rows
```

Use cases:
- Generating all combinations (sizes × colors for product variants)
- Date range generation
- Testing and data generation

> ⚠️ CROSS JOIN can produce enormous result sets. Use with caution.

### NATURAL JOIN

A **NATURAL JOIN** automatically joins on columns with the same name in both tables.

```sql
SELECT * FROM customers NATURAL JOIN orders;
-- Joins on any columns with matching names (customer_id, if present in both)
```

> ⚠️ NATURAL JOIN is rarely used in practice because it can join on unexpected columns and produce wrong results.

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

-- Departments table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL
);

-- Employees with manager reference (self-referencing)
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dept_id INT,
    manager_id INT,  -- References emp_id in the same table
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

-- Projects
CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100),
    dept_id INT,
    budget DECIMAL(12,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Employee-project assignments
CREATE TABLE project_assignments (
    emp_id INT,
    project_id INT,
    role VARCHAR(50),
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Locations
CREATE TABLE locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Department locations
CREATE TABLE dept_locations (
    dept_id INT,
    location_id INT,
    PRIMARY KEY (dept_id, location_id),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Insert departments
INSERT INTO departments (dept_name)
VALUES ('Engineering'), ('Marketing'), ('Sales'), ('HR'), ('Finance');

-- Insert employees (with manager hierarchy)
INSERT INTO employees (first_name, last_name, dept_id, manager_id, salary)
VALUES
    ('Alice', 'Smith', 1, NULL, 120000),    -- Alice is top of Engineering (no manager)
    ('Bob', 'Johnson', 1, 1, 95000),        -- Bob reports to Alice
    ('Carol', 'Williams', 1, 1, 88000),     -- Carol reports to Alice
    ('David', 'Brown', 2, NULL, 110000),    -- David heads Marketing
    ('Eve', 'Davis', 2, 4, 72000),          -- Eve reports to David
    ('Frank', 'Miller', 3, NULL, 105000),   -- Frank heads Sales
    ('Grace', 'Wilson', 3, 6, 68000),       -- Grace reports to Frank
    ('Henry', 'Taylor', 4, NULL, 115000),   -- Henry heads HR
    ('Ivy', 'Anderson', 5, NULL, 112000);   -- Ivy heads Finance

-- Insert projects
INSERT INTO projects (project_name, dept_id, budget)
VALUES
    ('App Redesign', 1, 50000),
    ('API Migration', 1, 80000),
    ('SEO Campaign', 2, 20000),
    ('Sales Portal', 3, 35000),
    ('Budget Audit', 5, 15000);

-- Insert project assignments
INSERT INTO project_assignments (emp_id, project_id, role)
VALUES
    (1, 1, 'Lead'),
    (2, 1, 'Developer'),
    (3, 2, 'Developer'),
    (4, 3, 'Lead'),
    (5, 3, 'Analyst'),
    (6, 4, 'Lead'),
    (9, 5, 'Lead');

-- Insert locations
INSERT INTO locations (city, country)
VALUES ('New York', 'USA'), ('London', 'UK'), ('Tokyo', 'Japan');

-- Department locations
INSERT INTO dept_locations (dept_id, location_id)
VALUES (1, 1), (1, 2), (2, 1), (3, 3), (4, 1), (5, 2);
```

### Example 1: Joining 4 Tables

```sql
-- Full employee → project details
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee,
    d.dept_name,
    p.project_name,
    pa.role,
    p.budget
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN project_assignments pa ON e.emp_id = pa.emp_id
JOIN projects p ON pa.project_id = p.project_id
ORDER BY d.dept_name, p.project_name;
```

### Example 2: Joining 5 Tables

```sql
-- Employee → department → location details
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee,
    d.dept_name,
    l.city,
    l.country
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN dept_locations dl ON d.dept_id = dl.dept_id
JOIN locations l ON dl.location_id = l.location_id
ORDER BY l.country, l.city;
```

### Example 3: Self Join — Employee → Manager

```sql
-- Show each employee with their manager's name
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee,
    CONCAT(m.first_name, ' ', m.last_name) AS manager,
    e.salary
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY manager, employee;

-- Top-level employees (no manager) show NULL for manager
```

### Example 4: Self Join — Finding Peers

```sql
-- Find all pairs of employees who share the same manager
SELECT
    CONCAT(e1.first_name, ' ', e1.last_name) AS employee1,
    CONCAT(e2.first_name, ' ', e2.last_name) AS employee2,
    CONCAT(m.first_name, ' ', m.last_name) AS manager
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.manager_id AND e1.emp_id < e2.emp_id
LEFT JOIN employees m ON e1.manager_id = m.emp_id
ORDER BY manager, employee1;

-- e1.emp_id < e2.emp_id prevents duplicate pairs (A,B) and (B,A)
```

### Example 5: Self Join — Hierarchical Query

```sql
-- Show full org chart: employee → manager → manager's manager
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee,
    CONCAT(m.first_name, ' ', m.last_name) AS manager,
    CONCAT(mm.first_name, ' ', mm.last_name) AS managers_manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
LEFT JOIN employees mm ON m.manager_id = mm.emp_id
ORDER BY mm.last_name, m.last_name, e.last_name;
```

### Example 6: CROSS JOIN — Generate Combinations

```sql
-- Generate all possible size-color combinations for products
CREATE TABLE sizes (size VARCHAR(10));
CREATE TABLE colors (color VARCHAR(20));

INSERT INTO sizes VALUES ('S'), ('M'), ('L'), ('XL');
INSERT INTO colors VALUES ('Red'), ('Blue'), ('Black');

-- Cartesian product: 4 sizes × 3 colors = 12 combinations
SELECT s.size, c.color
FROM sizes s
CROSS JOIN colors c
ORDER BY s.size, c.color;
```

### Example 7: Multi-Join with Aggregation

```sql
-- Total project budget per department, with employee count
SELECT
    d.dept_name,
    COUNT(DISTINCT p.project_id) AS project_count,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    SUM(p.budget) AS total_budget,
    AVG(e.salary) AS avg_salary
FROM departments d
LEFT JOIN projects p ON d.dept_id = p.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY total_budget DESC;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Joining in the Wrong Order

```sql
-- ❌ WRONG: Joining unrelated tables first
SELECT *
FROM employees e
JOIN projects p ON e.dept_id = p.dept_id  -- OK
JOIN project_assignments pa ON e.emp_id = pa.emp_id  -- Missing project link!

-- ✅ CORRECT: Follow the relationship chain
SELECT *
FROM employees e
JOIN project_assignments pa ON e.emp_id = pa.emp_id
JOIN projects p ON pa.project_id = p.project_id;
```

### Mistake 2: Duplicate Pairs in Self Join

```sql
-- ❌ WRONG: Returns (Alice, Bob) AND (Bob, Alice) — duplicates
SELECT e1.name, e2.name
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.manager_id;

-- ✅ CORRECT: Use < or > to get each pair only once
SELECT e1.name, e2.name
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.manager_id
    AND e1.emp_id < e2.emp_id;
```

### Mistake 3: Losing Rows with Multiple JOINs

```sql
-- ❌ WRONG: INNER JOINs may drop employees with no projects
SELECT e.name, p.project_name
FROM employees e
JOIN project_assignments pa ON e.emp_id = pa.emp_id
JOIN projects p ON pa.project_id = p.project_id;

-- ✅ CORRECT: Use LEFT JOIN to keep all employees
SELECT e.name, p.project_name
FROM employees e
LEFT JOIN project_assignments pa ON e.emp_id = pa.emp_id
LEFT JOIN projects p ON pa.project_id = p.project_id;
```

### Mistake 4: Ambiguous Column Names in Multi-Joins

```sql
-- ❌ WRONG: Which dept_id? Both employees and departments have it
SELECT dept_id, dept_name, first_name
FROM employees JOIN departments ON employees.dept_id = departments.dept_id;

-- ✅ CORRECT: Use table aliases and qualify columns
SELECT d.dept_id, d.dept_name, e.first_name
FROM employees e JOIN departments d ON e.dept_id = d.dept_id;
```

---

## ✅ Exercises

### Setup (using company_db from above)

### Exercise 1: Multi-Table Joins
1. Show all employees with their department, manager, and salary
2. Show all projects with department name, assigned employees, and their roles
3. Find the total budget per department including all projects

### Exercise 2: Self Joins
1. List all managers and the number of employees reporting to each
2. Find employees who earn more than their manager
3. Find pairs of employees in the same department

### Exercise 3: Complex Multi-Join Queries
1. For each project, show: project name, department, lead employee, and budget
2. Find departments that have locations in more than one country
3. Show the complete reporting chain for each employee (up to 3 levels)

### Exercise 4: CROSS JOIN Practice
1. Generate all employee-project combinations (even unassigned ones)
2. Create a report showing every department paired with every location

---

## 🧠 Key Takeaways

- Chain **multiple JOINs** to connect tables through relationship paths
- **Self joins** are for recursive relationships (manager/employee, category/parent)
- Use `e1.emp_id < e2.emp_id` in self joins to avoid duplicate pairs
- **CROSS JOIN** produces the Cartesian product — every combination of rows
- **NATURAL JOIN** auto-joins on matching column names — rarely used in practice
- When joining 3+ tables, follow the **foreign key path** logically
- Use **LEFT JOIN** in multi-table joins to avoid losing rows

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 10: LEFT JOIN & RIGHT JOIN →](./lesson-10-outer-joins.md)
**Next:** [Lesson 12: Aggregate Functions & GROUP BY →](./lesson-12-aggregations.md)
