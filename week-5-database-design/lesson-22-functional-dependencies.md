# Lesson 22: Functional Dependencies

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 5:45:00 – 6:30:00 | 45 min |

## 📖 Theory

### What is a Functional Dependency?

A **functional dependency (FD)** is a constraint between two sets of attributes in a relation. It describes how one attribute determines another.

**Notation:** `A → B` means "A functionally determines B"

> If two rows have the same value for A, they must have the same value for B.

### Simple Example

```
employees table:
┌────────┬───────┬───────────┐
│ emp_id │ name  │ dept_name │
├────────┼───────┼───────────┤
│ 1      │ Alice │ Engineering│
│ 2      │ Bob   │ Marketing  │
│ 3      │ Carol │ Engineering│
└────────┴───────┴───────────┘

emp_id → name       ✅ (same emp_id always has same name)
emp_id → dept_name  ✅ (same emp_id always has same dept)
name → dept_name    ❌ (two people with same name could be in different depts)
dept_name → name    ❌ (one dept has many names)
```

### Types of Functional Dependencies

| Type | Description | Example |
|------|-------------|---------|
| **Trivial** | B is a subset of A | `{A, B} → A` (always true) |
| **Non-trivial** | B is not a subset of A | `emp_id → name` |
| **Multivalued** | A determines multiple independent values of B | See below |
| **Transitive** | A → B and B → C, so A → C | `emp_id → dept_id → dept_name` |
| **Partial** | A composite key determines B, but a subset also does | `{order_id, product_id} → product_name` (but `product_id → product_name` alone suffices) |

### Keys and Functional Dependencies

| Term | Definition |
|------|-----------|
| **Superkey** | A set of attributes that uniquely identifies a row |
| **Candidate Key** | A minimal superkey (no subset is also a superkey) |
| **Primary Key** | The chosen candidate key |
| **Prime Attribute** | Part of any candidate key |
| **Non-prime Attribute** | Not part of any candidate key |

```
students(student_id, email, name, birth_date)

Superkeys: {student_id}, {email}, {student_id, email}, {student_id, name}, ...
Candidate keys: {student_id}, {email}  (minimal — no subset works)
Primary key: {student_id}  (chosen one)
Prime attributes: student_id, email
Non-prime: name, birth_date
```

### Armstrong's Axioms

Rules for deriving functional dependencies:

| Axiom | Rule | Example |
|-------|------|---------|
| **Reflexivity** | If B ⊆ A, then A → B | `{name, email} → email` |
| **Augmentation** | If A → B, then AC → BC | If `id → name`, then `{id, email} → {name, email}` |
| **Transitivity** | If A → B and B → C, then A → C | `id → dept_id` and `dept_id → dept_name`, so `id → dept_name` |

Derived rules:
- **Union**: If A → B and A → C, then A → BC
- **Decomposition**: If A → BC, then A → B and A → C
- **Pseudotransitivity**: If A → B and BC → D, then AC → D

### Finding Candidate Keys

Given FDs, find the minimal set of attributes that determines all others:

```
R(A, B, C, D, E)
FDs: A → B, B → C, CD → E, E → A

Step 1: Find attributes that appear only on the left side (must be in key)
Step 2: Find attributes that appear only on the right side (can't be in key alone)
Step 3: Compute closure of candidate sets

Closure of D: {D} → no FD has only D on left → {D}
Closure of CD: {C, D} → CD → E → E → A → A → B → B → C → {A, B, C, D, E} ✅
So CD is a candidate key.
```

---

## 💻 Examples

### Example 1: Identifying FDs in a Table

```sql
-- Consider this denormalized table:
CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    product_name VARCHAR(100),
    product_price DECIMAL(10,2),
    quantity INT,
    customer_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100)
);

Functional Dependencies:
order_id → customer_id           (an order belongs to one customer)
order_id, product_id → quantity   (quantity depends on both order and product)
product_id → product_name         (product id determines name)
product_id → product_price        (product id determines price)
customer_id → customer_name       (customer id determines name)
customer_id → customer_email      (customer id determines email)

Transitive:
order_id → customer_id → customer_name  (order determines customer, which determines name)
```

### Example 2: Closure Calculation

```
Relation: R(A, B, C, D, E, F)
FDs: AB → C, BC → AD, D → E, CF → B

Find closure of {A, B}:
{A, B}⁺ = {A, B}           (start)
        → {A, B, C}         (AB → C)
        → {A, B, C, D}      (BC → AD, we have B and C)
        → {A, B, C, D, E}   (D → E)
        = {A, B, C, D, E}   (CF → B doesn't help — no F)

{A, B} does NOT determine F, so it's not a superkey.

Find closure of {A, B, F}:
{A, B, F}⁺ = {A, B, F}
           → {A, B, C, F}    (AB → C)
           → {A, B, C, D, F} (BC → AD)
           → {A, B, C, D, E, F} (D → E)
           = ALL attributes ✅
So {A, B, F} is a superkey. Is it minimal?
Check {A, F}: no FD with just AF → doesn't give B → not a key
Check {B, F}: no FD with just BF → doesn't give A → not a key
So {A, B, F} is a candidate key.
```

### Example 3: Detecting Redundancy via FDs

```sql
-- This table violates good design:
CREATE TABLE bad_employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    dept_id INT,
    dept_name VARCHAR(50),     -- dept_id → dept_name (redundant!)
    dept_location VARCHAR(100), -- dept_id → dept_location (redundant!)
    manager_id INT,
    manager_name VARCHAR(100),  -- manager_id → manager_name (redundant!)
    manager_email VARCHAR(100)  -- manager_id → manager_email (redundant!)
);

-- FDs that show redundancy:
-- dept_id → dept_name, dept_location
-- manager_id → manager_name, manager_email
-- These should be in separate tables!
```

---

## ⚠️ Common Mistakes

### Mistake 1: Confusing Correlation with Functional Dependency

```
-- ❌ WRONG: Just because values often go together doesn't mean FD exists
name → salary  -- "Alice always earns 95000"? No — salary can change

-- ✅ CORRECT: FD must ALWAYS hold
emp_id → salary  -- At any point in time, one emp_id has one salary
```

### Mistake 2: Missing Composite FDs

```
-- ❌ INCOMPLETE: Only considering single-column FDs
order_id → product_name  -- Wrong! One order has many products

-- ✅ CORRECT: Composite FD
{order_id, product_id} → quantity  -- Quantity depends on BOTH
```

### Mistake 3: Ignoring Transitive Dependencies

```
-- ⚠️ TRAP: Transitive dependencies cause redundancy
emp_id → dept_id → dept_name
-- emp_id determines dept_name THROUGH dept_id
-- This is the root cause of update anomalies
```

---

## ✅ Exercises

### Exercise 1: Identify FDs
For this table schema, list all functional dependencies:
```
projects(project_id, title, lead_emp_id, lead_emp_name, dept_id, dept_name, budget)
```

### Exercise 2: Find Candidate Keys
Given R(A,B,C,D,E) with FDs: A → B, BC → E, ED → AB

1. Find the closure of {A, C}
2. Find the closure of {E, D}
3. Find all candidate keys

### Exercise 3: Identify Anomalies
Given the bad_employees table above, list:
1. Insert anomaly (what can't you insert?)
2. Delete anomaly (what do you lose when deleting?)
3. Update anomaly (what must you update in multiple places?)

---

## 🧠 Key Takeaways

- **Functional dependency** A → B means A uniquely determines B
- FDs are the **mathematical foundation** of normalization
- **Transitive dependencies** (A → B → C) cause redundancy
- **Partial dependencies** (subset of key determines non-key) cause redundancy
- **Candidate keys** are minimal sets of attributes that determine all others
- Use **closure** computation to verify if a set of attributes is a key
- FDs help identify which columns should be split into separate tables
- Understanding FDs is essential for achieving 2NF and 3NF

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 21: Relationships →](./lesson-21-relationships.md)
**Next:** [Lesson 23: Normalization (1NF, 2NF, 3NF) →](./lesson-23-normalization.md)
