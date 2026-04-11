# Lesson 15: String Functions, Date Functions & CASE

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟧 Bro Code | 3:00:00 – 3:35:00 | 35 min |
| 🟩 Brototype | 2:50:00 – 3:15:00 | 25 min |

## 📖 Theory

### String Functions

MySQL provides many functions for manipulating and analyzing text data.

| Function | Description | Example | Result |
|----------|-------------|---------|--------|
| `CONCAT(a, b)` | Join strings | `CONCAT('Hello', ' ', 'World')` | `'Hello World'` |
| `CONCAT_WS(sep, a, b)` | Join with separator | `CONCAT_WS('-', 'a', 'b')` | `'a-b'` |
| `LENGTH(str)` | Byte length | `LENGTH('hello')` | `5` |
| `CHAR_LENGTH(str)` | Character length | `CHAR_LENGTH('hello')` | `5` |
| `UPPER(str)` | Uppercase | `UPPER('hello')` | `'HELLO'` |
| `LOWER(str)` | Lowercase | `LOWER('HELLO')` | `'hello'` |
| `SUBSTRING(str, start, len)` | Extract substring | `SUBSTRING('hello', 2, 3)` | `'ell'` |
| `LEFT(str, n)` | First n characters | `LEFT('hello', 2)` | `'he'` |
| `RIGHT(str, n)` | Last n characters | `RIGHT('hello', 2)` | `'lo'` |
| `TRIM(str)` | Remove leading/trailing spaces | `TRIM('  hi  ')` | `'hi'` |
| `LTRIM(str)` / `RTRIM(str)` | Trim left/right | `LTRIM('  hi')` | `'hi'` |
| `REPLACE(str, from, to)` | Replace substring | `REPLACE('hello', 'l', 'L')` | `'heLLo'` |
| `REVERSE(str)` | Reverse string | `REVERSE('abc')` | `'cba'` |
| `INSERT(str, pos, len, new)` | Insert/replace at position | `INSERT('abc', 2, 1, 'XYZ')` | `'aXYZc'` |
| `LOCATE(substr, str)` | Position of substring | `LOCATE('ll', 'hello')` | `3` |

### Date & Time Functions

| Function | Description | Example | Result |
|----------|-------------|---------|--------|
| `NOW()` | Current date and time | `NOW()` | `'2024-06-15 14:30:00'` |
| `CURDATE()` | Current date | `CURDATE()` | `'2024-06-15'` |
| `CURTIME()` | Current time | `CURTIME()` | `'14:30:00'` |
| `DATE(value)` | Extract date part | `DATE('2024-06-15 14:30')` | `'2024-06-15'` |
| `YEAR(date)` | Extract year | `YEAR('2024-06-15')` | `2024` |
| `MONTH(date)` | Extract month | `MONTH('2024-06-15')` | `6` |
| `DAY(date)` | Extract day | `DAY('2024-06-15')` | `15` |
| `DAYNAME(date)` | Day name | `DAYNAME('2024-06-15')` | `'Saturday'` |
| `MONTHNAME(date)` | Month name | `MONTHNAME('2024-06-15')` | `'June'` |
| `DATE_FORMAT(date, fmt)` | Format date | `DATE_FORMAT(NOW(), '%m/%d/%Y')` | `'06/15/2024'` |
| `DATEDIFF(d1, d2)` | Days between dates | `DATEDIFF('2024-06-15', '2024-01-01')` | `166` |
| `DATE_ADD(date, INTERVAL n unit)` | Add time | `DATE_ADD(NOW(), INTERVAL 7 DAY)` | `+7 days` |
| `DATE_SUB(date, INTERVAL n unit)` | Subtract time | `DATE_SUB(NOW(), INTERVAL 1 MONTH)` | `-1 month` |
| `TIMESTAMPDIFF(unit, d1, d2)` | Difference in units | `TIMESTAMPDIFF(YEAR, '1990-01-01', NOW())` | Age in years |

**DATE_FORMAT patterns:** `%Y` (4-digit year), `%m` (month 01-12), `%d` (day 01-31), `%H` (hour 00-23), `%i` (minutes), `%s` (seconds), `%W` (weekday name), `%M` (month name)

### IFNULL and COALESCE

| Function | Description | Example | Result |
|----------|-------------|---------|--------|
| `IFNULL(a, b)` | Return b if a is NULL | `IFNULL(NULL, 'N/A')` | `'N/A'` |
| `COALESCE(a, b, c, ...)` | Return first non-NULL | `COALESCE(NULL, NULL, 'x', 'y')` | `'x'` |

### CAST

`CAST` converts a value from one data type to another.

```sql
CAST(expression AS type)
```

Common types: `SIGNED`, `UNSIGNED`, `DECIMAL(10,2)`, `DATE`, `DATETIME`, `CHAR`, `JSON`

### CASE WHEN

The `CASE` expression provides conditional logic (like if/else) in SQL.

```sql
-- Simple CASE
CASE column
    WHEN value1 THEN result1
    WHEN value2 THEN result2
    ELSE default_result
END

-- Searched CASE (more flexible)
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END
```

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS functions_db;
USE functions_db;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    hire_date DATE,
    birth_date DATE,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    notes TEXT
);

INSERT INTO employees (first_name, last_name, email, phone, hire_date, birth_date, department, salary, notes)
VALUES
    ('Alice', 'Smith', 'alice.smith@company.com', '+1-555-0100', '2020-01-15', '1990-05-20', 'Engineering', 95000, 'Senior developer  '),
    ('Bob', 'Johnson', 'bob.johnson@company.com', '+1-555-0101', '2021-03-10', '1988-11-30', 'Marketing', 72000, NULL),
    ('Carol', 'Williams', 'carol@company.com', NULL, '2019-07-20', '1992-07-10', 'Engineering', 88000, '  Team lead  '),
    ('David', 'Brown', 'd.brown@company.com', '+44-20-7946-0958', '2022-01-05', '1995-03-15', 'Sales', 68000, '  '),
    ('Eve', 'Davis', 'eve@company.com', '+1-555-0104', '2018-05-12', '1985-01-25', 'Engineering', 105000, 'Principal engineer');
```

### Example 1: String Functions

```sql
-- CONCAT: Build full names
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    department
FROM employees;

-- UPPER / LOWER
SELECT
    UPPER(first_name) AS name_upper,
    LOWER(last_name) AS name_lower
FROM employees;

-- SUBSTRING: Extract parts
SELECT
    email,
    SUBSTRING(email, 1, LOCATE('@', email) - 1) AS username,
    SUBSTRING(email, LOCATE('@', email) + 1) AS domain
FROM employees;

-- LEFT / RIGHT
SELECT
    LEFT(email, 5) AS email_prefix,
    RIGHT(phone, 4) AS phone_last4
FROM employees;

-- TRIM: Clean up notes
SELECT notes, TRIM(notes) AS cleaned_notes FROM employees;

-- REPLACE: Format phone numbers
SELECT
    phone,
    REPLACE(REPLACE(phone, '-', ''), '+', '') AS digits_only
FROM employees;

-- LENGTH
SELECT
    first_name,
    LENGTH(first_name) AS byte_length,
    CHAR_LENGTH(first_name) AS char_length
FROM employees;
```

### Example 2: Date Functions

```sql
-- Extract components
SELECT
    hire_date,
    YEAR(hire_date) AS hire_year,
    MONTH(hire_date) AS hire_month,
    DAY(hire_date) AS hire_day,
    DAYNAME(hire_date) AS hire_day_name,
    MONTHNAME(hire_date) AS hire_month_name
FROM employees;

-- DATE_FORMAT: Custom formatting
SELECT
    first_name,
    DATE_FORMAT(hire_date, '%M %d, %Y') AS hire_formatted,
    DATE_FORMAT(hire_date, '%m/%d/%Y') AS hire_us,
    DATE_FORMAT(hire_date, '%Y-%m-%d') AS hire_iso
FROM employees;

-- DATEDIFF: Years of service
SELECT
    first_name,
    hire_date,
    DATEDIFF(CURDATE(), hire_date) AS days_worked,
    ROUND(DATEDIFF(CURDATE(), hire_date) / 365, 1) AS years_worked
FROM employees;

-- TIMESTAMPDIFF: Calculate age
SELECT
    first_name,
    birth_date,
    TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age
FROM employees;

-- DATE_ADD / DATE_SUB
SELECT
    hire_date,
    DATE_ADD(hire_date, INTERVAL 90 DAY) AS probation_ends,
    DATE_ADD(hire_date, INTERVAL 1 YEAR) AS anniversary,
    DATE_SUB(CURDATE(), INTERVAL 30 DAY) AS thirty_days_ago
FROM employees;
```

### Example 3: IFNULL and COALESCE

```sql
-- IFNULL: Replace NULL phone
SELECT
    first_name,
    IFNULL(phone, 'N/A') AS contact_phone
FROM employees;

-- COALESCE: First non-NULL value
SELECT
    first_name,
    COALESCE(phone, email, 'No contact') AS best_contact
FROM employees;

-- COALESCE in aggregation
SELECT
    department,
    COUNT(*) AS count,
    COALESCE(AVG(salary), 0) AS avg_salary
FROM employees
GROUP BY department;
```

### Example 4: CAST

```sql
-- CAST string to number
SELECT CAST('12345' AS SIGNED) AS num;

-- CAST number to string
SELECT CAST(salary AS CHAR) AS salary_text FROM employees;

-- CAST string to date
SELECT CAST('2024-06-15' AS DATE) AS the_date;

-- CAST decimal precision
SELECT CAST(99.999 AS DECIMAL(10,2)) AS rounded;
-- Result: 100.00
```

### Example 5: CASE WHEN

```sql
-- Salary grade
SELECT
    first_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'Executive'
        WHEN salary >= 80000 THEN 'Senior'
        WHEN salary >= 60000 THEN 'Mid-level'
        ELSE 'Junior'
    END AS grade
FROM employees;

-- Department category
SELECT
    first_name,
    department,
    CASE department
        WHEN 'Engineering' THEN 'Technical'
        WHEN 'Marketing' THEN 'Creative'
        WHEN 'Sales' THEN 'Revenue'
        ELSE 'Support'
    END AS category
FROM employees;

-- Tenure-based bonus
SELECT
    first_name,
    hire_date,
    CASE
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 5 THEN salary * 0.20
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 3 THEN salary * 0.15
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 1 THEN salary * 0.10
        ELSE salary * 0.05
    END AS bonus
FROM employees;

-- CASE in ORDER BY
SELECT first_name, department, salary
FROM employees
ORDER BY
    CASE department
        WHEN 'Engineering' THEN 1
        WHEN 'Marketing' THEN 2
        WHEN 'Sales' THEN 3
        ELSE 4
    END,
    salary DESC;
```

### Example 6: Combined Functions

```sql
-- Full employee profile
SELECT
    CONCAT(UPPER(LEFT(first_name, 1)), '.', UPPER(last_name)) AS display_name,
    CONCAT(
        LEFT(first_name, 1),
        LEFT(last_name, 7),
        '@company.com'
    ) AS standardized_email,
    TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age,
    CONCAT(
        YEAR(CURDATE()) - YEAR(hire_date),
        ' years, ',
        MONTH(CURDATE()) - MONTH(hire_date),
        ' months'
    ) AS tenure_approx,
    IFNULL(phone, 'No phone on file') AS contact,
    CASE
        WHEN CHAR_LENGTH(TRIM(COALESCE(notes, ''))) = 0 THEN 'No notes'
        ELSE TRIM(notes)
    END AS clean_notes
FROM employees;
```

---

## ⚠️ Common Mistakes

### Mistake 1: LENGTH vs CHAR_LENGTH

```sql
-- ❌ WRONG for character count: LENGTH counts bytes
SELECT LENGTH('hello');        -- 5 (OK for ASCII)
SELECT LENGTH('你好');          -- 6 (3 bytes per Chinese char!)

-- ✅ CORRECT for character count
SELECT CHAR_LENGTH('你好');    -- 2 (correct character count)
```

### Mistake 2: SUBSTRING Off-by-One

```sql
-- ❌ WRONG: SUBSTRING is 1-indexed, not 0-indexed
SELECT SUBSTRING('hello', 0, 3);  -- Returns '' (position 0 is empty)

-- ✅ CORRECT: Start at position 1
SELECT SUBSTRING('hello', 1, 3);  -- Returns 'hel'
```

### Mistake 3: DATE_FORMAT Wrong Patterns

```sql
-- ❌ WRONG: %M is month name, %m is month number
SELECT DATE_FORMAT(NOW(), '%M/%d/%Y');  -- 'June/15/2024'

-- ✅ CORRECT: Use %m for numeric month
SELECT DATE_FORMAT(NOW(), '%m/%d/%Y');  -- '06/15/2024'
```

### Mistake 4: CASE Without ELSE

```sql
-- ⚠️ TRAP: CASE without ELSE returns NULL for unmatched rows
SELECT first_name,
    CASE WHEN salary > 90000 THEN 'High' END AS level
FROM employees;
-- Bob, Carol, David get NULL for level

-- ✅ CORRECT: Always include ELSE
SELECT first_name,
    CASE WHEN salary > 90000 THEN 'High' ELSE 'Standard' END AS level
FROM employees;
```

---

## ✅ Exercises

### Setup (using functions_db from above)

### Exercise 1: String Functions
1. Create an email list showing just the username part (before @)
2. Format phone numbers to show only last 4 digits
3. Find employees whose last name starts with 'S'
4. Create initials: "A. Smith" from first_name and last_name

### Exercise 2: Date Functions
1. Find all employees hired in 2020 or later
2. Calculate everyone's age in years
3. Find employees hired in the month of May
4. Find employees hired on a Monday

### Exercise 3: CASE WHEN
1. Categorize employees by salary: < 70K = 'Junior', 70K-90K = 'Mid', > 90K = 'Senior'
2. Create a contact priority: show phone if available, else email, else 'No contact'
3. Order employees by department (Engineering first, then Marketing, then Sales, then others)

### Exercise 4: Combined Challenge
Create an employee directory report showing:
- Display name as "LAST, First"
- Age
- Years of service
- Salary grade (via CASE)
- Clean contact info (IFNULL for missing phone)
- Sorted by department, then by years of service DESC

---

## 🧠 Key Takeaways

- **CONCAT** joins strings; **CONCAT_WS** joins with a separator
- **LENGTH** counts bytes; **CHAR_LENGTH** counts characters
- **SUBSTRING(str, pos, len)** is 1-indexed
- **DATE_FORMAT** uses `%Y`, `%m`, `%d`, `%H`, `%i`, `%s` patterns
- **DATEDIFF** returns days; **TIMESTAMPDIFF** returns in specified unit
- **IFNULL(a, b)** is MySQL-specific; **COALESCE(a, b, c)** is standard SQL
- **CASE WHEN** provides conditional logic — always include **ELSE** to avoid NULLs
- **CAST** converts between data types
- Combining functions enables powerful data transformation in pure SQL

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 14: Subqueries →](./lesson-14-subqueries.md)
**Next:** [Lesson 16: Window Functions & CTEs →](./lesson-16-window-functions-ctes.md)
