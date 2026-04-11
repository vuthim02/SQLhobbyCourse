-- ============================================================
-- Week 5 Exercises: Database Design
-- ============================================================

CREATE DATABASE IF NOT EXISTS week5_exercises;
USE week5_exercises;

-- ============================================================
-- Exercise 1: Design a Restaurant Database ⭐⭐
-- ============================================================

-- Requirements:
-- - Tables for: customers, tables, menu_items, orders, order_items, staff
-- - A customer can place many orders; an order has many menu items
-- - Staff members have a manager (self-referencing)
-- - Menu items belong to categories
--
-- Tasks:
-- 1. Draw the ER diagram (on paper or using a tool)
-- 2. Create all tables with proper PKs, FKs, and data types
-- 3. Insert sample data (5 menu items, 3 categories, 2 tables, 3 staff)

-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 2: Identify Relationships ⭐
-- ============================================================

-- For each scenario, identify the cardinality (1:1, 1:N, M:N):
-- 1. A car and its VIN number
-- 2. A professor and the courses they teach
-- 3. A patient and their medical records
-- 4. A tweet and its hashtags
-- 5. A country and its capital city
--
-- Then implement ONE of these as SQL tables

-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 3: Normalize to 3NF ⭐⭐⭐
-- ============================================================

-- Given this denormalized table:
/*
CREATE TABLE bad_sales (
    sale_id INT,
    sale_date DATE,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    customer_city VARCHAR(50),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    product_price DECIMAL(10,2),
    salesperson_name VARCHAR(100),
    salesperson_region VARCHAR(50),
    quantity INT
);
*/

-- Tasks:
-- 1. Identify all functional dependencies
-- 2. Normalize to 1NF (if needed)
-- 3. Normalize to 2NF (remove partial dependencies)
-- 4. Normalize to 3NF (remove transitive dependencies)
-- 5. Create the final schema in SQL

-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 4: BCNF Check ⭐⭐⭐
-- ============================================================

-- Given R(A, B, C, D, E) with FDs: AB → C, C → D, D → E, E → A
-- 1. Find all candidate keys
-- 2. Is it in BCNF? If not, decompose.
--
-- Write the SQL to implement the decomposed tables.

-- YOUR QUERY HERE:

-- ============================================================
-- Bonus Challenge ⭐⭐⭐⭐
-- ============================================================

-- Design a database for a hospital:
-- - Patients (with medical history)
-- - Doctors (with specialties)
-- - Appointments (patient, doctor, date, time, room)
-- - Prescriptions (patient, medication, dosage, doctor)
-- - Rooms (number, type, floor)
--
-- Requirements:
-- 1. Draw the complete ER diagram
-- 2. Normalize to 3NF
-- 3. Implement all tables with constraints
-- 4. Write 5 meaningful queries

-- YOUR QUERY HERE:
