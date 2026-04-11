# Lesson 30: Backup, Restore & Connecting to Applications

## 📺 Video Timestamps

| Video | Timestamp | Duration |
|-------|-----------|----------|
| 🟪 CS50 | 11:15:00 – 12:00:00 | 45 min |

## 📖 Theory

### Backup Strategies

A **backup** is a copy of your database that can be restored in case of data loss, corruption, or disaster.

### Backup Types

| Type | Description | Tool |
|------|-------------|------|
| **Logical backup** | SQL statements that recreate the database | `mysqldump`, `mysqlpump` |
| **Physical backup** | Copy of the raw data files | `mysqlbackup`, file copy |
| **Full backup** | Entire database | `mysqldump --all-databases` |
| **Incremental backup** | Only changes since last backup | Binary logs |

### mysqldump — The Standard Tool

```bash
# Backup single database
mysqldump -u root -p database_name > backup.sql

# Backup specific tables
mysqldump -u root -p database_name table1 table2 > backup.sql

# Backup all databases
mysqldump -u root -p --all-databases > all_backup.sql

# Backup with structure only (no data)
mysqldump -u root -p --no-data database_name > schema.sql

# Backup data only (no structure)
mysqldump -u root -p --no-create-info database_name > data.sql

# Backup with compression
mysqldump -u root -p database_name | gzip > backup.sql.gz

# Backup with triggers and routines
mysqldump -u root -p --routines --triggers database_name > backup.sql
```

### Restore from Backup

```bash
# Restore from SQL dump
mysql -u root -p database_name < backup.sql

# Restore compressed backup
gunzip < backup.sql.gz | mysql -u root -p database_name

# Restore all databases
mysql -u root -p < all_backup.sql
```

### Automated Backups

```bash
# Cron job: daily backup at 2 AM
0 2 * * * mysqldump -u backup_user -p'password' mydb | gzip > /backups/mydb_$(date +\%Y\%m\%d).sql.gz

# Keep last 7 days
find /backups/ -name "mydb_*.sql.gz" -mtime +7 -delete
```

### Binary Log (Point-in-Time Recovery)

The **binary log** records all changes, enabling recovery to any point in time.

```sql
-- Enable binary logging (in my.cnf):
-- [mysqld]
-- log-bin=mysql-bin
-- binlog-format=ROW

-- Check binary logs
SHOW BINARY LOGS;
SHOW BINLOG EVENTS IN 'mysql-bin.000001';

-- Restore to a specific point in time
mysqlbinlog --stop-datetime="2024-06-01 14:00:00" /var/lib/mysql/mysql-bin.000001 | mysql -u root -p
```

---

## 💻 Examples

### Setup

```sql
CREATE DATABASE IF NOT EXISTS app_demo;
USE app_demo;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash CHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200),
    body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users (username, email, password_hash)
VALUES ('alice', 'alice@email.com', 'hashed_pw_1'), ('bob', 'bob@email.com', 'hashed_pw_2');

INSERT INTO posts (user_id, title, body)
VALUES (1, 'First Post', 'Hello world!'), (1, 'Second Post', 'More content'), (2, "Bob's Post", 'Hi!');
```

### Example 1: Backup via mysqldump (Terminal)

```bash
# Backup the app_demo database
mysqldump -u root -p app_demo > app_demo_backup.sql

# Check the backup file
head -20 app_demo_backup.sql
# Contains: CREATE DATABASE, USE, CREATE TABLE, INSERT statements

# File size
ls -lh app_demo_backup.sql
```

### Example 2: Restore from Backup (Terminal)

```bash
# Create a fresh database
mysql -u root -p -e "CREATE DATABASE app_demo_restored;"

# Restore backup
mysql -u root -p app_demo_restored < app_demo_backup.sql

# Verify
mysql -u root -p -e "USE app_demo_restored; SELECT COUNT(*) FROM users; SELECT COUNT(*) FROM posts;"
```

### Example 3: Connect MySQL to Python

```python
# Install: pip install mysql-connector-python
import mysql.connector

# Connect
conn = mysql.connector.connect(
    host='localhost',
    user='app_user',
    password='StrongPassword!',
    database='app_demo'
)

cursor = conn.cursor(dictionary=True)  # Returns dicts instead of tuples

# SELECT
cursor.execute("SELECT user_id, username, email FROM users")
users = cursor.fetchall()
for user in users:
    print(f"{user['username']}: {user['email']}")

# INSERT (parameterized — safe from SQL injection!)
cursor.execute(
    "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s)",
    ('carol', 'carol@email.com', 'hashed_pw_3')
)
conn.commit()
print(f"Inserted {cursor.lastrowid}")

# UPDATE
cursor.execute("UPDATE users SET email = %s WHERE username = %s",
               ('new_alice@email.com', 'alice'))
conn.commit()

# DELETE
cursor.execute("DELETE FROM posts WHERE post_id = %s", (3,))
conn.commit()

# JOIN query
cursor.execute("""
    SELECT u.username, p.title, p.created_at
    FROM users u
    JOIN posts p ON u.user_id = p.user_id
    ORDER BY p.created_at DESC
""")
for row in cursor.fetchall():
    print(f"{row['username']}: {row['title']}")

cursor.close()
conn.close()
```

### Example 4: Connect MySQL to Node.js

```javascript
// Install: npm install mysql2
const mysql = require('mysql2/promise');

async function main() {
    // Create connection pool
    const pool = mysql.createPool({
        host: 'localhost',
        user: 'app_user',
        password: 'StrongPassword!',
        database: 'app_demo',
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0
    });

    // SELECT
    const [users] = await pool.execute(
        'SELECT user_id, username, email FROM users'
    );
    console.log('Users:', users);

    // INSERT (parameterized)
    const [result] = await pool.execute(
        'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
        ['dave', 'dave@email.com', 'hashed_pw_4']
    );
    console.log('Inserted ID:', result.insertId);

    // JOIN query
    const [posts] = await pool.execute(`
        SELECT u.username, p.title, p.created_at
        FROM users u JOIN posts p ON u.user_id = p.user_id
        ORDER BY p.created_at DESC
    `);
    console.log('Posts:', posts);

    await pool.end();
}

main().catch(console.error);
```

### Example 5: Connect MySQL to PHP

```php
<?php
// PDO connection
$pdo = new PDO(
    'mysql:host=localhost;dbname=app_demo;charset=utf8mb4',
    'app_user',
    'StrongPassword!',
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]
);

// SELECT
$stmt = $pdo->query('SELECT user_id, username, email FROM users');
$users = $stmt->fetchAll();
foreach ($users as $user) {
    echo "{$user['username']}: {$user['email']}\n";
}

// INSERT (parameterized)
$stmt = $pdo->prepare(
    'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)'
);
$stmt->execute(['eve', 'eve@email.com', 'hashed_pw_5']);
echo "Inserted ID: " . $pdo->lastInsertId() . "\n";

// JOIN
$stmt = $pdo->query("
    SELECT u.username, p.title, p.created_at
    FROM users u JOIN posts p ON u.user_id = p.user_id
    ORDER BY p.created_at DESC
");
$posts = $stmt->fetchAll();
print_r($posts);
?>
```

### Example 6: ORM Example — SQLAlchemy (Python)

```python
# Install: pip install sqlalchemy
from sqlalchemy import create_engine, Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
from datetime import datetime

# Setup
engine = create_engine('mysql+mysqlconnector://app_user:StrongPassword!@localhost/app_demo')
Base = declarative_base()
Session = sessionmaker(bind=engine)
session = Session()

# Define models
class User(Base):
    __tablename__ = 'users'
    user_id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True)
    email = Column(String(100), unique=True)
    posts = relationship('Post', back_populates='user')

class Post(Base):
    __tablename__ = 'posts'
    post_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.user_id'))
    title = Column(String(200))
    body = Column(Text)
    user = relationship('User', back_populates='posts')

# Query
users = session.query(User).all()
for u in users:
    print(f"{u.username}: {len(u.posts)} posts")

# ORM insert
new_user = User(username='frank', email='frank@email.com', password_hash='hash')
session.add(new_user)
session.commit()
```

---

## ⚠️ Common Mistakes

### Mistake 1: No Backups

```bash
# ❌ WRONG: Running production without backups
# "It won't happen to me" — until it does

# ✅ CORRECT: Automated daily backups
# Cron: 0 2 * * * mysqldump -u root -p mydb | gzip > /backups/mydb_$(date +\%Y\%m\%d).sql.gz
```

### Mistake 2: Backups Not Tested

```bash
# ❌ WRONG: Having backups but never testing restore
# A backup you haven't restored is not a backup

# ✅ CORRECT: Regularly test restores in a staging environment
mysql -u root -p test_restore < latest_backup.sql
# Verify data integrity, then drop test_restore
```

### Mistake 3: Hardcoding Credentials

```python
# ❌ DANGEROUS: Password in source code
conn = mysql.connector.connect(
    host='localhost',
    user='app_user',
    password='SuperSecret123!',  # ← Committed to Git!
    database='app_demo'
)

# ✅ CORRECT: Use environment variables
import os
conn = mysql.connector.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASSWORD'],
    database=os.environ['DB_NAME']
)
```

### Mistake 4: Not Using Connection Pools

```python
# ❌ SLOW: New connection for every request
def handle_request():
    conn = mysql.connector.connect(...)  # Expensive!
    # ... query ...
    conn.close()

# ✅ FAST: Use connection pool
from mysql.connector import pooling
pool = pooling.MySQLConnectionPool(
    pool_name="mypool",
    pool_size=10,
    host='localhost', user='app_user',
    password='password', database='app_demo'
)

def handle_request():
    conn = pool.get_connection()
    # ... query ...
    conn.close()  # Returns to pool
```

---

## ✅ Exercises

### Exercise 1: Backup & Restore
1. Backup your app_demo database using mysqldump
2. Create a new empty database
3. Restore the backup into it
4. Verify the data matches

### Exercise 2: Python Connection
Write a Python script that:
1. Connects to your MySQL database
2. Lists all users with their post counts
3. Inserts a new user
4. Deletes a post by ID (from user input)
5. Uses parameterized queries throughout

### Exercise 3: Connection Pooling
Modify your application to use connection pooling instead of creating a new connection per request.

### Exercise 4: Backup Script
Write a bash script that:
1. Backups a database with timestamp
2. Compresses the backup
3. Deletes backups older than 30 days
4. Logs the result

---

## 🧠 Key Takeaways

- **Always backup** — use `mysqldump` for logical backups
- **Test restores** — a backup is only valid if you can restore it
- **Automate backups** — use cron jobs for daily backups
- **Binary logs** enable point-in-time recovery
- **Connection pooling** reuses connections — much faster than creating new ones
- **Parameterized queries** prevent SQL injection in all languages
- **Environment variables** for credentials — never hardcode passwords
- **ORMs** (SQLAlchemy, Sequelize, Eloquent) abstract SQL but understand the underlying queries
- **PDO** (PHP) and **mysql2** (Node.js) are the standard libraries for their languages
- Use `utf8mb4` charset to support emojis and all Unicode characters

---

## 📝 Notes

_Add your own observations here:_

---

**Previous:** [Lesson 29: Storage Engines & Architecture →](./lesson-29-storage-engines.md)
**Next:** [Capstone Projects →](../README.md)

---

# 🎉 Congratulations!

You've completed all 30 lessons of the SQL Mega Course!

**What you've learned:**
- ✅ SQL basics (SELECT, WHERE, ORDER BY, LIMIT)
- ✅ Data manipulation (INSERT, UPDATE, DELETE)
- ✅ Data types and constraints
- ✅ Joins (INNER, LEFT, RIGHT, CROSS, self-joins)
- ✅ Aggregations and GROUP BY
- ✅ Subqueries and functions
- ✅ Indexes and query optimization
- ✅ Transactions and ACID
- ✅ Views, triggers, stored procedures
- ✅ Database design and normalization
- ✅ Security, SQL injection prevention
- ✅ Backup, restore, and application integration

**Next steps:**
1. Complete the [Capstone Projects](../README.md#capstone-projects)
2. Build your own project using MySQL
3. Explore advanced topics: replication, sharding, partitioning
4. Practice on LeetCode, HackerRank, or StrataScratch
5. Prepare for SQL interviews with the questions in `interview-prep/`

**Keep practicing — the more SQL you write, the more natural it becomes!**
