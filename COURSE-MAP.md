# Course Map: Which Video Covers What

This document maps all SQL topics to the exact video(s) that cover them best. Use this to find the best video source for each topic.

## Legend

| Icon | Video |
|------|-------|
| 🟦 | **Programming with Mosh** — SQL Course for Beginners (~4h) |
| 🟧 | **Bro Code** — SQL Full Course for free (~4h) |
| 🟩 | **freeCodeCamp (Brototype)** — SQL Tutorial Full Database Course (~4h) |
| 🟪 | **freeCodeCamp (CS50/Harvard)** — Intro to Databases with SQL (~12h) |

---

## Week 1: SQL Basics

| Topic | Best Source(s) | Notes |
|-------|---------------|-------|
| What is a Database? | 🟦 🟧 🟩 | All 3 cover this — pick any |
| What is SQL? | 🟦 🟧 | Mosh explains concisely |
| Installing MySQL | 🟦 🟧 🟩 | Mosh has the clearest install guide |
| Creating a Database | 🟦 🟧 🟩 | `CREATE DATABASE` syntax |
| Data Types Overview | 🟦 🟧 | Intro to INT, VARCHAR, DATE, etc. |
| CREATE TABLE | 🟦 🟧 🟩 | Table structure, columns, columns types |
| INSERT (Basic) | 🟦 🟧 🟩 | Single row inserts |
| SELECT | 🟦 🟧 🟩 | `SELECT *`, selecting columns |
| SELECT DISTINCT | 🟦 🟧 | Remove duplicates |
| WHERE Clause | 🟦 🟧 🟩 | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| AND / OR / NOT | 🟦 🟧 🟩 | Combining conditions |
| IN Operator | 🟦 🟧 | Alternative to multiple OR |
| BETWEEN Operator | 🟦 🟧 | Range filtering |
| LIKE Operator | 🟦 🟧 🟩 | Pattern matching with `%` and `_` |
| REGEXP | 🟦 | Mosh covers regex basics |
| IS NULL / IS NOT NULL | 🟦 🟧 | NULL handling in WHERE |
| ORDER BY | 🟦 🟧 🟩 | ASC, DESC, multiple columns |
| LIMIT / OFFSET | 🟦 🟧 🟩 | Pagination basics |

---

## Week 2: Data Manipulation & Data Types

| Topic | Best Source(s) | Notes |
|-------|---------------|-------|
| INSERT Advanced | 🟧 🟩 | Multi-row inserts |
| UPDATE | 🟦 🟧 🟩 | Updating existing records |
| UPDATE with WHERE | 🟦 🟧 🟩 | Conditional updates |
| DELETE | 🟦 🟧 🟩 | Removing records |
| DELETE vs TRUNCATE | 🟧 🟩 | Important differences |
| Numeric Data Types | 🟦 🟧 🟩 | INT, DECIMAL, FLOAT, etc. |
| String Data Types | 🟦 🟧 🟩 | VARCHAR, CHAR, TEXT, BLOB |
| Date/Time Data Types | 🟦 🟧 🟩 | DATE, TIME, DATETIME, TIMESTAMP, YEAR |
| Boolean | 🟦 🟧 | TINYINT(1) in MySQL |
| Default Values | 🟦 🟧 | `DEFAULT` keyword |
| NOT NULL Constraint | 🟦 🟧 🟩 | Required columns |
| UNIQUE Constraint | 🟦 🟧 | Prevent duplicates |
| PRIMARY KEY | 🟦 🟧 🟩 | Table identity |
| AUTO_INCREMENT | 🟦 🟧 🟩 | Auto-generating IDs |
| CHECK Constraint | 🟧 🟩 | Data validation |
| FOREIGN KEY | 🟦 🟧 🟩 | Relationships between tables |
| ON DELETE / ON UPDATE | 🟦 🟧 | CASCADE, SET NULL, RESTRICT |
| CREATE DATABASE (full) | 🟩 | Complete database creation |

---

## Week 3: Joins, Aggregations & Functions

| Topic | Best Source(s) | Notes |
|-------|---------------|-------|
| INNER JOIN | 🟦 🟧 🟩 | Matching rows from multiple tables |
| LEFT JOIN | 🟦 🟧 🟩 | All rows from left table |
| RIGHT JOIN | 🟦 🟧 | All rows from right table |
| CROSS JOIN | 🟧 🟩 | Cartesian product |
| Self Join | 🟧 🟩 | Joining a table with itself |
| JOIN with USING | 🟦 | Shorthand when column names match |
| NATURAL JOIN | 🟧 | Implicit column matching |
| Multiple Joins | 🟦 🟧 | Joining 3+ tables |
| OUTER JOIN (simulated) | 🟧 🟩 | FULL OUTER JOIN workaround in MySQL |
| Aggregate Functions | 🟦 🟧 🟩 | COUNT, SUM, AVG, MIN, MAX |
| GROUP BY | 🟦 🟧 🟩 | Grouping results |
| HAVING | 🟦 🟧 🟩 | Filtering grouped results |
| Subqueries (WHERE) | 🟦 🟧 🟩 | Queries inside queries |
| Subqueries (FROM) | 🟧 🟩 | Derived tables |
| Subqueries (SELECT) | 🟧 | Scalar subqueries |
| IN with Subqueries | 🟦 🟧 | Dynamic filtering |
| ALL / ANY / SOME | 🟧 | Quantified subqueries |
| String Functions | 🟧 🟩 | CONCAT, LENGTH, UPPER, LOWER, SUBSTRING, TRIM |
| Date Functions | 🟧 🟩 | NOW(), CURDATE(), DATE_FORMAT(), DATEDIFF() |
| IFNULL / COALESCE | 🟦 🟧 | NULL handling |
| CASE WHEN | 🟦 🟧 🟩 | Conditional logic in queries |
| CAST | 🟧 | Type conversion |
| Window Functions (ROW_NUMBER, RANK, etc.) | 🟪 | Advanced analytics queries |
| CTEs (WITH clause) | 🟪 | Query organization and recursion |
| Recursive CTEs | 🟪 | Hierarchical data queries |

---

## Week 4: Advanced SQL

| Topic | Best Source(s) | Notes |
|-------|---------------|-------|
| ALTER TABLE | 🟦 🟧 🟩 | Adding, dropping, modifying columns |
| DROP TABLE / DATABASE | 🟦 🟧 🟩 | Deleting tables and databases |
| Indexes | 🟪 | CS50 covers B-trees, how indexes work |
| How Indexes Work | 🟪 | Performance impact, when to use |
| CREATE INDEX | 🟪 | Single and composite indexes |
| Transactions | 🟪 | ACID properties |
| BEGIN / COMMIT / ROLLBACK | 🟪 | Transaction control |
| Isolation Levels | 🟪 | Read uncommitted, committed, repeatable read, serializable |
| Concurrency Problems | 🟪 | Dirty reads, non-repeatable reads, phantoms |
| Views | 🟪 | Creating and using views |
| CREATE / ALTER / DROP VIEW | 🟪 | View management |
| Triggers | 🟪 | BEFORE/AFTER INSERT, UPDATE, DELETE |
| Stored Procedures | 🟪 | Creating reusable query blocks |
| Variables in SQL | 🟪 | User-defined variables |
| Cursors | 🟪 | Row-by-row processing |
| Window Functions | 🟪 | ROW_NUMBER(), RANK(), DENSE_RANK() |
| CTEs (Common Table Expressions) | 🟪 | WITH clause |

---

## Week 5: Database Design

| Topic | Best Source(s) | Notes |
|-------|---------------|-------|
| Database Design Principles | 🟪 | CS50's strongest section |
| Entity-Relationship Diagrams | 🟪 | Entities, attributes, relationships |
| One-to-One Relationships | 🟪 | 1:1 cardinality |
| One-to-Many Relationships | 🟪 | 1:N cardinality |
| Many-to-Many Relationships | 🟪 | M:N cardinality, junction tables |
| Keys (Primary, Foreign, Candidate, Super) | 🟪 | All key types explained |
| Functional Dependencies | 🟪 | Mathematical foundation |
| Normalization: 1NF | 🟪 | Atomic values, no repeating groups |
| Normalization: 2NF | 🟪 | No partial dependencies |
| Normalization: 3NF | 🟪 | No transitive dependencies |
| Boyce-Codd Normal Form (BCNF) | 🟪 | Stronger version of 3NF |
| Denormalization | 🟪 | When and why to break normalization |
| Relational Algebra | 🟪 | SELECT, PROJECT, JOIN operators (theoretical foundation) |

---

## Week 6: Real-World SQL

| Topic | Best Source(s) | Notes |
|-------|---------------|-------|
| User Management | 🟪 | Creating users, granting privileges |
| SQL Injection | 🟪 | Security best practices |
| Parameterized Queries | 🟪 | Preventing SQL injection |
| Performance Tuning | 🟪 | Query optimization |
| EXPLAIN | 🟪 | Reading query execution plans |
| Query Optimization | 🟪 | Writing efficient queries |
| Storage Engines (InnoDB vs MyISAM) | 🟪 | Engine differences |
| Backup & Restore | 🟪 | mysqldump, restoring databases |
| Connecting SQL to Applications | 🟪 | Python, web apps, ORMs |
| Real-World Database Architecture | 🟪 | How production databases are set up |
| ORM vs Raw SQL | 🟪 | Pros and cons of each approach |

---

## Quick Reference: Best Video per Topic

| If You Want... | Watch... |
|----------------|----------|
| **Fastest intro to SQL** | 🟦 Mosh (3h, very clear) |
| **Most exercises & examples** | 🟧 Bro Code (4h, hands-on) |
| **Good balance of theory + practice** | 🟩 Brototype (4h, practical) |
| **Deep understanding + CS fundamentals** | 🟪 CS50 (12h, Harvard-quality lectures) |
| **Database design & normalization** | 🟪 CS50 (best explanation) |
| **Indexes & performance** | 🟪 CS50 (how things work under the hood) |
| **Quick reference for syntax** | 🟦 Mosh (concise, well-structured) |
