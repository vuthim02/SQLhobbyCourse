# Study Plan: 6-Week SQL Mega Course

This is a **day-by-day study plan** for completing all 4 video courses merged into one progressive curriculum.

> **Estimated total time: ~130 hours** (24h video + 45h reading + 42h practice + 19h projects)

---

## Week 1: SQL Basics (Days 1-7)

**Goal:** Understand databases, install MySQL, write basic queries

| Day | Topic | Watch | Read | Practice | Time |
|-----|-------|-------|------|----------|------|
| **Day 1** | What is a Database & SQL? | 🟦 0:00–15:00<br>🟧 0:00–10:00 | [lesson-01-intro.md](./week-1-sql-basics/lesson-01-intro.md) | Install MySQL, create first DB | 3h |
| **Day 2** | Creating Tables & Data Types | 🟦 15:00–45:00<br>🟧 10:00–30:00 | [lesson-02-create-table.md](./week-1-sql-basics/lesson-02-create-table.md) | Create 3 tables with different types | 3h |
| **Day 3** | INSERT & SELECT | 🟦 45:00–1:10:00<br>🟧 30:00–50:00 | [lesson-03-insert-select.md](./week-1-sql-basics/lesson-03-insert-select.md) | Insert 10+ rows, write 10 SELECT queries | 3h |
| **Day 4** | WHERE Clause Deep Dive | 🟦 1:10:00–1:45:00<br>🟧 50:00–1:20:00 | [lesson-04-where.md](./week-1-sql-basics/lesson-04-where.md) | Write 20 WHERE queries with different operators | 4h |
| **Day 5** | ORDER BY & LIMIT | 🟦 1:45:00–2:00:00<br>🟧 1:20:00–1:35:00 | [lesson-05-order-limit.md](./week-1-sql-basics/lesson-05-order-limit.md) | Practice sorting + pagination queries | 2h |
| **Day 6** | Practice Day | 🟩 0:00–1:00:00 (review basics) | Review all Week 1 lessons | Complete [exercises.sql](./week-1-sql-basics/exercises.sql) | 4h |
| **Day 7** | Week 1 Test | — | Self-assessment (below) | Build a database from scratch with 5+ queries | 3h |

### Week 1 Test Checklist
- [ ] Create a database and 3 related tables
- [ ] Insert at least 10 rows into each table
- [ ] Write SELECT queries with WHERE, AND/OR, IN, BETWEEN, LIKE
- [ ] Sort results with ORDER BY (multiple columns, ASC/DESC)
- [ ] Use LIMIT/OFFSET for pagination
- [ ] Use SELECT DISTINCT

---

## Week 2: Data Manipulation & Data Types (Days 8-14)

**Goal:** Master INSERT, UPDATE, DELETE, understand all data types and constraints

| Day | Topic | Watch | Read | Practice | Time |
|-----|-------|-------|------|----------|------|
| **Day 8** | INSERT Advanced Techniques | 🟧 1:35:00–1:55:00<br>🟩 1:00:00–1:20:00 | [lesson-05-insert-advanced.md](./week-2-dml-data-types/lesson-05-insert-advanced.md) | Multi-row inserts, bulk loading | 3h |
| **Day 9** | UPDATE — Modifying Data | 🟦 2:00:00–2:20:00<br>🟧 1:55:00–2:15:00 | [lesson-06-update.md](./week-2-dml-data-types/lesson-06-update.md) | Update with WHERE, conditional updates | 3h |
| **Day 10** | DELETE & TRUNCATE | 🟦 2:20:00–2:30:00<br>🟧 2:15:00–2:30:00 | [lesson-07-delete.md](./week-2-dml-data-types/lesson-07-delete.md) | Delete with conditions, soft deletes pattern | 2h |
| **Day 11** | Data Types Deep Dive | 🟧 2:30:00–3:10:00<br>🟩 1:20:00–1:50:00 | [lesson-08-data-types.md](./week-2-dml-data-types/lesson-08-data-types.md) | Experiment with all numeric, string, date types | 4h |
| **Day 12** | Constraints (NOT NULL, UNIQUE, CHECK) | 🟧 3:10:00–3:35:00<br>🟩 1:50:00–2:15:00 | [lesson-09-constraints.md](./week-2-dml-data-types/lesson-09-constraints.md) | Create tables with all constraint types | 3h |
| **Day 13** | PRIMARY KEY & FOREIGN KEY | 🟦 2:30:00–3:00:00<br>🟧 3:35:00–4:00:00 | [lesson-10-keys.md](./week-2-dml-data-types/lesson-10-keys.md) | Build a relational schema with FKs | 4h |
| **Day 14** | Week 2 Test | — | Self-assessment (below) | Build a blog database with 4+ tables, constraints, FKs | 4h |

### Week 2 Test Checklist
- [ ] Create tables with all data types (INT, VARCHAR, DATE, DECIMAL, BOOLEAN)
- [ ] Apply all constraints (PK, FK, NOT NULL, UNIQUE, DEFAULT, CHECK)
- [ ] Write INSERT, UPDATE, DELETE queries with conditions
- [ ] Demonstrate CASCADE, SET NULL, RESTRICT on FKs
- [ ] Explain the difference between DELETE and TRUNCATE

---

## Week 3: Joins, Aggregations & Functions (Days 15-21)

**Goal:** Master multi-table queries, aggregate data, and use SQL functions

| Day | Topic | Watch | Read | Practice | Time |
|-----|-------|-------|------|----------|------|
| **Day 15** | INNER JOIN | 🟦 2:20:00–2:50:00<br>🟧 2:40:00–3:10:00 | [lesson-09-inner-join.md](./week-3-joins-functions/lesson-09-inner-join.md) | Join 2-3 tables, 15+ queries | 4h |
| **Day 16** | LEFT JOIN & RIGHT JOIN | 🟦 2:50:00–3:10:00<br>🟧 3:10:00–3:30:00 | [lesson-10-outer-joins.md](./week-3-joins-functions/lesson-10-outer-joins.md) | Anti-join pattern, find missing records | 3h |
| **Day 17** | Multiple Joins & Self Joins | 🟧 3:30:00–3:50:00<br>🟩 2:30:00–2:50:00 | [lesson-11-multi-joins.md](./week-3-joins-functions/lesson-11-multi-joins.md) | Self joins, 4+ table joins | 4h |
| **Day 18** | Aggregate Functions & GROUP BY | 🟦 3:10:00–3:30:00<br>🟧 3:50:00–4:15:00 | [lesson-12-aggregations.md](./week-3-joins-functions/lesson-12-aggregations.md) | COUNT, SUM, AVG, MIN, MAX with GROUP BY | 3h |
| **Day 19** | HAVING & Filtering Aggregates | 🟦 3:30:00–3:40:00<br>🟧 4:15:00–4:30:00 | [lesson-13-having.md](./week-3-joins-functions/lesson-13-having.md) | WHERE vs HAVING, combined filtering | 2h |
| **Day 20** | Subqueries | 🟦 3:40:00–4:00:00<br>🟧 4:30:00–4:55:00 | [lesson-14-subqueries.md](./week-3-joins-functions/lesson-14-subqueries.md) | WHERE, FROM, SELECT subqueries | 4h |
| **Day 21** | String/Date Functions & CASE | 🟧 3:00:00–3:35:00<br>🟩 2:50:00–3:15:00 | [lesson-15-string-date-functions.md](./week-3-joins-functions/lesson-15-string-date-functions.md) | CONCAT, UPPER, DATE_FORMAT, CASE WHEN | 4h |
| **Day 22** | Week 3 Test | — | Self-assessment (below) + [lesson-16-window-functions-ctes.md](./week-3-joins-functions/lesson-16-window-functions-ctes.md) | Write 10 complex queries + window functions intro | 5h |

### Week 3 Test Checklist
- [ ] Write INNER JOIN, LEFT JOIN, RIGHT JOIN queries
- [ ] Join 3+ tables in a single query
- [ ] Use GROUP BY with multiple aggregate functions
- [ ] Filter grouped results with HAVING
- [ ] Write correlated and non-correlated subqueries
- [ ] Use string functions (CONCAT, UPPER, SUBSTRING, LENGTH, TRIM)
- [ ] Use date functions (NOW, DATE_FORMAT, DATEDIFF, TIMESTAMPDIFF)
- [ ] Use CASE WHEN for conditional logic in SELECT and ORDER BY
- [ ] Use IFNULL/COALESCE for NULL handling
- [ ] Use ROW_NUMBER, RANK, or DENSE_RANK for ranking
- [ ] Use LAG/LEAD for comparing rows
- [ ] Write a query using a CTE (WITH clause)

---

## Week 4: Advanced SQL (Days 23-29)

**Goal:** Understand indexes, transactions, views, triggers, and stored procedures

| Day | Topic | Watch | Read | Practice | Time |
|-----|-------|-------|------|----------|------|
| **Day 23** | ALTER TABLE & Schema Modifications | 🟧 4:00:00–4:20:00<br>🟩 2:45:00–3:05:00 | [lesson-13-alter-table.md](./week-4-advanced-sql/lesson-13-alter-table.md) | Add/drop/modify columns | 2h |
| **Day 24** | How Indexes Work (Theory) | 🟪 0:30:00–1:00:00 | [lesson-14-indexes-theory.md](./week-4-advanced-sql/lesson-14-indexes-theory.md) | B+ trees, index types, when to use | 3h |
| **Day 25** | Creating & Using Indexes | 🟪 1:00:00–1:30:00 | [lesson-15-indexes-practice.md](./week-4-advanced-sql/lesson-15-indexes-practice.md) | Create indexes, compare query performance | 3h |
| **Day 26** | Transactions & ACID | 🟪 1:30:00–2:15:00 | [lesson-16-transactions.md](./week-4-advanced-sql/lesson-16-transactions.md) | BEGIN, COMMIT, ROLLBACK practice | 4h |
| **Day 27** | Views | 🟪 2:15:00–2:45:00 | [lesson-17-views.md](./week-4-advanced-sql/lesson-17-views.md) | Create, use, and manage views | 3h |
| **Day 28** | Triggers & Stored Procedures | 🟪 2:45:00–3:30:00 | [lesson-18-triggers-procedures.md](./week-4-advanced-sql/lesson-18-triggers-procedures.md) | Create triggers, write stored procedures | 4h |
| **Day 29** | Week 4 Test | — | Self-assessment (below) | Build a system using transactions, triggers, views | 4h |

### Week 4 Test Checklist
- [ ] ALTER TABLE: add, drop, modify columns
- [ ] Explain how indexes work and when to create them
- [ ] Create single and composite indexes
- [ ] Use BEGIN/COMMIT/ROLLBACK for transactions
- [ ] Create and query views
- [ ] Write a trigger (BEFORE/AFTER)
- [ ] Create a stored procedure with parameters

---

## Week 5: Database Design (Days 30-36)

**Goal:** Learn to design proper database schemas and normalize data

| Day | Topic | Watch | Read | Practice | Time |
|-----|-------|-------|------|----------|------|
| **Day 30** | Database Design Principles | 🟪 3:30:00–4:15:00 | [lesson-19-design-principles.md](./week-5-database-design/lesson-19-design-principles.md) | Analyze 3 real-world schemas | 3h |
| **Day 31** | ER Diagrams | 🟪 4:15:00–5:00:00 | [lesson-20-er-diagrams.md](./week-5-database-design/lesson-20-er-diagrams.md) | Draw ERDs for 2 systems | 4h |
| **Day 32** | Relationships (1:1, 1:N, M:N) | 🟪 5:00:00–5:45:00 | [lesson-21-relationships.md](./week-5-database-design/lesson-21-relationships.md) | Implement all relationship types | 4h |
| **Day 33** | Functional Dependencies | 🟪 5:45:00–6:30:00 | [lesson-22-functional-dependencies.md](./week-5-database-design/lesson-22-functional-dependencies.md) | Identify FDs in sample tables | 3h |
| **Day 34** | Normalization: 1NF, 2NF, 3NF | 🟪 6:30:00–7:30:00 | [lesson-23-normalization.md](./week-5-database-design/lesson-23-normalization.md) | Normalize a denormalized table | 4h |
| **Day 35** | BCNF & Denormalization | 🟪 7:30:00–8:15:00 | [lesson-24-bcdf-denormalization.md](./week-5-database-design/lesson-24-bcdf-denormalization.md) | When to denormalize and why | 3h |
| **Day 36** | Week 5 Test | — | Self-assessment (below) | Design a normalized schema for an e-commerce system | 4h |

### Week 5 Test Checklist
- [ ] Draw an ER diagram for a complex system (5+ entities)
- [ ] Implement 1:1, 1:N, and M:N relationships
- [ ] Explain and apply 1NF, 2NF, 3NF, BCNF
- [ ] Identify functional dependencies in a table
- [ ] Justify when to denormalize

---

## Week 6: Real-World SQL (Days 37-43)

**Goal:** Security, performance, and connecting SQL to applications

| Day | Topic | Watch | Read | Practice | Time |
|-----|-------|-------|------|----------|------|
| **Day 37** | User Management & Privileges | 🟪 8:15:00–8:45:00 | [lesson-25-security.md](./week-6-real-world/lesson-25-security.md) | Create users, grant/revoke privileges | 3h |
| **Day 38** | SQL Injection & Prevention | 🟪 8:45:00–9:15:00 | [lesson-26-sql-injection.md](./week-6-real-world/lesson-26-sql-injection.md) | Write vulnerable + safe queries | 3h |
| **Day 39** | EXPLAIN & Query Performance | 🟪 9:15:00–10:00:00 | [lesson-27-explain.md](./week-6-real-world/lesson-27-explain.md) | Analyze 5+ queries with EXPLAIN | 4h |
| **Day 40** | Query Optimization Techniques | 🟪 10:00:00–10:45:00 | [lesson-28-optimization.md](./week-6-real-world/lesson-28-optimization.md) | Optimize slow queries | 4h |
| **Day 41** | Storage Engines & Architecture | 🟪 10:45:00–11:15:00 | [lesson-29-storage-engines.md](./week-6-real-world/lesson-29-storage-engines.md) | InnoDB vs MyISAM comparison | 2h |
| **Day 42** | Backup, Restore & Connecting to Apps | 🟪 11:15:00–12:00:00 | [lesson-30-apps-apis.md](./week-6-real-world/lesson-30-apps-apis.md) | mysqldump, connect Python to MySQL | 3h |
| **Day 43** | Week 6 Test & Course Review | — | Self-assessment (below) | Final capstone project planning | 4h |

### Week 6 Test Checklist
- [ ] Create a MySQL user with limited privileges
- [ ] Demonstrate SQL injection and fix it with parameterized queries
- [ ] Read and understand EXPLAIN output
- [ ] Optimize a slow query using indexes
- [ ] Explain InnoDB vs MyISAM differences
- [ ] Backup and restore a database

---

## Capstone Projects (Days 44-50)

After completing all 6 weeks, build the 3 projects in the `projects/` folder:

| Day | Project | Description | Time |
|-----|---------|-------------|------|
| **Day 43-44** | Project 1: Basic Database | Student management system (CRUD + reports) | 8h |
| **Day 45-46** | Project 2: E-Commerce | Full e-commerce DB with analytics queries | 8h |
| **Day 47-49** | Project 3: Full-Stack | Connect MySQL to a web app (Python/Node.js) | 12h |

---

## Study Tips

1. **Don't rush.** Understanding WHY is more important than finishing fast.
2. **Type every query yourself.** Don't copy-paste — muscle memory matters.
3. **Break things on purpose.** Try to cause errors so you learn to debug them.
4. **Take notes.** Use the lesson files as templates, add your own observations.
5. **Re-watch difficult topics.** If something doesn't click, watch it again from a different video.
6. **Build something real.** The projects are where the real learning happens.

---

**Ready?** Start with [Week 1, Day 1](./week-1-sql-basics/lesson-01-intro.md)!
