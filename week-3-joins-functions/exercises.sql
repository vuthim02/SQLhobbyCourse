-- ============================================================
-- Week 3 Exercises: Joins, Aggregations & Functions
-- ============================================================

-- ============================================================
-- SETUP: E-Commerce Database
-- ============================================================

CREATE DATABASE IF NOT EXISTS week3_exercises;
USE week3_exercises;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    state VARCHAR(20),
    signup_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert data
INSERT INTO customers (first_name, last_name, email, city, state, signup_date) VALUES
('Alice', 'Smith', 'alice@email.com', 'New York', 'NY', '2023-01-15'),
('Bob', 'Johnson', 'bob@email.com', 'Los Angeles', 'CA', '2023-02-10'),
('Carol', 'Williams', 'carol@email.com', 'Chicago', 'IL', '2023-03-05'),
('David', 'Brown', 'david@email.com', 'Houston', 'TX', '2023-04-01'),
('Eve', 'Davis', 'eve@email.com', 'New York', 'NY', '2023-05-20'),
('Frank', 'Miller', 'frank@email.com', NULL, NULL, '2023-06-15');

INSERT INTO products (name, category, price, stock) VALUES
('Laptop', 'Electronics', 999.99, 50),
('Mouse', 'Electronics', 29.99, 200),
('Keyboard', 'Electronics', 79.99, 150),
('Desk Chair', 'Furniture', 249.99, 30),
('Monitor', 'Electronics', 399.99, 75),
('Desk Lamp', 'Furniture', 45.99, 100),
('Notebook', 'Stationery', 12.99, 500),
('Webcam', 'Electronics', 89.99, 0);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2024-01-15', 'completed'), (1, '2024-03-20', 'completed'),
(2, '2024-02-10', 'completed'), (3, '2024-04-05', 'pending'),
(4, '2024-05-12', 'completed'), (1, '2024-06-01', 'shipped');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99), (1, 2, 2, 29.99),
(2, 3, 1, 79.99), (3, 4, 1, 249.99),
(4, 2, 1, 29.99), (5, 5, 1, 399.99),
(5, 1, 1, 999.99), (6, 3, 2, 79.99);

-- ============================================================
-- Exercise 1: INNER JOIN ⭐
-- ============================================================

-- 1. List all orders with customer names
-- YOUR QUERY HERE:

-- 2. Show order items with product names and prices
-- YOUR QUERY HERE:

-- 3. Find all completed orders with customer name and total
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 2: LEFT JOIN & Anti-Join ⭐⭐
-- ============================================================

-- 1. List ALL customers with their orders (including those without)
-- YOUR QUERY HERE:

-- 2. Find customers who have never placed an order
-- YOUR QUERY HERE:

-- 3. Find products that have never been ordered
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 3: Aggregations ⭐⭐
-- ============================================================

-- 1. Total revenue per order
-- YOUR QUERY HERE:

-- 2. Average order value per customer
-- YOUR QUERY HERE:

-- 3. Total quantity sold per product
-- YOUR QUERY HERE:

-- 4. Revenue per product category
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 4: HAVING ⭐⭐
-- ============================================================

-- 1. Customers with total spending > $500
-- YOUR QUERY HERE:

-- 2. Products ordered more than once
-- YOUR QUERY HERE:

-- 3. Months with more than 2 orders
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 5: Subqueries ⭐⭐⭐
-- ============================================================

-- 1. Find products priced above the average product price
-- YOUR QUERY HERE:

-- 2. Find customers who spent more than the average customer
-- YOUR QUERY HERE:

-- 3. Find the most expensive product in each category
-- YOUR QUERY HERE:

-- ============================================================
-- Bonus Challenge ⭐⭐⭐⭐
-- ============================================================

-- 1. Monthly revenue report: month, order_count, revenue, avg_order_value
-- YOUR QUERY HERE:

-- 2. Customer ranking by total spending (use variables or window functions if available)
-- YOUR QUERY HERE:

-- 3. Products with declining stock (compare current stock to initial stock)
-- YOUR QUERY HERE:

-- 4. Find customers from the same city as another customer (self-join)
-- YOUR QUERY HERE:
