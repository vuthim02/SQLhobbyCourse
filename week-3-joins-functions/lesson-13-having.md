# Lesson 13: HAVING & Filtering Aggregates

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟦 Mosh | 3:30:00 – 3:40:00 | 10 min |
| 🟧 Bro Code | 4:25:00 – 4:40:00 | 15 min |

## 📖 Theory

### HAVING Clause

The **HAVING** clause filters **groups** after aggregation. While `WHERE` filters individual rows **before** grouping, `HAVING` filters groups **after** they are computed.

```sql
SELECT column, aggregate_function(column)
FROM table
WHERE condition          -- Filters rows BEFORE grouping
GROUP BY column
HAVING aggregate_condition  -- Filters groups AFTER grouping
ORDER BY column;
```

### WHERE vs HAVING

| Aspect | WHERE | HAVING |
|--------|-------|--------|
| **When** | Before GROUP BY | After GROUP BY |
| **Filters** | Individual rows | Groups (aggregated results) |
| **Can use** | Column values | Aggregate functions (COUNT, SUM, AVG) |
| **Performance** | More efficient (filters early) | Less efficient (filters after grouping) |

### Key Rule

> **Never use aggregate functions in WHERE.** Use HAVING for conditions on COUNT, SUM, AVG, MIN, MAX.

```sql
-- ❌ WRONG: Aggregate in WHERE
SELECT state, COUNT(*) FROM customers WHERE COUNT(*) > 5 GROUP BY state;

-- ✅ CORRECT: Use HAVING for aggregate conditions
SELECT state, COUNT(*) FROM customers GROUP BY state HAVING COUNT(*) > 5;
```

### Combining WHERE and HAVING

You can use both in the same query:

```sql
SELECT state, COUNT(*) AS count, AVG(points) AS avg_points
FROM customers
WHERE points > 100            -- Filter individual customers first
GROUP BY state
HAVING COUNT(*) >= 3          -- Then filter states with 3+ qualifying customers
ORDER BY avg_points DESC;
```

Execution order:
1. **WHERE** — filter rows
2. **GROUP BY** — create groups
3. **HAVING** — filter groups
4. **SELECT** — compute final output

### HAVING Without GROUP BY

Technically, HAVING can be used without GROUP BY (it treats the entire table as one group), but this is rarely useful:

```sql
SELECT COUNT(*) AS total
FROM orders
HAVING COUNT(*) > 100;
-- Returns the count only if there are more than 100 orders
```

---

## 💻 Examples

### Setup (using analytics_db from Lesson 12)

```sql
USE analytics_db;

-- Recall the orders table:
-- order_id, customer_id, order_date, total, status, region, salesperson
```

### Example 1: Basic HAVING

```sql
-- Find regions with more than 2 orders
SELECT region, COUNT(*) AS order_count
FROM orders
WHERE region IS NOT NULL
GROUP BY region
HAVING COUNT(*) > 2
ORDER BY order_count DESC;
```

### Example 2: HAVING with Multiple Aggregates

```sql
-- Find salespeople with average order value > $150 and at least 2 orders
SELECT
    salesperson,
    COUNT(*) AS orders,
    ROUND(AVG(total), 2) AS avg_order,
    SUM(total) AS total_revenue
FROM orders
WHERE salesperson IS NOT NULL
GROUP BY salesperson
HAVING COUNT(*) >= 2 AND AVG(total) > 150
ORDER BY total_revenue DESC;
```

### Example 3: WHERE + HAVING Combined

```sql
-- Completed orders only, regions with total revenue > $300
SELECT
    region,
    COUNT(*) AS completed_orders,
    SUM(total) AS revenue
FROM orders
WHERE status = 'completed' AND region IS NOT NULL
GROUP BY region
HAVING SUM(total) > 300
ORDER BY revenue DESC;
```

### Example 4: HAVING with SUM and COUNT

```sql
-- Monthly revenue report: only months with 2+ orders
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    ROUND(AVG(total), 2) AS avg_order
FROM orders
GROUP BY month
HAVING COUNT(*) >= 2
ORDER BY month;
```

### Example 5: Finding Underperformers with HAVING

```sql
-- Salespeople whose total revenue is below $200
SELECT
    salesperson,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
WHERE salesperson IS NOT NULL
GROUP BY salesperson
HAVING SUM(total) < 200
ORDER BY revenue;
```

### Example 6: HAVING with MIN/MAX

```sql
-- Find regions where the smallest order is still above $100
SELECT
    region,
    COUNT(*) AS orders,
    MIN(total) AS smallest_order,
    MAX(total) AS largest_order
FROM orders
WHERE region IS NOT NULL
GROUP BY region
HAVING MIN(total) > 100
ORDER BY smallest_order DESC;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Using WHERE Instead of HAVING

```sql
-- ❌ WRONG: Can't use COUNT in WHERE
SELECT region, COUNT(*) FROM orders WHERE COUNT(*) > 2 GROUP BY region;

-- ✅ CORRECT: Use HAVING
SELECT region, COUNT(*) FROM orders GROUP BY region HAVING COUNT(*) > 2;
```

### Mistake 2: Using HAVING Instead of WHERE for Row-Level Filters

```sql
-- ❌ WRONG: HAVING is for aggregates; this filters rows
SELECT region, COUNT(*) FROM orders GROUP BY region HAVING status = 'completed';

-- ✅ CORRECT: Use WHERE for row-level filtering before grouping
SELECT region, COUNT(*) FROM orders WHERE status = 'completed' GROUP BY region;
```

### Mistake 3: Forgetting WHERE Before GROUP BY

```sql
-- ❌ INEFFICIENT: Groups everything, then filters
SELECT region, SUM(total) AS revenue
FROM orders
GROUP BY region
HAVING region IS NOT NULL AND SUM(total) > 100;

-- ✅ EFFICIENT: Filters NULL regions first, then groups
SELECT region, SUM(total) AS revenue
FROM orders
WHERE region IS NOT NULL
GROUP BY region
HAVING SUM(total) > 100;
```

### Mistake 4: Confusing HAVING with WHERE Column Alias

```sql
-- ❌ WRONG: HAVING can't use column aliases in most MySQL versions
SELECT region, COUNT(*) AS cnt FROM orders GROUP BY region HAVING cnt > 2;

-- ✅ CORRECT: Repeat the aggregate
SELECT region, COUNT(*) AS cnt FROM orders GROUP BY region HAVING COUNT(*) > 2;
```

---

## ✅ Exercises

### Setup (using sales_analytics from Lesson 12)

```sql
USE sales_analytics;

-- Recall the sales table:
-- sale_id, product_name, category, region, quantity, unit_price, sale_date, salesperson
-- Revenue = quantity * unit_price
```

### Exercise 1: Basic HAVING
1. Find categories with total revenue greater than $1000
2. Find regions with more than 3 sales
3. Find salespeople whose total quantity sold exceeds 15

### Exercise 2: WHERE + HAVING Combined
1. Find regions where total revenue from Electronics exceeds $2000
2. Find salespeople who have made at least 2 sales in the North region
3. Find months where the average sale price was above $500

### Exercise 3: Advanced HAVING
1. Find categories where the minimum single sale revenue is above $100
2. Find regions where the total quantity sold is between 10 and 50
3. Find products sold in more than 2 different regions

### Exercise 4: WHERE vs HAVING Practice
For each query below, identify whether the condition belongs in WHERE or HAVING:
1. Filter to only 'Electronics' category → ?
2. Show only categories with revenue > $500 → ?
3. Only include sales in 2024 → ?
4. Only show months with average revenue > $200 → ?

---

## 🧠 Key Takeaways

- **WHERE** filters **rows before** GROUP BY; **HAVING** filters **groups after** GROUP BY
- **Never** use aggregate functions (COUNT, SUM, AVG) in WHERE — use HAVING
- **Always** prefer WHERE over HAVING for row-level filters (more efficient)
- You can use **both** WHERE and HAVING in the same query
- Execution order: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
- HAVING conditions should reference **aggregate functions**, not individual column values

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 12: Aggregate Functions & GROUP BY →](./lesson-12-aggregations.md)
**Next:** [Lesson 14: Subqueries →](./lesson-14-subqueries.md)
