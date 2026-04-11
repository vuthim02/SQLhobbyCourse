# Lesson 23: Normalization (1NF, 2NF, 3NF)

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 6:30:00 – 7:30:00 | 60 min |

## 📖 Theory

### What is Normalization?

**Normalization** is the process of organizing data in a database to:
1. **Eliminate redundancy** — don't store the same fact multiple times
2. **Eliminate anomalies** — prevent problems on insert, update, and delete
3. **Ensure data integrity** — relationships are logical and consistent

### Anomalies in Unnormalized Tables

```sql
-- Denormalized table
CREATE TABLE unnormalized_orders (
    order_id INT,
    order_date DATE,
    customer_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    product_id INT,
    product_name VARCHAR(100),
    product_price DECIMAL(10,2),
    quantity INT,
    city VARCHAR(50),
    state VARCHAR(20)
);

**Insert anomaly:** Can't add a new customer without an order
**Delete anomaly:** Deleting an order loses customer info if it was their only order
**Update anomaly:** Changing customer email requires updating every order row
```

### First Normal Form (1NF)

**Rules:**
1. All columns contain **atomic** (indivisible) values
2. No repeating groups
3. Each column has a unique name
4. Order of rows/columns doesn't matter

```
❌ NOT 1NF:
┌────────┬─────────────────────────┐
│ emp_id │ skills                  │
├────────┼─────────────────────────┤
│ 1      │ Java, Python, SQL       │  ← Comma-separated (non-atomic)
│ 2      │ JavaScript, React       │
└────────┴─────────────────────────┘

❌ NOT 1NF:
┌────────┬──────────┬──────────┬──────────┐
│ emp_id │ skill_1  │ skill_2  │ skill_3  │  ← Repeating group
├────────┼──────────┼──────────┼──────────┤
│ 1      │ Java     │ Python   │ SQL      │
└────────┴──────────┴──────────┴──────────┘

✅ 1NF:
┌────────┬──────────┐
│ emp_id │ skill    │
├────────┼──────────┤
│ 1      │ Java     │
│ 1      │ Python   │
│ 1      │ SQL      │
│ 2      │ JavaScript│
│ 2      │ React    │
└────────┴──────────┘
```

### Second Normal Form (2NF)

**Rules:**
1. Must be in 1NF
2. **No partial dependencies** — no non-key attribute depends on only part of a composite primary key

```
❌ 1NF but NOT 2NF:
Table: order_items  PK: {order_id, product_id}
┌──────────┬────────────┬──────────┬───────────────┬───────────┐
│ order_id │ product_id │ quantity │ product_name  │ order_date│
├──────────┼────────────┼──────────┼───────────────┼───────────┤
│ 1        │ 101        │ 2        │ Laptop        │ 2024-01-15│
│ 1        │ 102        │ 1        │ Mouse         │ 2024-01-15│
│ 2        │ 101        │ 1        │ Laptop        │ 2024-02-10│
└──────────┴────────────┴──────────┴───────────────┴───────────┘

Partial dependencies:
- product_id → product_name  (depends only on product_id, not full PK)
- order_id → order_date  (depends only on order_id, not full PK)

✅ 2NF — Split into 3 tables:
order_items(order_id, product_id, quantity)  ← PK: {order_id, product_id}
products(product_id, product_name)           ← PK: product_id
orders(order_id, order_date)                 ← PK: order_id
```

### Third Normal Form (3NF)

**Rules:**
1. Must be in 2NF
2. **No transitive dependencies** — no non-key attribute depends on another non-key attribute

```
❌ 2NF but NOT 3NF:
Table: employees  PK: emp_id
┌────────┬───────┬─────────┬───────────────┐
│ emp_id │ name  │ dept_id │ dept_name     │
├────────┼───────┼─────────┼───────────────┤
│ 1      │ Alice │ 10      │ Engineering   │
│ 2      │ Bob   │ 20      │ Marketing     │
│ 3      │ Carol │ 10      │ Engineering   │
└────────┴───────┴─────────┴───────────────┘

Transitive dependency:
emp_id → dept_id → dept_name
(dept_name depends on dept_id, which depends on emp_id)

✅ 3NF — Split:
employees(emp_id, name, dept_id)    ← PK: emp_id, FK: dept_id → departments
departments(dept_id, dept_name)     ← PK: dept_id
```

### Summary of Normal Forms

| Normal Form | Requirement | Eliminates |
|-------------|------------|------------|
| **1NF** | Atomic values, no repeating groups | Multi-valued columns |
| **2NF** | No partial dependencies (full PK determines everything) | Redundancy in composite-key tables |
| **3NF** | No transitive dependencies | Redundancy through intermediate columns |

### The "Golden Rule" of 3NF

> Every non-key attribute must depend on **the key, the whole key, and nothing but the key.**

- "The key" → 1NF
- "The whole key" → 2NF
- "Nothing but the key" → 3NF

---

## 💻 Examples

### Example: Full Normalization Walkthrough

Starting with a denormalized table:

```sql
-- UNNORMALIZED:
CREATE TABLE student_courses (
    student_id INT,
    student_name VARCHAR(100),
    student_email VARCHAR(100),
    courses VARCHAR(200),           -- "Math,CSS,CS" — not 1NF
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    dept_name VARCHAR(50),
    dept_building VARCHAR(50)
);
```

**Step 1: Achieve 1NF** — Make all values atomic

```sql
-- Split courses into individual rows, remove multi-valued column
CREATE TABLE student_courses_1nf (
    student_id INT,
    student_name VARCHAR(100),
    student_email VARCHAR(100),
    course_name VARCHAR(100),   -- One course per row
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    dept_name VARCHAR(50),
    dept_building VARCHAR(50),
    PRIMARY KEY (student_id, course_name)
);
```

**Step 2: Achieve 2NF** — Remove partial dependencies

```sql
-- student_id → student_name, student_email, advisor_name, advisor_office, dept_name, dept_building
-- course_name → (nothing additional on its own)
-- {student_id, course_name} → (the enrollment itself)

-- Extract student data
CREATE TABLE students_2nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    student_email VARCHAR(100),
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    dept_name VARCHAR(50),
    dept_building VARCHAR(50)
);

-- Enrollment (pure junction)
CREATE TABLE enrollments_2nf (
    student_id INT,
    course_name VARCHAR(100),
    PRIMARY KEY (student_id, course_name)
);
```

**Step 3: Achieve 3NF** — Remove transitive dependencies

```sql
-- In students_2nf: student_id → advisor_name → advisor_office (transitive)
-- In students_2nf: student_id → dept_name → dept_building (transitive)

-- Final 3NF tables:
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    student_email VARCHAR(100) UNIQUE NOT NULL,
    advisor_id INT,
    dept_id INT
);

CREATE TABLE advisors (
    advisor_id INT PRIMARY KEY,
    advisor_name VARCHAR(100) NOT NULL,
    office VARCHAR(20)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    building VARCHAR(50)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL UNIQUE,
    credits INT
);

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
```

---

## ⚠️ Common Mistakes

### Mistake 1: Over-Normalizing

```sql
-- ❌ EXCESSIVE: Splitting things that don't need to be split
CREATE TABLE title_prefix (
    prefix_id INT PRIMARY KEY,
    prefix VARCHAR(5)  -- 'Mr', 'Mrs', 'Dr'
);
-- For just 3-4 values, an ENUM is simpler
```

### Mistake 2: Stopping at 2NF

```sql
-- ⚠️ INCOMPLETE: Removed partial deps but left transitive deps
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    dept_id INT,
    dept_name VARCHAR(50),    -- dept_id → dept_name (transitive!)
    dept_location VARCHAR(50)  -- dept_id → dept_location (transitive!)
);
```

### Mistake 3: Not Recognizing 1NF Violations

```sql
-- ❌ NOT 1NF: Comma-separated values
phones VARCHAR(200)  -- "555-0100,555-0101"

-- ❌ NOT 1NF: JSON in a column when it should be a table
address VARCHAR(200)  -- '{"street":"123 Main", "city":"NY", "zip":"10001"}'
-- If you query individual address fields often, make it a proper table
```

---

## ✅ Exercises

### Exercise 1: Normalize to 1NF
Convert this to 1NF:
```
books(book_id, title, authors, genres)
where authors = "Alice,Bob" and genres = "Sci-Fi,Adventure"
```

### Exercise 2: Normalize to 2NF
Given this 1NF table with PK {order_id, product_id}:
```
order_details(order_id, product_id, quantity, product_name, product_price, order_date, customer_id)
```
Identify partial dependencies and normalize to 2NF.

### Exercise 3: Normalize to 3NF
Given this 2NF table:
```
employees(emp_id, name, dept_id, dept_name, dept_location, manager_id, manager_name, manager_email)
```
Identify transitive dependencies and normalize to 3NF.

---

## 🧠 Key Takeaways

- **Normalization** eliminates redundancy and anomalies
- **1NF**: Atomic values, no repeating groups or comma-separated data
- **2NF**: No partial dependencies — every non-key column depends on the **whole** PK
- **3NF**: No transitive dependencies — every non-key column depends on **nothing but** the key
- Golden rule: "The key, the whole key, and nothing but the key"
- Normalization is **iterative** — each build on the previous
- Every FD that isn't based on the key is a red flag for further normalization
- Aim for 3NF in most cases — it handles the vast majority of redundancy issues

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 22: Functional Dependencies →](./lesson-22-functional-dependencies.md)
**Next:** [Lesson 24: BCNF & Denormalization →](./lesson-24-bcdf-denormalization.md)
