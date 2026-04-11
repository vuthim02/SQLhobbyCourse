# Lesson 19: Database Design Principles

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 3:30:00 – 4:15:00 | 45 min |

## 📖 Theory

### What is Database Design?

**Database design** is the process of organizing data into tables and defining relationships between them. Good design ensures data integrity, eliminates redundancy, and supports efficient querying.

### Goals of Good Database Design

| Goal | Description |
|------|-------------|
| **Eliminate Redundancy** | Store each fact once — don't repeat data across rows |
| **Ensure Integrity** | Data remains consistent and valid through constraints |
| **Support Queries** | Design supports the queries your application needs |
| **Maintainability** | Easy to modify as requirements change |
| **Scalability** | Handles growing data volumes efficiently |

### Design Process

1. **Requirements Analysis** — What data do we need? What queries will we run?
2. **Conceptual Design** — Identify entities, attributes, and relationships (ER diagram)
3. **Logical Design** — Convert to relational schema (tables, columns, keys)
4. **Normalization** — Apply normal forms to eliminate redundancy
5. **Physical Design** — Choose data types, indexes, storage engine

### Common Design Anti-Patterns

#### Anti-Pattern 1: Spreadsheet Thinking

```sql
-- ❌ WRONG: One table for everything (like a spreadsheet)
CREATE TABLE bad_orders (
    order_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    customer_address VARCHAR(200),
    product_name VARCHAR(100),
    product_price DECIMAL(10,2),
    product_category VARCHAR(50),
    order_date DATE,
    quantity INT,
    total DECIMAL(10,2),
    shipping_method VARCHAR(50),
    tracking_number VARCHAR(50)
);
-- Problems:
-- 1. Customer info repeated for every order (redundancy)
-- 2. Product info repeated (redundancy)
-- 3. Can't store customers without orders
-- 4. Can't store products never ordered
-- 5. Updating customer email requires updating every order row
-- 6. Inconsistent data: "John Doe" vs "John  Doe" vs "john doe"
```

#### Anti-Pattern 2: Comma-Separated Values

```sql
-- ❌ WRONG: Storing lists in a single column
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    hobbies VARCHAR(200)  -- "reading,gaming,cooking"
);
-- Problems:
-- Can't efficiently query "find all users who like gaming"
-- Can't enforce valid hobby values
-- Hard to add/remove individual hobbies
```

#### Anti-Pattern 3: Repeating Groups

```sql
-- ❌ WRONG: Columns for each possible item
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product1 VARCHAR(100),
    price1 DECIMAL(10,2),
    product2 VARCHAR(100),
    price2 DECIMAL(10,2),
    product3 VARCHAR(100),
    price3 DECIMAL(10,2)
);
-- What if order has 4 products? What if only 1?
```

### Proper Relational Design

```sql
-- ✅ CORRECT: Separate tables for each entity
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(200)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipping_method VARCHAR(50),
    tracking_number VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,  -- Snapshot of price at order time
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### Naming Conventions

| Convention | Example | Pros | Cons |
|-----------|---------|------|------|
| **snake_case** | `customer_id`, `order_date` | ✅ Most common in SQL | — |
| **CamelCase** | `customerId`, `orderDate` | Matches application code | Less common in SQL |
| **Table names** | Plural (`customers`) or singular (`customer`) | Pick one, be consistent | Mixed is confusing |
| **FK naming** | `customer_id` or `fk_customer` | Descriptive is best | — |
| **Index naming** | `idx_column_name` or `table_column_idx` | Consistent pattern | — |

---

## 💻 Examples

### Example 1: From Spreadsheet to Relational

Starting with a sales spreadsheet:

```
Date | Customer | Email | Product | Category | Price | Qty | Total | Salesperson | Region
```

Step 1: Identify entities → Customers, Products, Orders, Salespeople
Step 2: Create tables with proper keys
Step 3: Link with foreign keys

```sql
CREATE TABLE salespeople (
    salesperson_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (salesperson_id) REFERENCES salespeople(salesperson_id)
);
```

### Example 2: Designing a Blog Database

Requirements: Users can write posts, add tags, and comment on posts.

```sql
-- Users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash CHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts (one user → many posts)
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Tags (many-to-many with posts)
CREATE TABLE tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE post_tags (
    post_id INT,
    tag_id INT,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- Comments (one post → many comments)
CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

---

## ⚠️ Common Mistakes

### Mistake 1: Storing Derived Values

```sql
-- ❌ UNNECESSARY: total can be calculated
CREATE TABLE order_items (
    id INT PRIMARY KEY,
    quantity INT,
    unit_price DECIMAL(10,2),
    total DECIMAL(10,2)  -- = quantity * unit_price — REDUNDANT
);

-- ✅ CORRECT: Calculate when needed
SELECT quantity, unit_price, quantity * unit_price AS total FROM order_items;
```

### Mistake 2: Multi-Valued Columns

```sql
-- ❌ WRONG: Multiple phone numbers in one column
CREATE TABLE contacts (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    phones VARCHAR(200)  -- "555-0100,555-0101,555-0102"
);

-- ✅ CORRECT: Separate table for phones
CREATE TABLE contacts (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE contact_phones (
    contact_id INT,
    phone VARCHAR(20),
    PRIMARY KEY (contact_id, phone),
    FOREIGN KEY (contact_id) REFERENCES contacts(id)
);
```

### Mistake 3: No Primary Keys

```sql
-- ❌ WRONG: No way to uniquely identify rows
CREATE TABLE logs (
    message TEXT,
    level VARCHAR(10),
    timestamp DATETIME
);

-- ✅ CORRECT: Always have a primary key
CREATE TABLE logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    message TEXT,
    level VARCHAR(10),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## ✅ Exercises

### Exercise 1: Identify Design Flaws
Given this table, list all design problems:
```sql
CREATE TABLE employee_data (
    employee_id INT,
    name VARCHAR(100),
    department VARCHAR(50),
    dept_location VARCHAR(100),
    skills VARCHAR(200),     -- "Java,Python,SQL"
    manager_name VARCHAR(100),
    salary DECIMAL(10,2),
    hire_date DATE,
    project1 VARCHAR(100),
    project2 VARCHAR(100),
    project3 VARCHAR(100)
);
```

### Exercise 2: Redesign
Redesign the table above into proper relational tables. Draw the schema.

### Exercise 3: Design a Library System
Design a database for a public library with: books (ISBN, title, author, genre), members, borrowals (checkout date, due date, return date, fines), and categories.

---

## 🧠 Key Takeaways

- **Each fact should be stored once** — avoid repeating data across rows
- **Separate tables for each entity** — link with foreign keys, not repeated columns
- Never use **comma-separated values** in a column for a list of items
- Avoid **repeating groups** (column1, column2, column3 for the same type of data)
- Don't store **derived values** — calculate them when needed
- Use **junction tables** for many-to-many relationships
- Pick **naming conventions** and be consistent
- Every table needs a **primary key**
- Design around the **queries you'll run**, not just the data you have

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 18: Triggers & Stored Procedures →](../week-4-advanced-sql/lesson-18-triggers-procedures.md)
**Next:** [Lesson 20: ER Diagrams →](./lesson-20-er-diagrams.md)
