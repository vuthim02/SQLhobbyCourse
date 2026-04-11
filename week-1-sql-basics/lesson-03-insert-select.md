# Lesson 03: INSERT & SELECT

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 45:00 – 1:10:00 | 25 min |
| 🟧 Bro Code | 30:00 – 50:00 | 20 min |

## 📖 Theory

### INSERT — Adding Data

#### Single Row Insert

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);
```

#### Multi-Row Insert (More Efficient)

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES 
    (value1a, value2a, value3a),
    (value1b, value2b, value3c),
    (value1c, value2c, value3c);
```

> **Performance tip:** Multi-row inserts are much faster than multiple single-row inserts.

### SELECT — Reading Data

#### Basic SELECT Syntax

```sql
-- Get ALL columns
SELECT * FROM table_name;

-- Get SPECIFIC columns
SELECT column1, column2 FROM table_name;

-- Get columns with ALIASES (rename them in the result)
SELECT column1 AS 'First Name', column2 AS 'Last Name' FROM table_name;
```

#### SELECT with Expressions

```sql
-- Math expressions
SELECT 
    first_name,
    last_name,
    salary,
    salary * 1.10 AS 'New Salary (10% raise)'
FROM employees;

-- String concatenation
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Full Name',
    email
FROM employees;
```

---

## 💻 Examples

### Setup: Create a Table

```sql
CREATE DATABASE IF NOT EXISTS store;
USE store;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    points INT DEFAULT 0,
    city VARCHAR(50),
    state VARCHAR(20),
    birth_date DATE
);
```

### INSERT Examples

```sql
-- Single row
INSERT INTO customers (first_name, last_name, email, points, city, state, birth_date)
VALUES ('John', 'Smith', 'john@email.com', 100, 'New York', 'NY', '1990-01-15');

-- Multi-row (insert 5 customers at once)
INSERT INTO customers (first_name, last_name, email, points, city, state, birth_date)
VALUES 
    ('Jane', 'Doe', 'jane@email.com', 250, 'Los Angeles', 'CA', '1985-03-22'),
    ('Bob', 'Johnson', 'bob@email.com', 50, 'Chicago', 'IL', '1992-07-10'),
    ('Alice', 'Williams', 'alice@email.com', 500, 'Houston', 'TX', '1988-11-30'),
    ('Charlie', 'Brown', 'charlie@email.com', 0, 'Phoenix', 'AZ', '1995-05-18'),
    ('Diana', 'Ross', 'diana@email.com', 1000, 'Miami', 'FL', '1980-12-25');

-- Using DEFAULT for auto-generated values
INSERT INTO customers (first_name, last_name, email)
VALUES ('Test', 'User', 'test@email.com');
-- points defaults to 0, city/state/birth_date default to NULL
```

### SELECT Examples

```sql
-- Get all customers with all columns
SELECT * FROM customers;

-- Get specific columns only (better performance than *)
SELECT first_name, last_name, email FROM customers;

-- Use column aliases
SELECT 
    first_name AS 'First',
    last_name AS 'Last',
    CONCAT(first_name, ' ', last_name) AS 'Full Name',
    email AS 'Email Address'
FROM customers;

-- Select with expressions
SELECT 
    first_name,
    last_name,
    points,
    points + 100 AS 'Points After Bonus'
FROM customers;

-- Select DISTINCT values
SELECT DISTINCT city FROM customers;
SELECT DISTINCT state FROM customers;

-- Count total rows
SELECT COUNT(*) AS 'Total Customers' FROM customers;
```

---

## ⚠️ Common Mistakes

### Mistake 1: String Values Without Quotes

```sql
-- ❌ WRONG
INSERT INTO customers (first_name) VALUES (John);

-- ✅ CORRECT
INSERT INTO customers (first_name) VALUES ('John');
```

### Mistake 2: Wrong Date Format

```sql
-- ❌ WRONG (in most configurations)
INSERT INTO customers (birth_date) VALUES ('15-01-1990');

-- ✅ CORRECT (ISO 8601 format)
INSERT INTO customers (birth_date) VALUES ('1990-01-15');
```

### Mistake 3: Missing Required (NOT NULL) Columns

```sql
-- ❌ WRONG if first_name is NOT NULL
INSERT INTO customers (last_name, email) VALUES ('Smith', 'smith@email.com');

-- ✅ CORRECT
INSERT INTO customers (first_name, last_name, email) 
VALUES ('John', 'Smith', 'smith@email.com');
```

### Mistake 4: SELECT * in Production Code

```sql
-- ❌ Bad practice in application code
SELECT * FROM customers;

-- ✅ Better: specify exactly what you need
SELECT customer_id, first_name, last_name, email FROM customers;
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS university;
USE university;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    gpa DECIMAL(3,2),
    major VARCHAR(50),
    enrollment_year YEAR
);
```

### Exercise 1: Insert Data

Insert 10 students into the `students` table with varying GPAs, majors, and enrollment years.

### Exercise 2: Basic SELECT

Write queries to:
1. Get all students
2. Get only first_name and last_name of all students
3. Get the email and GPA of all students
4. Get all unique majors

### Exercise 3: SELECT with Expressions

Write queries to:
1. Display each student's full name (concatenate first + last)
2. Show GPA with a 10% bonus (gpa * 1.10)
3. Count total number of students

### Exercise 4: Practice Multi-Row Insert

Insert 5 more students using a single INSERT statement with multiple VALUE rows.

---

## 🧠 Key Takeaways

- **INSERT** adds new rows; **SELECT** reads existing rows
- Use **multi-row INSERT** for bulk data (much faster)
- `SELECT *` is fine for exploration but avoid in production code
- Use **column aliases** (`AS`) to rename columns in output
- **Expressions** let you calculate new values on the fly
- String values need **single quotes**; numbers do not

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 02: Creating Tables →](./lesson-02-create-table.md)  
**Next:** [Lesson 04: WHERE Clause Deep Dive →](./lesson-04-where.md)
