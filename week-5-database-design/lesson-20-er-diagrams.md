# Lesson 20: ER Diagrams

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 4:15:00 – 5:00:00 | 45 min |

## 📖 Theory

### What is an ER Diagram?

An **Entity-Relationship (ER) Diagram** is a visual representation of the structure of a database. It shows:
- **Entities** (tables) — rectangles
- **Attributes** (columns) — ovals or listed inside entity boxes
- **Relationships** — diamonds or lines connecting entities

### ER Diagram Components

| Component | Symbol | Description |
|-----------|--------|-------------|
| **Entity** | Rectangle | A table — e.g., `Customer`, `Order` |
| **Attribute** | Listed in box | A column — e.g., `name`, `email` |
| **Primary Key** | Underlined | The unique identifier — e.g., `<u>customer_id</u>` |
| **Relationship** | Line/Diamond | How entities connect — e.g., Customer *places* Order |
| **Cardinality** | Notation on line | How many on each side — 1:1, 1:N, M:N |

### Cardinality Notation

| Notation | Meaning | Example |
|----------|---------|---------|
| **1:1** | One-to-One | Person ↔ Passport (one person has one passport) |
| **1:N** | One-to-Many | Customer → Orders (one customer places many orders) |
| **M:N** | Many-to-Many | Students ↔ Courses (student takes many courses, course has many students) |

### Chen Notation vs Crow's Foot

```
Chen Notation:          Crow's Foot Notation:
┌──────────┐            ┌──────────┐       ┌──────────┐
│ Customer │───places───│ Order    │   │ Customer │───<│ Order    │
└──────────┘   (1:N)    └──────────┘   └──────────┘    └──────────┘
                         1      N          1            N
```

Crow's Foot is more common in practice:
- `|` = exactly one
- `O` = zero or one
- `<` = many (crow's foot)
- `||` = one and only one
- `O<` = zero or many

### Drawing ER Diagrams: Step by Step

1. **Identify entities** — Nouns in requirements (Customer, Order, Product)
2. **Identify attributes** — Properties of each entity (name, email, price)
3. **Identify relationships** — Verbs connecting entities (places, contains, belongs to)
4. **Determine cardinality** — How many on each side?
5. **Identify primary keys** — What uniquely identifies each entity?
6. **Resolve M:N relationships** — Add junction/bridge tables

---

## 💻 Examples

### Example 1: Simple E-Commerce System

```
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   customers       │       │     orders        │       │     products      │
├──────────────────┤       ├──────────────────┤       ├──────────────────┤
│ PK customer_id   │───1 ──<│ PK order_id      │       │ PK product_id    │
│    first_name    │       │ FK customer_id   │    >──┤    name          │
│    last_name     │       │    order_date    │   M   │    price         │
│    email         │       │    total         │       │    category      │
│    phone         │       │    status        │       │    description   │
└──────────────────┘       └──────────────────┘       └──────────────────┘
        1                          N                          M
        │                          │                          │
        │                    1     │     N                    │
        │                    ┌──────────────────┐             │
        └────────────────────│  order_items     │─────────────┘
                    M        ├──────────────────┤
                             │ PK order_item_id│
                             │ FK order_id     │
                             │ FK product_id   │
                             │    quantity     │
                             │    unit_price   │
                             └──────────────────┘
```

### Example 2: University System

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────┐
│  students     │       │   enrollments     │       │   courses     │
├──────────────┤       ├──────────────────┤       ├──────────────┤
│ PK student_id│───1 ──<│ PK enrollment_id │    >──┤ PK course_id │
│    first_name│       │ FK student_id    │   M   │    code      │
│    last_name │       │ FK course_id     │       │    title     │
│    email     │       │    grade         │       │    credits   │
│    major     │       │    enroll_date   │       │    dept_id   │
└──────────────┘       └──────────────────┘       └──────┬───────┘
        M                         1                      │
        │                                                │ 1
        │                                                │
        │                    ┌──────────────┐            │
        └────────────────────│ departments  │────────────┘
                    M        ├──────────────┤
                             │ PK dept_id   │
                             │    name      │
                             │    location  │
                             └──────────────┘
```

### Example 3: Social Media Platform

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   users      │      │    posts      │      │  comments    │
├─────────────┤  1  ┌├──────────────┤  1  ┌├─────────────┤
│ PK user_id  │─────<│ FK user_id   │─────<│ FK post_id  │
│    username │      │ PK post_id   │      │ PK comment_id│
│    email    │      │    title     │      │ FK user_id  │
│    bio      │      │    body      │      │    body     │
└──────┬──────┘      │    created_at│      │    created_at│
       │ M           └──────────────┘      └─────────────┘
       │                    │
       │  M                 │ M
       │                    │
┌──────┴──────┐      ┌──────┴──────┐
│  followers   │      │  post_tags  │      ┌─────────────┐
├─────────────┤      ├─────────────┤      │    tags      │
│ FK follower │      │ FK post_id  │      ├─────────────┤
│ FK following│      │ FK tag_id   │─────>│ PK tag_id   │
│    since    │      └─────────────┘      │    name     │
└─────────────┘                           └─────────────┘
```

### Example 4: Converting ERD to SQL

From the ERD above, the SQL is straightforward:

```sql
-- Each entity becomes a table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

-- 1:N relationship → FK on the "many" side
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- M:N → junction table with two FKs
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

---

## ⚠️ Common Mistakes

### Mistake 1: Confusing 1:N with M:N

```
-- ❌ WRONG: Thinking "an order has many products, a product appears in many orders"
-- means 1:N between orders and products

-- ✅ CORRECT: This IS M:N — requires a junction table
orders ────1:N──── order_items ────N:1──── products
```

### Mistake 2: Missing Relationships

```
-- ❌ INCOMPLETE ERD: No relationship between customer and product
-- "How do we find what products a customer has ordered?"

-- ✅ COMPLETE: Customer → Order → Order_items → Product
-- The path through junction tables connects everything
```

### Mistake 3: Not Resolving M:N

```
-- ❌ WRONG: Trying to implement M:N directly
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    course_ids VARCHAR(200)  -- "101,102,201" — BAD!
);

-- ✅ CORRECT: Resolve M:N with junction table
students ────1:N──── enrollments ────N:1──── courses
```

### Mistake 4: Overcomplicating the ERD

```
-- ❌ TOO DETAILED: Showing every single attribute makes ERD unreadable

-- ✅ RIGHT LEVEL: Show key attributes and relationships clearly
-- Use separate documentation for full column lists
```

---

## ✅ Exercises

### Exercise 1: Draw ERD
Draw an ER diagram for a hotel management system with: guests, rooms, reservations, payments, and room_types.

### Exercise 2: Convert ERD to SQL
Convert this ERD to SQL tables:
```
authors ────1:N──── books ────M:N──── genres (via book_genres)
```

### Exercise 3: Identify Cardinality
For each scenario, identify the cardinality:
1. A country and its president
2. A teacher and their students
3. A person and their birth certificate
4. A book and its authors (a book can have multiple authors)
5. A flight and its passengers

---

## 🧠 Key Takeaways

- **ER diagrams** visually represent database structure
- **Entities** = tables, **Attributes** = columns, **Relationships** = foreign keys
- **Cardinality**: 1:1, 1:N, M:N — determines how tables are linked
- **M:N relationships** must be resolved with a **junction table**
- **1:N relationships** → FK goes on the "many" side
- **Crow's Foot** notation is the most widely used in practice
- ERDs should be drawn at the right level of detail — focus on structure, not every column
- The ERD-to-SQL conversion is mechanical: entity → table, relationship → FK

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 19: Database Design Principles →](./lesson-19-design-principles.md)
**Next:** [Lesson 21: Relationships (1:1, 1:N, M:N) →](./lesson-21-relationships.md)
