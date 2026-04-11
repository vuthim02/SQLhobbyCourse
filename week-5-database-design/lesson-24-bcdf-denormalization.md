# Lesson 24: BCNF & Denormalization

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 7:30:00 – 8:15:00 | 45 min |

## 📖 Theory

### Boyce-Codd Normal Form (BCNF)

**BCNF** is a stricter version of 3NF. A table is in BCNF if, for every non-trivial functional dependency `X → Y`, **X is a superkey**.

| Normal Form | Requirement |
|-------------|------------|
| **3NF** | For every FD `X → A`: X is a superkey, OR A is a prime attribute |
| **BCNF** | For every FD `X → A`: X **must** be a superkey (no exceptions) |

### When 3NF ≠ BCNF

This happens when a table has:
- Multiple candidate keys
- Overlapping candidate keys
- A non-key attribute that determines part of a composite key

```
Example:
R(student, course, instructor)

FDs:
- {student, course} → instructor  (a student in a course has one instructor)
- instructor → course              (an instructor teaches only one course)

Candidate keys: {student, course} and {student, instructor}

Check 3NF:
- {student, course} → instructor: {student, course} is a superkey ✅
- instructor → course: instructor is NOT a superkey, BUT course is prime (part of CK) ✅
→ This is in 3NF

Check BCNF:
- instructor → course: instructor is NOT a superkey ❌
→ This is NOT in BCNF!

Fix: Decompose
R1(instructor, course)      — instructor → course
R2(student, instructor)      — {student, instructor} is the PK
```

### BCNF Decomposition Algorithm

1. Find an FD `X → Y` where X is **not** a superkey
2. Decompose R into:
   - R1 = X ∪ Y (the FD itself)
   - R2 = R - Y (remove the dependent attributes)
3. Repeat for each resulting table until all are in BCNF

### Denormalization

**Denormalization** is the deliberate introduction of redundancy into a normalized database to improve **read performance**.

### Why Denormalize?

| Reason | Description | Trade-off |
|--------|-------------|-----------|
| **Read performance** | Avoid expensive JOINs | More storage, slower writes |
| **Simplicity** | Fewer tables to query | Risk of inconsistent data |
| **Analytics** | Pre-aggregated data | Stale data, update overhead |
| **Caching** | Store computed results | Must be refreshed |

### Common Denormalization Patterns

```sql
-- Pattern 1: Store derived values
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    total DECIMAL(10,2)  -- = SUM(order_items.total), stored to avoid JOIN+SUM
);

-- Pattern 2: Duplicate frequently joined data
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100)  -- Denormalized from customers table
);

-- Pattern 3: Pre-aggregated summary tables
CREATE TABLE daily_sales_summary (
    sale_date DATE PRIMARY KEY,
    total_orders INT,
    total_revenue DECIMAL(12,2),
    avg_order_value DECIMAL(10,2)
);
```

### When to Denormalize

| Situation | Denormalize? |
|-----------|-------------|
| Read-heavy, write-light system | ✅ Yes |
| Reporting/analytics tables | ✅ Yes |
| Data warehouse (OLAP) | ✅ Yes |
| Real-time transactional system | ❌ No |
| Data must always be consistent | ❌ No |
| Storage is limited | ❌ No |

### Maintaining Denormalized Data

```sql
-- Use triggers to keep denormalized data in sync
DELIMITER //
CREATE TRIGGER update_order_total
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders SET total = (
        SELECT SUM(quantity * unit_price)
        FROM order_items WHERE order_id = NEW.order_id
    ) WHERE order_id = NEW.order_id;
END //
DELIMITER ;
```

---

## 💻 Examples

### Example 1: BCNF Violation and Fix

```sql
-- 3NF but NOT BCNF:
CREATE TABLE project_assignments (
    employee_id INT,
    project_id INT,
    department VARCHAR(50),
    PRIMARY KEY (employee_id, project_id)
);

FDs:
- {employee_id, project_id} → department  (superkey → ok for both 3NF and BCNF)
- employee_id → department                (NOT a superkey → BCNF violation!)
  (Each employee belongs to exactly one department)

Decompose:
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50)
);

CREATE TABLE project_assignments (
    employee_id INT,
    project_id INT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

### Example 2: Denormalization for Performance

```sql
-- Normalized (3NF/BCNF):
-- customers(customer_id, name, email)
-- orders(order_id, customer_id, order_date)
-- order_items(item_id, order_id, product_id, quantity, price)

-- Query requires 3 JOINs to get customer order totals:
SELECT c.name, SUM(oi.quantity * oi.price) AS total
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id;

-- Denormalized version for fast reads:
ALTER TABLE customers ADD COLUMN lifetime_value DECIMAL(12,2) DEFAULT 0;

-- Keep it updated via trigger:
DELIMITER //
CREATE TRIGGER update_ltv_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE customers c
    SET lifetime_value = lifetime_value + NEW.quantity * NEW.price
    WHERE c.customer_id = (
        SELECT o.customer_id FROM orders o WHERE o.order_id = NEW.order_id
    );
END //
DELIMITER ;

-- Now the query is instant:
SELECT name, lifetime_value FROM customers ORDER BY lifetime_value DESC;
```

### Example 3: Summary Table Denormalization

```sql
-- Instead of computing this every time:
SELECT
    DATE(order_date) AS day,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order
FROM orders
GROUP BY DATE(order_date);

-- Pre-compute into a summary table:
CREATE TABLE daily_stats (
    stat_date DATE PRIMARY KEY,
    order_count INT DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0,
    avg_order_value DECIMAL(10,2) DEFAULT 0
);

-- Update daily:
INSERT INTO daily_stats (stat_date, order_count, total_revenue, avg_order_value)
SELECT
    DATE(order_date),
    COUNT(*),
    SUM(total),
    AVG(total)
FROM orders
WHERE DATE(order_date) = CURDATE()
GROUP BY DATE(order_date)
ON DUPLICATE KEY UPDATE
    order_count = VALUES(order_count),
    total_revenue = VALUES(total_revenue),
    avg_order_value = VALUES(avg_order_value);
```

---

## ⚠️ Common Mistakes

### Mistake 1: Denormalizing Without a Plan

```sql
-- ❌ WRONG: Denormalizing everything "just in case"
CREATE TABLE mega_orders (
    order_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    customer_address VARCHAR(200),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    department_name VARCHAR(50),
    salesperson_name VARCHAR(100),
    shipping_city VARCHAR(50),
    ...  -- 50+ columns
);

-- ✅ CORRECT: Denormalize only what's proven slow via EXPLAIN
-- Keep 3NF as the source of truth, add specific denormalized tables as needed
```

### Mistake 2: Forgetting to Maintain Denormalized Data

```sql
-- ❌ DANGEROUS: Denormalized column that's never updated
ALTER TABLE orders ADD COLUMN customer_name VARCHAR(100);
-- Insert order with customer name...
-- Later, customer changes name...
-- Orders still have the old name → inconsistency!

-- ✅ CORRECT: Either maintain via triggers or accept eventual consistency
```

### Mistake 3: Denormalizing Too Early

```sql
-- ❌ PREMATURE: Denormalizing before measuring performance
-- "This will be slow" — without evidence

-- ✅ CORRECT: Normalize first, then denormalize based on EXPLAIN analysis
-- 1. Design in 3NF
-- 2. Run actual queries
-- 3. EXPLAIN slow queries
-- 4. Denormalize only the proven bottlenecks
```

---

## ✅ Exercises

### Exercise 1: BCNF Check
Given R(A, B, C, D) with FDs: AB → C, C → D, D → A
1. Find all candidate keys
2. Is it in BCNF? If not, decompose.

### Exercise 2: Denormalization Design
For an e-commerce dashboard that frequently shows "top customers by revenue", design a denormalized solution.

### Exercise 3: Maintenance Strategy
Design triggers or procedures to keep a `product_order_count` column (denormalized) in sync when orders are inserted, updated, or deleted.

---

## 🧠 Key Takeaways

- **BCNF** requires that every determinant is a superkey (stricter than 3NF)
- 3NF ≠ BCNF only when there are **overlapping candidate keys**
- **BCNF decomposition** removes the FD violation by splitting tables
- **Denormalization** trades write speed/storage for read speed
- Denormalize **only after** measuring actual performance problems
- Use **triggers, scheduled jobs, or application logic** to maintain denormalized data
- **Never** denormalize as your starting design — normalize first, then denormalize selectively
- Data warehouses and analytics tables are common denormalization targets
- Always have a **source of truth** (the normalized tables) even when denormalizing

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 23: Normalization (1NF, 2NF, 3NF) →](./lesson-23-normalization.md)
**Next:** [Lesson 25: User Management & Privileges →](../week-6-real-world/lesson-25-security.md)
