# Lesson 13: ALTER TABLE & Schema Modifications

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟧 Bro Code | 4:00:00 – 4:20:00 | 20 min |
| 🟩 Brototype | 2:45:00 – 3:05:00 | 20 min |

## 📖 Theory

### ALTER TABLE

The `ALTER TABLE` statement modifies the structure of an existing table. It is one of the DDL (Data Definition Language) commands and is essential for **schema evolution** — changing your database as requirements change over time.

### What You Can Do with ALTER TABLE

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Add column | `ADD COLUMN col_name type` | Add a new column |
| Drop column | `DROP COLUMN col_name` | Remove a column and its data |
| Modify column | `MODIFY COLUMN col_name new_type` | Change data type or constraints |
| Change column | `CHANGE COLUMN old new new_type` | Rename and/or change type |
| Rename table | `RENAME TO new_name` | Change table name |
| Add constraint | `ADD CONSTRAINT ...` | Add PK, FK, UNIQUE, CHECK |
| Drop constraint | `DROP INDEX/CONSTRAINT name` | Remove a constraint |
| Add index | `ADD INDEX idx_name (col)` | Add an index |
| Set default | `ALTER col_name SET DEFAULT val` | Change default value |
| Drop default | `ALTER col_name DROP DEFAULT` | Remove default value |

### Important Notes

- `ALTER TABLE` operations can **lock the table** on large datasets
- Some operations (like `DROP COLUMN`) are **irreversible** — backup first
- `MODIFY` requires you to respecify the entire column definition
- `CHANGE` can rename AND modify in one operation

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS alter_demo;
USE alter_demo;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100)
);

INSERT INTO users (username, email)
VALUES ('alice', 'alice@email.com'), ('bob', 'bob@email.com');
```

### Example 1: ADD COLUMN

```sql
-- Add a single column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Add with DEFAULT
ALTER TABLE users ADD COLUMN is_active TINYINT(1) DEFAULT 1;

-- Add with position (FIRST or AFTER column)
ALTER TABLE users ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER email;

-- Add multiple columns
ALTER TABLE users
    ADD COLUMN first_name VARCHAR(50),
    ADD COLUMN last_name VARCHAR(50),
    ADD COLUMN birth_date DATE;
```

### Example 2: DROP COLUMN

```sql
-- Remove a column (data is lost!)
ALTER TABLE users DROP COLUMN phone;

-- Drop multiple columns
ALTER TABLE users
    DROP COLUMN first_name,
    DROP COLUMN last_name;
```

### Example 3: MODIFY COLUMN

```sql
-- Change data type (must be compatible with existing data)
ALTER TABLE users MODIFY COLUMN email VARCHAR(255);

-- Add NOT NULL (only works if no NULL values exist)
ALTER TABLE users MODIFY COLUMN email VARCHAR(255) NOT NULL;

-- Add UNIQUE
ALTER TABLE users MODIFY COLUMN username VARCHAR(50) NOT NULL UNIQUE;

-- Change default
ALTER TABLE users MODIFY COLUMN is_active TINYINT(1) DEFAULT 0;
```

### Example 4: CHANGE COLUMN (Rename + Modify)

```sql
-- Rename a column
ALTER TABLE users CHANGE COLUMN username user_name VARCHAR(50) NOT NULL;

-- Rename AND change type
ALTER TABLE users CHANGE COLUMN email email_address VARCHAR(255) NOT NULL;

-- CHANGE requires you to respecify the type even if not changing it
ALTER TABLE users CHANGE COLUMN is_active is_active TINYINT(1) DEFAULT 1;
```

### Example 5: ADD Constraints

```sql
-- Add UNIQUE constraint
ALTER TABLE users ADD CONSTRAINT uq_email UNIQUE (email_address);

-- Add CHECK constraint
ALTER TABLE users ADD CONSTRAINT chk_name_length CHECK (LENGTH(user_name) >= 3);

-- Add a new column with FK
ALTER TABLE users ADD COLUMN role_id INT;
-- (After creating the roles table)
-- ALTER TABLE users ADD FOREIGN KEY (role_id) REFERENCES roles(id);
```

### Example 6: DROP Constraints

```sql
-- Drop UNIQUE constraint (by index name)
ALTER TABLE users DROP INDEX uq_email;

-- Drop CHECK constraint
ALTER TABLE users DROP CHECK chk_name_length;

-- Drop FOREIGN KEY
-- ALTER TABLE users DROP FOREIGN KEY fk_name;
```

### Example 7: RENAME TABLE

```sql
-- Rename a table
ALTER TABLE users RENAME TO accounts;

-- Or use RENAME TABLE statement
RENAME TABLE accounts TO users;

-- Rename multiple tables at once
RENAME TABLE
    users TO customers,
    orders TO customer_orders;
```

### Example 8: Practical Schema Evolution

```sql
-- Starting with a basic table and evolving it
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);

-- Phase 1: Add inventory tracking
ALTER TABLE products
    ADD COLUMN stock INT DEFAULT 0,
    ADD COLUMN sku VARCHAR(20) UNIQUE;

-- Phase 2: Add categorization
ALTER TABLE products
    ADD COLUMN category VARCHAR(50) DEFAULT 'General',
    ADD COLUMN description TEXT AFTER name;

-- Phase 3: Improve constraints
ALTER TABLE products
    MODIFY COLUMN price DECIMAL(10,2) NOT NULL,
    ADD CONSTRAINT chk_positive_price CHECK (price > 0),
    ADD CONSTRAINT chk_stock CHECK (stock >= 0);

-- Phase 4: Add audit columns
ALTER TABLE products
    ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESCRIBE products;
```

---

## ⚠️ Common Mistakes

### Mistake 1: MODIFY Without Respecifying Full Definition

```sql
-- ❌ WRONG: MODIFY only changes what you specify, losing other attributes
ALTER TABLE users MODIFY COLUMN email VARCHAR(255);
-- This DROPS the NOT NULL constraint if it existed!

-- ✅ CORRECT: Always respecify the full definition
ALTER TABLE users MODIFY COLUMN email VARCHAR(255) NOT NULL;
```

### Mistake 2: DROP COLUMN Without Backup

```sql
-- ❌ DANGEROUS: Data is permanently lost
ALTER TABLE users DROP COLUMN email;

-- ✅ SAFE: Backup first, or use soft delete pattern
-- 1. Export data: SELECT email FROM users INTO OUTFILE '/tmp/emails.csv';
-- 2. Then drop
ALTER TABLE users DROP COLUMN email;
```

### Mistake 3: Incompatible Type Change

```sql
-- ❌ WRONG: Can't convert 'alice@email.com' to INT
ALTER TABLE users MODIFY COLUMN username INT;
-- ERROR: Data truncation

-- ✅ CORRECT: Ensure type compatibility or clean data first
-- Clean data, then alter
```

### Mistake 4: Adding NOT NULL to Column with Existing NULLs

```sql
-- ❌ WRONG: Can't add NOT NULL if NULL values exist
ALTER TABLE users ADD COLUMN phone VARCHAR(20) NOT NULL;
-- ERROR if any existing rows have NULL phone

-- ✅ CORRECT: Add with DEFAULT first, then modify
ALTER TABLE users ADD COLUMN phone VARCHAR(20) DEFAULT 'N/A';
-- Or update existing NULLs first
UPDATE users SET phone = 'N/A' WHERE phone IS NULL;
ALTER TABLE users MODIFY COLUMN phone VARCHAR(20) NOT NULL;
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS alter_exercises;
USE alter_exercises;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    dept VARCHAR(50)
);

INSERT INTO employees (name, dept)
VALUES ('Alice', 'Engineering'), ('Bob', 'Marketing'), ('Carol', NULL);
```

### Exercise 1: Add Columns
1. Add an `email` column (VARCHAR(100), UNIQUE)
2. Add a `salary` column (DECIMAL(10,2), default 50000)
3. Add a `hire_date` column (DATE, default CURRENT_DATE)
4. Add an `is_active` column (BOOLEAN, default TRUE)

### Exercise 2: Modify Columns
1. Change `name` to NOT NULL
2. Change `dept` to `department` (rename it)
3. Change `salary` to NOT NULL with a CHECK constraint (salary > 0)

### Exercise 3: Constraints
1. Add a UNIQUE constraint on email
2. Add a CHECK constraint that name must be at least 2 characters
3. Add a CHECK constraint that department is one of: 'Engineering', 'Marketing', 'Sales', 'HR'

### Exercise 4: Schema Evolution
1. Start with a simple `orders` table (id, total)
2. Add: customer_id (FK to a new customers table), status (ENUM), created_at
3. Add constraints: total > 0, status defaults to 'pending'
4. Rename the table to `customer_orders`

---

## 🧠 Key Takeaways

- **ALTER TABLE** modifies existing table structure — DDL operation
- **ADD COLUMN** adds new columns; **DROP COLUMN** removes them (data lost!)
- **MODIFY** changes type/constraints — must respecify the full column definition
- **CHANGE** renames AND/OR modifies — requires respecifying type even if unchanged
- **RENAME TABLE** changes table name (or use `RENAME TABLE` statement)
- Constraints can be **added** or **dropped** with ALTER TABLE
- ALTER TABLE can **lock tables** on large datasets — be careful in production
- Always **backup** before destructive ALTER operations (DROP COLUMN, type changes)

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 12: Aggregate Functions & GROUP BY →](../week-3-joins-functions/lesson-12-aggregations.md)
**Next:** [Lesson 14: How Indexes Work (Theory) →](./lesson-14-indexes-theory.md)
