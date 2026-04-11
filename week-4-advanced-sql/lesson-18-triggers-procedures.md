# Lesson 18: Triggers & Stored Procedures

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 2:45:00 – 3:30:00 | 45 min |

## 📖 Theory

### Triggers

A **trigger** is a stored program that **automatically executes** in response to a specific event on a table (INSERT, UPDATE, DELETE).

**Use cases:**
- Audit logging (track who changed what)
- Data validation (reject invalid data)
- Auto-updating derived columns (updated_at, total)
- Enforcing business rules

### Trigger Syntax

```sql
CREATE TRIGGER trigger_name
    timing event ON table_name
    FOR EACH ROW
BEGIN
    -- trigger body
END;
```

| Component | Options |
|-----------|---------|
| **Timing** | `BEFORE` or `AFTER` |
| **Event** | `INSERT`, `UPDATE`, `DELETE` |
| **Table** | Any table (one trigger per event per table) |

### OLD and NEW References

| Event | OLD | NEW |
|-------|-----|-----|
| **INSERT** | Not available | ✅ New row values |
| **UPDATE** | ✅ Old row values | ✅ New row values |
| **DELETE** | ✅ Old row values | Not available |

```sql
-- BEFORE INSERT: modify NEW values before they're saved
CREATE TRIGGER set_timestamp
BEFORE INSERT ON users
FOR EACH ROW
SET NEW.created_at = NOW();

-- AFTER UPDATE: log changes using OLD and NEW
CREATE TRIGGER log_changes
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO salary_log (emp_id, old_sal, new_sal, changed_at)
        VALUES (NEW.emp_id, OLD.salary, NEW.salary, NOW());
    END IF;
END;
```

### Stored Procedures

A **stored procedure** is a named, reusable block of SQL code that can be called with parameters.

```sql
DELIMITER //
CREATE PROCEDURE procedure_name(
    IN param1 TYPE,
    OUT param2 TYPE,
    INOUT param3 TYPE
)
BEGIN
    -- SQL statements
END //
DELIMITER ;

-- Call it:
CALL procedure_name(value1, @var2, @var3);
SELECT @var2, @var3;
```

| Parameter Type | Direction | Description |
|---------------|-----------|-------------|
| `IN` | Input | Value passed into procedure (default) |
| `OUT` | Output | Value returned from procedure |
| `INOUT` | Both | Value passed in and modified |

### Variables in Stored Procedures

```sql
-- User-defined variables (session-scoped)
SET @my_var = 100;
SELECT @my_var;

-- Local variables (procedure-scoped, DECLARE must come first)
DECLARE total INT DEFAULT 0;
DECLARE done INT DEFAULT FALSE;
```

### Control Flow

```sql
-- IF/ELSEIF/ELSE
IF condition THEN
    statements;
ELSEIF other_condition THEN
    other_statements;
ELSE
    default_statements;
END IF;

-- CASE
CASE variable
    WHEN value1 THEN statements1;
    WHEN value2 THEN statements2;
    ELSE default_statements;
END CASE;

-- WHILE loop
WHILE condition DO
    statements;
END WHILE;

-- REPEAT loop (like do-while)
REPEAT
    statements;
UNTIL condition END REPEAT;

-- LOOP with LEAVE
my_loop: LOOP
    IF condition THEN
        LEAVE my_loop;  -- break
    END IF;
    -- Also: ITERATE my_loop; (continue)
END LOOP my_loop;
```

### Cursors

A **cursor** allows row-by-row processing of a result set.

```sql
DECLARE cursor_name CURSOR FOR SELECT ...;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_name;
read_loop: LOOP
    FETCH cursor_name INTO var1, var2;
    IF done THEN
        LEAVE read_loop;
    END IF;
    -- Process var1, var2
END LOOP;
CLOSE cursor_name;
```

> ⚠️ Cursors are slow — use set-based operations (regular queries) whenever possible.

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS triggers_proc_db;
USE triggers_proc_db;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    action VARCHAR(10),
    old_values JSON,
    new_values JSON,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    quantity INT,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, price, stock)
VALUES ('Laptop', 999.99, 50), ('Mouse', 29.99, 200), ('Keyboard', 79.99, 150);
```

### Example 1: BEFORE INSERT Trigger — Auto-Calculate Total

```sql
DELIMITER //
CREATE TRIGGER calc_order_total
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE prod_price DECIMAL(10,2);
    SELECT price INTO prod_price FROM products WHERE product_id = NEW.product_id;
    SET NEW.total = prod_price * NEW.quantity;
END //
DELIMITER ;

-- Insert order without specifying total — trigger calculates it
INSERT INTO orders (product_id, quantity) VALUES (1, 2);
-- total is automatically set to 999.99 * 2 = 1999.98
SELECT * FROM orders;
```

### Example 2: AFTER INSERT Trigger — Update Stock

```sql
DELIMITER //
CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE products SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;

-- Insert order
INSERT INTO orders (product_id, quantity) VALUES (2, 5);
-- Stock for Mouse (product_id=2) is reduced from 200 to 195
SELECT product_id, name, stock FROM products WHERE product_id = 2;
```

### Example 3: AFTER UPDATE Trigger — Audit Log

```sql
DELIMITER //
CREATE TRIGGER log_price_changes
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO audit_log (table_name, action, old_values, new_values)
        VALUES (
            'products',
            'UPDATE',
            JSON_OBJECT('price', OLD.price, 'stock', OLD.stock),
            JSON_OBJECT('price', NEW.price, 'stock', NEW.stock)
        );
    END IF;
END //
DELIMITER ;

-- Change a price — trigger logs it
UPDATE products SET price = 899.99 WHERE product_id = 1;
SELECT * FROM audit_log;
```

### Example 4: BEFORE DELETE Trigger — Prevent Deletion

```sql
DELIMITER //
CREATE TRIGGER prevent_product_delete
BEFORE DELETE ON products
FOR EACH ROW
BEGIN
    IF OLD.stock > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete product with remaining stock';
    END IF;
END //
DELIMITER ;

-- ❌ This fails:
DELETE FROM products WHERE product_id = 2;
-- ERROR: Cannot delete product with remaining stock
```

### Example 5: Simple Stored Procedure

```sql
DELIMITER //
CREATE PROCEDURE get_product_stats()
BEGIN
    SELECT
        COUNT(*) AS total_products,
        AVG(price) AS avg_price,
        SUM(stock) AS total_stock,
        MAX(price) AS max_price
    FROM products;
END //
DELIMITER ;

CALL get_product_stats();
```

### Example 6: Procedure with IN Parameter

```sql
DELIMITER //
CREATE PROCEDURE get_products_by_price(
    IN min_price DECIMAL(10,2)
)
BEGIN
    SELECT product_id, name, price, stock
    FROM products
    WHERE price >= min_price
    ORDER BY price DESC;
END //
DELIMITER ;

CALL get_products_by_price(50.00);
```

### Example 7: Procedure with IN and OUT Parameters

```sql
DELIMITER //
CREATE PROCEDURE get_order_summary(
    IN order_id INT,
    OUT customer_total DECIMAL(10,2),
    OUT item_count INT
)
BEGIN
    SELECT total, quantity INTO customer_total, item_count
    FROM orders
    WHERE order_id = order_id;
END //
DELIMITER ;

-- Call with variables
CALL get_order_summary(1, @total, @count);
SELECT @total AS order_total, @count AS quantity;
```

### Example 8: Procedure with IF/ELSE

```sql
DELIMITER //
CREATE PROCEDURE update_order_status(
    IN p_order_id INT,
    IN p_new_status VARCHAR(20)
)
BEGIN
    DECLARE current_status VARCHAR(20);

    SELECT status INTO current_status FROM orders WHERE order_id = p_order_id;

    IF current_status = 'cancelled' THEN
        SELECT 'Cannot update a cancelled order' AS message;
    ELSEIF p_new_status = 'delivered' AND current_status <> 'shipped' THEN
        SELECT 'Order must be shipped before delivery' AS message;
    ELSE
        UPDATE orders SET status = p_new_status WHERE order_id = p_order_id;
        SELECT CONCAT('Order ', p_order_id, ' updated to ', p_new_status) AS message;
    END IF;
END //
DELIMITER ;

CALL update_order_status(1, 'shipped');
CALL update_order_status(1, 'delivered');
CALL update_order_status(1, 'cancelled');
CALL update_order_status(1, 'pending');  -- Should fail validation
```

### Example 9: Procedure with WHILE Loop

```sql
DELIMITER //
CREATE PROCEDURE insert_test_data(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= num_rows DO
        INSERT INTO products (name, price, stock)
        VALUES (CONCAT('Test Product ', i), ROUND(RAND() * 100, 2), FLOOR(RAND() * 100));
        SET i = i + 1;
    END WHILE;

    SELECT CONCAT('Inserted ', num_rows, ' test products') AS result;
END //
DELIMITER ;

CALL insert_test_data(5);
SELECT * FROM products WHERE name LIKE 'Test Product%';
```

### Example 10: Cursor Example

```sql
DELIMITER //
CREATE PROCEDURE list_low_stock_products()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE prod_name VARCHAR(100);
    DECLARE prod_stock INT;
    DECLARE prod_id INT;

    DECLARE cur CURSOR FOR
        SELECT product_id, name, stock FROM products WHERE stock < 100;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS low_stock_report (
        id INT, name VARCHAR(100), stock INT
    );
    TRUNCATE TABLE low_stock_report;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO prod_id, prod_name, prod_stock;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO low_stock_report VALUES (prod_id, prod_name, prod_stock);
    END LOOP;
    CLOSE cur;

    SELECT * FROM low_stock_report;
    DROP TEMPORARY TABLE low_stock_report;
END //
DELIMITER ;

CALL list_low_stock_products();
```

### Managing Triggers and Procedures

```sql
-- List all triggers
SHOW TRIGGERS;

-- Drop a trigger
DROP TRIGGER IF EXISTS calc_order_total;

-- List all stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'triggers_proc_db';

-- Drop a procedure
DROP PROCEDURE IF EXISTS get_product_stats;

-- View procedure definition
SHOW CREATE PROCEDURE get_order_summary;
```

---

## ⚠️ Common Mistakes

### Mistake 1: Forgetting DELIMITER

```sql
-- ❌ WRONG: Semicolon inside body ends the CREATE statement prematurely
CREATE TRIGGER my_trigger
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();  -- MySQL thinks this ends the CREATE!
END;

-- ✅ CORRECT: Change delimiter first
DELIMITER //
CREATE TRIGGER my_trigger
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //
DELIMITER ;
```

### Mistake 2: Too Many Triggers

```sql
-- ❌ BAD: Trigger fires for EVERY row — slow on bulk inserts
CREATE TRIGGER log_every_insert
AFTER INSERT ON products
FOR EACH ROW
BEGIN
    INSERT INTO audit_log ...;
    UPDATE stats SET count = count + 1;
    CALL notify_admin();
END;

-- ✅ BETTER: Keep triggers minimal; do logging/analytics in application code
```

### Mistake 3: Cursor When Set-Based Works

```sql
-- ❌ SLOW: Cursor processes row by row
DECLARE cur CURSOR FOR SELECT id, price FROM products;
-- ... loop and update one by one ...

-- ✅ FAST: Single UPDATE
UPDATE products SET price = price * 1.10 WHERE category = 'Electronics';
```

### Mistake 4: Trigger Recursion

```sql
-- ❌ DANGEROUS: Trigger updates same table → infinite loop
CREATE TRIGGER update_timestamp
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    UPDATE products SET updated_at = NOW() WHERE product_id = NEW.product_id;
    -- This fires the trigger again → infinite loop!
END;

-- ✅ CORRECT: Use BEFORE trigger to modify NEW values
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
SET NEW.updated_at = NOW();
```

---

## ✅ Exercises

### Setup (using triggers_proc_db from above)

### Exercise 1: Create Triggers
1. Create a BEFORE INSERT trigger that sets `updated_at` to NOW()
2. Create an AFTER DELETE trigger that logs the deleted product to audit_log
3. Create a BEFORE UPDATE trigger that prevents price from going below $1

### Exercise 2: Create Procedures
1. A procedure `add_product(name, price, stock)` that inserts a new product
2. A procedure `get_expensive_products(min_price)` that returns products above a price
3. A procedure `transfer_stock(from_id, to_id, quantity)` that moves stock between products

### Exercise 3: Procedure with Logic
Create a procedure `place_order(product_id, quantity)` that:
1. Checks stock is sufficient
2. Creates the order (total is calculated by trigger)
3. If stock is insufficient, returns an error message
4. Otherwise returns the order_id

### Exercise 4: Cursor Practice
Create a procedure that uses a cursor to:
1. Find all products with stock < 100
2. Increase their price by 10%
3. Report the changes made

---

## 🧠 Key Takeaways

- **Triggers** auto-execute on INSERT/UPDATE/DELETE events
- Use **BEFORE** triggers to modify values; **AFTER** triggers for logging/actions
- **OLD** and **NEW** references give access to row values in triggers
- **Stored procedures** are reusable, parameterized SQL blocks
- Parameters: `IN` (input), `OUT` (output), `INOUT` (both)
- **DELIMITER** must be changed when creating triggers/procedures with multiple statements
- **Cursors** allow row-by-row processing but are slow — prefer set-based queries
- **SIGNAL SQLSTATE '45000'** raises a custom error in triggers/procedures
- Triggers should be **minimal** — heavy logic belongs in application code
- Avoid **trigger recursion** (trigger modifying the same table it's on)

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 17: Views →](./lesson-17-views.md)
**Next:** [Lesson 19: Database Design Principles →](../week-5-database-design/lesson-19-design-principles.md)
