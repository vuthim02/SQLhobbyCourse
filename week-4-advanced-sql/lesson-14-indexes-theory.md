# Lesson 14: How Indexes Work (Theory)

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 0:30:00 – 1:00:00 | 30 min |

## 📖 Theory

### What is an Index?

An **index** is a data structure that improves the speed of data retrieval operations on a database table. Think of it like an **index in a book** — instead of reading every page to find a topic, you look it up in the index.

**Without index:** MySQL scans every row (full table scan) — O(n)
**With index:** MySQL uses the index structure to jump directly — O(log n)

### How Indexes Work: B+ Tree

MySQL (InnoDB) stores indexes as **B+ trees** (Balanced tree).

```
         Root Node
        /    |    \
    Internal  Internal  Internal
     Node      Node      Node
     /  \      /  \      /  \
   Leaf  Leaf Leaf Leaf Leaf Leaf  → Data (or pointers to data)
```

**Properties of B+ Trees:**
- All data is in **leaf nodes** (bottom level)
- Leaf nodes are **linked** (for range scans)
- Tree is **balanced** — all leaf nodes are the same depth
- Each node can have many children (not just 2 like binary trees)
- Height is typically only **3-4 levels** even for millions of rows

### Index Traversal Example

Finding `WHERE id = 42` in a table with 10 million rows:

```
Without Index: 10,000,000 row comparisons (full table scan)
With B+ Tree:  ~3-4 node traversals (log₂(10M) ≈ 24, but B+ tree branching is much larger)

Speedup: ~10,000,000 / 4 = 2,500,000x faster
```

### Clustered vs Secondary Indexes

| Type | Description | Leaf Contains | Per Table |
|------|-------------|---------------|-----------|
| **Clustered Index** | The table itself, organized by PK | Full row data | Exactly 1 |
| **Secondary Index** | Additional index on non-PK columns | PK value of the row | Many |

```
Clustered Index (Primary Key = id):
┌────┬──────┬───────┐
│ id │ name │ email │  ← The table IS the leaf level
├────┼──────┼───────┤
│ 1  │ Alice│ a@x   │
│ 2  │ Bob  │ b@x   │
│ 3  │ Carol│ c@x   │
└────┴──────┴───────┘

Secondary Index on name:
┌───────┬────┐
│ name  │ id │  ← Leaf contains PK (id) for lookup
├───────┼────┤
│ Alice │ 1  │
│ Bob   │ 2  │
│ Carol │ 3  │
└───────┴────┘
```

**Secondary Index Lookup Process:**
1. Search the secondary index B+ tree for the value → get the PK
2. Search the clustered index (PK) → get the full row
This is called a **bookmark lookup** or **row lookup**.

### Index Selectivity

**Selectivity** = Number of distinct values / Total rows

| Column | Distinct Values | Total Rows | Selectivity | Good for Index? |
|--------|----------------|------------|-------------|-----------------|
| `id` (PK) | 1,000,000 | 1,000,000 | 100% | ✅ Excellent |
| `email` | 999,999 | 1,000,000 | 99.9% | ✅ Excellent |
| `country` | 195 | 1,000,000 | 0.02% | ⚠️ Low |
| `gender` | 2 | 1,000,000 | 0.0002% | ❌ Poor |
| `is_active` | 2 | 1,000,000 | 0.0002% | ❌ Poor |

High selectivity = fewer rows per index entry = better index performance.

### When Indexes Help

| Query Pattern | Index Helps? | Why |
|--------------|-------------|-----|
| `WHERE id = 5` | ✅ Yes | Exact match on indexed column |
| `WHERE name LIKE 'A%'` | ✅ Yes | Prefix match (B+ tree range scan) |
| `WHERE name LIKE '%A'` | ❌ No | Leading wildcard can't use index |
| `ORDER BY id` | ✅ Yes | B+ tree leaf nodes are already sorted |
| `GROUP BY country` | ✅ Yes | Index groups values |
| `JOIN on foreign_key` | ✅ Yes | FK lookups benefit from index |
| `WHERE age > 25 AND age < 35` | ✅ Yes | Range scan on index |
| `WHERE age + 1 = 26` | ❌ No | Function on indexed column prevents index use |
| `WHERE YEAR(date) = 2024` | ❌ No | Function prevents index use |

### Covering Index

A **covering index** contains ALL columns needed by the query, so MySQL never needs to visit the table itself.

```sql
-- If index exists on (last_name, first_name):
SELECT last_name, first_name FROM employees WHERE last_name = 'Smith';
-- ✅ Covering index — only needs the index, not the table

SELECT last_name, first_name, email FROM employees WHERE last_name = 'Smith';
-- ❌ Not covering — needs email from the table (row lookup)
```

Covering indexes are extremely fast because they avoid the second lookup to the clustered index.

### Index Costs

Indexes are not free:

| Cost | Description |
|------|-------------|
| **Storage** | Each index uses disk space (can be 20-50% of table size) |
| **Write overhead** | INSERT, UPDATE, DELETE must also update all indexes |
| **Maintenance** | Indexes fragment over time, may need rebuilding |

**Rule of thumb:** Add indexes for columns used in WHERE, JOIN, ORDER BY, and GROUP BY. Avoid indexing columns used only for INSERT.

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS index_theory;
USE index_theory;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Generate some sample data
INSERT INTO users (username, email, country, is_active, created_at)
VALUES
    ('alice', 'alice@email.com', 'USA', 1, '2024-01-15'),
    ('bob', 'bob@email.com', 'UK', 1, '2024-02-10'),
    ('carol', 'carol@email.com', 'USA', 0, '2024-03-05'),
    ('david', 'david@email.com', 'Japan', 1, '2024-03-20'),
    ('eve', 'eve@email.com', 'UK', 1, '2024-04-01'),
    ('frank', 'frank@email.com', 'Canada', 0, '2024-04-15'),
    ('grace', 'grace@email.com', 'USA', 1, '2024-05-10'),
    ('henry', 'henry@email.com', 'Germany', 1, '2024-06-01');
```

### Example 1: Understanding Primary Key Index

```sql
-- PRIMARY KEY automatically creates a clustered index
-- This query uses the clustered index directly:
SELECT * FROM users WHERE id = 3;
-- B+ tree: Root → Leaf node for id=3 → Full row returned

-- No full table scan needed — instant lookup regardless of table size
```

### Example 2: Secondary Index Concept

```sql
-- Without an index on email:
SELECT * FROM users WHERE email = 'bob@email.com';
-- Full table scan: checks all 8 rows

-- After adding index:
-- CREATE INDEX idx_email ON users(email);
-- B+ tree lookup: find 'bob@email.com' in index → get id=2 → lookup row in clustered index
```

### Example 3: Index Selectivity Demonstration

```sql
-- High selectivity (good for index):
SELECT * FROM users WHERE email = 'alice@email.com';
-- Returns exactly 1 row out of 8 — very selective

-- Low selectivity (poor for index):
SELECT * FROM users WHERE is_active = 1;
-- Returns 6 out of 8 rows — MySQL may choose full scan instead

-- Very low selectivity (index useless):
SELECT * FROM users WHERE id > 0;
-- Returns ALL rows — full table scan is faster than index
```

### Example 4: Range Queries and B+ Tree

```sql
-- B+ tree leaf nodes are linked — efficient for ranges
SELECT * FROM users WHERE id BETWEEN 3 AND 6;
-- B+ tree: jump to id=3, then scan linked leaf nodes to id=6

-- Works on any indexed column
-- CREATE INDEX idx_created ON users(created_at);
SELECT * FROM users WHERE created_at >= '2024-03-01' AND created_at < '2024-05-01';
```

### Example 5: LIKE and Index Usage

```sql
-- ✅ Uses index (prefix match — B+ tree can start from 'alice')
SELECT * FROM users WHERE username LIKE 'alice%';

-- ❌ Cannot use index (leading wildcard — must check every value)
SELECT * FROM users WHERE username LIKE '%alice';

-- ✅ Uses index (exact match)
SELECT * FROM users WHERE username = 'bob';
```

---

## ⚠️ Common Mistakes

### Mistake 1: Indexing Everything

```sql
-- ❌ WRONG: Too many indexes slow down writes
CREATE TABLE bad_table (
    id INT PRIMARY KEY,
    col1 VARCHAR(50),
    col2 VARCHAR(50),
    col3 VARCHAR(50),
    INDEX(col1),
    INDEX(col2),
    INDEX(col3),
    INDEX(col1, col2),
    INDEX(col2, col3),
    INDEX(col1, col2, col3)
);
-- Every INSERT/UPDATE/DELETE must update ALL these indexes!

-- ✅ CORRECT: Index only columns used in WHERE, JOIN, ORDER BY
CREATE TABLE good_table (
    id INT PRIMARY KEY,
    email VARCHAR(100),
    status VARCHAR(20),
    created_at DATE,
    INDEX(email),       -- Used in WHERE
    INDEX(status, created_at)  -- Used in WHERE + ORDER BY
);
```

### Mistake 2: Indexing Low-Selectivity Columns

```sql
-- ❌ USELESS: is_active has only 2 values — index helps little
-- CREATE INDEX idx_active ON users(is_active);
-- Query: SELECT * FROM users WHERE is_active = 1;
-- Returns 75% of rows — full scan may be faster

-- ✅ CORRECT: Index high-selectivity columns
-- CREATE INDEX idx_email ON users(email);
-- Query: SELECT * FROM users WHERE email = 'x@y.com';
-- Returns 1 row — index is essential
```

### Mistake 3: Functions on Indexed Columns

```sql
-- ❌ WRONG: YEAR() function prevents index usage
SELECT * FROM users WHERE YEAR(created_at) = 2024;
-- MySQL must evaluate YEAR() for every row

-- ✅ CORRECT: Use range comparison on the raw column
SELECT * FROM users WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01';
-- Index can be used directly
```

### Mistake 4: Not Understanding Composite Index Order

```sql
-- CREATE INDEX idx_country_active ON users(country, is_active);

-- ✅ Uses index: filtering on leftmost column
SELECT * FROM users WHERE country = 'USA';

-- ✅ Uses index: filtering on both columns
SELECT * FROM users WHERE country = 'USA' AND is_active = 1;

-- ❌ May NOT use index: skipping leftmost column
SELECT * FROM users WHERE is_active = 1;
-- Composite index: (country, is_active) — must use country first
```

---

## ✅ Exercises

### Exercise 1: Analyze Selectivity
Given a table with 100,000 employees:
- `id` (100,000 distinct values)
- `email` (100,000 distinct)
- `department` (20 distinct)
- `job_title` (500 distinct)
- `office_building` (3 distinct)
- `is_full_time` (2 distinct)

1. Calculate selectivity for each column
2. Rank them from best to worst for indexing
3. Which would you index? Why?

### Exercise 2: Predict Index Usage
For each query, predict whether an index on `(last_name, first_name)` would be used:
1. `WHERE last_name = 'Smith'`
2. `WHERE first_name = 'John'`
3. `WHERE last_name = 'Smith' AND first_name = 'John'`
4. `WHERE last_name LIKE 'Smi%'`
5. `WHERE last_name LIKE '%ith'`
6. `ORDER BY last_name, first_name`
7. `WHERE UPPER(last_name) = 'SMITH'`

### Exercise 3: Design Indexes
For a blog system with tables: `posts(id, title, author_id, published_at, status)`, `comments(id, post_id, user_id, created_at, content)`:
1. What indexes would you create for: "Find all published posts by author, sorted by date"?
2. What indexes for: "Find all comments on a specific post, sorted by date"?
3. Would a covering index help? Design one if so.

---

## 🧠 Key Takeaways

- **Indexes** speed up reads using B+ tree data structures
- **B+ trees** are balanced — 3-4 levels even for millions of rows
- **Clustered index** = the table itself (by PK); **Secondary index** = points to PK
- **Selectivity** matters: high cardinality = better index performance
- Indexes speed up: WHERE, JOIN, ORDER BY, GROUP BY, range scans
- Indexes **slow down** writes (INSERT, UPDATE, DELETE must update indexes too)
- **Functions on indexed columns** prevent index use (`YEAR(date)`, `UPPER(name)`)
- **Leading wildcards** in LIKE (`'%abc'`) cannot use indexes
- **Composite index** leftmost prefix rule: `(A, B, C)` supports queries on A, A+B, A+B+C

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 13: ALTER TABLE →](./lesson-13-alter-table.md)
**Next:** [Lesson 15: Creating & Using Indexes →](./lesson-15-indexes-practice.md)
