# Lesson 02: Creating Tables & Data Types

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 15:00 – 45:00 | 30 min |
| 🟧 Bro Code | 10:00 – 30:00 | 20 min |

## 📖 Theory

### The CREATE TABLE Statement

```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
    PRIMARY KEY (column_name),
    FOREIGN KEY (column_name) REFERENCES other_table(column)
);
```

### MySQL Data Types

#### Numeric Types

| Type | Size | Range | Use Case |
|------|------|-------|----------|
| **TINYINT** | 1 byte | -128 to 127 | Age, status flags |
| **SMALLINT** | 2 bytes | -32,768 to 32,767 | Small counters |
| **MEDIUMINT** | 3 bytes | -8M to 8M | Medium counters |
| **INT** | 4 bytes | -2B to 2B | IDs, quantities, most numbers |
| **BIGINT** | 8 bytes | -9 quintillion to 9 quintillion | Large counters, timestamps |
| **DECIMAL(m,d)** | Variable | Exact precision | Money, prices |
| **FLOAT** | 4 bytes | Approximate | Scientific data (less precision) |
| **DOUBLE** | 8 bytes | Approximate | Scientific data (more precision) |

```sql
-- DECIMAL example: DECIMAL(10,2) means 10 total digits, 2 after decimal
-- Can store: 99999999.99
price DECIMAL(10,2)

-- INT example
quantity INT
```

#### String Types

| Type | Max Length | Use Case |
|------|-----------|----------|
| **CHAR(n)** | Fixed 0-255 chars | Country codes, fixed-length values |
| **VARCHAR(n)** | Variable 0-65,535 chars | Names, emails, addresses |
| **TEXT** | 65,535 chars | Long text, descriptions, blog posts |
| **MEDIUMTEXT** | 16MB | Very long text |
| **LONGTEXT** | 4GB | Books, massive text data |
| **BLOB** | 65,535 bytes | Binary data (images, files) |
| **ENUM('a','b','c')** | One of listed values | Status: 'pending','active','done' |
| **SET('a','b','c')** | Multiple of listed values | Tags, multiple selections |

```sql
-- VARCHAR vs CHAR
email VARCHAR(100)    -- Uses only as much space as needed
country_code CHAR(2)  -- Always 2 characters, fixed
```

#### Date/Time Types

| Type | Format | Range | Use Case |
|------|--------|-------|----------|
| **DATE** | YYYY-MM-DD | 1000-01-01 to 9999-12-31 | Birth dates, order dates |
| **TIME** | HH:MM:SS | -838:59:59 to 838:59:59 | Duration, time of day |
| **DATETIME** | YYYY-MM-DD HH:MM:SS | 1000 to 9999 | Created timestamps |
| **TIMESTAMP** | YYYY-MM-DD HH:MM:SS | 1970 to 2038 (UTC) | Auto-tracking changes |
| **YEAR** | YYYY | 1901 to 2155 | Graduation year, manufacturing year |

```sql
-- Common patterns
birth_date DATE
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
```

#### Boolean

MySQL has no native BOOLEAN type. `BOOL` and `BOOLEAN` are synonyms for `TINYINT(1)`.

```sql
is_active BOOLEAN        -- Stored as TINYINT(1): 0 = false, 1 = true
is_deleted BOOL          -- Same thing
```

---

## 💻 Examples

### Example 1: Simple Table

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    birth_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Example 2: Products Table

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    category ENUM('Electronics', 'Clothing', 'Books', 'Food') NOT NULL,
    sku CHAR(10) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Example 3: Orders Table

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') 
           DEFAULT 'pending',
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Example 4: Using ENUM and SET

```sql
CREATE TABLE tasks (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    status ENUM('todo', 'in_progress', 'review', 'done') DEFAULT 'todo',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    tags SET('frontend', 'backend', 'design', 'testing', 'docs'),
    due_date DATE
);
```

---

## ✅ Exercises

### Exercise 1: Create a Books Table

```sql
-- Create a table called 'books' with:
-- book_id (primary key, auto increment)
-- title (varchar 150, not null)
-- author (varchar 100, not null)
-- isbn (char 13, unique)
-- published_date (date)
-- price (decimal 8,2)
-- genre (enum: 'fiction', 'non-fiction', 'science', 'history', 'biography')
-- pages (int)
-- created_at (timestamp, default current_timestamp)
```

### Exercise 2: Create an Employees Table

```sql
-- Create a table called 'employees' with:
-- emp_id (primary key, auto increment)
-- first_name, last_name (varchar 50, not null)
-- email (varchar 100, unique, not null)
-- hire_date (date, not null)
-- salary (decimal 10,2)
-- department (enum: 'engineering', 'sales', 'marketing', 'hr', 'finance')
-- is_manager (boolean, default false)
-- phone (varchar 20, can be null)
```

### Exercise 3: Create a Movies Table

```sql
-- Create a table called 'movies' with:
-- movie_id (primary key, auto increment)
-- title (varchar 200, not null)
-- director (varchar 100)
-- release_year (year)
-- runtime_minutes (smallint)
-- rating (enum: 'G', 'PG', 'PG-13', 'R', 'NC-17')
-- description (text)
-- budget (decimal 12,2)
-- box_office (decimal 12,2)
```

---

## 🧠 Key Takeaways

- Choose the **smallest data type** that fits your needs (saves space and improves performance)
- Use **VARCHAR** for variable-length strings, **CHAR** for fixed-length
- Use **DECIMAL** for money (exact), **FLOAT/DOUBLE** for scientific (approximate)
- **TIMESTAMP** auto-updates, **DATETIME** does not
- **ENUM** restricts values to a predefined list
- **AUTO_INCREMENT** automatically generates unique IDs
- Always use **NOT NULL** for required columns

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 01: Intro →](./lesson-01-intro.md)  
**Next:** [Lesson 03: INSERT & SELECT →](./lesson-03-insert-select.md)
