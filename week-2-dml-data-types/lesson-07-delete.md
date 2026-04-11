# Lesson 07: DELETE

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 2:05:00 – 2:20:00 | 15 min |
| 🟧 Bro Code | 1:25:00 – 1:40:00 | 15 min |
| 🟩 Brototype | 1:35:00 – 1:50:00 | 15 min |

## 📖 Theory

The `DELETE` statement **removes rows** from a table. It is a DML (Data Manipulation Language) operation, meaning it operates on data, not table structure.

### Basic DELETE Syntax

```sql
DELETE FROM table_name
WHERE condition;
```

The `WHERE` clause is **critical**:
- **With WHERE**: only matching rows are deleted
- **Without WHERE**: ALL rows in the table are deleted (table structure remains)

### DELETE vs TRUNCATE vs DROP

| Feature | DELETE | TRUNCATE | DROP |
|---------|--------|----------|------|
| **What it removes** | Rows | All rows | Entire table |
| **WHERE clause** | Yes | No | N/A |
| **Speed** | Slow (row by row) | Very fast | Very fast |
| **Rollback** | Can rollback | Cannot rollback | Cannot rollback |
| **AUTO_INCREMENT reset** | No | Yes | Yes (table gone) |
| **Triggers fired** | Yes | No | No |
| **Returns affected rows** | Yes | No | No |
| **Type** | DML | DDL | DDL |

```sql
-- DELETE: removes rows, can use WHERE, can rollback
DELETE FROM customers WHERE customer_id = 1;

-- TRUNCATE: removes ALL rows instantly, resets AUTO_INCREMENT
TRUNCATE TABLE customers;

-- DROP: removes the entire table (structure + data)
DROP TABLE customers;
```

### Foreign Key Cascades

When tables are related through foreign keys, deleting a row in the parent table can affect child tables:

| Option | Behavior |
|--------|----------|
| **CASCADE** | Deleting the parent also deletes all related child rows |
| **SET NULL** | Deleting the parent sets the foreign key in child rows to NULL |
| **RESTRICT** / **NO ACTION** | Prevents deletion of the parent if child rows exist |

```sql
-- CASCADE: deleting a customer also deletes their orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

-- SET NULL: deleting a customer sets their orders' customer_id to NULL
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE SET NULL
);

-- RESTRICT: prevents deleting a customer who has orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT
);
```

### Soft Deletes Pattern

Instead of permanently deleting rows, many applications use a "soft delete" pattern:

```sql
-- Add a deleted_at column
ALTER TABLE customers ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL;

-- "Delete" by setting the timestamp
UPDATE customers SET deleted_at = NOW() WHERE customer_id = 1;

-- Query only "active" (non-deleted) rows
SELECT * FROM customers WHERE deleted_at IS NULL;
```

Benefits of soft deletes:
- **Data recovery**: "deleted" data can be recovered
- **Audit trails**: you know when something was deleted
- **Referential integrity**: no orphaned records
- **Compliance**: meets legal requirements for data retention

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS store;
USE store;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    points INT DEFAULT 0,
    state VARCHAR(20),
    deleted_at TIMESTAMP NULL DEFAULT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE
);

-- Insert sample data
INSERT INTO customers (first_name, last_name, email, points, state)
VALUES
    ('John', 'Smith', 'john@email.com', 100, 'NY'),
    ('Jane', 'Doe', 'jane@email.com', 250, 'CA'),
    ('Bob', 'Johnson', 'bob@email.com', 50, 'IL'),
    ('Alice', 'Williams', 'alice@email.com', 500, 'TX'),
    ('Charlie', 'Brown', 'charlie@email.com', 0, 'AZ');

INSERT INTO orders (customer_id, order_date, total, status)
VALUES
    (1, '2024-01-15', 150.00, 'completed'),
    (1, '2024-03-20', 75.50, 'completed'),
    (2, '2024-02-10', 200.00, 'shipped'),
    (3, '2024-04-05', 50.00, 'pending'),
    (4, '2024-05-12', 300.00, 'completed');

INSERT INTO order_items (order_id, product_name, quantity, price)
VALUES
    (1, 'Laptop', 1, 999.99),
    (1, 'Mouse', 2, 29.99),
    (2, 'Keyboard', 1, 79.99),
    (3, 'Monitor', 1, 399.99),
    (4, 'Desk Lamp', 3, 45.99);
```

### Example 1: Basic DELETE with WHERE

```sql
-- Delete a specific customer
DELETE FROM customers
WHERE customer_id = 5;

-- Verify (Charlie Brown is gone)
SELECT * FROM customers;

-- Delete multiple customers by condition
DELETE FROM customers
WHERE state = 'IL';

-- Verify (Bob Johnson is gone)
SELECT * FROM customers;
```

### Example 2: DELETE with Subquery

```sql
-- Delete customers who have never placed an order
DELETE FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);

-- Delete orders with total less than $100
DELETE FROM orders
WHERE total < 100;

-- Check remaining data
SELECT * FROM customers;
SELECT * FROM orders;
```

### Example 3: CASCADE Delete in Action

```sql
-- Because we set ON DELETE CASCADE on orders,
-- deleting a customer will also delete their orders

-- First, let's see the current state
SELECT c.customer_id, c.first_name, o.order_id, o.total
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Delete customer 2 (Jane Doe) — her orders will be deleted too
DELETE FROM customers
WHERE customer_id = 2;

-- Verify: both Jane and her order are gone
SELECT c.customer_id, c.first_name, o.order_id, o.total
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Check order_items too (also CASCADE)
SELECT * FROM order_items;
```

### Example 4: TRUNCATE vs DELETE

```sql
-- Re-insert data for demonstration
INSERT INTO customers (first_name, last_name, email, points, state)
VALUES
    ('Test1', 'User', 'test1@email.com', 100, 'NY'),
    ('Test2', 'User', 'test2@email.com', 200, 'CA'),
    ('Test3', 'User', 'test3@email.com', 300, 'TX');

-- DELETE: removes rows but keeps AUTO_INCREMENT counter
DELETE FROM customers WHERE customer_id >= 6;
-- Next insert will use the next AUTO_INCREMENT value

-- Re-insert
INSERT INTO customers (first_name, last_name, email, points, state)
VALUES ('New', 'Customer', 'new@email.com', 0, 'NY');
-- Notice: customer_id continues from where it left off

-- TRUNCATE: removes ALL rows AND resets AUTO_INCREMENT
TRUNCATE TABLE order_items;

-- Re-insert into order_items — starts from 1 again
INSERT INTO order_items (order_id, product_name, quantity, price)
VALUES (1, 'Test Product', 1, 10.00);
SELECT * FROM order_items;
-- item_id will be 1 (reset by TRUNCATE)
```

### Example 5: RESTRICT (Prevent Deletion)

```sql
-- Create a table with RESTRICT
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE RESTRICT
);

-- Insert an invoice
INSERT INTO invoices (order_id, amount) VALUES (1, 150.00);

-- Try to delete the order that has an invoice
DELETE FROM orders WHERE order_id = 1;
-- Error: Cannot delete or update a parent row: a foreign key constraint fails

-- Must delete the invoice first, or use CASCADE
DELETE FROM invoices WHERE order_id = 1;
DELETE FROM orders WHERE order_id = 1;
-- Now it works
```

### Example 6: Soft Delete Pattern

```sql
-- "Delete" customer 4 by setting deleted_at
UPDATE customers
SET deleted_at = NOW()
WHERE customer_id = 4;

-- Query only active customers
SELECT * FROM customers WHERE deleted_at IS NULL;

-- Query including soft-deleted customers
SELECT * FROM customers;

-- "Recover" a soft-deleted customer
UPDATE customers
SET deleted_at = NULL
WHERE customer_id = 4;

-- Count active vs deleted
SELECT
    COUNT(*) AS total,
    SUM(deleted_at IS NULL) AS active,
    SUM(deleted_at IS NOT NULL) AS deleted
FROM customers;
```

### Example 7: Safe Delete Patterns

```sql
-- ALWAYS test with SELECT first
-- Step 1: See what will be deleted
SELECT * FROM orders WHERE status = 'pending' AND order_date < '2024-03-01';

-- Step 2: If the results look correct, run the DELETE
DELETE FROM orders WHERE status = 'pending' AND order_date < '2024-03-01';

-- Step 3: Verify the deletion
SELECT COUNT(*) AS remaining FROM orders WHERE status = 'pending';

-- Even safer: use a transaction
START TRANSACTION;

DELETE FROM orders WHERE status = 'pending' AND total < 50;

-- Check the result
SELECT * FROM orders;

-- If it looks good:
COMMIT;

-- If something went wrong:
-- ROLLBACK;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Forgetting the WHERE Clause

```sql
-- ❌ WRONG (deletes EVERYTHING in the table!)
DELETE FROM customers;

-- ✅ CORRECT (only delete specific rows)
DELETE FROM customers WHERE customer_id = 1;
```

### Mistake 2: Confusing DELETE with TRUNCATE

```sql
-- ❌ WRONG: trying to use WHERE with TRUNCATE
TRUNCATE FROM customers WHERE state = 'TX';
-- Syntax error: TRUNCATE doesn't support WHERE

-- ✅ CORRECT: use DELETE if you need a WHERE clause
DELETE FROM customers WHERE state = 'TX';

-- ✅ CORRECT: use TRUNCATE only when you want ALL rows gone
TRUNCATE TABLE customers;
```

### Mistake 3: Not Understanding CASCADE Behavior

```sql
-- ❌ WRONG: expecting RESTRICT to cascade deletes
-- If FK is ON DELETE RESTRICT, deleting the parent will FAIL

-- ✅ CORRECT: understand your FK settings before deleting
-- Check FK constraints:
SHOW CREATE TABLE orders;

-- If CASCADE: parent delete removes children
-- If RESTRICT: must delete children first
-- If SET NULL: parent delete nullifies the FK in children
```

### Mistake 4: Deleting Data Without Backing Up

```sql
-- ❌ WRONG: running DELETE in production without backup
DELETE FROM customers WHERE points = 0;

-- ✅ CORRECT: backup first, then delete
-- Create a backup table
CREATE TABLE customers_backup AS SELECT * FROM customers WHERE points = 0;

-- Or export the data
-- Then delete
DELETE FROM customers WHERE points = 0;

-- If needed, restore from backup
-- INSERT INTO customers SELECT * FROM customers_backup;
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS blog_db;
USE blog_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    status VARCHAR(20) DEFAULT 'active',
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    published TINYINT(1) DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    body TEXT,
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

INSERT INTO users (username, email, status)
VALUES
    ('alice', 'alice@email.com', 'active'),
    ('bob', 'bob@email.com', 'active'),
    ('charlie', 'charlie@email.com', 'inactive'),
    ('diana', 'diana@email.com', 'active'),
    ('eve', 'eve@email.com', 'inactive');

INSERT INTO posts (user_id, title, content, published)
VALUES
    (1, 'My First Post', 'Hello world!', 1),
    (1, 'Second Post', 'More content here.', 1),
    (2, 'Bob Writes', 'This is my first post.', 0),
    (3, 'Charlie Says', 'Some thoughts.', 1),
    (4, 'Diana Here', 'Learning SQL!', 1);

INSERT INTO comments (post_id, user_id, body)
VALUES
    (1, 2, 'Great post!'),
    (1, 3, 'Nice one!'),
    (2, 4, 'Thanks for sharing.'),
    (3, 1, 'Welcome to blogging!'),
    (4, 5, 'Interesting read.');
```

### Exercise 1: Basic Deletes

1. Delete the comment with `comment_id = 5`
2. Delete all unpublished posts (`published = 0`)
3. Delete the user 'charlie' by username
4. Verify what data remains after each deletion

### Exercise 2: CASCADE Effects

1. Check how many posts and comments exist
2. Delete user 'bob' — observe how CASCADE removes their posts and comments
3. Verify the cascade worked correctly
4. Check which comments still exist and which were cascaded

### Exercise 3: Soft Deletes

1. Add a `deleted_at` column to the `posts` table (if not already there)
2. Soft-delete all posts by inactive users (users with `status = 'inactive'`)
3. Write a query to show only active (non-deleted) posts
4. Write a query to show all posts including soft-deleted ones
5. "Un-delete" Diana's post

### Exercise 4: Safe Delete Patterns

1. Write a SELECT to identify which users have no posts
2. Delete those users using the same condition (verify first!)
3. Use a transaction to delete all comments on unpublished posts, then rollback to test

### Exercise 5: TRUNCATE vs DELETE

1. Count total rows in the `comments` table
2. Use DELETE to remove comments on `post_id = 1`
3. Note the next `AUTO_INCREMENT` value
4. TRUNCATE the comments table
5. Insert a new comment and observe that `comment_id` starts from 1 again

---

## 🧠 Key Takeaways

- **DELETE removes rows**; always use a `WHERE` clause unless you want to empty the entire table
- **DELETE** is DML (can rollback, fires triggers, slow); **TRUNCATE** is DDL (fast, resets AUTO_INCREMENT, no rollback); **DROP** removes the entire table
- **ON DELETE CASCADE** automatically removes child rows when a parent is deleted
- **ON DELETE RESTRICT** prevents deletion of a parent while child rows exist
- **ON DELETE SET NULL** sets the foreign key to NULL when the parent is deleted
- **Soft deletes** (using a `deleted_at` column) preserve data and enable recovery
- Always **SELECT before DELETE** to verify which rows will be affected
- Use **transactions** (`START TRANSACTION` / `ROLLBACK`) for safe, reversible deletes
- **TRUNCATE cannot use WHERE** — it always removes all rows

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 06: UPDATE →](./lesson-06-update.md)
**Next:** [Lesson 08: Data Types Deep Dive →](./lesson-08-data-types.md)
