# Lesson 06: UPDATE

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 1:45:00 – 2:05:00 | 20 min |
| 🟧 Bro Code | 1:10:00 – 1:25:00 | 15 min |
| 🟩 Brototype | 1:20:00 – 1:35:00 | 15 min |

## 📖 Theory

The `UPDATE` statement **modifies existing rows** in a table. It is one of the core DML (Data Manipulation Language) operations.

### Basic UPDATE Syntax

```sql
UPDATE table_name
SET column1 = value1,
    column2 = value2,
    ...
WHERE condition;
```

The `WHERE` clause is **critical**:
- **With WHERE**: only matching rows are updated
- **Without WHERE**: ALL rows in the table are updated (usually a disaster!)

### UPDATE with Multiple Columns

You can update multiple columns in a single statement by separating them with commas:

```sql
UPDATE customers
SET first_name = 'Jane',
    last_name = 'Smith',
    email = 'jane.smith@email.com',
    points = 300
WHERE customer_id = 5;
```

### UPDATE with Expressions

You can use expressions to update columns based on their current values:

```sql
-- Give all customers a 10% points bonus
UPDATE customers
SET points = points * 1.10
WHERE state = 'CA';

-- Increase all product prices by $5
UPDATE products
SET price = price + 5.00;
```

### UPDATE with CASE (Conditional Updates)

The `CASE` expression lets you update different rows to different values in a single statement:

```sql
UPDATE employees
SET salary = CASE
    WHEN department = 'Engineering' THEN salary * 1.15
    WHEN department = 'Marketing' THEN salary * 1.10
    WHEN department = 'Sales' THEN salary * 1.08
    ELSE salary * 1.05
END;
```

### UPDATE with Subqueries

You can use subqueries in the `WHERE` clause or even in the `SET` clause:

```sql
-- Update customers who have placed orders
UPDATE customers
SET points = points + 100
WHERE customer_id IN (
    SELECT customer_id FROM orders
);

-- Update to a value from a subquery
UPDATE products
SET price = (SELECT AVG(price) FROM products) * 0.90
WHERE price < (SELECT AVG(price) FROM products);
```

### UPDATE with JOIN

MySQL allows updating rows based on joins with other tables:

```sql
UPDATE customers c
JOIN orders o ON c.customer_id = o.customer_id
SET c.points = c.points + 50
WHERE o.order_date > '2024-01-01';
```

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
    city VARCHAR(50),
    state VARCHAR(20),
    birth_date DATE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 0,
    category VARCHAR(50)
);

-- Insert sample data
INSERT INTO customers (first_name, last_name, email, points, city, state, birth_date)
VALUES
    ('John', 'Smith', 'john@email.com', 100, 'New York', 'NY', '1990-01-15'),
    ('Jane', 'Doe', 'jane@email.com', 250, 'Los Angeles', 'CA', '1985-03-22'),
    ('Bob', 'Johnson', 'bob@email.com', 50, 'Chicago', 'IL', '1992-07-10'),
    ('Alice', 'Williams', 'alice@email.com', 500, 'Houston', 'TX', '1988-11-30'),
    ('Charlie', 'Brown', 'charlie@email.com', 0, 'Phoenix', 'AZ', '1995-05-18');

INSERT INTO orders (customer_id, order_date, total, status)
VALUES
    (1, '2024-01-15', 150.00, 'completed'),
    (1, '2024-03-20', 75.50, 'completed'),
    (2, '2024-02-10', 200.00, 'shipped'),
    (3, '2024-04-05', 50.00, 'pending'),
    (4, '2024-05-12', 300.00, 'completed');

INSERT INTO products (name, price, quantity, category)
VALUES
    ('Laptop', 999.99, 50, 'Electronics'),
    ('Mouse', 29.99, 200, 'Electronics'),
    ('Keyboard', 79.99, 150, 'Electronics'),
    ('Desk Chair', 249.99, 30, 'Furniture'),
    ('Monitor', 399.99, 75, 'Electronics'),
    ('Desk Lamp', 45.99, 100, 'Furniture'),
    ('Notebook', 12.99, 500, 'Stationery'),
    ('Pen Set', 8.99, 300, 'Stationery');
```

### Example 1: Basic UPDATE with WHERE

```sql
-- Update a single customer's email
UPDATE customers
SET email = 'john.smith@newmail.com'
WHERE customer_id = 1;

-- Update multiple columns
UPDATE customers
SET city = 'San Francisco',
    state = 'CA'
WHERE customer_id = 1;

-- Verify
SELECT customer_id, first_name, last_name, email, city, state
FROM customers
WHERE customer_id = 1;
```

### Example 2: UPDATE with Expressions

```sql
-- Give all customers a 20% points bonus
UPDATE customers
SET points = points * 1.20;

-- Verify
SELECT first_name, last_name, points FROM customers;

-- Reset: reduce points by 100 for customers with more than 200
UPDATE customers
SET points = points - 100
WHERE points > 200;
```

### Example 3: UPDATE Multiple Rows at Once

```sql
-- Update all customers from California
UPDATE customers
SET points = points + 500
WHERE state = 'CA';

-- Update all customers from multiple states
UPDATE customers
SET points = points + 200
WHERE state IN ('NY', 'TX', 'IL');

-- Verify
SELECT first_name, state, points FROM customers ORDER BY state;
```

### Example 4: UPDATE with CASE

```sql
-- Reset points first
UPDATE customers SET points = 0;

-- Award points based on number of orders
UPDATE customers c
SET points = CASE
    WHEN (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'completed') >= 2 THEN 1000
    WHEN (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'completed') = 1 THEN 500
    ELSE 100
END;

-- Simpler version: direct points by state
UPDATE customers
SET points = CASE
    WHEN state = 'CA' THEN 500
    WHEN state = 'NY' THEN 400
    WHEN state = 'TX' THEN 300
    ELSE 100
END;

SELECT first_name, state, points FROM customers;
```

### Example 5: UPDATE with Subquery

```sql
-- Update order status for orders above average total
UPDATE orders
SET status = 'priority'
WHERE total > (SELECT avg_total FROM (
    SELECT AVG(total) AS avg_total FROM orders
) AS sub);

-- Reset order status
UPDATE orders SET status = 'pending';

-- Update customers who have at least one completed order
UPDATE customers
SET points = points + 200
WHERE customer_id IN (
    SELECT customer_id FROM orders WHERE status = 'completed'
);
```

### Example 6: UPDATE with JOIN

```sql
-- Give bonus points to customers who have placed orders in 2024
UPDATE customers c
JOIN orders o ON c.customer_id = o.customer_id
SET c.points = c.points + 100
WHERE o.order_date >= '2024-01-01'
  AND o.order_date < '2025-01-01';

-- Avoid double-counting with DISTINCT
UPDATE customers c
SET c.points = c.points + 50
WHERE c.customer_id IN (
    SELECT DISTINCT customer_id FROM orders WHERE status = 'shipped'
);
```

### Example 7: UPDATE Product Prices

```sql
-- Increase all electronics prices by 5%
UPDATE products
SET price = price * 1.05
WHERE category = 'Electronics';

-- Decrease quantity after a sale
UPDATE products
SET quantity = quantity - 10
WHERE name = 'Laptop';

-- Update multiple products at once with CASE
UPDATE products
SET price = CASE
    WHEN category = 'Electronics' THEN price * 1.10
    WHEN category = 'Furniture' THEN price * 1.08
    WHEN category = 'Stationery' THEN price * 1.03
    ELSE price
END;

SELECT name, category, price FROM products;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Forgetting the WHERE Clause

```sql
-- ❌ WRONG (updates EVERY row — likely not what you want!)
UPDATE customers
SET points = 0;

-- ✅ CORRECT (only update specific customers)
UPDATE customers
SET points = 0
WHERE customer_id = 5;
```

### Mistake 2: Using Wrong Column in WHERE

```sql
-- ❌ WRONG: updating by non-unique column (updates multiple rows!)
UPDATE customers
SET email = 'new@email.com'
WHERE first_name = 'John';
-- What if there are 5 Johns? All get updated!

-- ✅ CORRECT: use the primary key for precision
UPDATE customers
SET email = 'new@email.com'
WHERE customer_id = 1;
```

### Mistake 3: Using = Instead of , Between SET Assignments

```sql
-- ❌ WRONG: using AND or = between column assignments
UPDATE customers
SET points = 100 AND city = 'Boston'
WHERE customer_id = 1;

-- ✅ CORRECT: use commas
UPDATE customers
SET points = 100,
    city = 'Boston'
WHERE customer_id = 1;
```

### Mistake 4: Updating with Wrong Data Types

```sql
-- ❌ WRONG: updating a numeric column with a string
UPDATE products
SET price = 'twenty'
WHERE product_id = 1;

-- ✅ CORRECT: use the correct data type
UPDATE products
SET price = 20.00
WHERE product_id = 1;
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    price DECIMAL(8,2),
    stock INT DEFAULT 0,
    category VARCHAR(50),
    published_year YEAR
);

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    membership_type VARCHAR(20) DEFAULT 'basic',
    books_borrowed INT DEFAULT 0,
    fines DECIMAL(8,2) DEFAULT 0.00
);

INSERT INTO books (title, author, price, stock, category, published_year)
VALUES
    ('The Great Gatsby', 'F. Scott Fitzgerald', 12.99, 25, 'Fiction', 1925),
    ('Clean Code', 'Robert C. Martin', 39.99, 15, 'Technology', 2008),
    ('A Brief History of Time', 'Stephen Hawking', 15.99, 10, 'Science', 1988),
    ('The Art of War', 'Sun Tzu', 8.99, 30, 'History', 1910),
    ('1984', 'George Orwell', 11.99, 20, 'Fiction', 1949),
    ('Design Patterns', 'Gang of Four', 54.99, 8, 'Technology', 1994),
    ('The Origin of Species', 'Charles Darwin', 14.99, 12, 'Science', 1859),
    ('Dune', 'Frank Herbert', 16.99, 18, 'Fiction', 1965);

INSERT INTO members (name, email, membership_type, books_borrowed, fines)
VALUES
    ('Alice Smith', 'alice@email.com', 'premium', 12, 0.00),
    ('Bob Johnson', 'bob@email.com', 'basic', 3, 5.50),
    ('Carol White', 'carol@email.com', 'basic', 7, 2.00),
    ('David Brown', 'david@email.com', 'premium', 15, 0.00),
    ('Eve Davis', 'eve@email.com', 'basic', 1, 10.00);
```

### Exercise 1: Basic Updates

1. Update the price of "Clean Code" to $44.99
2. Change Bob Johnson's membership type from 'basic' to 'premium'
3. Update the stock of all Fiction books to 50
4. Set Carol White's fines to 0

### Exercise 2: UPDATE with Expressions

1. Increase all book prices by 10%
2. Reduce the stock of books published before 1950 by 5
3. Give all premium members a bonus of 5 books_borrowed (as a loyalty reward)
4. Double the fines for members who have fines greater than $5

### Exercise 3: UPDATE with CASE

1. Update book categories to use broader classifications:
   - 'Fiction' and 'History' → 'Literature'
   - 'Technology' and 'Science' → 'Academic'
   - Everything else stays the same
2. Update member fines:
   - If fines > $8, set to $5 (forgiveness program cap)
   - If fines <= $8, keep as is

### Exercise 4: UPDATE with Subqueries

1. Update books_borrowed for each member to match the actual count from a (hypothetical) borrowings table. Create a simple borrowals table and test.
2. Update the stock of books that have the lowest stock to match the average stock of all books.

### Exercise 5: Safe Update Patterns

1. Before updating, write a SELECT with the same WHERE clause to verify which rows will be affected
2. Use a transaction (START TRANSACTION; ... COMMIT;) to safely test updates
3. Practice the SELECT-then-UPDATE pattern for updating members with fines > 0

---

## 🧠 Key Takeaways

- **UPDATE modifies existing rows**; always use a `WHERE` clause unless you truly want to update all rows
- You can update **multiple columns** in one statement, separated by commas (not AND)
- **Expressions** let you update columns based on their current values (`points = points + 100`)
- **CASE** enables conditional updates — different rows get different values in one statement
- **Subqueries** in UPDATE let you base changes on data from other tables
- **JOINs** in UPDATE allow you to update based on related table data
- **Always test with SELECT first** using the same WHERE clause before running UPDATE
- Use **transactions** (`START TRANSACTION` / `ROLLBACK`) when making critical updates

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 05: INSERT Advanced →](./lesson-05-insert-advanced.md)
**Next:** [Lesson 07: DELETE →](./lesson-07-delete.md)
