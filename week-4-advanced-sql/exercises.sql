-- ============================================================
-- Week 4 Exercises: Advanced SQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS week4_exercises;
USE week4_exercises;

-- SETUP
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);

CREATE TABLE salary_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO employees (name, department, salary, hire_date) VALUES
('Alice', 'Engineering', 95000, '2020-01-15'), ('Bob', 'Marketing', 72000, '2021-03-10'),
('Carol', 'Engineering', 88000, '2019-07-20'), ('David', 'Sales', 68000, '2022-01-05'),
('Eve', 'Engineering', 105000, '2018-05-12');

-- ============================================================
-- Exercise 1: ALTER TABLE ⭐
-- ============================================================

-- 1. Add email column to employees
-- YOUR QUERY HERE:

-- 2. Add a CHECK constraint: salary > 0
-- YOUR QUERY HERE:

-- 3. Rename department to dept_name
-- YOUR QUERY HERE:

-- 4. Drop the CHECK constraint
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 2: Indexes ⭐⭐
-- ============================================================

-- 1. Create an index on department
-- YOUR QUERY HERE:

-- 2. Create a composite index on (department, salary)
-- YOUR QUERY HERE:

-- 3. Use EXPLAIN to verify index usage for: WHERE department = 'Engineering'
-- YOUR QUERY HERE:

-- 4. Drop the single-column index
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 3: Transactions ⭐⭐
-- ============================================================

-- 1. Start a transaction, give all Engineering employees a 10% raise, COMMIT
-- YOUR QUERY HERE:

-- 2. Start a transaction, update a salary, verify with SELECT, then ROLLBACK
-- YOUR QUERY HERE:

-- 3. Use SAVEPOINT: update 3 employees, rollback to after the 2nd
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 4: Views ⭐⭐
-- ============================================================

-- 1. Create a view: high_earners (salary > 80000)
-- YOUR QUERY HERE:

-- 2. Create a view: dept_stats (dept, count, avg_salary, max_salary)
-- YOUR QUERY HERE:

-- 3. Query both views
-- YOUR QUERY HERE:

-- 4. Use CREATE OR REPLACE to add department to high_earners
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 5: Triggers ⭐⭐⭐
-- ============================================================

-- 1. Create a trigger that logs salary changes to salary_audit
-- YOUR QUERY HERE:

-- 2. Update an employee's salary, verify the audit log
-- YOUR QUERY HERE:

-- 3. Create a BEFORE INSERT trigger that prevents salary below minimum wage
-- YOUR QUERY HERE:

-- ============================================================
-- Bonus Challenge ⭐⭐⭐⭐
-- ============================================================

-- 1. Create a stored procedure `raise_salary(emp_id, percentage)` that:
--    - Validates the employee exists
--    - Raises their salary
--    - Logs the change
-- YOUR QUERY HERE:

-- 2. Create a view that shows employees with their rank by salary (use variables)
-- YOUR QUERY HERE:
