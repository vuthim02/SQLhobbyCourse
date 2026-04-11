-- =====================================================
-- Week 1 Exercises: SQL Basics
-- =====================================================
-- Topics: CREATE TABLE, INSERT, SELECT, WHERE, ORDER BY, LIMIT
-- =====================================================

-- =====================================================
-- SETUP: Create the store database and customers table
-- =====================================================

CREATE DATABASE IF NOT EXISTS week1_exercises;
USE week1_exercises;

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    points INT DEFAULT 0,
    city VARCHAR(50),
    state VARCHAR(2),
    birth_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (first_name, last_name, email, points, city, state, birth_date)
VALUES 
    ('John', 'Smith', 'john@email.com', 100, 'New York', 'NY', '1990-01-15'),
    ('Jane', 'Doe', 'jane@email.com', 250, 'Los Angeles', 'CA', '1985-03-22'),
    ('Bob', 'Johnson', 'bob@email.com', 50, 'Chicago', 'IL', '1992-07-10'),
    ('Alice', 'Williams', 'alice@email.com', 500, 'Houston', 'TX', '1988-11-30'),
    ('Charlie', 'Brown', 'charlie@email.com', 0, 'Phoenix', 'AZ', '1995-05-18'),
    ('Diana', 'Ross', 'diana@email.com', 1000, 'Miami', 'FL', '1980-12-25'),
    ('Eve', 'Davis', 'eve@email.com', 300, 'San Francisco', 'CA', '1993-08-05'),
    ('Frank', 'Miller', 'frank@email.com', 75, 'Dallas', 'TX', '1987-04-12'),
    ('Grace', 'Wilson', 'grace@email.com', NULL, 'Austin', 'TX', '1991-09-20'),
    ('Henry', 'Taylor', 'henry@email.com', 450, 'Boston', 'MA', '1989-02-28'),
    ('Ivy', 'Anderson', 'ivy@email.com', 600, 'Seattle', 'WA', '1994-06-14'),
    ('Jack', 'Thomas', 'jack@email.com', 150, 'Denver', 'CO', '1986-11-03'),
    ('Karen', 'Jackson', 'karen@email.com', 200, 'Portland', 'OR', '1990-04-27'),
    ('Leo', 'White', 'leo@email.com', 350, 'Atlanta', 'GA', '1983-01-19'),
    ('Mia', 'Harris', 'mia@email.com', 80, 'Nashville', 'TN', '1996-08-08');

-- =====================================================
-- EXERCISE 1: Basic SELECT (Difficulty: ⭐)
-- =====================================================

-- 1. Get all customers with all columns
-- YOUR QUERY HERE:

-- 2. Get only first_name, last_name, and email
-- YOUR QUERY HERE:

-- 3. Get the full name of each customer (concatenate first + last)
-- Hint: Use CONCAT(first_name, ' ', last_name) AS full_name
-- YOUR QUERY HERE:

-- 4. Count the total number of customers
-- YOUR QUERY HERE:

-- =====================================================
-- EXERCISE 2: WHERE Clause — Comparison (Difficulty: ⭐⭐)
-- =====================================================

-- 1. Find all customers from Texas (TX)
-- YOUR QUERY HERE:

-- 2. Find customers with more than 400 points
-- YOUR QUERY HERE:

-- 3. Find customers born after 1990-01-01
-- YOUR QUERY HERE:

-- 4. Find customers who are NOT from California
-- YOUR QUERY HERE:

-- 5. Find customers with exactly 250 points
-- YOUR QUERY HERE:

-- =====================================================
-- EXERCISE 3: WHERE Clause — AND / OR / NOT (Difficulty: ⭐⭐)
-- =====================================================

-- 1. Find customers from California with more than 200 points
-- YOUR QUERY HERE:

-- 2. Find customers from California OR New York
-- YOUR QUERY HERE:

-- 3. Find customers with points between 100 and 500 (inclusive)
-- YOUR QUERY HERE:

-- 4. Find customers from Texas, Florida, or Georgia
-- YOUR QUERY HERE:

-- 5. Find customers NOT from California, New York, or Texas
-- YOUR QUERY HERE:

-- =====================================================
-- EXERCISE 4: WHERE Clause — LIKE Patterns (Difficulty: ⭐⭐⭐)
-- =====================================================

-- 1. Find customers whose last name starts with 'S'
-- YOUR QUERY HERE:

-- 2. Find customers whose last name ends with 'son'
-- YOUR QUERY HERE:

-- 3. Find customers whose email contains 'email.com'
-- YOUR QUERY HERE:

-- 4. Find customers whose first name has exactly 4 letters
-- Hint: LIKE with 4 underscores
-- YOUR QUERY HERE:

-- 5. Find customers whose last name contains 'll' or 'rr'
-- Hint: Use REGEXP
-- YOUR QUERY HERE:

-- =====================================================
-- EXERCISE 5: NULL Handling (Difficulty: ⭐⭐)
-- =====================================================

-- 1. Find customers with NULL points
-- YOUR QUERY HERE:

-- 2. Find customers with non-NULL points
-- YOUR QUERY HERE:

-- 3. Find customers from Texas who have NULL points
-- YOUR QUERY HERE:

-- =====================================================
-- EXERCISE 6: ORDER BY (Difficulty: ⭐⭐)
-- =====================================================

-- 1. Sort all customers by last name (A to Z)
-- YOUR QUERY HERE:

-- 2. Sort customers by points (highest first)
-- YOUR QUERY HERE:

-- 3. Sort by state (A to Z), then by points (highest first) within each state
-- YOUR QUERY HERE:

-- 4. Sort by birth date (oldest first), then by last name (A to Z) for same dates
-- YOUR QUERY HERE:

-- 5. Sort by points descending, but put NULLs last
-- Hint: ORDER BY points IS NULL, points DESC
-- YOUR QUERY HERE:

-- =====================================================
-- EXERCISE 7: LIMIT & OFFSET (Difficulty: ⭐⭐)
-- =====================================================

-- 1. Get the top 5 customers by points
-- YOUR QUERY HERE:

-- 2. Get the 3 youngest customers (most recent birth dates)
-- YOUR QUERY HERE:

-- 3. Get page 1 of customers: 3 per page, sorted by customer_id
-- YOUR QUERY HERE:

-- 4. Get page 2 of customers: 3 per page, sorted by customer_id
-- YOUR QUERY HERE:

-- 5. Get page 4 of customers: 3 per page, sorted by customer_id
-- YOUR QUERY HERE:

-- =====================================================
-- EXERCISE 8: Combined Challenges (Difficulty: ⭐⭐⭐)
-- =====================================================

-- 1. Get the top 3 customers from Texas by points
-- YOUR QUERY HERE:

-- 2. Get the 2 customers with the longest last names (by character count)
-- Hint: Use ORDER BY LENGTH(last_name) DESC
-- YOUR QUERY HERE:

-- 3. Get customers born in the 1990s, sorted by birth date, limited to 5
-- Hint: birth_date BETWEEN '1990-01-01' AND '1999-12-31'
-- YOUR QUERY HERE:

-- 4. Get page 2 (3 results per page) of California customers, sorted by points DESC
-- YOUR QUERY HERE:

-- 5. Get the customer with the highest points from each state (top state)
-- Hint: This is tricky! Sort by state, points DESC, then use a technique to pick top per state.
-- YOUR QUERY HERE:

-- =====================================================
-- BONUS: Create Your Own Table (Difficulty: ⭐⭐⭐⭐)
-- =====================================================

-- Create a table called `products` with:
-- product_id (INT, PK, AUTO_INCREMENT)
-- name (VARCHAR 100, NOT NULL)
-- category (ENUM: 'Electronics', 'Books', 'Clothing', 'Food')
-- price (DECIMAL 10,2, NOT NULL)
-- stock (INT, DEFAULT 0)
-- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

-- YOUR CREATE TABLE HERE:

-- Insert 8 products with various categories and prices
-- YOUR INSERTS HERE:

-- Write queries to:
-- a) Find all products under $50
-- b) Find all Electronics sorted by price DESC
-- c) Find the most expensive product in each category
-- d) Find products with stock = 0
-- YOUR QUERIES HERE:
