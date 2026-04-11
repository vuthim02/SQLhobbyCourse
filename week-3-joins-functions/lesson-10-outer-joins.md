# Lesson 10: LEFT JOIN & RIGHT JOIN

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 2:50:00 – 3:10:00 | 20 min |
| 🟧 Bro Code | 3:10:00 – 3:30:00 | 20 min |
| 🟩 Brototype | 2:15:00 – 2:30:00 | 15 min |

## 📖 Theory

### OUTER JOINs

Unlike INNER JOIN (which only returns matching rows), **OUTER JOINs** return all rows from one table, plus matching rows from the other table — and fill with `NULL` when there is no match.

### LEFT JOIN (LEFT OUTER JOIN)

A **LEFT JOIN** returns **all rows from the left table**, plus matching rows from the right table. If there is no match, the right table columns are filled with `NULL`.

```
Table A (Left)    Table B (Right)
┌────┬──────┐     ┌────┬──────┐
│ 1  │ John │     │ 1  │ NY   │
│ 2  │ Jane │     │ 3  │ LA   │
│ 3  │ Bob  │     └────┴──────┘
└────┴──────┘

LEFT JOIN on id → Returns:
(1, John, NY), (2, Jane, NULL), (3, Bob, LA)
— All rows from A, matches from B, NULL where no match
```

### RIGHT JOIN (RIGHT OUTER JOIN)

A **RIGHT JOIN** returns **all rows from the right table**, plus matching rows from the left table. It is the mirror of LEFT JOIN.

```
RIGHT JOIN on id → Returns:
(1, John, NY), (3, Bob, LA), (NULL, NULL, LA_from_row_4)
— All rows from B, matches from A, NULL where no match
```

> **Note:** MySQL does not support FULL OUTER JOIN natively. It can be simulated with `LEFT JOIN UNION RIGHT JOIN`.

### Anti-Join Pattern

The **anti-join** is one of the most useful patterns: find rows in the left table that have **no match** in the right table.

```sql
SELECT left_table.*
FROM left_table
LEFT JOIN right_table ON left_table.id = right_table.foreign_id
WHERE right_table.foreign_id IS NULL;
```

This finds records that are **missing** a relationship — e.g., customers with no orders, products never ordered, employees not assigned to projects.

### When to Use LEFT JOIN vs INNER JOIN

| Scenario | Use |
|----------|-----|
| "Show me all customers, even those without orders" | LEFT JOIN |
| "Show me customers who have placed orders" | INNER JOIN |
| "Show me products that have never been ordered" | LEFT JOIN + IS NULL |
| "Only show departments that have employees" | INNER JOIN |

---

## 💻 Examples

### Setup (continuing from Lesson 09)

```sql
-- Using the store_db database from Lesson 09
USE store_db;

-- Add a customer with NO orders
INSERT INTO customers (first_name, last_name, email, city)
VALUES ('Diana', 'Ross', 'diana@email.com', 'Seattle');

-- Add a product that has never been ordered
INSERT INTO products (name, price, category)
VALUES ('Webcam', 89.99, 'Electronics');
```

### Example 1: LEFT JOIN — All Customers with Their Orders

```sql
-- Show ALL customers, even those without orders
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_id,
    o.order_date,
    o.total
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- Diana Ross will appear with NULL order_id, order_date, total
```

### Example 2: Anti-Join — Customers with NO Orders

```sql
-- Find customers who have never placed an order
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Result: Diana Ross (the customer with no orders)
```

### Example 3: Anti-Join — Products Never Ordered

```sql
-- Find products that have never been ordered
SELECT
    p.product_id,
    p.name,
    p.price,
    p.category
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- Result: Webcam (the product never ordered)
```

### Example 4: RIGHT JOIN

```sql
-- Same as LEFT JOIN but reversed
SELECT
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- This is equivalent to:
-- SELECT o.order_id, o.order_date, c.first_name, c.last_name
-- FROM orders o
-- LEFT JOIN customers c ON o.customer_id = c.customer_id;
```

### Example 5: LEFT JOIN with Aggregation

```sql
-- Count orders per customer (including customers with 0 orders)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- COALESCE replaces NULL with 0 for customers without orders
```

### Example 6: LEFT JOIN with Multiple Tables

```sql
-- Full order details, including orders without items yet
SELECT
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.status,
    p.name AS product_name,
    oi.quantity
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;
```

### Example 7: Simulating FULL OUTER JOIN

```sql
-- MySQL doesn't have FULL OUTER JOIN, simulate with UNION
-- All customers + all orders, matched where possible
SELECT c.customer_id, c.first_name, o.order_id, o.total
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id

UNION

SELECT c.customer_id, c.first_name, o.order_id, o.total
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Using WHERE Instead of ON for Join Conditions

```sql
-- ❌ WRONG: This turns LEFT JOIN into INNER JOIN
SELECT c.*, o.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed';
-- The WHERE filters out NULL rows, defeating the LEFT JOIN

-- ✅ CORRECT: Put the filter in the ON clause
SELECT c.*, o.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
    AND o.status = 'completed';
```

### Mistake 2: Checking IS NULL on the Wrong Column

```sql
-- ❌ WRONG: Checking a column that could legitimately be NULL
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.total IS NULL;
-- An order could have total = NULL legitimately

-- ✅ CORRECT: Check the primary key or NOT NULL column
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- order_id is PRIMARY KEY, so NULL means "no match"
```

### Mistake 3: Confusing LEFT and RIGHT

```sql
-- ❌ WRONG: Thinking LEFT JOIN returns unmatched right rows
SELECT * FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;
-- Returns ALL customers, not all orders

-- ✅ CORRECT: Use RIGHT JOIN for all right-table rows
SELECT * FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;
-- Or reverse the table order with LEFT JOIN
SELECT * FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id;
```

### Mistake 4: Forgetting COALESCE with Aggregates

```sql
-- ❌ WRONG: SUM returns NULL for customers with no orders
SELECT c.first_name, SUM(o.total) AS total
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- ✅ CORRECT: Use COALESCE to replace NULL with 0
SELECT c.first_name, COALESCE(SUM(o.total), 0) AS total
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS university_db;
USE university_db;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    major VARCHAR(50)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_code VARCHAR(10),
    grade VARCHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

CREATE TABLE courses (
    course_code VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT
);

INSERT INTO students (first_name, last_name, major)
VALUES
    ('Alice', 'Smith', 'Computer Science'),
    ('Bob', 'Johnson', 'Mathematics'),
    ('Carol', 'Williams', 'Computer Science'),
    ('David', 'Brown', 'Physics'),
    ('Eve', 'Davis', 'Chemistry');

INSERT INTO courses (course_code, course_name, credits)
VALUES
    ('CS101', 'Intro to Programming', 3),
    ('CS201', 'Data Structures', 4),
    ('MATH101', 'Calculus I', 4),
    ('MATH201', 'Linear Algebra', 3),
    ('PHYS101', 'Physics I', 4),
    ('ENG101', 'English Composition', 3);

INSERT INTO enrollments (student_id, course_code, grade)
VALUES
    (1, 'CS101', 'A'),
    (1, 'CS201', 'B+'),
    (1, 'MATH101', 'A-'),
    (2, 'MATH101', 'B'),
    (2, 'MATH201', 'A'),
    (3, 'CS101', 'B+'),
    (4, 'PHYS101', 'A-'),
    (4, 'MATH101', 'B');
-- Note: student 5 (Eve) has no enrollments
-- Note: ENG101 has no enrollments
```

### Exercise 1: LEFT JOIN Basics
1. List all students with their enrollments (including students with no enrollments)
2. List all courses with their enrollments (including courses with no students)

### Exercise 2: Anti-Join Pattern
1. Find students who have not enrolled in any courses
2. Find courses that no student has taken
3. Find students whose major is 'Computer Science' but have not taken CS101

### Exercise 3: LEFT JOIN with Aggregation
1. Count the number of courses each student is enrolled in (show 0 for unenrolled students)
2. Calculate the average grade per course (include courses with no enrollments)
3. Find students who are enrolled in more than 2 courses

### Exercise 4: RIGHT JOIN
1. Rewrite Exercise 1 using RIGHT JOIN instead of LEFT JOIN
2. Show all enrollments with student details (use RIGHT JOIN from the courses table perspective)

### Exercise 5: Simulating FULL OUTER JOIN
1. Show all students and all courses in a combined result, matching where enrollments exist and showing NULLs where they don't

---

## 🧠 Key Takeaways

- **LEFT JOIN** returns all rows from the left table + matching right rows (NULL if no match)
- **RIGHT JOIN** is the mirror of LEFT JOIN
- **Anti-join** (`LEFT JOIN ... WHERE right_table.id IS NULL`) finds missing relationships
- `COALESCE()` replaces NULL values with a default in aggregated results
- Filtering in the `WHERE` clause after a LEFT JOIN can accidentally turn it into an INNER JOIN
- Use `IS NULL` on a **NOT NULL column** (like PRIMARY KEY) to find unmatched rows
- MySQL has no native `FULL OUTER JOIN` — simulate with `LEFT JOIN UNION RIGHT JOIN`

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 09: INNER JOIN →](./lesson-09-inner-join.md)
**Next:** [Lesson 11: Multiple Joins & Self Joins →](./lesson-11-multi-joins.md)
