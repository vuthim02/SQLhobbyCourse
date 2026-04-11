# Lesson 25: User Management & Privileges

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 8:15:00 – 8:45:00 | 30 min |

## 📖 Theory

### MySQL Security Model

MySQL controls access through:
1. **User accounts** — who can connect
2. **Authentication** — verifying identity (password, auth plugin)
3. **Privileges** — what the user can do
4. **Host restrictions** — where the user can connect from

### Privilege Levels

| Level | Scope | Example |
|-------|-------|---------|
| **Global** | All databases | `GRANT ALL ON *.*` |
| **Database** | One database | `GRANT ALL ON mydb.*` |
| **Table** | One table | `GRANT SELECT ON mydb.users` |
| **Column** | One column | `GRANT SELECT(name, email) ON mydb.users` |
| **Routine** | Stored procedures | `GRANT EXECUTE ON mydb.proc` |

### Common Privileges

| Privilege | Description |
|-----------|-------------|
| `ALL PRIVILEGES` | All permissions |
| `SELECT` | Read data |
| `INSERT` | Add data |
| `UPDATE` | Modify data |
| `DELETE` | Remove data |
| `CREATE` | Create tables/databases |
| `DROP` | Delete tables/databases |
| `ALTER` | Modify table structure |
| `INDEX` | Create/drop indexes |
| `CREATE VIEW` | Create views |
| `EXECUTE` | Run stored procedures |
| `GRANT OPTION` | Grant privileges to others |
| `FILE` | Read/write files on server |
| `PROCESS` | View running threads |
| `SHUTDOWN` | Shut down server |

### Principle of Least Privilege

> **Give each user only the minimum privileges they need to do their job.**

| Role | Typical Privileges |
|------|-------------------|
| **Application** | SELECT, INSERT, UPDATE, DELETE on specific tables |
| **Read-only analyst** | SELECT on specific database |
| **Admin** | ALL on specific database |
| **Backup user** | SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER |
| **Root** | ALL — only for DBA tasks |

---

## 💻 Examples

### Setup — Connect as Root

```bash
mysql -u root -p
```

### Example 1: View Existing Users

```sql
-- List all MySQL users
SELECT user, host, authentication_string FROM mysql.user;

-- See what privileges the current user has
SHOW GRANTS FOR CURRENT_USER;
```

### Example 2: Create a User

```sql
-- Create user with password (can connect from any host)
CREATE USER 'app_user'@'%' IDENTIFIED BY 'SecurePass123!';

-- Create user (can only connect from localhost)
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'SecurePass123!';

-- Create user (can only connect from specific IP)
CREATE USER 'app_user'@'192.168.1.100' IDENTIFIED BY 'SecurePass123!';

-- Create user with no password (not recommended!)
CREATE USER 'guest'@'localhost';
```

### Example 3: Grant Privileges

```sql
-- Grant SELECT only on one database
GRANT SELECT ON store_db.* TO 'analyst'@'localhost';

-- Grant SELECT, INSERT, UPDATE, DELETE (CRUD) on one database
GRANT SELECT, INSERT, UPDATE, DELETE ON store_db.* TO 'app_user'@'localhost';

-- Grant ALL on one database
GRANT ALL PRIVILEGES ON store_db.* TO 'admin_user'@'localhost';

-- Grant SELECT on specific columns
GRANT SELECT(id, name, email) ON store_db.customers TO 'readonly'@'localhost';

-- Grant EXECUTE on stored procedures
GRANT EXECUTE ON store_db.* TO 'app_user'@'localhost';

-- Grant CREATE VIEW
GRANT CREATE VIEW ON store_db.* TO 'analyst'@'localhost';

-- Apply changes immediately
FLUSH PRIVILEGES;
```

### Example 4: View User Privileges

```sql
-- See all grants for a specific user
SHOW GRANTS FOR 'app_user'@'localhost';

-- See all grants including GRANT OPTION
SHOW GRANTS FOR 'app_user'@'localhost' USING app_user;
```

### Example 5: Revoke Privileges

```sql
-- Remove DELETE privilege
REVOKE DELETE ON store_db.* FROM 'app_user'@'localhost';

-- Remove all privileges on a database
REVOKE ALL ON store_db.* FROM 'app_user'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Verify
SHOW GRANTS FOR 'app_user'@'localhost';
```

### Example 6: Alter User

```sql
-- Change password
ALTER USER 'app_user'@'localhost' IDENTIFIED BY 'NewSecurePass456!';

-- Lock account
ALTER USER 'app_user'@'localhost' ACCOUNT LOCK;

-- Unlock account
ALTER USER 'app_user'@'localhost' ACCOUNT UNLOCK;

-- Force password change on next login
ALTER USER 'app_user'@'localhost' PASSWORD EXPIRE;
```

### Example 7: Drop User

```sql
-- Delete a user
DROP USER 'guest'@'localhost';
DROP USER IF EXISTS 'old_user'@'%';
```

### Example 8: Role-Based Access (MySQL 8.0+)

```sql
-- Create a role
CREATE ROLE 'read_only';
CREATE ROLE 'app_developer';

-- Grant privileges to roles
GRANT SELECT ON store_db.* TO 'read_only';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER ON store_db.* TO 'app_developer';

-- Assign roles to users
CREATE USER 'john'@'localhost' IDENTIFIED BY 'JohnsPass123!';
CREATE USER 'jane'@'localhost' IDENTIFIED BY 'JanesPass123!';

GRANT 'read_only' TO 'john'@'localhost';
GRANT 'app_developer' TO 'jane'@'localhost';

-- Set default role
SET DEFAULT ROLE 'read_only' TO 'john'@'localhost';

-- Activate role in session
SET ROLE 'read_only';
```

---

## ⚠️ Common Mistakes

### Mistake 1: Using Root for Everything

```sql
-- ❌ DANGEROUS: Application connects as root
-- mysql -u root -p (in application config)
-- If application is compromised, attacker has full database control!

-- ✅ CORRECT: Create a dedicated user with minimal privileges
CREATE USER 'myapp'@'localhost' IDENTIFIED BY 'StrongPassword!';
GRANT SELECT, INSERT, UPDATE, DELETE ON myapp_db.* TO 'myapp'@'localhost';
```

### Mistake 2: Using '%' as Host

```sql
-- ❌ INSECURE: User can connect from anywhere
CREATE USER 'admin'@'%' IDENTIFIED BY 'password';

-- ✅ CORRECT: Restrict to specific hosts
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'StrongPassword!';
CREATE USER 'admin'@'192.168.1.%' IDENTIFIED BY 'StrongPassword!';  -- Internal network only
```

### Mistake 3: Forgetting FLUSH PRIVILEGES

```sql
-- ❌ INCOMPLETE: Changes may not take effect immediately
GRANT SELECT ON mydb.* TO 'user'@'localhost';
-- (In most cases, GRANT auto-flushes, but manual DML on mysql.user does not)

-- ✅ CORRECT: Flush after direct mysql.user table modifications
UPDATE mysql.user SET authentication_string = PASSWORD('newpass') WHERE user = 'myuser';
FLUSH PRIVILEGES;
```

### Mistake 4: Over-Granting Privileges

```sql
-- ❌ EXCESSIVE: Analyst gets DROP and CREATE — not needed
GRANT ALL ON analytics_db.* TO 'analyst'@'localhost';

-- ✅ CORRECT: Give only what's needed
GRANT SELECT ON analytics_db.* TO 'analyst'@'localhost';
GRANT CREATE TEMPORARY TABLES ON analytics_db.* TO 'analyst'@'localhost';
```

---

## ✅ Exercises

### Exercise 1: User Management
1. Create a user `report_user` who can only connect from localhost
2. Grant them SELECT access on a specific database
3. Verify with SHOW GRANTS
4. Revoke the privilege and verify again

### Exercise 2: Application User Setup
Create a user for a web application that needs to:
- SELECT, INSERT, UPDATE, DELETE on `store_db.customers`
- SELECT, INSERT on `store_db.orders`
- SELECT only on `store_db.products`
- Execute stored procedures in `store_db`

### Exercise 3: Role Setup
Create roles for your team:
- `intern`: SELECT only
- `developer`: SELECT, INSERT, UPDATE, DELETE, CREATE
- `dba`: ALL privileges

### Exercise 4: Security Audit
1. List all users on your MySQL server
2. Identify any users with ALL PRIVILEGES on *.*
3. Identify any users that can connect from '%'
4. Recommend improvements

---

## 🧠 Key Takeaways

- **Always create dedicated users** — never use root for applications
- **Principle of least privilege** — give minimum necessary access
- **Restrict hosts** — use `@'localhost'` instead of `@'%'` when possible
- **GRANT** assigns privileges, **REVOKE** removes them, **FLUSH PRIVILEGES** applies changes
- **Roles** (MySQL 8.0+) simplify managing many users
- **Column-level privileges** restrict access to sensitive columns (e.g., SSN, salary)
- **SHOW GRANTS** verifies what a user can actually do
- **FLUSH PRIVILEGES** is needed after direct edits to `mysql.user` table

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 24: BCNF & Denormalization →](../week-5-database-design/lesson-24-bcdf-denormalization.md)
**Next:** [Lesson 26: SQL Injection & Prevention →](./lesson-26-sql-injection.md)
