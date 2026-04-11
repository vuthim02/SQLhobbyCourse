# Lesson 10: PRIMARY KEY & FOREIGN KEY

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 2:10:00 – 2:40:00 | 30 min |
| 🟧 Bro Code | 2:40:00 – 3:05:00 | 25 min |
| 🟩 Brototype | 2:05:00 – 2:25:00 | 20 min |

## 📖 Theory

### PRIMARY KEY

A **PRIMARY KEY (PK)** uniquely identifies each row in a table. It is the most fundamental constraint in relational databases.

**Properties:**
- Must be **UNIQUE** — no two rows can have the same primary key
- Must be **NOT NULL** — every row must have a value
- A table can have **only one** primary key (but it can span multiple columns — composite key)
- Automatically creates an **index** for fast lookups

```sql
-- Single-column primary key
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

-- Composite primary key (multiple columns)
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id)   -- Each student can enroll in each course once
);
```

### AUTO_INCREMENT

`AUTO_INCREMENT` automatically generates a unique number for each new row. It starts at 1 and increments by 1.

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

INSERT INTO products (name) VALUES ('Laptop');   -- product_id = 1
INSERT INTO products (name) VALUES ('Mouse');     -- product_id = 2
INSERT INTO products (name) VALUES ('Keyboard');  -- product_id = 3
```

### FOREIGN KEY

A **FOREIGN KEY (FK)** creates a link between two tables. It ensures that a value in one table **must exist** in another table's referenced column (usually a PRIMARY KEY).

```
Table: orders                    Table: customers
┌──────────┬──────────────┐      ┌──────────────┬──────────┐
│ order_id │ customer_id  │  →   │ customer_id  │ name     │
├──────────┼──────────────┤      ├──────────────┼──────────┤
│ 1        │ 5            │      │ 5            │ Alice    │
│ 2        │ 5            │      │ 8            │ Bob      │
│ 3        │ 8            │      └──────────────┴──────────┘
└──────────┴──────────────┘

customer_id in orders REFERENCES customers(customer_id)
— You cannot insert order with customer_id=99 if customer 99 doesn't exist
— You cannot delete customer 5 if orders reference it (unless CASCADE)
```

### Referential Actions (ON DELETE / ON UPDATE)

When a referenced row is deleted or updated, what happens to the child rows?

| Action | Behavior | Use When |
|--------|----------|----------|
| `RESTRICT` (default) | Blocks the delete/update | You want to prevent orphaned records |
| `CASCADE` | Deletes/updates child rows too | Child rows depend on parent |
| `SET NULL` | Sets FK to NULL | Child can exist without parent |
| `NO ACTION` | Same as RESTRICT (standard SQL) | Same as RESTRICT |
| `SET DEFAULT` | Sets FK to default (not in MySQL) | N/A in MySQL |

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,

    -- When customer is deleted, delete their orders too
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- When product is deleted, set to NULL (order history preserved)
    product_id INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE SET NULL
);
```

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS relational_db;
USE relational_db;
```

### Example 1: PRIMARY KEY with AUTO_INCREMENT

```sql
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    bio TEXT
);

-- Insert without specifying ID
INSERT INTO authors (first_name, last_name, bio)
VALUES
    ('Jane', 'Austen', 'English novelist'),
    ('Mark', 'Twain', 'American writer'),
    ('Leo', 'Tolstoy', 'Russian author');

-- IDs are auto-generated: 1, 2, 3
SELECT * FROM authors;
```

### Example 2: Composite PRIMARY KEY

```sql
CREATE TABLE student_courses (
    student_id INT,
    course_id INT,
    enrollment_date DATE NOT NULL,
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id)  -- Student can only enroll once per course
);

INSERT INTO student_courses (student_id, course_id, enrollment_date)
VALUES
    (1, 101, '2024-01-15'),
    (1, 102, '2024-01-15'),
    (2, 101, '2024-01-16');

-- ❌ This fails: duplicate primary key
INSERT INTO student_courses (student_id, course_id, enrollment_date)
VALUES (1, 101, '2024-02-01');
-- ERROR: Duplicate entry '1-101' for key 'PRIMARY'
```

### Example 3: FOREIGN KEY with RESTRICT (Default)

```sql
CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments (dept_name) VALUES ('Engineering'), ('Marketing');
INSERT INTO employees (name, dept_id) VALUES ('Alice', 1), ('Bob', 2);

-- ❌ Cannot delete department — employees reference it
DELETE FROM departments WHERE dept_id = 1;
-- ERROR: Cannot delete or update a parent row: a foreign key constraint fails

-- ✅ Must delete employees first, then department
DELETE FROM employees WHERE dept_id = 1;
DELETE FROM departments WHERE dept_id = 1;
```

### Example 4: FOREIGN KEY with CASCADE

```sql
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO categories (category_name) VALUES ('Electronics'), ('Books');
INSERT INTO products (name, category_id) VALUES ('Laptop', 1), ('Mouse', 1), ('Novel', 2);

-- ✅ Deleting a category also deletes its products
DELETE FROM categories WHERE category_id = 1;
-- Products 'Laptop' and 'Mouse' are also deleted automatically!

SELECT * FROM products;
-- Only 'Novel' remains (category 2 was not deleted)
```

### Example 5: FOREIGN KEY with SET NULL

```sql
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    publisher_id INT,  -- Can be NULL
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
        ON DELETE SET NULL
);

INSERT INTO publishers (name) VALUES ('Penguin'), ('HarperCollins');
INSERT INTO books (title, publisher_id) VALUES
    ('Book A', 1), ('Book B', 1), ('Book C', 2);

-- ✅ Deleting publisher sets books' publisher_id to NULL (books preserved)
DELETE FROM publishers WHERE publisher_id = 1;

SELECT * FROM books;
-- Book A and Book B remain, but publisher_id is now NULL
```

### Example 6: Self-Referencing FOREIGN KEY

```sql
CREATE TABLE employees_hierarchy (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    manager_id INT NULL,  -- References emp_id in the same table
    FOREIGN KEY (manager_id) REFERENCES employees_hierarchy(emp_id)
        ON DELETE SET NULL
);

INSERT INTO employees_hierarchy (name, manager_id)
VALUES
    ('Alice', NULL),       -- Top-level (no manager)
    ('Bob', 1),            -- Reports to Alice
    ('Carol', 1),          -- Reports to Alice
    ('David', 2);          -- Reports to Bob
```

---

## ⚠️ Common Mistakes

### Mistake 1: Referencing a Non-Unique Column

```sql
-- ❌ WRONG: Can't FK to a non-unique column
CREATE TABLE bad_example (
    id INT PRIMARY KEY,
    name VARCHAR(100)  -- NOT unique
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    FOREIGN KEY (customer_name) REFERENCES bad_example(name)  -- ERROR!
);

-- ✅ CORRECT: FK must reference a PRIMARY KEY or UNIQUE column
FOREIGN KEY (customer_id) REFERENCES bad_example(id)
```

### Mistake 2: Mismatched Data Types

```sql
-- ❌ WRONG: INT can't reference VARCHAR
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,  -- String type
    name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,                       -- INT type — mismatch!
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ✅ CORRECT: Types must match exactly
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id VARCHAR(10),               -- Same type as referenced column
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Mistake 3: CASCADE Everything

```sql
-- ❌ DANGEROUS: Deleting a customer deletes ALL their orders, payments, reviews
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE;
-- One mistake and you lose years of order history!

-- ✅ SAFER: Use SET NULL or RESTRICT for important history
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE SET NULL;  -- Orders remain, just lose customer link
-- Or use a "soft delete" pattern (set is_active = 0 instead of deleting)
```

### Mistake 4: Forcing ORDER of Table Creation/Deletion

```sql
-- ❌ WRONG: Can't create orders before customers exist
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);
-- ERROR: Can't create table 'orders' (errno: 150 "Foreign key constraint is incorrectly formed")

-- ✅ CORRECT: Create parent tables first
CREATE TABLE customers (customer_id INT PRIMARY KEY, name VARCHAR(100));
CREATE TABLE orders (order_id INT PRIMARY KEY, customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id));
```

---

## ✅ Exercises

### Setup

```sql
CREATE DATABASE IF NOT EXISTS school_db;
USE school_db;
```

### Exercise 1: Build a School Schema
Create the following tables with proper PKs and FKs:
1. `teachers` — teacher_id (PK, auto-increment), name, subject, hire_date
2. `classes` — class_id (PK, auto-increment), class_name, teacher_id (FK → teachers), room_number
3. `students` — student_id (PK, auto-increment), first_name, last_name, email (UNIQUE), enrollment_date
4. `enrollments` — student_id (FK → students), class_id (FK → classes), grade (composite PK on student_id + class_id)

### Exercise 2: Test Referential Integrity
1. Insert 3 teachers, 4 classes, 5 students, and 8 enrollments
2. Try to insert an enrollment for a non-existent student — observe the error
3. Try to delete a teacher who teaches a class — observe the error
4. Alter the classes table to use `ON DELETE SET NULL` for the teacher FK
5. Now delete a teacher — what happens to their classes?

### Exercise 3: CASCADE Practice
1. Create a `projects` table and a `project_members` table with CASCADE on delete
2. Insert data, delete a project, verify members are cascade-deleted

### Exercise 4: Design Challenge
Design a database for a library system with:
- Books (with ISBN as PK)
- Authors (many-to-many with books — requires a junction table)
- Members
- Borrowals (which member borrowed which book, when, due date, return date)

Create all tables with appropriate PKs, FKs, and referential actions.

---

## 🧠 Key Takeaways

- **PRIMARY KEY** uniquely identifies each row — every table should have one
- **AUTO_INCREMENT** automatically generates sequential IDs
- **Composite PK** (multiple columns) enforces uniqueness of a combination
- **FOREIGN KEY** creates a relationship — child value must exist in parent
- **ON DELETE CASCADE** removes child rows when parent is deleted
- **ON DELETE SET NULL** preserves child rows but removes the relationship
- **ON DELETE RESTRICT** (default) prevents deleting a parent with children
- FK data types **must match** the referenced column type exactly
- **Parent tables** must be created before child tables with FKs

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 09: Constraints →](./lesson-09-constraints.md)
**Next:** [Lesson 11: INNER JOIN →](../week-3-joins-functions/lesson-09-inner-join.md)
