# Lesson 01: What is a Database & SQL?

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 0:00 – 15:00 | 15 min |
| 🟧 Bro Code | 0:00 – 10:00 | 10 min |

## 📖 Theory

### What is a Database?

A **database** is an organized collection of structured data that can be easily accessed, managed, and updated. Think of it as a digital filing cabinet.

**Without a database:**
- Data stored in spreadsheets or text files
- Hard to search, update, or share
- No built-in security or consistency checks

**With a database:**
- Fast searching and filtering
- Concurrent access by multiple users
- Built-in security, backup, and recovery
- Data integrity through constraints

### What is a DBMS?

A **Database Management System (DBMS)** is software that interacts with the database, users, and applications. Examples:

| DBMS | Type | Used By |
|------|------|---------|
| **MySQL** | Relational | Facebook, Uber, Airbnb |
| **PostgreSQL** | Relational | Apple, Instagram, Spotify |
| **SQLite** | Relational (embedded) | Android, iPhone, browsers |
| **MongoDB** | NoSQL (document) | eBay, Cisco, Forbes |
| **Redis** | NoSQL (key-value) | Twitter, GitHub, Stack Overflow |

### What is SQL?

**SQL (Structured Query Language)** is the standard language for interacting with relational databases.

```
SQL Commands
├── DDL (Data Definition Language)     → CREATE, ALTER, DROP
├── DML (Data Manipulation Language)   → SELECT, INSERT, UPDATE, DELETE
├── DCL (Data Control Language)        → GRANT, REVOKE
└── TCL (Transaction Control Language) → COMMIT, ROLLBACK, SAVEPOINT
```

### Relational Database Concepts

| Term | Definition | Example |
|------|------------|---------|
| **Table** | A collection of related data | `students` table |
| **Column (Field)** | A specific attribute | `name`, `email`, `age` |
| **Row (Record)** | A single entry | One specific student |
| **Primary Key** | A unique identifier for each row | `student_id` |

### How MySQL Works Internally (Simplified)

```
Your SQL Query
    ↓
MySQL Server parses the query
    ↓
Query Optimizer finds the best execution path
    ↓
Storage Engine (InnoDB) reads/writes data
    ↓
Results returned to you
```

MySQL stores data in **pages** (typically 16KB each) organized in **B+ tree** structures for fast lookups.

---

## 💻 Installation

### Linux

```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Windows

1. Download from https://dev.mysql.com/downloads/installer/
2. Run the installer (choose "Developer Default")
3. Set a root password
4. Test: Open MySQL Command Line Client

### macOS

```bash
brew install mysql
brew services start mysql
mysql_secure_installation
```

### Verify Installation

```bash
mysql --version
```

---

## 💻 Your First Commands

### Connect to MySQL

```bash
mysql -u root -p
```

### Create Your First Database

```sql
-- Create a database
CREATE DATABASE school;

-- Use the database
USE school;

-- See current database
SELECT DATABASE();
```

### Create Your First Table

```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    birth_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### See Your Table Structure

```sql
DESCRIBE students;
```

### Insert Your First Row

```sql
INSERT INTO students (first_name, last_name, email, birth_date)
VALUES ('John', 'Doe', 'john@example.com', '2000-05-15');
```

### Select Your First Data

```sql
-- Get all students
SELECT * FROM students;

-- Get specific columns
SELECT first_name, last_name FROM students;
```

---

## ✅ Exercises

### Exercise 1: Setup
1. Install MySQL on your system
2. Connect to it via terminal or a GUI tool
3. Verify the version with `mysql --version`

### Exercise 2: First Database
1. Create a database called `test_db`
2. Use it with `USE test_db`
3. Create a table called `people` with columns: `id`, `name`, `age`, `city`
4. Insert 3 rows
5. Select all rows

### Exercise 3: Explore
1. Run `SHOW DATABASES;` — what databases exist?
2. Run `SHOW TABLES;` in your database — what tables exist?
3. Run `DESCRIBE people;` — what does each column mean?

---

## 🧠 Key Takeaways

- A **database** organizes data so it can be efficiently stored and retrieved
- **MySQL** is a relational DBMS that uses **SQL** to interact with data
- **Tables** consist of **columns** (structure) and **rows** (data)
- **SQL commands** are grouped into DDL, DML, DCL, and TCL
- MySQL uses **InnoDB** as its default storage engine with **B+ trees** for indexing

---

## 📝 Notes

_Add your own observations here:_

---

**Next:** [Lesson 02: Creating Tables & Data Types →](./lesson-02-create-table.md)
