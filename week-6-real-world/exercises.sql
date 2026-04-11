-- ============================================================
-- Week 6 Exercises: Real-World SQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS week6_exercises;
USE week6_exercises;

-- SETUP
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users (username, email, role) VALUES
('admin', 'admin@site.com', 'admin'), ('alice', 'alice@email.com', 'user'),
('bob', 'bob@email.com', 'user'), ('analyst', 'analyst@site.com', 'analyst');

INSERT INTO orders (user_id, total, status) VALUES
(2, 150.00, 'completed'), (2, 75.50, 'completed'), (3, 200.00, 'pending');

-- ============================================================
-- Exercise 1: User Management ⭐
-- ============================================================

-- 1. Create a new user 'webapp'@'localhost' with a strong password
-- YOUR QUERY HERE:

-- 2. Grant SELECT, INSERT, UPDATE on week6_exercises.* to 'webapp'
-- YOUR QUERY HERE:

-- 3. View the grants with SHOW GRANTS
-- YOUR QUERY HERE:

-- 4. Revoke INSERT from 'webapp'
-- YOUR QUERY HERE:

-- 5. Drop the user
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 2: SQL Injection Prevention ⭐⭐
-- ============================================================

-- Identify which of these patterns are vulnerable and how to fix them:

-- 1. f"SELECT * FROM users WHERE username = '{user}'"
-- Fix:

-- 2. f"SELECT * FROM orders WHERE user_id = {uid}"
-- Fix:

-- 3. cursor.execute("SELECT * FROM users WHERE username = %s", (user,))
-- Safe? Yes/No:

-- ============================================================
-- Exercise 3: EXPLAIN Practice ⭐⭐
-- ============================================================

-- 1. EXPLAIN a query that uses the PK (what type? how many rows?)
-- YOUR QUERY HERE:

-- 2. EXPLAIN a full table scan (no WHERE clause)
-- YOUR QUERY HERE:

-- 3. Create an index on status, then EXPLAIN: WHERE status = 'completed'
-- YOUR QUERY HERE:

-- 4. EXPLAIN a JOIN query — observe how both tables are accessed
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 4: Query Optimization ⭐⭐⭐
-- ============================================================

-- Optimize each query:

-- 1. SELECT * FROM orders WHERE DATE(order_date) = '2024-06-01';
-- Problem:
-- Fix:

-- 2. SELECT username FROM users WHERE CONCAT(first_name, ' ', last_name) = 'Alice Smith';
-- Problem:
-- Fix:

-- 3. SELECT * FROM orders WHERE status = 'completed' OR user_id = 2;
-- Problem:
-- Fix (use UNION):

-- ============================================================
-- Exercise 5: Backup Practice ⭐
-- ============================================================

-- Run these in your terminal (not MySQL prompt):

-- 1. Backup week6_exercises:
--    mysqldump -u root -p week6_exercises > week6_backup.sql

-- 2. Check the backup:
--    head -30 week6_backup.sql

-- 3. Restore into a new database:
--    mysql -u root -p -e "CREATE DATABASE week6_restored;"
--    mysql -u root -p week6_restored < week6_backup.sql

-- ============================================================
-- Bonus Challenge ⭐⭐⭐⭐
-- ============================================================

-- 1. Write a Python/Node.js script that:
--    a. Connects to your MySQL database
--    b. Lists all users with their order counts
--    c. Inserts a new user with parameterized query
--    d. Uses a transaction for a multi-step operation
--    e. Handles errors gracefully

-- YOUR CODE HERE (in your preferred language):

-- 2. Create a bash backup script with:
--    - Timestamped filename
--    - Compression (gzip)
--    - Delete backups older than 30 days
--    - Logging

-- YOUR SCRIPT HERE:
