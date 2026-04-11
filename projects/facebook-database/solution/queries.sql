-- ============================================================
-- Facebook Database — Complete Solution
-- ============================================================

-- ============================================================
-- SCHEMA
-- ============================================================

CREATE DATABASE IF NOT EXISTS facebook_db;
USE facebook_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE,
    gender ENUM('M', 'F', 'Other') NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    profile_pic VARCHAR(200),
    is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE friendships (
    requester_id INT,
    addressee_id INT,
    status ENUM('pending', 'accepted', 'blocked') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (requester_id, addressee_id),
    FOREIGN KEY (requester_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (addressee_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (requester_id <> addressee_id)
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    privacy ENUM('public', 'friends', 'only_me') DEFAULT 'public',
    post_type ENUM('text', 'photo', 'link') DEFAULT 'text',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    parent_id INT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

CREATE TABLE reactions (
    user_id INT,
    post_id INT,
    reaction_type ENUM('like', 'love', 'haha', 'wow', 'sad', 'angry') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

CREATE TABLE groups (
    group_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    privacy ENUM('public', 'private', 'secret') DEFAULT 'public',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE group_members (
    group_id INT,
    user_id INT,
    role ENUM('admin', 'moderator', 'member') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE group_posts (
    gpost_id INT PRIMARY KEY AUTO_INCREMENT,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    location VARCHAR(200),
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    created_by INT NOT NULL,
    privacy ENUM('public', 'private') DEFAULT 'public',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE event_attendees (
    event_id INT,
    user_id INT,
    status ENUM('going', 'interested', 'not_going') DEFAULT 'interested',
    responded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, user_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE photos (
    photo_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    url VARCHAR(300) NOT NULL,
    caption VARCHAR(200),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

CREATE TABLE messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (sender_id <> receiver_id)
);

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO users (username, email, first_name, last_name, dob, gender, joined_at) VALUES
('alice_w', 'alice@email.com', 'Alice', 'Walker', '1990-05-15', 'F', '2020-01-10 08:00:00'),
('bob_smith', 'bob@email.com', 'Bob', 'Smith', '1988-11-30', 'M', '2020-02-15 10:00:00'),
('carol_j', 'carol@email.com', 'Carol', 'Johnson', '1992-07-20', 'F', '2020-03-01 12:00:00'),
('david_b', 'david@email.com', 'David', 'Brown', '1995-03-10', 'M', '2020-06-20 14:00:00'),
('eve_d', 'eve@email.com', 'Eve', 'Davis', '1991-01-25', 'F', '2021-01-05 09:00:00'),
('frank_m', 'frank@email.com', 'Frank', 'Miller', '1987-09-12', 'M', '2021-03-15 11:00:00'),
('grace_w', 'grace@email.com', 'Grace', 'Wilson', '1993-12-01', 'F', '2021-06-01 16:00:00'),
('henry_t', 'henry@email.com', 'Henry', 'Taylor', '1989-04-18', 'M', '2021-09-10 10:00:00'),
('ivy_a', 'ivy@email.com', 'Ivy', 'Anderson', '1994-08-22', 'F', '2022-01-20 13:00:00'),
('jack_t', 'jack@email.com', 'Jack', 'Thomas', '1991-06-30', 'M', '2022-04-05 15:00:00'),
('karen_l', 'karen@email.com', 'Karen', 'Lee', '1990-10-05', 'F', '2022-07-15 08:00:00'),
('leo_g', 'leo@email.com', 'Leo', 'Garcia', '1996-02-14', 'M', '2023-01-10 10:00:00'),
('mia_r', 'mia@email.com', 'Mia', 'Robinson', '1988-04-28', 'F', '2023-03-20 14:00:00'),
('noah_h', 'noah@email.com', 'Noah', 'Hall', '1993-07-11', 'M', '2023-06-01 09:00:00'),
('olivia_c', 'olivia@email.com', 'Olivia', 'Clark', '1995-11-03', 'F', '2023-09-15 11:00:00');

-- Friendships (bidirectional: A→B and B→A for accepted)
-- Alice's network
INSERT INTO friendships (requester_id, addressee_id, status, created_at) VALUES
(1, 2, 'accepted', '2020-03-01'), (2, 1, 'accepted', '2020-03-01'),
(1, 3, 'accepted', '2020-04-15'), (3, 1, 'accepted', '2020-04-15'),
(1, 5, 'accepted', '2021-02-10'), (5, 1, 'accepted', '2021-02-10'),
(1, 7, 'accepted', '2021-07-20'), (7, 1, 'accepted', '2021-07-20'),
(1, 8, 'pending', '2024-01-15'),
-- Bob's network
(2, 3, 'accepted', '2020-05-10'), (3, 2, 'accepted', '2020-05-10'),
(2, 4, 'accepted', '2020-08-15'), (4, 2, 'accepted', '2020-08-15'),
(2, 6, 'accepted', '2021-04-01'), (6, 2, 'accepted', '2021-04-01'),
-- Carol's network
(3, 5, 'accepted', '2021-01-20'), (5, 3, 'accepted', '2021-01-20'),
(3, 9, 'accepted', '2022-02-15'), (9, 3, 'accepted', '2022-02-15'),
-- David's network
(4, 6, 'accepted', '2021-05-10'), (6, 4, 'accepted', '2021-05-10'),
(4, 10, 'accepted', '2022-05-01'), (10, 4, 'accepted', '2022-05-01'),
-- Eve's network
(5, 7, 'accepted', '2021-08-01'), (7, 5, 'accepted', '2021-08-01'),
(5, 11, 'accepted', '2022-08-10'), (11, 5, 'accepted', '2022-08-10'),
-- Frank's network
(6, 8, 'accepted', '2021-10-15'), (8, 6, 'accepted', '2021-10-15'),
(6, 12, 'accepted', '2023-02-01'), (12, 6, 'accepted', '2023-02-01'),
-- Grace's network
(7, 9, 'accepted', '2022-03-10'), (9, 7, 'accepted', '2022-03-10'),
(7, 13, 'pending', '2024-02-01'),
-- Henry's network
(8, 10, 'accepted', '2022-06-15'), (10, 8, 'accepted', '2022-06-15'),
(8, 11, 'pending', '2024-03-01'),
-- Ivy's network
(9, 11, 'accepted', '2022-09-01'), (11, 9, 'accepted', '2022-09-01'),
(9, 14, 'accepted', '2023-07-01'), (14, 9, 'accepted', '2023-07-01'),
-- Jack's network
(10, 12, 'accepted', '2023-03-01'), (12, 10, 'accepted', '2023-03-01'),
-- Karen's network
(11, 13, 'accepted', '2023-04-15'), (13, 11, 'accepted', '2023-04-15'),
-- Leo's network
(12, 14, 'accepted', '2023-08-01'), (14, 12, 'accepted', '2023-08-01'),
-- Mia's network
(13, 15, 'accepted', '2023-10-01'), (15, 13, 'accepted', '2023-10-01'),
-- Blocked
(1, 15, 'blocked', '2024-01-20'),
(15, 1, 'blocked', '2024-01-20');

-- Posts
INSERT INTO posts (user_id, body, created_at, privacy, post_type) VALUES
(1, 'Just finished my first marathon! So proud of myself!', '2024-01-15 09:00:00', 'public', 'text'),
(1, 'Beautiful sunset at the beach today.', '2024-02-10 18:00:00', 'public', 'photo'),
(2, 'New job announcement: starting at Google next month!', '2024-01-20 12:00:00', 'public', 'text'),
(2, 'Coffee and code ☕', '2024-03-01 08:00:00', 'public', 'photo'),
(3, 'My recipe for the perfect chocolate cake 🎂', '2024-02-14 14:00:00', 'public', 'text'),
(3, 'Weekend hiking trip photos!', '2024-03-10 16:00:00', 'friends', 'photo'),
(4, 'Just adopted a puppy! Meet Max 🐕', '2024-01-25 10:00:00', 'public', 'photo'),
(4, 'Working from home today', '2024-03-05 09:00:00', 'friends', 'text'),
(5, 'Excited to announce our new startup!', '2024-02-01 11:00:00', 'public', 'text'),
(5, 'Team building day at the office', '2024-03-15 15:00:00', 'public', 'photo'),
(6, 'Happy birthday to my amazing wife!', '2024-02-14 00:00:00', 'public', 'text'),
(6, 'Check out this amazing article about AI', '2024-03-20 10:00:00', 'public', 'link'),
(7, 'First day at my new job!', '2024-01-30 08:00:00', 'public', 'text'),
(7, 'Cooking experiment: homemade pasta 🍝', '2024-03-08 19:00:00', 'public', 'photo'),
(8, 'My garden is finally blooming!', '2024-03-12 07:00:00', 'public', 'photo'),
(8, 'Throwback to last summer vacation', '2024-02-20 14:00:00', 'only_me', 'photo'),
(9, 'Graduated today! 🎓', '2024-01-15 16:00:00', 'public', 'text'),
(9, 'New apartment, new beginnings', '2024-03-01 12:00:00', 'public', 'photo'),
(10, 'Just ran my first 5K!', '2024-02-28 07:00:00', 'public', 'text'),
(10, 'Sunday brunch with friends', '2024-03-17 11:00:00', 'friends', 'photo'),
(11, 'Promoted to Senior Engineer! 🎉', '2024-01-10 09:00:00', 'public', 'text'),
(11, 'Weekend getaway to the mountains', '2024-03-03 18:00:00', 'public', 'photo'),
(12, 'First day of college!', '2024-01-22 08:00:00', 'public', 'photo'),
(12, 'Study group session 📚', '2024-03-10 20:00:00', 'friends', 'text'),
(13, 'Celebrating 10 years at the company!', '2024-02-05 10:00:00', 'public', 'text'),
(13, 'Family reunion this weekend', '2024-03-15 12:00:00', 'friends', 'photo'),
(14, 'Just moved to the city!', '2024-01-28 14:00:00', 'public', 'text'),
(14, 'Exploring new neighborhoods', '2024-03-08 16:00:00', 'public', 'photo'),
(15, 'New hobby: pottery 🏺', '2024-02-18 11:00:00', 'public', 'text'),
(15, 'Private thoughts about the future', '2024-03-20 22:00:00', 'only_me', 'text'),
-- More posts for reaction/comment density
(1, 'Monday motivation: never give up!', '2024-03-18 06:00:00', 'public', 'text'),
(2, 'Open source project update', '2024-03-19 15:00:00', 'public', 'link'),
(3, 'Farmers market haul 🥕🥬🍅', '2024-03-16 10:00:00', 'public', 'photo'),
(4, 'My pup Max learned a new trick!', '2024-03-17 18:00:00', 'public', 'photo'),
(5, 'Pitch deck ready for investors', '2024-03-18 20:00:00', 'public', 'text'),
(6, 'Book recommendation: Atomic Habits', '2024-03-14 09:00:00', 'public', 'text'),
(7, 'Art gallery opening tonight', '2024-03-15 20:00:00', 'public', 'photo'),
(8, 'Science fair at the local school', '2024-03-13 14:00:00', 'public', 'text'),
(9, 'Job hunting is exhausting', '2024-03-12 16:00:00', 'friends', 'text'),
(10, 'New bike day! 🚴', '2024-03-11 10:00:00', 'public', 'photo');

-- Comments
INSERT INTO comments (post_id, user_id, body, parent_id) VALUES
-- Marathon post (post 1)
(1, 2, 'Congratulations Alice! That is incredible!', NULL),
(1, 3, 'You are so inspiring! 🏃‍♀️', 1),
(1, 5, 'Well deserved! How long did you train?', NULL),
(1, 7, 'Amazing achievement!', 1),
(1, 8, 'Goals!', 3),
-- Bob's job announcement (post 3)
(3, 1, 'So happy for you Bob! 🎉', NULL),
(3, 3, 'Google is lucky to have you!', NULL),
(3, 4, 'Congrats mate!', 6),
(3, 6, 'Deserved! 🙌', NULL),
-- Eve's startup (post 9)
(9, 1, 'This is exciting Eve! What does it do?', NULL),
(9, 3, 'Count me in as an early user!', 10),
(9, 5, 'Thanks Carol! It is a productivity app.', 11),
(9, 7, 'Love the hustle! 💪', NULL),
-- Ivy's graduation (post 17)
(17, 3, 'So proud of you Ivy! 🎓', NULL),
(17, 7, 'Congratulations! What is next?', 14),
(17, 9, 'Thank you! Looking for jobs now.', 15),
(17, 11, 'You will do great!', 14),
-- Karen's promotion (post 21)
(21, 5, 'Well deserved Karen! 👏', NULL),
(21, 9, 'Congrats Karen! Let us celebrate!', NULL),
(21, 11, 'Thanks Eve! Drinks this weekend?', 19),
-- Leo's college (post 23)
(23, 6, 'Enjoy it Leo! Best years of your life.', NULL),
(23, 10, 'Good luck bro!', NULL),
(23, 12, 'See you around campus!', 22),
-- Mia's anniversary (post 25)
(25, 7, 'Happy anniversary Mia!', NULL),
(25, 11, '10 years is impressive!', NULL),
-- More comments
(4, 1, 'What IDE are you using?', NULL),
(5, 2, 'Recipe please! 🙏', NULL),
(5, 1, 'I need this recipe too!', 26),
(7, 3, 'Max is adorable! 😍', NULL),
(10, 2, 'Startup life! You got this!', NULL),
(13, 1, 'Grace, you will do great!', NULL),
(14, 3, 'That looks delicious!', NULL),
(15, 1, 'Your tomatoes look amazing Henry!', NULL),
(20, 2, 'Great job Jack! 5K is huge!', NULL),
(24, 3, 'Good luck with finals!', NULL),
(27, 1, 'Welcome to the city Noah!', NULL),
(28, 4, 'The city is great for exploring!', NULL),
(29, 5, 'Pottery is so therapeutic!', NULL),
(31, 2, 'Needed this today, thanks Alice!', NULL),
(33, 1, 'Those carrots are huge Carol!', NULL),
(34, 2, 'Max is the best boy 🐶', NULL),
(36, 3, 'Great read! Also recommend Deep Work.', 36),
(38, 5, 'Hang in there Ivy, the right job will come!', NULL);

-- Reactions
INSERT INTO reactions (user_id, post_id, reaction_type) VALUES
-- Post 1 (marathon): 8 reactions
(2, 1, 'love'), (3, 1, 'love'), (5, 1, 'wow'), (7, 1, 'like'), (8, 1, 'like'),
(4, 1, 'like'), (6, 1, 'wow'), (9, 1, 'love'),
-- Post 2 (sunset): 5 reactions
(3, 2, 'love'), (5, 2, 'love'), (7, 2, 'like'), (8, 2, 'like'), (9, 2, 'love'),
-- Post 3 (job): 10 reactions
(1, 3, 'love'), (3, 3, 'like'), (4, 3, 'wow'), (6, 3, 'like'),
(7, 3, 'like'), (8, 3, 'wow'), (9, 3, 'like'), (10, 3, 'like'), (11, 3, 'like'), (12, 3, 'like'),
-- Post 5 (cake): 4 reactions
(2, 5, 'love'), (1, 5, 'like'), (7, 5, 'love'), (9, 5, 'haha'),
-- Post 7 (puppy): 7 reactions
(3, 7, 'love'), (1, 7, 'love'), (5, 7, 'love'), (2, 7, 'like'),
(6, 7, 'love'), (7, 7, 'haha'), (8, 7, 'like'),
-- Post 9 (startup): 5 reactions
(1, 9, 'love'), (3, 9, 'wow'), (7, 9, 'like'), (11, 9, 'like'), (2, 9, 'love'),
-- Post 11 (birthday): 3 reactions
(1, 11, 'love'), (2, 11, 'like'), (4, 11, 'like'),
-- Post 14 (pasta): 4 reactions
(3, 14, 'love'), (1, 14, 'wow'), (5, 14, 'like'), (2, 14, 'like'),
-- Post 17 (graduation): 8 reactions
(3, 17, 'love'), (7, 17, 'love'), (11, 17, 'like'), (9, 17, 'wow'),
(1, 17, 'like'), (5, 17, 'love'), (2, 17, 'like'), (4, 17, 'wow'),
-- Post 21 (promotion): 5 reactions
(5, 21, 'love'), (9, 21, 'like'), (11, 21, 'wow'), (7, 21, 'like'), (3, 21, 'like'),
-- Post 23 (college): 3 reactions
(6, 23, 'like'), (10, 23, 'love'), (12, 23, 'like'),
-- Post 25 (anniversary): 4 reactions
(7, 25, 'like'), (11, 25, 'wow'), (9, 25, 'like'), (13, 25, 'love'),
-- Post 34 (pup trick): 6 reactions
(2, 34, 'love'), (3, 34, 'love'), (1, 34, 'haha'), (5, 34, 'like'),
(7, 34, 'love'), (8, 34, 'wow'),
-- Post 32 (open source): 3 reactions
(4, 32, 'like'), (6, 32, 'wow'), (10, 32, 'like'),
-- Post 35 (pitch deck): 3 reactions
(1, 35, 'love'), (3, 35, 'wow'), (7, 35, 'like');

-- Groups
INSERT INTO `groups` (name, description, privacy, created_by) VALUES
('Tech Enthusiasts', 'For people who love technology and coding', 'public', 2),
('Foodies United', 'Share recipes, restaurant reviews, and food photos', 'public', 3),
('Fitness & Health', 'Workout tips, nutrition advice, and motivation', 'public', 5),
('Book Club', 'Monthly book discussions and recommendations', 'private', 6),
('Startup Founders', 'Private group for startup founders to share experiences', 'private', 1);

-- Group Members
INSERT INTO group_members (group_id, user_id, role) VALUES
-- Tech Enthusiasts (group 1)
(1, 2, 'admin'), (1, 1, 'member'), (1, 4, 'member'), (1, 6, 'moderator'),
(1, 8, 'member'), (1, 10, 'member'), (1, 12, 'member'),
-- Foodies United (group 2)
(2, 3, 'admin'), (2, 1, 'member'), (2, 5, 'member'), (2, 7, 'moderator'),
(2, 9, 'member'), (2, 11, 'member'), (2, 13, 'member'),
-- Fitness & Health (group 3)
(3, 5, 'admin'), (3, 1, 'member'), (3, 3, 'member'), (3, 10, 'moderator'),
(3, 14, 'member'),
-- Book Club (group 4)
(4, 6, 'admin'), (4, 9, 'member'), (4, 11, 'member'), (4, 13, 'moderator'),
(4, 15, 'member'),
-- Startup Founders (group 5)
(5, 1, 'admin'), (5, 5, 'member'), (5, 11, 'member');

-- Group Posts
INSERT INTO group_posts (group_id, user_id, body, created_at) VALUES
(1, 2, 'Has anyone tried the new M4 MacBook? Thoughts?', '2024-03-10 10:00:00'),
(1, 4, 'Just deployed my first React app!', '2024-03-12 14:00:00'),
(1, 6, 'Great article on AI ethics', '2024-03-14 09:00:00'),
(1, 8, 'Looking for recommendations on a mechanical keyboard', '2024-03-15 11:00:00'),
(1, 10, 'Python vs JavaScript for beginners?', '2024-03-18 16:00:00'),
(2, 3, 'Best pizza place in town? I found a new spot!', '2024-03-08 12:00:00'),
(2, 7, 'Made homemade bread today for the first time', '2024-03-10 15:00:00'),
(2, 11, 'Recipe exchange: share your best dishes!', '2024-03-14 18:00:00'),
(2, 1, 'Tried a new Korean BBQ place — amazing!', '2024-03-16 20:00:00'),
(2, 13, 'Meal prep Sunday 🥘', '2024-03-17 14:00:00'),
(3, 5, '30-day plank challenge — who is in?', '2024-03-01 06:00:00'),
(3, 1, 'Finished my first 5K this morning!', '2024-03-05 07:00:00'),
(3, 10, 'New running shoes recommendation?', '2024-03-10 08:00:00'),
(3, 14, 'Morning yoga routine for beginners', '2024-03-15 06:00:00'),
(4, 6, 'This month: "The Midnight Library" by Matt Haig', '2024-03-01 10:00:00'),
(4, 9, 'Just finished — loved the concept!', '2024-03-10 12:00:00'),
(4, 15, 'My review: 4/5 stars. Great exploration of regret.', '2024-03-12 14:00:00'),
(5, 1, 'Fundraising tips for seed round?', '2024-03-05 11:00:00'),
(5, 5, 'We just closed our pre-seed! $500K 🎉', '2024-03-10 15:00:00'),
(5, 11, 'Best pitch deck template I found', '2024-03-15 10:00:00');

-- Events
INSERT INTO events (name, description, location, start_time, end_time, created_by, privacy) VALUES
('Tech Meetup: AI in 2024', 'Discussion on the latest AI trends', 'Convention Center, Room 101', '2024-04-15 18:00:00', '2024-04-15 21:00:00', 2, 'public'),
('Food Festival Downtown', 'Annual food festival with 50+ vendors', 'City Park', '2024-05-01 10:00:00', '2024-05-01 18:00:00', 3, 'public'),
('Marathon Training Group', 'Weekly training sessions for the city marathon', 'Central Park Track', '2024-04-01 06:00:00', '2024-04-01 08:00:00', 1, 'public'),
('Startup Pitch Night', '10 startups pitch to investors', 'Innovation Hub', '2024-04-20 19:00:00', '2024-04-20 22:00:00', 5, 'private');

-- Event Attendees
INSERT INTO event_attendees (event_id, user_id, status) VALUES
(1, 2, 'going'), (1, 1, 'going'), (1, 4, 'going'), (1, 6, 'interested'), (1, 8, 'going'),
(1, 10, 'going'), (1, 12, 'interested'),
(2, 3, 'going'), (2, 1, 'going'), (2, 5, 'interested'), (2, 7, 'going'), (2, 9, 'going'),
(2, 11, 'going'), (2, 13, 'going'), (2, 15, 'going'),
(3, 1, 'going'), (3, 5, 'going'), (3, 10, 'going'), (3, 3, 'interested'), (3, 7, 'going'),
(3, 14, 'going'),
(4, 5, 'going'), (4, 1, 'going'), (4, 11, 'going'), (4, 2, 'interested');

-- Photos (linked to photo-type posts)
INSERT INTO photos (post_id, url, caption) VALUES
(2, 'https://photos.fb/sunset_beach.jpg', 'Sunset at the beach'),
(4, 'https://photos.fb/coffee_code.jpg', 'My workspace'),
(6, 'https://photos.fb/hiking_trip.jpg', 'Mountain trail views'),
(7, 'https://photos.fb/puppy_max.jpg', 'Meet Max! 🐕'),
(10, 'https://photos.fb/office_team.jpg', 'Team day'),
(14, 'https://photos.fb/pasta_homemade.jpg', 'Homemade fettuccine'),
(15, 'https://photos.fb/garden_spring.jpg', 'First tomatoes!'),
(16, 'https://photos.fb/vacation.jpg', 'Last summer memories'),
(19, 'https://photos.fb/brunch.jpg', 'Sunday vibes'),
(22, 'https://photos.fb/mountains.jpg', 'Mountain views'),
(23, 'https://photos.fb/first_day.jpg', 'Campus day 1'),
(24, 'https://photos.fb/study_group.jpg', 'Finals prep'),
(28, 'https://photos.fb/city_explorer.jpg', 'New neighborhood'),
(33, 'https://photos.fb/farmers_market.jpg', 'Fresh produce'),
(34, 'https://photos.fb/max_trick.jpg', 'Max can shake now! 🐾'),
(40, 'https://photos.fb/new_bike.jpg', 'My new ride 🚴');

-- Messages
INSERT INTO messages (sender_id, receiver_id, body, sent_at) VALUES
(1, 2, 'Hey Bob, congrats on the Google job!', '2024-01-20 13:00:00'),
(2, 1, 'Thanks Alice! Still processing it 😄', '2024-01-20 13:05:00'),
(1, 2, 'You totally deserve it. Dinner to celebrate?', '2024-01-20 13:10:00'),
(2, 1, 'Sounds great! Next week?', '2024-01-20 13:15:00'),
(1, 2, 'Thursday works for me!', '2024-01-20 13:20:00'),
-- Eve and Alice discussing startup
(1, 5, 'Eve, I saw your startup announcement! Amazing!', '2024-02-01 12:00:00'),
(5, 1, 'Thanks Alice! Want to be a beta tester?', '2024-02-01 12:30:00'),
(1, 5, 'Absolutely! Send me the link', '2024-02-01 12:35:00'),
(5, 1, 'Sent! Let me know what you think', '2024-02-01 12:40:00'),
(1, 5, 'Love the UI. One suggestion: add dark mode', '2024-02-02 09:00:00'),
(5, 1, 'Already working on it! 😊', '2024-02-02 09:15:00'),
-- Ivy and Carol
(3, 9, 'Ivy, any luck with the job search?', '2024-03-13 10:00:00'),
(9, 3, 'A few interviews but nothing yet 😔', '2024-03-13 10:30:00'),
(3, 9, 'Keep going! You will find something great', '2024-03-13 10:35:00'),
(9, 3, 'Thanks Carol, I appreciate it ❤️', '2024-03-13 10:40:00'),
-- David and Frank
(4, 6, 'Max learned to shake! Video coming soon', '2024-03-17 19:00:00'),
(6, 4, 'That is so cute! Dogs are the best', '2024-03-17 19:15:00'),
-- Bob and Alice open source
(2, 1, 'Alice, want to contribute to my open source project?', '2024-03-19 16:00:00'),
(1, 2, 'Sure! What is the repo?', '2024-03-19 16:10:00'),
(2, 1, 'github.com/bob/ai-toolkit. Need help with the docs', '2024-03-19 16:15:00'),
(1, 2, 'On it! I will add some examples', '2024-03-19 16:20:00'),
-- Grace and Ivy
(7, 9, 'Grace, how is the new job?', '2024-02-05 14:00:00'),
(9, 7, 'Great! Still learning the ropes', '2024-02-05 14:30:00'),
(7, 9, 'You will do great. Want to grab coffee?', '2024-02-05 14:35:00'),
(9, 7, 'Would love to! This weekend?', '2024-02-05 14:40:00'),
(7, 9, 'Saturday at 2pm?', '2024-02-05 14:45:00');

-- ============================================================
-- SOLUTION QUERIES
-- ============================================================

-- 1. User Directory
SELECT
    user_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    joined_at
FROM users
WHERE is_active = 1
ORDER BY joined_at DESC;

-- 2. Friend Count
SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    COUNT(*) AS friend_count
FROM users u
JOIN friendships f ON u.user_id = f.requester_id
WHERE f.status = 'accepted'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY friend_count DESC;

-- 3. Post Feed (public posts only)
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS author,
    p.body,
    p.created_at,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.post_id) AS reaction_count
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.privacy = 'public'
ORDER BY p.created_at DESC;

-- 4. Pending Friend Requests (for user_id = 1)
SELECT
    CASE
        WHEN f.requester_id = 1 THEN 'outgoing'
        ELSE 'incoming'
    END AS direction,
    CONCAT(u.first_name, ' ', u.last_name) AS other_user,
    f.created_at
FROM friendships f
JOIN users u ON (
    CASE WHEN f.requester_id = 1 THEN f.addressee_id ELSE f.requester_id END
) = u.user_id
WHERE f.status = 'pending' AND (f.requester_id = 1 OR f.addressee_id = 1)
ORDER BY f.created_at DESC;

-- 5. Most Popular Posts
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS author,
    LEFT(p.body, 50) AS preview,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.post_id) AS reaction_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.post_id) AS comment_count
FROM posts p
JOIN users u ON p.user_id = u.user_id
ORDER BY reaction_count DESC
LIMIT 10;

-- 6. Group Activity
SELECT
    g.name AS group_name,
    g.privacy,
    COUNT(DISTINCT gm.user_id) AS member_count,
    COUNT(gp.gpost_id) AS post_count,
    MAX(gp.created_at) AS last_post_date
FROM `groups` g
LEFT JOIN group_members gm ON g.group_id = gm.group_id
LEFT JOIN group_posts gp ON g.group_id = gp.group_id
GROUP BY g.group_id, g.name, g.privacy
ORDER BY post_count DESC;

-- 7. Event RSVPs
SELECT
    e.name AS event_name,
    e.start_time,
    SUM(CASE WHEN ea.status = 'going' THEN 1 ELSE 0 END) AS going,
    SUM(CASE WHEN ea.status = 'interested' THEN 1 ELSE 0 END) AS interested,
    SUM(CASE WHEN ea.status = 'not_going' THEN 1 ELSE 0 END) AS not_going
FROM events e
LEFT JOIN event_attendees ea ON e.event_id = ea.event_id
GROUP BY e.event_id, e.name, e.start_time
ORDER BY e.start_time;

-- 8. Mutual Friends (user 1 and user 2)
WITH user1_friends AS (
    SELECT CASE WHEN requester_id = 1 THEN addressee_id ELSE requester_id END AS friend_id
    FROM friendships WHERE status = 'accepted' AND (requester_id = 1 OR addressee_id = 1)
),
user2_friends AS (
    SELECT CASE WHEN requester_id = 2 THEN addressee_id ELSE requester_id END AS friend_id
    FROM friendships WHERE status = 'accepted' AND (requester_id = 2 OR addressee_id = 2)
)
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS mutual_friend,
    u1f.friend_id AS friend_of_1,
    u2f.friend_id AS friend_of_2
FROM user1_friends u1f
JOIN user2_friends u2f ON u1f.friend_id = u2f.friend_id
JOIN users u ON u1f.friend_id = u.user_id;

-- 9. Most Active Groups
SELECT
    g.name AS group_name,
    COUNT(DISTINCT gm.user_id) AS member_count,
    COUNT(gp.gpost_id) AS post_count,
    ROUND(COUNT(gp.gpost_id) / NULLIF(COUNT(DISTINCT gm.user_id), 0), 2) AS posts_per_member
FROM `groups` g
JOIN group_members gm ON g.group_id = gm.group_id
LEFT JOIN group_posts gp ON g.group_id = gp.group_id
GROUP BY g.group_id, g.name
HAVING posts_per_member > 0.5
ORDER BY posts_per_member DESC;

-- 10. Reaction Breakdown per User
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS author,
    SUM(CASE WHEN r.reaction_type = 'like' THEN 1 ELSE 0 END) AS likes,
    SUM(CASE WHEN r.reaction_type = 'love' THEN 1 ELSE 0 END) AS loves,
    SUM(CASE WHEN r.reaction_type = 'haha' THEN 1 ELSE 0 END) AS hahas,
    SUM(CASE WHEN r.reaction_type = 'wow' THEN 1 ELSE 0 END) AS wows,
    SUM(CASE WHEN r.reaction_type = 'sad' THEN 1 ELSE 0 END) AS sads,
    SUM(CASE WHEN r.reaction_type = 'angry' THEN 1 ELSE 0 END) AS angries,
    COUNT(DISTINCT r.post_id) AS posts_with_reactions
FROM users u
JOIN posts p ON u.user_id = p.user_id
LEFT JOIN reactions r ON p.post_id = r.post_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY likes + loves + hahas + wows + sads + angries DESC;

-- 11. Inactive Users
SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user,
    u.joined_at
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN comments c ON u.user_id = c.user_id
LEFT JOIN reactions r ON u.user_id = r.user_id
WHERE u.joined_at < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
  AND u.is_active = 1
  AND p.post_id IS NULL
  AND c.comment_id IS NULL
  AND r.user_id IS NULL;

-- 12. Photo Engagement
WITH photo_posts AS (
    SELECT DISTINCT post_id FROM photos
),
post_stats AS (
    SELECT
        p.post_id,
        CASE WHEN pp.post_id IS NOT NULL THEN 'with_photo' ELSE 'without_photo' END AS has_photo,
        (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.post_id) AS reactions
    FROM posts p
    LEFT JOIN photo_posts pp ON p.post_id = pp.post_id
    WHERE p.privacy = 'public'
)
SELECT
    has_photo,
    COUNT(*) AS post_count,
    ROUND(AVG(reactions), 2) AS avg_reactions
FROM post_stats
GROUP BY has_photo;

-- 13. Conversation Depth
SELECT
    CONCAT(sender.first_name, ' ', sender.last_name) AS user1,
    CONCAT(receiver.first_name, ' ', receiver.last_name) AS user2,
    COUNT(*) AS message_count,
    MIN(m.sent_at) AS first_message,
    MAX(m.sent_at) AS last_message,
    CONCAT(
        CONCAT(
            CASE
                WHEN sender_msg.cnt > receiver_msg.cnt THEN sender.first_name
                ELSE receiver.first_name
            END
        ),
        ' sent most (',
        GREATEST(sender_msg.cnt, receiver_msg.cnt),
        ' messages)'
    ) AS most_active
FROM (SELECT DISTINCT LEAST(sender_id, receiver_id) AS u1, GREATEST(sender_id, receiver_id) AS u2 FROM messages) conv
JOIN messages m ON (m.sender_id = conv.u1 AND m.receiver_id = conv.u2) OR (m.sender_id = conv.u2 AND m.receiver_id = conv.u1)
JOIN users sender ON conv.u1 = sender.user_id
JOIN users receiver ON conv.u2 = receiver.user_id
JOIN (SELECT sender_id, COUNT(*) AS cnt FROM messages GROUP BY sender_id) sender_msg ON sender_msg.sender_id = conv.u1
JOIN (SELECT sender_id, COUNT(*) AS cnt FROM messages GROUP BY sender_id) receiver_msg ON receiver_msg.sender_id = conv.u2
GROUP BY conv.u1, conv.u2, sender.first_name, sender.last_name, receiver.first_name, receiver.last_name, sender_msg.cnt, receiver_msg.cnt
ORDER BY message_count DESC;

-- 14. Group Admin Report
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS admin_name,
    g.name AS group_name,
    (SELECT COUNT(*) FROM group_members WHERE group_id = g.group_id) AS member_count,
    CASE
        WHEN MAX(gp.created_at) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 'Yes'
        ELSE 'No'
    END AS has_recent_posts
FROM group_members gm
JOIN `groups` g ON gm.group_id = g.group_id
JOIN users u ON gm.user_id = u.user_id
LEFT JOIN group_posts gp ON g.group_id = gp.group_id
WHERE gm.role = 'admin'
GROUP BY gm.user_id, g.group_id, u.first_name, u.last_name, g.name
ORDER BY admin_name, g.name;

-- 15. BONUS: Social Graph (2 degrees from user 1)
WITH RECURSIVE social_graph AS (
    -- Degree 1: direct friends
    SELECT
        CASE WHEN requester_id = 1 THEN addressee_id ELSE requester_id END AS friend_id,
        1 AS degree,
        CONCAT(
            (SELECT first_name FROM users WHERE user_id = 1), ' ',
            (SELECT last_name FROM users WHERE user_id = 1),
            ' → ',
            (SELECT CONCAT(first_name, ' ', last_name) FROM users
             WHERE user_id = CASE WHEN requester_id = 1 THEN addressee_id ELSE requester_id END)
        ) AS path,
        CAST(CASE WHEN requester_id = 1 THEN addressee_id ELSE requester_id END AS CHAR(200)) AS visited
    FROM friendships
    WHERE status = 'accepted' AND (requester_id = 1 OR addressee_id = 1)

    UNION ALL

    -- Degree 2: friends of friends
    SELECT
        CASE WHEN f.requester_id = sg.friend_id THEN f.addressee_id ELSE f.requester_id END AS friend_id,
        2 AS degree,
        CONCAT(sg.path, ' → ',
            (SELECT CONCAT(first_name, ' ', last_name) FROM users
             WHERE user_id = CASE WHEN f.requester_id = sg.friend_id THEN f.addressee_id ELSE f.requester_id END)
        ) AS path,
        CONCAT(sg.visited, ',',
            CASE WHEN f.requester_id = sg.friend_id THEN f.addressee_id ELSE f.requester_id END
        ) AS visited
    FROM social_graph sg
    JOIN friendships f ON (
        (f.requester_id = sg.friend_id OR f.addressee_id = sg.friend_id)
        AND f.status = 'accepted'
    )
    WHERE sg.degree = 1
      AND sg.friend_id != 1
      AND CASE WHEN f.requester_id = sg.friend_id THEN f.addressee_id ELSE f.requester_id END != 1
      AND FIND_IN_SET(
          CASE WHEN f.requester_id = sg.friend_id THEN f.addressee_id ELSE f.requester_id END,
          sg.visited
      ) = 0
)
SELECT DISTINCT
    CONCAT(u.first_name, ' ', u.last_name) AS person,
    sg.degree,
    sg.path
FROM social_graph sg
JOIN users u ON sg.friend_id = u.user_id
WHERE sg.friend_id != 1
ORDER BY sg.degree, person;

-- 16. BONUS: Content Virality Score
WITH post_reactions AS (
    SELECT post_id, COUNT(*) AS reaction_count FROM reactions GROUP BY post_id
),
post_comments AS (
    SELECT post_id, COUNT(*) AS comment_count FROM comments GROUP BY post_id
),
post_photos AS (
    SELECT DISTINCT post_id FROM photos
),
non_friend_reactions AS (
    SELECT
        r.post_id,
        COUNT(DISTINCT r.user_id) AS non_friend_reactors
    FROM reactions r
    JOIN posts p ON r.post_id = p.post_id
    LEFT JOIN friendships f ON (
        (f.requester_id = p.user_id AND f.addressee_id = r.user_id) OR
        (f.addressee_id = p.user_id AND f.requester_id = r.user_id)
    ) AND f.status = 'accepted'
    WHERE f.requester_id IS NULL  -- Not a friend
      AND r.user_id != p.user_id  -- Not the author
    GROUP BY r.post_id
),
early_momentum AS (
    SELECT
        post_id
    FROM reactions
    WHERE created_at <= (
        SELECT DATE_ADD(created_at, INTERVAL 1 HOUR) FROM posts p2 WHERE p2.post_id = reactions.post_id
    )
    GROUP BY post_id
    HAVING COUNT(*) >= 5
)
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS author,
    LEFT(p.body, 50) AS preview,
    COALESCE(pr.reaction_count, 0) AS reactions,
    COALESCE(pc.comment_count, 0) AS comments,
    COALESCE(pr.reaction_count, 0) * 1 + COALESCE(pc.comment_count, 0) * 3 AS base_score,
    COALESCE(nfr.non_friend_reactors, 0) * 10 AS non_friend_bonus,
    CASE WHEN pp.post_id IS NOT NULL THEN 5 ELSE 0 END AS photo_bonus,
    CASE WHEN em.post_id IS NOT NULL THEN 20 ELSE 0 END AS momentum_bonus,
    COALESCE(pr.reaction_count, 0) * 1 + COALESCE(pc.comment_count, 0) * 3
    + COALESCE(nfr.non_friend_reactors, 0) * 10
    + CASE WHEN pp.post_id IS NOT NULL THEN 5 ELSE 0 END
    + CASE WHEN em.post_id IS NOT NULL THEN 20 ELSE 0 END
    AS virality_score
FROM posts p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN post_reactions pr ON p.post_id = pr.post_id
LEFT JOIN post_comments pc ON p.post_id = pc.post_id
LEFT JOIN post_photos pp ON p.post_id = pp.post_id
LEFT JOIN non_friend_reactions nfr ON p.post_id = nfr.post_id
LEFT JOIN early_momentum em ON p.post_id = em.post_id
ORDER BY virality_score DESC
LIMIT 10;

-- 17. BONUS: Friendship Network Centrality
WITH friends_of AS (
    SELECT
        u1.user_id AS center_user,
        CASE WHEN f.requester_id = u1.user_id THEN f.addressee_id ELSE f.requester_id END AS friend
    FROM users u1
    JOIN friendships f ON (f.requester_id = u1.user_id OR f.addressee_id = u1.user_id)
    WHERE f.status = 'accepted'
),
friend_pairs AS (
    SELECT
        fo1.center_user,
        fo1.friend AS friend_a,
        fo2.friend AS friend_b
    FROM friends_of fo1
    JOIN friends_of fo2 ON fo1.center_user = fo2.center_user AND fo1.friend < fo2.friend
)
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS user,
    COUNT(DISTINCT CONCAT(LEAST(fp.friend_a, fp.friend_b), '-', GREATEST(fp.friend_a, fp.friend_b))) AS unique_friend_pairs,
    COUNT(DISTINCT fp.friend_a) AS friends_count
FROM friend_pairs fp
JOIN users u ON fp.center_user = u.user_id
GROUP BY fp.center_user, u.first_name, u.last_name
ORDER BY unique_friend_pairs DESC;

-- ============================================================
-- ADVANCED FEATURES (Milestone 4)
-- ============================================================

-- 1. View: Active Feed for user_id = 1
CREATE OR REPLACE VIEW active_feed AS
-- Own posts
SELECT
    p.post_id,
    p.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS author,
    p.body,
    p.created_at,
    'own_post' AS source
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.user_id = 1 AND p.privacy IN ('public', 'friends', 'only_me')

UNION ALL

-- Friends' public posts
SELECT
    p.post_id,
    p.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS author,
    p.body,
    p.created_at,
    'friend_post' AS source
FROM posts p
JOIN users u ON p.user_id = u.user_id
JOIN friendships f ON (
    (f.requester_id = 1 AND f.addressee_id = p.user_id) OR
    (f.addressee_id = 1 AND f.requester_id = p.user_id)
) AND f.status = 'accepted'
WHERE p.privacy IN ('public', 'friends')

UNION ALL

-- Group posts
SELECT
    gp.gpost_id + 1000 AS post_id,
    gp.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS author,
    gp.body,
    gp.created_at,
    'group_post' AS source
FROM group_posts gp
JOIN users u ON gp.user_id = u.user_id
JOIN group_members gm ON gp.group_id = gm.group_id
WHERE gm.user_id = 1

ORDER BY created_at DESC;

SELECT * FROM active_feed;

-- 2. Stored Procedure: Send Friend Request
DELIMITER //
CREATE PROCEDURE send_friend_request(
    IN p_requester_id INT,
    IN p_addressee_id INT
)
BEGIN
    DECLARE existing_count INT DEFAULT 0;

    -- Check no existing relationship
    SELECT COUNT(*) INTO existing_count
    FROM friendships
    WHERE (requester_id = p_requester_id AND addressee_id = p_addressee_id)
       OR (requester_id = p_addressee_id AND addressee_id = p_requester_id);

    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Friendship already exists between these users';
    END IF;

    IF p_requester_id = p_addressee_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot send friend request to yourself';
    END IF;

    INSERT INTO friendships (requester_id, addressee_id, status)
    VALUES (p_requester_id, p_addressee_id, 'pending');
END //
DELIMITER ;

-- Test:
CALL send_friend_request(14, 15);  -- Success
-- CALL send_friend_request(1, 2);  -- Error: already friends

-- 3. Trigger: Prevent self-reaction
DELIMITER //
CREATE TRIGGER prevent_self_reaction
BEFORE INSERT ON reactions
FOR EACH ROW
BEGIN
    DECLARE post_author INT;
    SELECT user_id INTO post_author FROM posts WHERE post_id = NEW.post_id;
    IF post_author = NEW.user_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot react to your own post';
    END IF;
END //
DELIMITER ;

-- Test:
-- INSERT INTO reactions (user_id, post_id, reaction_type) VALUES (1, 1, 'like');
-- ERROR: You cannot react to your own post

-- 4. Index Strategy
-- Index for friend lookup
CREATE INDEX idx_friendships_status ON friendships(status, requester_id, addressee_id);

-- Index for post reactions
CREATE INDEX idx_reactions_post ON reactions(post_id);

-- Index for post comments
CREATE INDEX idx_comments_post ON comments(post_id);

-- Index for group posts lookup
CREATE INDEX idx_group_posts_group ON group_posts(group_id, created_at);

-- Index for messages between users
CREATE INDEX idx_messages_pair ON messages(sender_id, receiver_id, sent_at);

-- Verify with EXPLAIN
EXPLAIN SELECT * FROM friendships WHERE status = 'accepted' AND requester_id = 1;
EXPLAIN SELECT * FROM reactions WHERE post_id = 1;
EXPLAIN SELECT * FROM comments WHERE post_id = 1;
