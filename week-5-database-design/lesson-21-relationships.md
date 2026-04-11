# Lesson 21: Relationships (1:1, 1:N, M:N)

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 5:00:00 – 5:45:00 | 45 min |

## 📖 Theory

### Types of Relationships

Relationships define how tables connect. There are three fundamental types:

| Type | Notation | Implementation | Example |
|------|----------|----------------|---------|
| **One-to-One** | 1:1 | FK with UNIQUE constraint | User ↔ Profile |
| **One-to-Many** | 1:N | FK on the "many" side | Department → Employees |
| **Many-to-Many** | M:N | Junction (bridge) table | Students ↔ Courses |

### One-to-One (1:1)

Each row in Table A relates to **at most one** row in Table B, and vice versa.

**When to use 1:1:**
- Splitting a wide table for performance
- Separating sensitive data (passwords from user info)
- Optional/extension data (not every row needs it)

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1:1: Each user has exactly one profile
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,  -- Same PK as users — enforces 1:1
    bio TEXT,
    avatar_url VARCHAR(200),
    phone VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

### One-to-Many (1:N)

One row in Table A relates to **many** rows in Table B, but each row in B relates to only one in A.

**This is the most common relationship type.**

```sql
CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL
);

-- 1:N: One department has many employees
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
```

### Many-to-Many (M:N)

Many rows in Table A relate to many rows in Table B. Requires a **junction table**.

```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    credits INT
);

-- Junction table: resolves M:N
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    enroll_date DATE DEFAULT (CURRENT_DATE),
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);
```

### Relationship Properties

| Property | Description | Options |
|----------|-------------|---------|
| **Participation** | Must every row have a relationship? | Total (NOT NULL FK) or Partial (NULL FK) |
| **Cardinality** | How many on each side? | 1:1, 1:N, M:N |
| **Referential Action** | What happens on delete/update? | CASCADE, SET NULL, RESTRICT |

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS relationships_db;
USE relationships_db;
```

### Example 1: 1:1 — User and Profile

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash CHAR(64) NOT NULL
);

CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,  -- PK = FK → enforces 1:1
    bio TEXT,
    avatar_url VARCHAR(200),
    date_of_birth DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Insert
INSERT INTO users (username, email, password_hash) VALUES ('alice', 'alice@email.com', 'hash1');
INSERT INTO user_profiles (user_id, bio, date_of_birth) VALUES (1, 'Developer', '1990-05-15');

-- Query: join to get full user info
SELECT u.username, u.email, p.bio, p.date_of_birth
FROM users u JOIN user_profiles p ON u.user_id = p.user_id;
```

### Example 2: 1:N — Blog System

```sql
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    author_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    published_at TIMESTAMP NULL,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Insert
INSERT INTO authors (name) VALUES ('Alice'), ('Bob');
INSERT INTO posts (author_id, title, body, published_at)
VALUES (1, 'First Post', 'Hello world!', NOW()),
       (1, 'Second Post', 'More content...', NOW()),
       (2, "Bob's Post", 'Hi there!', NOW());

-- Query: posts per author
SELECT a.name, COUNT(p.post_id) AS post_count
FROM authors a LEFT JOIN posts p ON a.author_id = p.author_id
GROUP BY a.author_id, a.name;
```

### Example 3: M:N — Student Course Enrollment

```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    credits INT NOT NULL
);

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

-- Insert
INSERT INTO students (name) VALUES ('Alice'), ('Bob'), ('Carol');
INSERT INTO courses (title, credits) VALUES ('Math 101', 3), ('CS 201', 4), ('English 101', 3);
INSERT INTO enrollments (student_id, course_id, semester, grade)
VALUES (1, 1, 'Fall 2024', 'A'), (1, 2, 'Fall 2024', 'B+'),
       (2, 2, 'Fall 2024', 'A-'), (2, 3, 'Fall 2024', 'B'),
       (3, 1, 'Fall 2024', NULL), (3, 3, 'Fall 2024', NULL);

-- Courses Alice is taking:
SELECT c.title, c.credits, e.grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.name = 'Alice';

-- Students in CS 201:
SELECT s.name, e.grade
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
JOIN students s ON e.student_id = s.student_id
WHERE c.title = 'CS 201';
```

### Example 4: Self-Referencing 1:N — Employee Hierarchy

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id) ON DELETE SET NULL
);

INSERT INTO employees (name, manager_id)
VALUES ('Alice (CEO)', NULL),
       ('Bob (VP)', 1),
       ('Carol (VP)', 1),
       ('David (Manager)', 2),
       ('Eve (Manager)', 3);

-- Manager → direct reports
SELECT
    CONCAT(m.name, ' manages ', e.name) AS hierarchy
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
ORDER BY m.emp_id;
```

### Example 5: Self-Referencing M:N — Social Network

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- M:N: Users follow other users
CREATE TABLE follows (
    follower_id INT,
    following_id INT,
    since DATE DEFAULT (CURRENT_DATE),
    PRIMARY KEY (follower_id, following_id),
    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (follower_id <> following_id)  -- Can't follow yourself
);

INSERT INTO users (name) VALUES ('Alice'), ('Bob'), ('Carol'), ('David');
INSERT INTO follows (follower_id, following_id)
VALUES (1, 2), (1, 3), (2, 1), (2, 4), (3, 1), (4, 1);

-- Alice's followers:
SELECT u.name AS follower
FROM users u JOIN follows f ON u.user_id = f.follower_id
WHERE f.following_id = 1;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Putting FK on the Wrong Side of 1:N

```sql
-- ❌ WRONG: FK on the "one" side
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    employee_id INT  -- Can only store ONE employee per dept!
);

-- ✅ CORRECT: FK on the "many" side
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    dept_id INT  -- Each employee belongs to one department
);
```

### Mistake 2: Not Enforcing 1:1 Uniqueness

```sql
-- ❌ WRONG: This is actually 1:N, not 1:1
CREATE TABLE user_profiles (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,  -- No UNIQUE — multiple profiles per user possible!
    bio TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ✅ CORRECT: Make user_id the PK (or add UNIQUE)
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,  -- 1:1 enforced
    bio TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### Mistake 3: M:N Without Junction Table

```sql
-- ❌ WRONG: Trying to store multiple values in one column
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    course_ids VARCHAR(200)  -- "1,2,3" — BAD!
);

-- ✅ CORRECT: Use junction table
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id)
);
```

---

## ✅ Exercises

### Exercise 1: Identify and Implement
For each scenario, identify the relationship type and implement it:
1. A person has exactly one passport
2. A library has many books; each book belongs to one category
3. Authors write books; a book can have multiple authors
4. An employee reports to one manager; a manager manages many employees

### Exercise 2: Complex Schema
Design and implement a database for a movie streaming service:
- Users can watch many movies; movies can be watched by many users (watch history with date)
- Movies belong to one genre; genres have many movies
- Movies can have many actors; actors appear in many movies
- Users can create watchlists (many-to-many between users and movies)

### Exercise 3: Query Practice
Using the relationships_db database, write queries for:
1. Find all students enrolled in more than 2 courses
2. Find the manager chain for each employee (up to 2 levels)
3. Find mutual followers (A follows B AND B follows A)

---

## 🧠 Key Takeaways

- **1:1** → FK with UNIQUE (or PK = FK) — for splitting or optional data
- **1:N** → FK on the "many" side — the most common relationship
- **M:N** → Junction table with two FKs — composite PK on both
- **Self-referencing** relationships use a FK pointing to the same table
- FK placement determines the relationship direction and cardinality
- **Composite PK** on junction tables prevents duplicate relationships
- Always consider **ON DELETE** behavior for each FK

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 20: ER Diagrams →](./lesson-20-er-diagrams.md)
**Next:** [Lesson 22: Functional Dependencies →](./lesson-22-functional-dependencies.md)
