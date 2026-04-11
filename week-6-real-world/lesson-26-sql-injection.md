# Lesson 26: SQL Injection & Prevention

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 8:45:00 – 9:15:00 | 30 min |

## 📖 Theory

### What is SQL Injection?

**SQL Injection (SQLi)** is a code injection attack where an attacker inserts malicious SQL into input fields, causing the application to execute unintended queries.

It is consistently ranked as one of the **top web application security risks** (OWASP Top 10).

### How SQL Injection Works

When an application constructs SQL queries by **concatenating user input**:

```python
# ❌ VULNERABLE Python code:
username = input("Username: ")
password = input("Password: ")
query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
cursor.execute(query)
```

An attacker enters:
```
Username: admin' --
Password: anything
```

The resulting query becomes:
```sql
SELECT * FROM users WHERE username = 'admin' --' AND password = 'anything'
--                                         ↑ Everything after -- is commented out!
-- This logs in as admin without knowing the password!
```

### Types of SQL Injection

| Type | Description | How |
|------|-------------|-----|
| **In-band (Classic)** | Results returned directly in response | `' OR '1'='1` to bypass login |
| **Blind** | No direct output — inferred from behavior | `admin' AND SLEEP(5) --` |
| **Union-based** | Attacker adds UNION to extract data | `' UNION SELECT username, password FROM users --` |
| **Error-based** | Database errors reveal information | `' AND (SELECT 1 FROM dual) --` |

### What Attackers Can Do

| Attack | Impact |
|--------|--------|
| **Authentication bypass** | Login as any user without password |
| **Data theft** | Dump entire database contents |
| **Data modification** | Change passwords, balances, records |
| **Data deletion** | `DROP TABLE`, `DELETE FROM` |
| **File access** | `LOAD_FILE()`, `INTO OUTFILE` |
| **Remote code execution** | In some configurations, execute OS commands |

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS sqli_demo;
USE sqli_demo;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(64) NOT NULL,
    email VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    credit_card VARCHAR(20)
);

CREATE TABLE secret_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    api_key VARCHAR(100),
    description VARCHAR(200)
);

INSERT INTO users (username, password_hash, email, role, credit_card)
VALUES
    ('admin', '5f4dcc3b5aa765d61d8327deb882cf99', 'admin@site.com', 'admin', '4111-1111-1111-1111'),
    ('alice', 'hashed_password_1', 'alice@site.com', 'user', '4222-2222-2222-2222'),
    ('bob', 'hashed_password_2', 'bob@site.com', 'user', '4333-3333-3333-3333');

INSERT INTO secret_data (api_key, description)
VALUES ('sk-12345-secret-key', 'Production API key');
```

### Attack 1: Authentication Bypass

**Vulnerable code:**
```python
query = f"SELECT * FROM users WHERE username = '{user}' AND password = '{pwd}'"
```

**Attack input:**
```
User: admin' --
Pwd: (anything)
```

**Resulting query:**
```sql
SELECT * FROM users WHERE username = 'admin' --' AND password = 'anything'
-- Returns the admin row, login succeeds without password!
```

**Another attack:**
```
User: ' OR '1'='1' --
```

```sql
SELECT * FROM users WHERE username = '' OR '1'='1' --' AND password = 'x'
-- '1'='1' is always true — returns ALL users (logs in as the first)
```

### Attack 2: UNION-Based Data Extraction

**Vulnerable code:**
```python
query = f"SELECT name, price FROM products WHERE name LIKE '%{search}%'"
```

**Attack input:**
```
Search: ' UNION SELECT username, password_hash FROM users --
```

**Resulting query:**
```sql
SELECT name, price FROM products WHERE name LIKE '%'
UNION SELECT username, password_hash FROM users --%'
-- Returns product names AND all usernames with password hashes!
```

### Attack 3: Extracting Table Names

```sql
-- Get all table names
' UNION SELECT table_name, NULL FROM information_schema.tables WHERE table_schema = database() --

-- Get all column names of users table
' UNION SELECT column_name, NULL FROM information_schema.columns WHERE table_name = 'users' --
```

### Attack 4: Destructive Attack

```
Search: '; DROP TABLE users; --
```

```sql
SELECT name, price FROM products WHERE name LIKE '%'; DROP TABLE users; --%'
-- Deletes the entire users table!
```

### Attack 5: Blind SQL Injection

```
Search: ' AND (SELECT IF(1=1, SLEEP(5), 0)) --
-- If the page takes 5 seconds to load, the injection worked (1=1 is true)

Search: ' AND (SELECT IF(SUBSTRING(password_hash,1,1)='5', SLEEP(5), 0)) FROM users WHERE username='admin' --
-- Extract password hash character by character via timing
```

---

## ✅ Prevention Methods

### Method 1: Parameterized Queries (Prepared Statements) — PRIMARY DEFENSE

```python
# ✅ SAFE — Python with mysql-connector:
query = "SELECT * FROM users WHERE username = %s AND password = %s"
cursor.execute(query, (username, password))

# ✅ SAFE — Python with psycopg2/sqlite3:
cursor.execute("SELECT * FROM users WHERE username = ? AND password = ?",
               (username, password))
```

The database treats input as **data**, not as **SQL code**.

### Method 2: Stored Procedures

```sql
-- Create a stored procedure
DELIMITER //
CREATE PROCEDURE get_user_by_name(IN p_username VARCHAR(50))
BEGIN
    SELECT id, username, email, role FROM users WHERE username = p_username;
END //
DELIMITER ;

-- Call it (parameters are always treated as data)
CALL get_user_by_name('admin');
```

### Method 3: Input Validation

```python
import re

def validate_username(username):
    # Only allow alphanumeric, 3-20 chars
    if not re.match(r'^[a-zA-Z0-9]{3,20}$', username):
        raise ValueError("Invalid username")
    return username

# Whitelist allowed characters
def validate_search(term):
    allowed = set('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -')
    if not all(c in allowed for c in term):
        raise ValueError("Invalid characters in search")
    return term
```

### Method 4: Escaping (Last Resort — Prefer Parameterized Queries)

```python
# ⚠️ LESS SAFE: Escaping special characters
username = username.replace("'", "''")  # Double the quotes

# In PHP:
$username = mysqli_real_escape_string($conn, $input);

# ⚠️ This is error-prone — always prefer parameterized queries when possible
```

### Method 5: Least Privilege

```sql
-- The application user should NOT have access to everything
CREATE USER 'webapp'@'localhost' IDENTIFIED BY 'StrongPass!';
GRANT SELECT, INSERT, UPDATE ON app_db.users TO 'webapp'@'localhost';
-- No access to information_schema, no DROP, no FILE privileges
```

---

## 💻 Secure Code Examples

### Secure Login in Python

```python
import mysql.connector

def login(username, password):
    conn = mysql.connector.connect(
        host='localhost', database='sqli_demo',
        user='webapp', password='StrongPass!'
    )
    cursor = conn.cursor()

    # ✅ SAFE: Parameterized query
    query = "SELECT id, username, role FROM users WHERE username = %s AND password_hash = %s"
    cursor.execute(query, (username, hash_password(password)))
    user = cursor.fetchone()

    cursor.close()
    conn.close()
    return user  # None if not found
```

### Secure Search with LIMIT

```python
def search_products(search_term, max_results=50):
    # Validate input
    if len(search_term) > 100:
        raise ValueError("Search term too long")

    # ✅ SAFE: Parameterized
    query = """
        SELECT name, price, description
        FROM products
        WHERE name LIKE %s OR description LIKE %s
        LIMIT %s
    """
    cursor.execute(query, (f'%{search_term}%', f'%{search_term}%', max_results))
    return cursor.fetchall()
```

---

## ⚠️ Common Mistakes

### Mistake 1: Client-Side Validation Only

```javascript
// ❌ WRONG: JavaScript validation is not security
function login(user, pass) {
    if (user.includes("'")) { alert("No quotes allowed!"); return; }
    // Send to server...
}
// Attacker bypasses JavaScript entirely with curl/Postman
```

### Mistake 2: Blacklisting Instead of Whitelisting

```python
# ❌ WEAK: Blacklist can always be bypassed
blocked = ["DROP", "DELETE", "--", "'"]
for word in blocked:
    if word in user_input.upper():
        return "Invalid input"

# Attacker uses: drop, ; delete, %27 (URL-encoded), etc.

# ✅ STRONG: Whitelist allowed characters only
import re
if not re.match(r'^[a-zA-Z0-9_@.]{3,50}$', username):
    raise ValueError("Invalid username")
```

### Mistake 3: Hiding Errors Isn't Enough

```python
# ❌ INSUFFICIENT: Error hiding doesn't prevent injection
try:
    cursor.execute(f"SELECT * FROM users WHERE username = '{user}'")
except:
    return "An error occurred"  # Error hidden, but injection still works
```

### Mistake 4: ORM Doesn't Always Protect

```python
# ❌ WRONG: Raw SQL through ORM is still vulnerable
User.objects.raw(f"SELECT * FROM users WHERE username = '{user}'")

# ✅ CORRECT: Use ORM query methods
User.objects.filter(username=user)
```

---

## ✅ Exercises

### Exercise 1: Identify Vulnerabilities
Which of these are vulnerable?
1. `f"SELECT * FROM users WHERE id = {user_id}"`
2. `cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))`
3. `f"SELECT * FROM users WHERE name LIKE '%{name}%'"`
4. `cursor.execute("SELECT * FROM users WHERE name LIKE %s", (f'%{name}%',))`

### Exercise 2: Exploit the Demo
Using the sqli_demo database, craft SQL injection payloads to:
1. Bypass login for the admin account
2. Extract the credit_card column for all users
3. List all tables in the database
4. Delete all users (on a copy of the database!)

### Exercise 3: Fix Vulnerable Code
Rewrite these to be safe:
```python
def get_user(user_id):
    return db.query(f"SELECT * FROM users WHERE id = {user_id}")

def search(term):
    return db.query(f"SELECT * FROM products WHERE name LIKE '%{term}%'")

def delete_order(order_id, user_id):
    return db.query(f"DELETE FROM orders WHERE id = {order_id} AND user_id = {user_id}")
```

---

## 🧠 Key Takeaways

- **SQL Injection** occurs when user input is concatenated into SQL queries
- It allows attackers to bypass auth, steal data, modify/delete data, or worse
- **Parameterized queries (prepared statements)** are the #1 defense
- **Never trust client-side validation** — always validate on the server
- **Whitelist** allowed characters, don't blacklist bad ones
- Use **least privilege** — the app user shouldn't access everything
- **Stored procedures** also prevent injection (parameters = data, not code)
- **Escaping** is a last resort — prefer parameterized queries
- **ORMs** are safe when using their query methods — not when passing raw SQL
- Error messages should be **generic** — don't leak SQL to the user

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 25: User Management & Privileges →](./lesson-25-security.md)
**Next:** [Lesson 27: EXPLAIN & Query Performance →](./lesson-27-explain.md)
