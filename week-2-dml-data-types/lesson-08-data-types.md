# Lesson 08: Data Types Deep Dive

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟧 Bro Code | 2:00:00 – 2:35:00 | 35 min |
| 🟩 Brototype | 1:20:00 – 1:45:00 | 25 min |

## 📖 Theory

MySQL data types define what kind of values a column can store. Choosing the right data type is critical for **data integrity**, **storage efficiency**, and **query performance**.

### Numeric Data Types

#### Integer Types

| Type | Size | Signed Range | Unsigned Range | Use When |
|------|------|-------------|----------------|----------|
| `TINYINT` | 1 byte | -128 to 127 | 0 to 255 | Age, status flags, small counts |
| `SMALLINT` | 2 bytes | -32,768 to 32,767 | 0 to 65,535 | Medium counts, year values |
| `MEDIUMINT` | 3 bytes | -8M to 8M | 0 to 16M | Larger counts |
| `INT` | 4 bytes | -2B to 2B | 0 to 4B | Primary keys, most counts |
| `BIGINT` | 8 bytes | -9 quintillion to 9 quintillion | 0 to 18 quintillion | Very large counts, timestamps in ms |

```sql
-- TINYINT for age (0-255 is enough)
age TINYINT UNSIGNED

-- INT for primary keys (up to 4 billion rows)
id INT PRIMARY KEY AUTO_INCREMENT

-- BIGINT for very large counters
view_count BIGINT UNSIGNED
```

#### Decimal and Floating-Point Types

| Type | Size | Precision | Use When |
|------|------|-----------|----------|
| `DECIMAL(M,D)` | Variable | Exact (M digits, D decimal places) | **Money, prices** (always use this!) |
| `FLOAT` | 4 bytes | ~7 significant digits | Scientific calculations (approximate) |
| `DOUBLE` | 8 bytes | ~15 significant digits | High-precision scientific (approximate) |

```sql
-- DECIMAL for money: DECIMAL(total_digits, decimal_places)
price DECIMAL(10,2)    -- Up to 99,999,999.99
salary DECIMAL(12,2)   -- Up to 999,999,999,999.99

-- FLOAT/DOUBLE for approximate values
scientific_value FLOAT
gps_coordinate DOUBLE
```

> ⚠️ **Never use FLOAT or DOUBLE for money.** They store approximate values due to floating-point representation. Always use `DECIMAL`.

### String Data Types

| Type | Max Length | Storage | Use When |
|------|-----------|---------|----------|
| `CHAR(n)` | 0–255 chars | Fixed-length (padded with spaces) | Country codes, hashes, fixed-length values |
| `VARCHAR(n)` | 0–65,535 chars | Variable-length (+1 or +2 bytes for length) | **Most text** — names, emails, descriptions |
| `TINYTEXT` | 255 bytes | Variable | Short free-form text |
| `TEXT` | 65KB | Variable | Articles, comments, descriptions |
| `MEDIUMTEXT` | 16MB | Variable | Long articles, logs |
| `LONGTEXT` | 4GB | Variable | Very large text data |
| `BLOB` | 65KB | Variable | Binary data (images, files) |
| `ENUM('a','b')` | 1-2 bytes | One value from a list | Status, category, type |
| `SET('a','b')` | 1-8 bytes | Zero or more values from a list | Multiple tags, flags |

```sql
-- CHAR for fixed-length values
country_code CHAR(2)         -- 'US', 'UK', 'JP'
password_hash CHAR(64)       -- SHA-256 hash

-- VARCHAR for variable-length text
email VARCHAR(100)
name VARCHAR(50)
description VARCHAR(500)

-- TEXT for longer content
article_body TEXT
user_bio TEXT

-- ENUM for predefined choices
status ENUM('active', 'inactive', 'suspended') DEFAULT 'active'
priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium'

-- SET for multiple selections
permissions SET('read', 'write', 'delete', 'admin')
-- Can store: 'read', 'read,write', 'read,write,delete,admin', etc.
```

### Date/Time Data Types

| Type | Format | Range | Use When |
|------|--------|-------|----------|
| `DATE` | `YYYY-MM-DD` | 1000-01-01 to 9999-12-31 | Birthdays, event dates |
| `TIME` | `HH:MM:SS` | -838:59:59 to 838:59:59 | Durations, time of day |
| `DATETIME` | `YYYY-MM-DD HH:MM:SS` | 1000-01-01 to 9999-12-31 | Timestamps without timezone |
| `TIMESTAMP` | `YYYY-MM-DD HH:MM:SS` | 1970-01-01 to 2038-01-19 | Auto-updating timestamps |
| `YEAR` | `YYYY` | 1901 to 2155 | Graduation year, manufacturing year |

```sql
-- DATE for calendar dates
birth_date DATE
hire_date DATE

-- DATETIME for specific moments (no timezone conversion)
created_at DATETIME DEFAULT CURRENT_TIMESTAMP

-- TIMESTAMP for auto-managed timestamps (converts to UTC)
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

-- TIME for durations or time of day
opening_time TIME
duration TIME

-- YEAR for year-only values
graduation_year YEAR
manufacturing_year YEAR
```

### Boolean Type

MySQL has no native `BOOLEAN` type. `BOOL` and `BOOLEAN` are synonyms for `TINYINT(1)`.

```sql
-- These are all equivalent:
is_active BOOLEAN          -- Stored as TINYINT(1): 0 = false, 1 = true
is_verified BOOL           -- Same
is_active TINYINT(1)       -- Same

-- Usage:
INSERT INTO users (name, is_active) VALUES ('Alice', TRUE);   -- Stored as 1
INSERT INTO users (name, is_active) VALUES ('Bob', FALSE);    -- Stored as 0

SELECT * FROM users WHERE is_active = TRUE;   -- Same as is_active = 1
SELECT * FROM users WHERE is_active;          -- Also works
```

---

## 💻 Examples

```sql
CREATE DATABASE IF NOT EXISTS datatypes_db;
USE datatypes_db;

-- Comprehensive data type example
CREATE TABLE products (
    product_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sku CHAR(10) NOT NULL UNIQUE,           -- Fixed-length code
    name VARCHAR(100) NOT NULL,              -- Variable-length name
    description TEXT,                         -- Long text
    price DECIMAL(10,2) NOT NULL,            -- Exact money
    cost DECIMAL(10,2),                      -- Cost price
    weight FLOAT,                            -- Approximate weight
    stock SMALLINT UNSIGNED DEFAULT 0,       -- Inventory count
    category ENUM('Electronics', 'Furniture', 'Stationery', 'Clothing'),
    tags SET('new', 'sale', 'featured', 'clearance'),
    is_available BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    release_date DATE,
    warranty_years TINYINT UNSIGNED DEFAULT 1
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone CHAR(15),                          -- Fixed format phone
    salary DECIMAL(12,2) NOT NULL,
    hire_date DATE NOT NULL,
    birth_date DATE,
    department_id SMALLINT UNSIGNED,
    is_manager TINYINT(1) DEFAULT 0,
    login_attempts TINYINT UNSIGNED DEFAULT 0,
    last_login TIMESTAMP NULL
);

-- Insert sample data
INSERT INTO products (sku, name, description, price, cost, stock, category, tags, is_available, release_date, warranty_years)
VALUES
    ('ELEC-001', 'Laptop', 'High-performance laptop for professionals', 999.99, 750.00, 50, 'Electronics', 'new,featured', TRUE, '2024-01-15', 2),
    ('FURN-001', 'Desk Chair', 'Ergonomic office chair', 249.99, 180.00, 30, 'Furniture', 'sale', TRUE, '2023-06-01', 1),
    ('STAT-001', 'Notebook', 'A5 lined notebook', 12.99, 5.00, 500, 'Stationery', 'clearance', TRUE, '2022-01-01', 0);

INSERT INTO employees (first_name, last_name, email, phone, salary, hire_date, birth_date, department_id, is_manager)
VALUES
    ('Alice', 'Smith', 'alice@company.com', '+1-555-0100', 95000.00, '2020-01-15', '1990-05-20', 1, 1),
    ('Bob', 'Johnson', 'bob@company.com', '+1-555-0101', 72000.00, '2021-03-10', '1988-11-30', 2, 0);
```

---

## ⚠️ Common Mistakes

### Mistake 1: Using VARCHAR for Fixed-Length Data

```sql
-- ❌ WASTEFUL: VARCHAR wastes space for fixed-length values
country VARCHAR(50)    -- 'US' stored with length prefix + padding

-- ✅ CORRECT: Use CHAR for fixed-length
country CHAR(2)        -- Always exactly 2 bytes
```

### Mistake 2: Using FLOAT for Money

```sql
-- ❌ DANGEROUS: Floating-point arithmetic errors
price FLOAT    -- 0.1 + 0.2 might not equal 0.3

-- ✅ CORRECT: Use DECIMAL for exact values
price DECIMAL(10,2)   -- 0.1 + 0.2 = 0.30 exactly
```

### Mistake 3: VARCHAR Too Short

```sql
-- ❌ RISKY: Truncates long emails
email VARCHAR(20)    -- 'very.long.email.address@gmail.com' gets cut!

-- ✅ CORRECT: Allow enough space
email VARCHAR(255)   -- Standard email max is 254 chars
```

### Mistake 4: TIMESTAMP Range Limitation

```sql
-- ❌ WRONG: TIMESTAMP only supports 1970-2038
birth_date TIMESTAMP    -- Can't store dates before 1970!

-- ✅ CORRECT: Use DATETIME for historical dates
birth_date DATE        -- or DATETIME for full timestamps
```

---

## ✅ Exercises

### Exercise 1: Choose the Right Type
For each scenario, pick the best MySQL data type:
1. A user's age
2. A product's price
3. A blog post title (max 200 chars)
4. Whether a user has verified their email
5. A blog post's full content
6. A country code (2 letters)
7. A GPS coordinate (latitude/longitude)
8. An order's total amount
9. A phone number in international format
10. A record's creation timestamp

### Exercise 2: Create Tables with Proper Types
1. Create a `movies` table with: title, release_year, duration (in minutes), rating (DECIMAL), genre (ENUM), description, poster_url
2. Create an `orders` table with: order_number (fixed 10-char code), total, tax_amount, shipping_cost, status (ENUM), placed_at, shipped_at
3. Create a `students` table with: student_id, first_name, last_name, email, gpa, enrollment_date, graduation_year, is_enrolled

---

## 🧠 Key Takeaways

- Use **DECIMAL** for money, **FLOAT/DOUBLE** for approximate scientific values
- Use **CHAR** for fixed-length data, **VARCHAR** for variable-length text
- Use **TEXT** for long content (articles, comments)
- Use **ENUM** for a fixed set of choices, **SET** for multiple selections
- **TIMESTAMP** auto-converts to UTC and has a 2038 limit; use **DATETIME** for historical dates
- **BOOLEAN** is `TINYINT(1)` in MySQL — `TRUE` = 1, `FALSE` = 0
- Choose the **smallest type** that fits your data — it saves storage and improves performance

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 07: DELETE →](../week-2-dml-data-types/lesson-07-delete.md)
**Next:** [Lesson 09: Constraints →](./lesson-09-constraints.md)
