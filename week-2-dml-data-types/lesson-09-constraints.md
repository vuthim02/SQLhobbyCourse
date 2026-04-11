# Lesson 09: Constraints

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟧 Bro Code | 2:35:00 – 3:00:00 | 25 min |
| 🟩 Brototype | 1:45:00 – 2:05:00 | 20 min |

## 📖 Theory

### What Are Constraints?

**Constraints** are rules applied to columns that enforce data integrity. They prevent invalid data from being inserted, updated, or deleted.

### Constraint Types

| Constraint | Purpose | Example |
|-----------|---------|---------|
| `NOT NULL` | Column cannot contain NULL | `name VARCHAR(50) NOT NULL` |
| `UNIQUE` | All values must be different | `email VARCHAR(100) UNIQUE` |
| `PRIMARY KEY` | NOT NULL + UNIQUE combined | `id INT PRIMARY KEY` |
| `DEFAULT` | Sets a value when none provided | `status VARCHAR(20) DEFAULT 'pending'` |
| `CHECK` | Values must satisfy condition | `age INT CHECK (age >= 18)` |
| `FOREIGN KEY` | References another table's key | `dept_id INT REFERENCES departments(id)` |
| `AUTO_INCREMENT` | Auto-generates sequential numbers | `id INT AUTO_INCREMENT` |

### NOT NULL

Ensures a column always has a value.

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,    -- Must always have a value
    email VARCHAR(100) NOT NULL,
    bio TEXT                           -- Can be NULL (optional)
);
```

### UNIQUE

All values in the column must be different.

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE,         -- No duplicate emails
    phone VARCHAR(20) UNIQUE           -- No duplicate phones
);
```

> **Note:** UNIQUE allows multiple NULL values (NULL ≠ NULL in SQL).

### DEFAULT

Provides a fallback value when no value is specified.

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    status VARCHAR(20) DEFAULT 'pending',
    quantity INT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    country VARCHAR(50) DEFAULT 'USA'
);

-- These insert with defaults:
INSERT INTO orders (order_id) VALUES (NULL);
-- status = 'pending', quantity = 1, country = 'USA', created_at = NOW()

INSERT INTO orders (order_id, status) VALUES (NULL, 'express');
-- quantity = 1, country = 'USA', created_at = NOW()
```

### CHECK

Ensures values meet a specific condition.

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    stock INT CHECK (stock >= 0),
    discount DECIMAL(5,2) CHECK (discount >= 0 AND discount <= 100),
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    email VARCHAR(100) CHECK (email LIKE '%@%')
);
```

> **Note:** CHECK constraints were added in MySQL 8.0.16. Earlier versions silently ignored them.

### Named Constraints

You can name constraints explicitly for better error messages and easier management.

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    salary DECIMAL(10,2),
    age INT,

    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_salary_positive CHECK (salary > 0),
    CONSTRAINT chk_age_range CHECK (age >= 18 AND age <= 100),
    CONSTRAINT uq_email UNIQUE (email)
);
```

### Composite Constraints

Constraints can span multiple columns.

```sql
CREATE TABLE reservations (
    room_id INT,
    start_time TIME,
    end_time TIME,
    booked_by VARCHAR(50),

    PRIMARY KEY (room_id, start_time),          -- Composite primary key
    UNIQUE (room_id, start_time, end_time),     -- Composite unique
    CHECK (start_time < end_time)               -- Multi-column check
);
```

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS constraints_db;
USE constraints_db;
```

### Example 1: NOT NULL

```sql
CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password_hash CHAR(64) NOT NULL,
    display_name VARCHAR(100),     -- Optional
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ✅ Works:
INSERT INTO accounts (username, password_hash) VALUES ('alice', 'abc123');

-- ❌ Fails: username cannot be NULL
INSERT INTO accounts (username, password_hash) VALUES (NULL, 'def456');
-- ERROR: Column 'username' cannot be null
```

### Example 2: UNIQUE

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE
);

-- ✅ Works:
INSERT INTO users (username, email) VALUES ('alice', 'alice@email.com');
INSERT INTO users (username, email) VALUES ('bob', NULL);  -- NULL is OK

-- ❌ Fails: Duplicate email
INSERT INTO users (username, email) VALUES ('charlie', 'alice@email.com');
-- ERROR: Duplicate entry 'alice@email.com' for key 'email'
```

### Example 3: DEFAULT

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    category VARCHAR(50) DEFAULT 'General',
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insert with all defaults:
INSERT INTO products (name, price) VALUES ('Widget', 9.99);
-- stock = 0, category = 'General', is_active = 1, created_at = NOW()

-- Override some defaults:
INSERT INTO products (name, price, stock, category) VALUES ('Gadget', 19.99, 100, 'Electronics');
```

### Example 4: CHECK

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) CHECK (email LIKE '%@%.%'),
    age INT CHECK (age >= 18 AND age <= 120),
    salary DECIMAL(10,2) CHECK (salary >= 0),
    rating TINYINT CHECK (rating BETWEEN 1 AND 5)
);

-- ✅ Works:
INSERT INTO employees (name, email, age, salary, rating)
VALUES ('Alice', 'alice@company.com', 30, 75000, 4);

-- ❌ Fails: Age below 18
INSERT INTO employees (name, email, age, salary)
VALUES ('Bob', 'bob@company.com', 15, 50000);
-- ERROR: Check constraint 'age' is violated
```

### Example 5: Adding Constraints to Existing Tables

```sql
CREATE TABLE items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    price DECIMAL(10,2),
    quantity INT
);

-- Add NOT NULL
ALTER TABLE items MODIFY name VARCHAR(100) NOT NULL;

-- Add UNIQUE
ALTER TABLE items ADD CONSTRAINT uq_name UNIQUE (name);

-- Add CHECK
ALTER TABLE items ADD CONSTRAINT chk_price CHECK (price > 0);
ALTER TABLE items ADD CONSTRAINT chk_quantity CHECK (quantity >= 0);

-- Add DEFAULT (MySQL uses ALTER TABLE ... ALTER COLUMN ... SET DEFAULT)
ALTER TABLE items ALTER quantity SET DEFAULT 0;
```

### Example 6: Dropping Constraints

```sql
-- Drop UNIQUE constraint
ALTER TABLE items DROP INDEX uq_name;

-- Drop CHECK constraint
ALTER TABLE items DROP CHECK chk_price;

-- Drop DEFAULT
ALTER TABLE items ALTER quantity DROP DEFAULT;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Confusing UNIQUE with PRIMARY KEY

```sql
-- ❌ WRONG thinking: UNIQUE means "this is the main identifier"
CREATE TABLE users (
    id INT UNIQUE,    -- This allows NULL and doesn't auto-index as PK
    email VARCHAR(100) PRIMARY KEY
);

-- ✅ CORRECT: Use PRIMARY KEY for the main identifier
CREATE TABLE users (
    id INT PRIMARY KEY,       -- NOT NULL + UNIQUE + auto-indexed
    email VARCHAR(100) UNIQUE -- Additional uniqueness constraint
);
```

### Mistake 2: Forgetting NOT NULL on Important Columns

```sql
-- ❌ RISKY: name can be NULL — probably not intended
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),    -- Should be NOT NULL
    price DECIMAL(10,2)
);

-- ✅ CORRECT: Enforce required fields
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
```

### Mistake 3: CHECK Constraint on NULL

```sql
-- ⚠️ TRICKY: CHECK allows NULL (NULL makes the condition UNKNOWN, not FALSE)
CREATE TABLE test (
    val INT CHECK (val > 0)
);

INSERT INTO test (val) VALUES (NULL);  -- ✅ This succeeds!
-- NULL is not > 0, but it's also not FALSE — CHECK passes for UNKNOWN

-- ✅ FIX: Add NOT NULL if you want to prevent NULLs
CREATE TABLE test (
    val INT NOT NULL CHECK (val > 0)
);
```

### Mistake 4: Multiple UNIQUE Constraints

```sql
-- ❌ WRONG: Trying to make multiple columns UNIQUE together
CREATE TABLE users (
    id INT PRIMARY KEY,
    first_name VARCHAR(50) UNIQUE,    -- Each first_name must be unique globally
    last_name VARCHAR(50) UNIQUE      -- Each last_name must be unique globally
);

-- ✅ CORRECT: Use composite UNIQUE for combined uniqueness
CREATE TABLE users (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    UNIQUE (first_name, last_name)    -- The combination must be unique
);
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS bank_db;
USE bank_db;
```

### Exercise 1: Apply Constraints
Create a `accounts` table with:
- `account_number` (CHAR(10), PRIMARY KEY)
- `holder_name` (VARCHAR(100), NOT NULL)
- `email` (VARCHAR(100), UNIQUE, NOT NULL)
- `balance` (DECIMAL(12,2), DEFAULT 0, must be >= 0)
- `account_type` (ENUM('savings', 'checking', 'business'), DEFAULT 'savings')
- `created_at` (DATETIME, DEFAULT CURRENT_TIMESTAMP)
- `is_active` (BOOLEAN, DEFAULT TRUE)

### Exercise 2: Test Constraints
1. Insert 3 valid accounts
2. Try to insert a duplicate email — observe the error
3. Try to insert a negative balance — observe the error
4. Try to insert with NULL holder_name — observe the error
5. Insert an account with only required fields — observe defaults

### Exercise 3: Modify Constraints
1. Add a CHECK constraint to ensure email contains '@'
2. Add a UNIQUE constraint on account_number (if not already PK)
3. Change the default balance to 100

### Exercise 4: Real-World Scenario
Create an `orders` table with constraints:
- Order ID auto-increments
- Customer email is required
- Total must be positive
- Status defaults to 'pending' and can only be 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
- Order date defaults to current timestamp
- Shipping date must be after order date (use CHECK)

---

## 🧠 Key Takeaways

- **NOT NULL** ensures a column always has a value
- **UNIQUE** prevents duplicate values (but allows multiple NULLs)
- **PRIMARY KEY** = NOT NULL + UNIQUE — the main row identifier
- **DEFAULT** provides fallback values when none specified
- **CHECK** enforces custom conditions on values
- **Named constraints** (`CONSTRAINT name CHECK (...)`) give better error messages
- Constraints can be **added** or **dropped** with `ALTER TABLE`
- **CHECK** allows NULL (UNKNOWN is not FALSE) — add NOT NULL if needed

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 08: Data Types Deep Dive →](./lesson-08-data-types.md)
**Next:** [Lesson 10: PRIMARY KEY & FOREIGN KEY →](./lesson-10-keys.md)
