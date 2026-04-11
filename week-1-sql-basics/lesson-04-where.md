# Lesson 04: WHERE Clause Deep Dive

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 1:10:00 – 1:45:00 | 35 min |
| 🟧 Bro Code | 50:00 – 1:20:00 | 30 min |

## 📖 Theory

The `WHERE` clause **filters rows** based on conditions. Only rows where the condition evaluates to TRUE are returned.

```sql
SELECT columns
FROM table_name
WHERE condition;
```

### Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equal to | `WHERE state = 'CA'` |
| `<>` or `!=` | Not equal to | `WHERE state <> 'CA'` |
| `>` | Greater than | `WHERE points > 3000` |
| `<` | Less than | `WHERE points < 100` |
| `>=` | Greater than or equal | `WHERE points >= 1000` |
| `<=` | Less than or equal | `WHERE points <= 500` |

### Logical Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| **AND** | Both conditions must be true | `WHERE state = 'CA' AND points > 1000` |
| **OR** | At least one condition must be true | `WHERE state = 'CA' OR state = 'NY'` |
| **NOT** | Negates the condition | `WHERE NOT state = 'CA'` |

### Special Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| **IN** | Matches any value in a list | `WHERE state IN ('CA', 'NY', 'TX')` |
| **BETWEEN** | Within a range (inclusive) | `WHERE points BETWEEN 100 AND 500` |
| **LIKE** | Pattern matching | `WHERE last_name LIKE 'S%'` |
| **REGEXP** | Regular expression matching | `WHERE last_name REGEXP '^S'` |
| **IS NULL** | Checks for NULL values | `WHERE phone IS NULL` |
| **IS NOT NULL** | Checks for non-NULL values | `WHERE phone IS NOT NULL` |

---

## 💻 Examples

### Setup

```sql
USE store;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    points INT DEFAULT 0,
    city VARCHAR(50),
    state VARCHAR(20),
    birth_date DATE
);

INSERT INTO customers (first_name, last_name, email, points, city, state, birth_date)
VALUES 
    ('John', 'Smith', 'john@email.com', 100, 'New York', 'NY', '1990-01-15'),
    ('Jane', 'Doe', 'jane@email.com', 250, 'Los Angeles', 'CA', '1985-03-22'),
    ('Bob', 'Johnson', 'bob@email.com', 50, 'Chicago', 'IL', '1992-07-10'),
    ('Alice', 'Williams', 'alice@email.com', 500, 'Houston', 'TX', '1988-11-30'),
    ('Charlie', 'Brown', 'charlie@email.com', 0, 'Phoenix', 'AZ', '1995-05-18'),
    ('Diana', 'Ross', 'diana@email.com', 1000, 'Miami', 'FL', '1980-12-25'),
    ('Eve', 'Davis', 'eve@email.com', 300, 'San Francisco', 'CA', '1993-08-05'),
    ('Frank', 'Miller', 'frank@email.com', 75, 'Dallas', 'TX', '1987-04-12'),
    ('Grace', 'Wilson', 'grace@email.com', NULL, 'Austin', 'TX', '1991-09-20'),
    ('Henry', 'Taylor', 'henry@email.com', 450, 'Boston', 'MA', '1989-02-28');
```

### 1. Basic Comparison Operators

```sql
-- Customers from California
SELECT * FROM customers WHERE state = 'CA';

-- Customers with more than 200 points
SELECT first_name, last_name, points 
FROM customers 
WHERE points > 200;

-- Customers with 500 points or less
SELECT * FROM customers WHERE points <= 500;

-- Customers NOT from Texas
SELECT * FROM customers WHERE state <> 'TX';
```

### 2. AND / OR / NOT

```sql
-- California customers with more than 200 points
SELECT * FROM customers 
WHERE state = 'CA' AND points > 200;

-- Customers from California OR New York
SELECT * FROM customers 
WHERE state = 'CA' OR state = 'NY';

-- High-value customers: points > 200 AND from CA or NY
SELECT * FROM customers 
WHERE points > 200 AND (state = 'CA' OR state = 'NY');

-- Customers NOT from California
SELECT * FROM customers 
WHERE NOT state = 'CA';
```

> **Important:** AND has higher precedence than OR. Use parentheses to be explicit.

### 3. IN Operator

```sql
-- Customers from specific states
SELECT * FROM customers 
WHERE state IN ('CA', 'NY', 'TX');

-- Same as:
-- WHERE state = 'CA' OR state = 'NY' OR state = 'TX'

-- NOT IN
SELECT * FROM customers 
WHERE state NOT IN ('CA', 'NY');
```

### 4. BETWEEN Operator

```sql
-- Customers with 100 to 500 points (inclusive)
SELECT * FROM customers 
WHERE points BETWEEN 100 AND 500;

-- Same as: WHERE points >= 100 AND points <= 500

-- NOT BETWEEN
SELECT * FROM customers 
WHERE points NOT BETWEEN 100 AND 500;

-- Date range
SELECT * FROM customers 
WHERE birth_date BETWEEN '1985-01-01' AND '1990-12-31';
```

### 5. LIKE Operator (Pattern Matching)

| Pattern | Meaning | Matches |
|---------|---------|---------|
| `'S%'` | Starts with S | Smith, Sanchez, Stevens |
| `'%son'` | Ends with son | Johnson, Wilson, Davisson |
| `'%ill%'` | Contains ill | Williams, Miller, Villanueva |
| `_ohn'` | Any single char + ohn | John, Cohn, Bohn |
| `'J_n%'` | J + any char + n + anything | Jane, Jons, Jinx |

```sql
-- Last names starting with 'S'
SELECT * FROM customers 
WHERE last_name LIKE 'S%';

-- Last names ending with 'son'
SELECT * FROM customers 
WHERE last_name LIKE '%son';

-- Last names containing 'ill'
SELECT * FROM customers 
WHERE last_name LIKE '%ill%';

-- First names with exactly 4 letters
SELECT * FROM customers 
WHERE first_name LIKE '____';  -- 4 underscores

-- First names starting with 'J' followed by any 3 letters
SELECT * FROM customers 
WHERE first_name LIKE 'J___';
```

### 6. REGEXP (Regular Expressions)

```sql
-- Last names starting with 'S'
SELECT * FROM customers 
WHERE last_name REGEXP '^S';

-- Last names ending with 'son'
SELECT * FROM customers 
WHERE last_name REGEXP 'son$';

-- Last names containing 'ill' or 'mil'
SELECT * FROM customers 
WHERE last_name REGEXP 'ill|mil';

-- First names starting with J, K, or L
SELECT * FROM customers 
WHERE first_name REGEXP '^[JKL]';

-- First names containing 'a' or 'e'
SELECT * FROM customers 
WHERE first_name REGEXP '[ae]';
```

### 7. IS NULL / IS NOT NULL

```sql
-- Customers with no points recorded
SELECT * FROM customers 
WHERE points IS NULL;

-- Customers with points recorded
SELECT * FROM customers 
WHERE points IS NOT NULL;

-- IMPORTANT: You CANNOT use = with NULL
-- ❌ WRONG: WHERE points = NULL
-- ✅ CORRECT: WHERE points IS NULL
```

### 8. Combining Everything

```sql
-- Complex query: multiple conditions
SELECT first_name, last_name, points, state
FROM customers
WHERE (state IN ('CA', 'TX', 'NY'))
  AND (points > 100 OR points IS NULL)
  AND last_name LIKE '%s%'
  AND birth_date >= '1985-01-01'
ORDER BY points DESC;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Using = Instead of IS NULL

```sql
-- ❌ WRONG (always returns nothing)
SELECT * FROM customers WHERE points = NULL;

-- ✅ CORRECT
SELECT * FROM customers WHERE points IS NULL;
```

### Mistake 2: Forgetting AND Precedence

```sql
-- ❌ This might not do what you think:
WHERE state = 'CA' OR state = 'NY' AND points > 200
-- Interpreted as: state = 'CA' OR (state = 'NY' AND points > 200)

-- ✅ Use parentheses for clarity:
WHERE (state = 'CA' OR state = 'NY') AND points > 200
```

### Mistake 3: LIKE is Case-Insensitive (in MySQL default)

```sql
-- These return the SAME results in MySQL default collation:
WHERE last_name LIKE 'smith'
WHERE last_name LIKE 'SMITH'
WHERE last_name LIKE 'Smith'
```

### Mistake 4: BETWEEN is Inclusive

```sql
-- BETWEEN 100 AND 500 includes BOTH 100 and 500
-- Equivalent to: >= 100 AND <= 500
```

---

## ✅ Exercises

### Exercise 1: Basic Filtering

Using the `customers` table above, write queries to:
1. Find all customers from Texas
2. Find customers with more than 400 points
3. Find customers born after 1990-01-01
4. Find customers who are NOT from California or New York

### Exercise 2: IN and BETWEEN

1. Find customers from California, Florida, or Massachusetts
2. Find customers with points between 50 and 300
3. Find customers born between 1985 and 1992
4. Find customers NOT from Texas, Illinois, or Arizona

### Exercise 3: LIKE Patterns

1. Find customers whose last name starts with 'D'
2. Find customers whose first name ends with 'e'
3. Find customers whose email contains 'gmail'
4. Find customers whose first name has exactly 4 letters
5. Find customers whose last name contains 'll' or 'nn'

### Exercise 4: NULL Handling

1. Find customers with no points value (NULL)
2. Find customers who have a points value (not NULL)
3. Find customers from Texas who have NULL points

### Exercise 5: Complex Combinations

1. Find customers from California with more than 200 points born before 1990
2. Find customers whose last name starts with 'W' OR has more than 6 letters, AND have points > 100
3. Find customers from NY, MA, or FL who have points between 100 and 500, ordered by points descending

---

## 🧠 Key Takeaways

- **WHERE** filters rows before any grouping or aggregation
- **AND** requires ALL conditions to be true; **OR** requires ANY to be true
- **AND** has higher precedence than **OR** — use parentheses for clarity
- **IN** is cleaner than multiple OR conditions for the same column
- **BETWEEN** is inclusive on both ends
- **LIKE** uses `%` (any chars) and `_` (single char) as wildcards
- **REGEXP** gives you full regex power
- Always use **IS NULL**, never `= NULL`

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 03: INSERT & SELECT →](./lesson-03-insert-select.md)  
**Next:** [Lesson 05: ORDER BY & LIMIT →](./lesson-05-order-limit.md)
