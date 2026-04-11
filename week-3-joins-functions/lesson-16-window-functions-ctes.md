# Lesson 16: Window Functions & CTEs

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 3:30:00 – 4:15:00 | 45 min |

## 📖 Theory

### Window Functions

**Window functions** perform calculations across a set of rows related to the current row, **without collapsing** them into a single result (unlike aggregate functions with GROUP BY).

```sql
-- Aggregate: collapses rows
SELECT department, AVG(salary) FROM employees GROUP BY department;
-- Returns 1 row per department

-- Window function: keeps all rows
SELECT name, department, salary,
       AVG(salary) OVER (PARTITION BY department) AS dept_avg
FROM employees;
-- Returns all employee rows, with dept_avg added
```

### Window Function Syntax

```sql
function_name() OVER (
    PARTITION BY column1, column2  -- Group rows (like GROUP BY, but doesn't collapse)
    ORDER BY column3               -- Order within partition
    ROWS/RANGE BETWEEN ... AND ... -- Frame clause
)
```

### Common Window Functions

| Function | Description | Example |
|----------|-------------|---------|
| `ROW_NUMBER()` | Unique sequential number | `ROW_NUMBER() OVER (ORDER BY salary DESC)` |
| `RANK()` | Rank with gaps for ties | `RANK() OVER (ORDER BY salary DESC)` |
| `DENSE_RANK()` | Rank without gaps | `DENSE_RANK() OVER (ORDER BY salary DESC)` |
| `NTILE(n)` | Divide into n buckets | `NTILE(4) OVER (ORDER BY salary DESC)` |
| `LAG(col, n)` | Value from n rows before | `LAG(salary, 1) OVER (ORDER BY hire_date)` |
| `LEAD(col, n)` | Value from n rows after | `LEAD(salary, 1) OVER (ORDER BY hire_date)` |
| `FIRST_VALUE(col)` | First value in window | `FIRST_VALUE(salary) OVER (ORDER BY hire_date)` |
| `LAST_VALUE(col)` | Last value in window | `LAST_VALUE(salary) OVER (ORDER BY hire_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)` |
| `SUM() OVER` | Running total | `SUM(salary) OVER (ORDER BY hire_date)` |
| `AVG() OVER` | Running average | `AVG(salary) OVER (PARTITION BY dept)` |

### ROW_NUMBER vs RANK vs DENSE_RANK

```
Salaries: 100K, 100K, 90K, 80K, 80K, 70K

ROW_NUMBER:  1,  2,  3,  4,  5,  6  (always unique)
RANK:        1,  1,  3,  4,  4,  6  (gaps after ties)
DENSE_RANK:  1,  1,  2,  3,  3,  4  (no gaps)
```

### CTEs (Common Table Expressions)

A **CTE** (Common Table Expression) is a named, temporary result set defined with the `WITH` clause.

```sql
WITH cte_name AS (
    SELECT ...  -- Define the CTE
)
SELECT * FROM cte_name;  -- Use it
```

### Why Use CTEs?

| Benefit | Description |
|---------|-------------|
| **Readability** | Break complex queries into named steps |
| **Reusability** | Reference the CTE multiple times |
| **Recursion** | Support recursive queries (hierarchical data) |
| **Alternative to subqueries** | Cleaner than nested subqueries |

### Recursive CTEs

```sql
WITH RECURSIVE cte_name AS (
    -- Anchor member (base case)
    SELECT ... WHERE condition

    UNION ALL

    -- Recursive member (references cte_name)
    SELECT ... FROM cte_name WHERE condition
)
SELECT * FROM cte_name;
```

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS window_db;
USE window_db;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    manager_id INT
);

INSERT INTO employees (name, department, salary, hire_date, manager_id)
VALUES
    ('Alice', 'Engineering', 120000, '2018-01-15', NULL),
    ('Bob', 'Engineering', 95000, '2020-03-10', 1),
    ('Carol', 'Engineering', 88000, '2021-07-20', 1),
    ('David', 'Engineering', 105000, '2019-05-12', 1),
    ('Eve', 'Marketing', 72000, '2021-02-28', NULL),
    ('Frank', 'Marketing', 68000, '2022-09-10', 5),
    ('Grace', 'Marketing', 78000, '2020-11-15', 5),
    ('Henry', 'Sales', 65000, '2022-06-01', NULL),
    ('Ivy', 'Sales', 82000, '2019-12-20', 8),
    ('Jack', 'Sales', 70000, '2023-01-15', 8);
```

### Example 1: ROW_NUMBER

```sql
-- Number all employees by salary descending
SELECT
    name,
    department,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

-- Row number within each department
SELECT
    name,
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM employees
ORDER BY department, dept_rank;
```

### Example 2: RANK vs DENSE_RANK

```sql
SELECT
    name,
    department,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees
ORDER BY salary DESC;
-- Notice: Alice (120K) is rank 1, David (105K) is rank 2
-- If two employees had the same salary, RANK would skip the next number
```

### Example 3: Top N Per Group

```sql
-- Top 2 earners per department
WITH ranked AS (
    SELECT
        name, department, salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT name, department, salary
FROM ranked
WHERE rn <= 2
ORDER BY department, rn;
```

### Example 4: Running Total

```sql
SELECT
    name,
    hire_date,
    salary,
    SUM(salary) OVER (ORDER BY hire_date) AS running_total,
    SUM(salary) OVER (ORDER BY hire_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_explicit
FROM employees
ORDER BY hire_date;
```

### Example 5: LAG and LEAD

```sql
-- Compare each employee's salary to the previous hire
SELECT
    name,
    hire_date,
    salary,
    LAG(name, 1) OVER (ORDER BY hire_date) AS prev_employee,
    LAG(salary, 1) OVER (ORDER BY hire_date) AS prev_salary,
    salary - LAG(salary, 1) OVER (ORDER BY hire_date) AS salary_diff,
    LEAD(name, 1) OVER (ORDER BY hire_date) AS next_employee
FROM employees
ORDER BY hire_date;

-- Year-over-year salary comparison
SELECT
    YEAR(hire_date) AS hire_year,
    COUNT(*) AS hires,
    AVG(salary) AS avg_salary,
    LAG(AVG(salary), 1) OVER (ORDER BY YEAR(hire_date)) AS prev_year_avg,
    AVG(salary) - LAG(AVG(salary), 1) OVER (ORDER BY YEAR(hire_date)) AS yoy_change
FROM employees
GROUP BY hire_year
ORDER BY hire_year;
```

### Example 6: NTILE — Quartiles

```sql
-- Divide employees into salary quartiles
SELECT
    name,
    department,
    salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS quartile,
    CASE NTILE(4) OVER (ORDER BY salary DESC)
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN '25-50%'
        WHEN 3 THEN '50-75%'
        WHEN 4 THEN 'Bottom 25%'
    END AS salary_group
FROM employees
ORDER BY salary DESC;
```

### Example 7: FIRST_VALUE and LAST_VALUE

```sql
-- First and last hire per department
SELECT
    name,
    department,
    hire_date,
    FIRST_VALUE(name) OVER (PARTITION BY department ORDER BY hire_date) AS first_hire,
    LAST_VALUE(name) OVER (
        PARTITION BY department ORDER BY hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_hire
FROM employees
ORDER BY department, hire_date;
```

### Example 8: CTE Basics

```sql
-- Simple CTE: Department averages
WITH dept_avg AS (
    SELECT department, AVG(salary) AS avg_sal, COUNT(*) AS emp_count
    FROM employees
    GROUP BY department
)
SELECT * FROM dept_avg WHERE avg_sal > 80000 ORDER BY avg_sal DESC;

-- Multiple CTEs
WITH dept_stats AS (
    SELECT department, MIN(salary) AS min_sal, MAX(salary) AS max_sal
    FROM employees GROUP BY department
),
high_paying_depts AS (
    SELECT department FROM dept_stats WHERE max_sal > 100000
)
SELECT e.name, e.department, e.salary
FROM employees e
JOIN high_paying_depts h ON e.department = h.department
ORDER BY e.salary DESC;
```

### Example 9: Recursive CTE — Employee Hierarchy

```sql
WITH RECURSIVE org_chart AS (
    -- Anchor: Top-level managers (no manager)
    SELECT emp_id, name, manager_id, 1 AS level, name AS path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: Direct reports
    SELECT e.emp_id, e.name, e.manager_id, oc.level + 1,
           CONCAT(oc.path, ' → ', e.name)
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.emp_id
)
SELECT * FROM org_chart ORDER BY level, name;
```

### Example 10: CTE + Window Function Combined

```sql
-- Department rankings with employee details
WITH dept_ranking AS (
    SELECT
        name,
        department,
        salary,
        hire_date,
        RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_salary_rank,
        salary - AVG(salary) OVER (PARTITION BY department) AS diff_from_dept_avg
    FROM employees
)
SELECT * FROM dept_ranking
ORDER BY department, dept_salary_rank;
```

---

## ⚠️ Common Mistakes

### Mistake 1: LAST_VALUE Without Frame Clause

```sql
-- ❌ WRONG: Default frame is ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT name, hire_date,
    LAST_VALUE(name) OVER (ORDER BY hire_date) AS last_hire
FROM employees;
-- Returns the CURRENT row, not the actual last row!

-- ✅ CORRECT: Expand the frame
SELECT name, hire_date,
    LAST_VALUE(name) OVER (
        ORDER BY hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_hire
FROM employees;
```

### Mistake 2: Window Function in WHERE

```sql
-- ❌ WRONG: Can't use window functions in WHERE
SELECT name, salary
FROM employees
WHERE RANK() OVER (ORDER BY salary DESC) <= 3;

-- ✅ CORRECT: Use a CTE or subquery
WITH ranked AS (
    SELECT name, salary, RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT name, salary FROM ranked WHERE rnk <= 3;
```

### Mistake 3: ORDER BY in PARTITION BY

```sql
-- ⚠️ TRAP: PARTITION BY without ORDER BY gives undefined order
SELECT name, salary,
    ROW_NUMBER() OVER (PARTITION BY department) AS rn
FROM employees;
-- The numbering within each department is arbitrary

-- ✅ CORRECT: Add ORDER BY within partition
SELECT name, salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
FROM employees;
```

### Mistake 4: Recursive CTE Without Termination

```sql
-- ❌ DANGEROUS: Infinite loop
WITH RECURSIVE infinite AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM infinite  -- No stopping condition!
)
SELECT * FROM infinite;

-- ✅ CORRECT: Add a WHERE condition
WITH RECURSIVE finite AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM finite WHERE n < 10
)
SELECT * FROM finite;
```

---

## ✅ Exercises

### Setup (using window_db from above)

### Exercise 1: Ranking Functions
1. Rank all employees by salary (use RANK and DENSE_RANK — observe the difference)
2. Find the top 3 earners overall
3. Find the top earner in each department

### Exercise 2: Running Totals and Averages
1. Calculate a running total of salaries ordered by hire_date
2. Calculate a running average of salaries within each department
3. Find the cumulative count of hires over time

### Exercise 3: LAG and LEAD
1. For each employee, show their salary and the salary of the person hired immediately before them
2. Calculate the gap (in days) between consecutive hires
3. Show year-over-year change in average salary

### Exercise 4: NTILE
1. Divide employees into 3 salary tiers (high, medium, low)
2. Within each department, divide employees into tertiles by salary

### Exercise 5: CTEs
1. Use a CTE to find departments where the average salary is above the company average
2. Use multiple CTEs: first find department stats, then find departments above median salary

### Exercise 6: Recursive CTE
1. Build the full management hierarchy (who reports to whom, up to any depth)
2. For each manager, count how many people report to them (directly or indirectly)

---

## 🧠 Key Takeaways

- **Window functions** compute across rows without collapsing them
- `OVER()` defines the window: **PARTITION BY** (group), **ORDER BY** (sort), **frame** (range)
- **ROW_NUMBER** is unique; **RANK** has gaps; **DENSE_RANK** has no gaps
- **LAG/LEAD** access values from previous/next rows
- **NTILE(n)** divides rows into n equal groups
- **LAST_VALUE** requires explicit frame clause (`ROWS BETWEEN ... AND ...`)
- Window functions **cannot** be used in WHERE — use CTE/subquery wrapper
- **CTEs** (`WITH`) make complex queries readable and reusable
- **Recursive CTEs** (`WITH RECURSIVE`) handle hierarchical data (org charts, categories)
- CTEs are evaluated once per query (not materialized — MySQL 8.0+ may optimize)

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 15: String, Date Functions & CASE →](./lesson-15-string-date-functions.md)
**Next:** [Lesson 17: ALTER TABLE →](../week-4-advanced-sql/lesson-13-alter-table.md)
