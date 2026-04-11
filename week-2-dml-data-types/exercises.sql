-- ============================================================
-- Week 2 Exercises: Data Manipulation & Data Types
-- ============================================================
-- Practice INSERT, UPDATE, DELETE, data types, constraints, keys
-- ============================================================

-- ============================================================
-- SETUP: Blog Database
-- ============================================================

CREATE DATABASE IF NOT EXISTS week2_exercises;
USE week2_exercises;

-- YOUR QUERY HERE: Create tables
-- 1. authors: id, name (NOT NULL), email (UNIQUE, NOT NULL), bio (TEXT), joined_date
-- 2. posts: id, author_id (FK), title (NOT NULL), body (TEXT), status (ENUM), published_at
-- 3. comments: id, post_id (FK), author_id (FK), body (TEXT), created_at

-- Insert 5 authors
-- YOUR QUERY HERE:

-- Insert 10 posts (distributed among authors)
-- YOUR QUERY HERE:

-- Insert 15 comments
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 1: Data Types & Constraints ⭐
-- ============================================================

-- 1. Insert an author with a NULL name — observe the error
-- YOUR QUERY HERE:

-- 2. Insert two authors with the same email — observe the error
-- YOUR QUERY HERE:

-- 3. Insert a post with a status not in the ENUM — observe the error
-- YOUR QUERY HERE:

-- 4. Insert an author with only required fields (name, email) — verify defaults
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 2: INSERT Advanced ⭐⭐
-- ============================================================

-- 1. Multi-row insert: Add 3 authors in one statement
-- YOUR QUERY HERE:

-- 2. INSERT ... SELECT: Copy all active authors to an authors_backup table
-- YOUR QUERY HERE:

-- 3. INSERT IGNORE: Try inserting a duplicate email without error
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 3: UPDATE Practice ⭐⭐
-- ============================================================

-- 1. Update all 'draft' posts to 'published'
-- YOUR QUERY HERE:

-- 2. Give authors with 2+ posts a 'Popular Author' bio suffix
-- YOUR QUERY HERE:

-- 3. Use CASE to set different statuses: posts older than 30 days → 'archived', others → 'active'
-- YOUR QUERY HERE:

-- 4. Update post counts for authors based on actual post count (subquery)
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 4: DELETE Practice ⭐⭐
-- ============================================================

-- 1. Soft delete: Add a deleted_at column to comments, set it for spam comments
-- YOUR QUERY HERE:

-- 2. Delete all posts with status = 'draft' that are older than 60 days
-- YOUR QUERY HERE:

-- 3. Delete authors who have no posts (anti-join pattern)
-- YOUR QUERY HERE:

-- 4. Demonstrate CASCADE: Delete an author and observe what happens to their posts
-- YOUR QUERY HERE:

-- ============================================================
-- Exercise 5: Challenge — Full CRUD ⭐⭐⭐
-- ============================================================

-- 1. Create a new post for a specific author
-- YOUR QUERY HERE:

-- 2. Update the post's status to 'published' and set published_at to NOW()
-- YOUR QUERY HERE:

-- 3. Add 3 comments to the new post
-- YOUR QUERY HERE:

-- 4. Count total posts and comments per author
-- YOUR QUERY HERE:

-- 5. Delete the new post and verify all its comments are cascade-deleted
-- YOUR QUERY HERE:

-- ============================================================
-- Bonus: Design Challenge ⭐⭐⭐⭐
-- ============================================================

-- Create a complete library database with:
-- books (ISBN PK, title, author_id, genre, published_year, pages, price)
-- authors (id, name, nationality, birth_year)
-- members (id, name, email, membership_type, joined_date)
-- borrowals (member_id, book_id, borrow_date, due_date, return_date, fine)
--
-- Requirements:
-- - Proper data types for each column
-- - All constraints (PK, FK, NOT NULL, UNIQUE, DEFAULT, CHECK)
-- - ON DELETE CASCADE for borrowals when book/member is deleted
-- - Insert 5 books, 3 authors, 4 members, 8 borrowals
--
-- Write queries:
-- 1. Books currently borrowed
-- 2. Members with overdue books
-- 3. Total fines per member
-- 4. Most popular genre
-- 5. Author with the most books in the library

-- YOUR QUERY HERE:
