# Lesson 05: ORDER BY & LIMIT

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 1:45:00 – 2:00:00 | 15 min |
| 🟧 Bro Code | 1:20:00 – 1:35:00 | 15 min |

## 📖 Theory

### ORDER BY — Sorting Results

```sql
SELECT columns
FROM table_name
WHERE conditions
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC];
```

- **ASC** (ascending) is the default: A→Z, 0→9
- **DESC** (descending): Z→A, 9→0

### LIMIT & OFFSET — Pagination

```sql
-- Get only N rows
SELECT * FROM table_name LIMIT N;

-- Skip M rows, then get N rows
SELECT * FROM table_name LIMIT N OFFSET M;
-- Or shorthand:
SELECT * FROM table_name LIMIT M, N;  -- skip M, get N
```

---

## 💻 Examples

### Setup

```sql
USE store;

-- (Assuming the customers table from previous lessons exists)
```

### 1. Basic ORDER BY

```sql
-- Sort by first name (A to Z)
SELECT first_name, last_name 
FROM customers 
ORDER BY first_name ASC;

-- Sort by points (highest first)
SELECT first_name, last_name, points 
FROM customers 
ORDER BY points DESC;

-- ASC is the default — these are equivalent:
ORDER BY first_name
ORDER BY first_name ASC
```

### 2. Sorting by Multiple Columns

```sql
-- Sort by state, then by points within each state
SELECT first_name, last_name, state, points 
FROM customers 
ORDER BY state ASC, points DESC;

-- Sort by birth year, then by last name
SELECT first_name, last_name, birth_date
FROM customers 
ORDER BY YEAR(birth_date) ASC, last_name ASC;
```

### 3. Sorting by Column Position (Not Recommended)

```sql
-- This works but is bad practice:
SELECT first_name, last_name, points 
FROM customers 
ORDER BY 3 DESC;  -- 3rd column = points

-- ✅ Better: use the column name
ORDER BY points DESC;
```

### 4. Sorting by Expressions

```sql
-- Sort by full name
SELECT first_name, last_name
FROM customers
ORDER BY CONCAT(first_name, ' ', last_name);

-- Sort by a calculated value
SELECT first_name, last_name, points,
       points * 1.10 AS `Points + 10%`
FROM customers
ORDER BY `Points + 10%` DESC;
```

### 5. NULL Values in ORDER BY

In MySQL, **NULL values sort first** in ASC order, **last** in DESC order.

```sql
-- NULLs appear FIRST
SELECT first_name, last_name, points 
FROM customers 
ORDER BY points ASC;

-- NULLs appear LAST
SELECT first_name, last_name, points 
FROM customers 
ORDER BY points DESC;

-- Force NULLs to always appear last (regardless of ASC/DESC):
SELECT first_name, last_name, points
FROM customers
ORDER BY 
    points IS NULL,   -- FALSE (0) first, TRUE (1) last
    points ASC;
```

### 6. LIMIT — Restricting Results

```sql
-- Get only the top 3 customers by points
SELECT first_name, last_name, points 
FROM customers 
ORDER BY points DESC 
LIMIT 3;

-- Get the 5 most recently born customers
SELECT first_name, last_name, birth_date 
FROM customers 
ORDER BY birth_date DESC 
LIMIT 5;
```

### 7. OFFSET — Pagination

```sql
-- Page 1: First 3 customers
SELECT * FROM customers ORDER BY customer_id LIMIT 3 OFFSET 0;

-- Page 2: Next 3 customers
SELECT * FROM customers ORDER BY customer_id LIMIT 3 OFFSET 3;

-- Page 3: Next 3 customers
SELECT * FROM customers ORDER BY customer_id LIMIT 3 OFFSET 6;
```

**Pagination formula:** For page `P` with `N` items per page:
```sql
LIMIT N OFFSET (P - 1) * N
```

### 8. LIMIT with Shorthand

```sql
-- These are equivalent:
LIMIT 3 OFFSET 6
LIMIT 6, 3   -- skip 6, get 3
```

> ⚠️ The shorthand `LIMIT offset, count` is MySQL-specific. The standard `LIMIT count OFFSET offset` works across databases.

---

## ⚠️ Common Mistakes

### Mistake 1: ORDER BY Before WHERE

```sql
-- ❌ WRONG order
SELECT * FROM customers ORDER BY points WHERE points > 100;

-- ✅ CORRECT order: SELECT → FROM → WHERE → ORDER BY → LIMIT
SELECT * FROM customers WHERE points > 100 ORDER BY points DESC;
```

### Mistake 2: Forgetting ORDER Before LIMIT

```sql
-- ❌ This gets 3 random rows (whatever MySQL returns first)
SELECT * FROM customers LIMIT 3;

-- ✅ This gets the top 3 by points
SELECT * FROM customers ORDER BY points DESC LIMIT 3;
```

### Mistake 3: OFFSET Without ORDER BY

```sql
-- ❌ Meaningless — rows aren't guaranteed in any order
SELECT * FROM customers LIMIT 5 OFFSET 5;

-- ✅ Always pair OFFSET with ORDER BY for consistent results
SELECT * FROM customers ORDER BY customer_id LIMIT 5 OFFSET 5;
```

---

## ✅ Exercises

### Exercise 1: Basic Sorting

1. Sort all customers by last name (A to Z)
2. Sort customers by points (highest first)
3. Sort customers by birth date (oldest first)
4. Sort by state (A to Z), then by points (highest first) within each state

### Exercise 2: LIMIT Queries

1. Get the top 5 customers by points
2. Get the 3 youngest customers (most recent birth dates)
3. Get the first 4 customers alphabetically by last name

### Exercise 3: Pagination

1. Simulate page 1 of results: 3 customers per page, sorted by customer_id
2. Simulate page 2 (next 3 customers)
3. Simulate page 3
4. How would you get page 4? Page 5?

### Exercise 4: Combined Challenges

1. Get the top 3 customers from Texas by points
2. Get the 2 customers with the longest last names, sorted by name length
3. Get customers born in the 1990s, sorted by birth date, limited to 5 results
4. Get page 2 (3 results per page) of customers from California, sorted by points descending

---

## 🧠 Key Takeaways

- **ORDER BY** sorts results; default is ASC
- Sort by **multiple columns** by separating with commas
- **LIMIT** restricts the number of rows returned
- **OFFSET** skips rows for pagination
- Always use **ORDER BY with LIMIT** for predictable results
- NULLs sort **first in ASC**, **last in DESC**
- SQL execution order: FROM → WHERE → SELECT → ORDER BY → LIMIT

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 04: WHERE Clause →](./lesson-04-where.md)  
**Next:** [Week 1 Exercises →](./exercises.sql)
