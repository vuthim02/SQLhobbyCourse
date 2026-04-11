-- ============================================================
-- YouTube Database — Complete Solution
-- ============================================================

-- ============================================================
-- SCHEMA
-- ============================================================

CREATE DATABASE IF NOT EXISTS youtube_db;
USE youtube_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified TINYINT(1) DEFAULT 0
);

CREATE TABLE channels (
    channel_id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT UNIQUE NOT NULL,
    channel_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subscriber_count INT DEFAULT 0,
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE videos (
    video_id INT PRIMARY KEY AUTO_INCREMENT,
    channel_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    duration_seconds INT,
    views INT UNSIGNED DEFAULT 0,
    privacy ENUM('public', 'unlisted', 'private') DEFAULT 'public',
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE
);

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    video_id INT NOT NULL,
    user_id INT NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reply_to INT NULL,
    FOREIGN KEY (video_id) REFERENCES videos(video_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to) REFERENCES comments(comment_id) ON DELETE CASCADE
);

CREATE TABLE video_likes (
    user_id INT,
    video_id INT,
    like_type ENUM('like', 'dislike') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, video_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES videos(video_id) ON DELETE CASCADE
);

CREATE TABLE subscriptions (
    user_id INT,
    channel_id INT,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, channel_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE
);

CREATE TABLE playlists (
    playlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE playlist_videos (
    playlist_id INT,
    video_id INT,
    position INT NOT NULL,
    PRIMARY KEY (playlist_id, video_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES videos(video_id) ON DELETE CASCADE
);

CREATE TABLE view_history (
    view_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    video_id INT NOT NULL,
    watched_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    watch_duration_seconds INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES videos(video_id) ON DELETE CASCADE
);

CREATE TABLE tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE video_tags (
    video_id INT,
    tag_id INT,
    PRIMARY KEY (video_id, tag_id),
    FOREIGN KEY (video_id) REFERENCES videos(video_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO users (username, email, display_name, is_verified) VALUES
('techguru', 'tech@email.com', 'Tech Guru', 1),
('cookingqueen', 'cook@email.com', 'Cooking Queen', 1),
('fitnessmax', 'fit@email.com', 'Fitness Max', 0),
('gamergod', 'gamer@email.com', 'Gamer God', 1),
('travelbug', 'travel@email.com', 'Travel Bug', 0),
('musiclover', 'music@email.com', 'Music Lover', 1),
('artworld', 'art@email.com', 'Art World', 0),
('sciencefun', 'science@email.com', 'Science Fun', 1),
('bookworm', 'book@email.com', 'Book Worm', 0),
('lifestyle', 'lifestyle@email.com', 'Lifestyle Daily', 0);

INSERT INTO channels (owner_id, channel_name, description, subscriber_count) VALUES
(1, 'Tech Guru Reviews', 'Latest tech reviews and tutorials', 1500000),
(2, 'Cooking Queen Kitchen', 'Delicious recipes from around the world', 800000),
(3, 'Fitness Max Training', 'Workout routines and nutrition tips', 500000),
(4, 'Gamer God Plays', 'Epic gaming sessions and walkthroughs', 2000000),
(5, 'Travel Bug Adventures', 'Explore the world with me', 350000),
(6, 'Music Lover Studio', 'Guitar tutorials and covers', 1200000),
(8, 'Science Fun Lab', 'Fun science experiments explained', 900000);
-- Users 7, 9, 10 have no channels

INSERT INTO videos (channel_id, title, description, upload_date, duration_seconds, views, privacy) VALUES
-- Tech Guru Reviews (channel 1)
(1, 'iPhone 16 Pro Review', 'Full review of the latest iPhone', '2024-09-20 10:00:00', 1200, 2500000, 'public'),
(1, 'Best Laptops 2024', 'Top 10 laptops for every budget', '2024-08-15 14:00:00', 1800, 1800000, 'public'),
(1, 'M4 MacBook Pro First Look', 'First impressions of the new M4', '2024-10-01 09:00:00', 900, 3200000, 'public'),
(1, 'Hidden Features of iOS 18', 'Things Apple didnt tell you', '2024-09-25 16:00:00', 600, 950000, 'public'),
-- Cooking Queen Kitchen (channel 2)
(2, 'Perfect Pasta Carbonara', 'Authentic Italian recipe', '2024-07-10 12:00:00', 720, 4500000, 'public'),
(2, '30-Minute Meal Prep', 'Healthy meals for the week', '2024-08-20 11:00:00', 1500, 1200000, 'public'),
(2, 'Sourdough Bread Tutorial', 'From starter to loaf', '2024-06-15 10:00:00', 2400, 800000, 'public'),
(2, '5 Breakfast Ideas', 'Quick and easy breakfasts', '2024-09-01 08:00:00', 480, 2100000, 'public'),
-- Fitness Max Training (channel 3)
(3, 'Full Body HIIT Workout', '30 min no equipment needed', '2024-09-10 06:00:00', 1800, 3500000, 'public'),
(3, 'Beginner Weight Training', 'Start your gym journey', '2024-08-01 07:00:00', 2100, 600000, 'public'),
(3, 'Yoga for Flexibility', 'Morning stretch routine', '2024-10-05 06:30:00', 1200, 150000, 'public'),
-- Gamer God Plays (channel 4)
(4, 'Elden Ring Boss Guide', 'Beat Malenia easily', '2024-07-20 20:00:00', 3600, 5000000, 'public'),
(4, 'GTA 6 First Look Reaction', 'This looks insane!', '2024-09-15 18:00:00', 1200, 8000000, 'public'),
(4, 'Best Indie Games 2024', 'Hidden gems you missed', '2024-08-25 19:00:00', 2400, 1500000, 'public'),
(4, 'Speedrun World Record', 'Sub 2 hours!', '2024-10-10 21:00:00', 7200, 4000000, 'public'),
-- Travel Bug Adventures (channel 5)
(5, 'Tokyo Street Food Tour', 'Best food in Shibuya', '2024-06-20 15:00:00', 1800, 1100000, 'public'),
(5, 'Budget Travel: Bali', '7 days under $500', '2024-07-15 14:00:00', 2100, 900000, 'public'),
(5, 'Northern Lights in Norway', 'Bucket list experience', '2024-09-28 16:00:00', 1500, 750000, 'public'),
-- Music Lover Studio (channel 6)
(6, 'Learn Guitar in 30 Days', 'Day 1: Basics', '2024-05-01 10:00:00', 1800, 6000000, 'public'),
(6, 'Wonderwall Tutorial', 'Oasis classic', '2024-06-10 11:00:00', 900, 3000000, 'public'),
(6, 'Fingerpicking Patterns', '5 essential patterns', '2024-08-05 10:00:00', 1500, 2000000, 'public'),
-- Science Fun Lab (channel 7)
(8, 'Volcano Experiment', 'Baking soda magic', '2024-07-01 14:00:00', 600, 5000000, 'public'),
(8, 'Why is the Sky Blue?', 'Light scattering explained', '2024-08-10 15:00:00', 900, 3500000, 'public'),
(8, 'DIY Rocket', 'Build a water rocket', '2024-09-20 13:00:00', 1200, 2000000, 'public'),
-- Unlisted/Private videos
(1, 'Unreleased Tech Leaks', 'Embargoed content', '2024-10-12 10:00:00', 600, 50, 'unlisted'),
(4, 'Private Stream VOD', 'Subscriber only', '2024-10-11 22:00:00', 5400, 200, 'private');

INSERT INTO comments (video_id, user_id, body, reply_to) VALUES
-- Comments on iPhone review (video 1)
(1, 2, 'Great review! Very detailed.', NULL),
(1, 3, 'I disagree about the camera, its amazing', 1),
(1, 5, 'Waiting for the Pixel review!', NULL),
(1, 8, 'Thanks for the honest take', 1),
-- Comments on Pasta Carbonara (video 5)
(5, 1, 'Made this last night, turned out perfect!', NULL),
(5, 4, 'My Italian grandmother approves 👨‍🍳', 5),
(5, 6, 'What type of pasta do you recommend?', NULL),
(5, 2, 'Spaghetti or rigatoni work best!', 7),
-- Comments on Elden Ring guide (video 12)
(12, 3, 'This saved me hours of frustration', NULL),
(12, 5, 'The summon strategy is clutch', 9),
(12, 8, 'Still cant beat her after 50 tries 😭', NULL),
(12, 4, 'Keep trying, youll get it! Try the mimic tear', 11),
-- Comments on Guitar tutorial (video 19)
(19, 1, 'Best guitar tutorial on YouTube', NULL),
(19, 7, 'Day 15 and I can already play a few songs!', 13),
(19, 2, 'Your teaching style is so clear', NULL),
-- Comments on Volcano Experiment (video 22)
(22, 5, 'My kids loved this!', NULL),
(22, 3, 'Great science content', 16),
(22, 9, 'Can you do more chemistry experiments?', NULL),
(22, 8, 'Next one: elephant toothpaste!', 18),
-- Reply to reply (nested)
(1, 5, 'Pixel is coming out next month actually', 3),
(5, 1, 'I used spaghetti, it was great', 7),
(12, 3, 'The mimic tear did the trick, thanks!', 12),
-- More comments
(2, 3, 'MacBook is too expensive', NULL),
(2, 8, 'ThinkPad is the way to go', 21),
(3, 2, 'M4 chip is insane!', NULL),
(9, 1, 'This workout destroyed me', NULL),
(9, 6, 'Doing this every morning now', 24),
(10, 8, 'Great form tips for beginners', NULL),
(13, 1, 'GTA 6 is going to be legendary', NULL),
(13, 3, 'Graphics look incredible', 27),
(15, 6, 'Tokyo food scene is unreal', NULL),
(16, 9, 'Adding Bali to my bucket list', NULL),
(17, 4, 'Northern Lights are on my list too!', NULL),
(20, 8, 'Wonderwall is the only song I can play 😂', NULL),
(21, 5, 'Fingerpicking is so satisfying', NULL),
(23, 2, 'The sky explanation was perfect', NULL),
(24, 1, 'Made this with my nephew, he loved it', NULL);

INSERT INTO video_likes (user_id, video_id, like_type) VALUES
-- iPhone review likes
(2, 1, 'like'), (3, 1, 'like'), (5, 1, 'like'), (8, 1, 'like'), (9, 1, 'like'),
(4, 1, 'dislike'),
-- Pasta likes
(1, 5, 'like'), (4, 5, 'like'), (6, 5, 'like'), (8, 5, 'like'), (9, 5, 'like'),
-- Elden Ring likes
(3, 12, 'like'), (5, 12, 'like'), (8, 12, 'like'), (4, 12, 'like'),
-- Guitar tutorial likes
(1, 19, 'like'), (7, 19, 'like'), (2, 19, 'like'), (8, 19, 'like'), (9, 19, 'like'), (5, 19, 'like'),
-- Volcano likes
(5, 22, 'like'), (3, 22, 'like'), (9, 22, 'like'), (8, 22, 'like'),
-- More likes
(3, 2, 'like'), (8, 2, 'like'), (2, 3, 'like'), (1, 3, 'like'),
(1, 9, 'like'), (6, 9, 'like'), (8, 9, 'like'),
(1, 13, 'like'), (3, 13, 'like'),
(6, 15, 'like'),
(4, 20, 'like'),
(2, 23, 'like');

INSERT INTO subscriptions (user_id, channel_id, subscribed_at) VALUES
(2, 1, '2024-01-15 10:00:00'), (2, 2, '2024-02-01 12:00:00'), (2, 6, '2024-03-10 14:00:00'),
(3, 1, '2024-01-20 09:00:00'), (3, 3, '2024-02-15 08:00:00'), (3, 4, '2024-03-01 20:00:00'),
(4, 1, '2024-02-10 11:00:00'), (4, 4, '2024-01-05 19:00:00'),
(5, 1, '2024-03-01 10:00:00'), (5, 2, '2024-03-15 12:00:00'), (5, 5, '2024-04-01 15:00:00'),
(5, 6, '2024-04-15 10:00:00'), (5, 8, '2024-05-01 14:00:00'),
(6, 2, '2024-02-20 11:00:00'), (6, 6, '2024-01-10 10:00:00'),
(7, 8, '2024-03-01 14:00:00'), (7, 5, '2024-04-01 15:00:00'),
(8, 1, '2024-01-10 10:00:00'), (8, 4, '2024-02-01 20:00:00'), (8, 8, '2024-03-15 14:00:00'),
(8, 6, '2024-04-01 10:00:00'),
(9, 2, '2024-04-01 12:00:00'), (9, 5, '2024-05-01 15:00:00'), (9, 8, '2024-06-01 14:00:00'),
(10, 1, '2024-05-01 10:00:00'), (10, 3, '2024-05-15 06:00:00'), (10, 6, '2024-06-01 10:00:00'),
(1, 2, '2024-06-01 12:00:00'), (1, 8, '2024-06-15 14:00:00'), (1, 4, '2024-07-01 20:00:00');

INSERT INTO playlists (user_id, name, description) VALUES
(2, 'Cooking Inspiration', 'Recipes I want to try', NULL),
(3, 'Workout Routines', 'My daily workouts', NULL),
(5, 'Travel Inspiration', 'Places I want to visit', NULL),
(5, 'Food Around the World', 'International food videos', NULL),
(8, 'Science Experiments', 'Fun experiments for kids', NULL),
(1, 'Tech Must-Watch', 'Important tech videos', NULL),
(4, 'Epic Gaming', 'Best gaming content', NULL),
(9, 'Learn Something New', 'Educational videos', NULL);

INSERT INTO playlist_videos (playlist_id, video_id, position) VALUES
-- Cooking Inspiration (playlist 1, user 2)
(1, 5, 1), (1, 6, 2), (1, 7, 3), (1, 8, 4),
-- Workout Routines (playlist 2, user 3)
(2, 9, 1), (2, 10, 2), (2, 11, 3),
-- Travel Inspiration (playlist 3, user 5)
(3, 15, 1), (3, 16, 2), (3, 17, 3),
-- Food Around the World (playlist 4, user 5)
(4, 5, 1), (4, 6, 2), (4, 15, 3),
-- Science Experiments (playlist 5, user 8)
(5, 22, 1), (5, 23, 2), (5, 24, 3),
-- Tech Must-Watch (playlist 6, user 1)
(6, 1, 1), (6, 2, 2), (6, 3, 3), (6, 4, 4),
-- Epic Gaming (playlist 7, user 4)
(7, 12, 1), (7, 13, 2), (7, 14, 3),
-- Learn Something New (playlist 8, user 9)
(8, 22, 1), (8, 23, 2), (8, 19, 3), (8, 1, 4);

INSERT INTO view_history (user_id, video_id, watched_at, watch_duration_seconds) VALUES
-- User 2 binge-watching Tech channel (3 videos in one day)
(2, 1, '2024-09-20 14:00:00', 1100), (2, 2, '2024-09-20 15:30:00', 1700), (2, 3, '2024-09-20 16:30:00', 850),
-- User 5 binge-watching (multiple channels in one day)
(5, 5, '2024-09-21 12:00:00', 700), (5, 6, '2024-09-21 12:45:00', 1400), (5, 15, '2024-09-21 13:30:00', 1700),
(5, 16, '2024-09-21 14:30:00', 2000),
-- Regular viewers
(3, 9, '2024-09-10 07:00:00', 1800), (3, 10, '2024-09-12 07:00:00', 2000),
(4, 12, '2024-09-15 20:00:00', 3600), (4, 13, '2024-09-16 19:00:00', 1200),
(6, 19, '2024-09-01 10:00:00', 1800), (6, 20, '2024-09-05 11:00:00', 850),
(7, 22, '2024-09-20 15:00:00', 550), (7, 23, '2024-09-21 14:00:00', 900),
(8, 1, '2024-09-20 10:30:00', 1150), (8, 12, '2024-09-18 21:00:00', 3500),
(8, 13, '2024-09-19 18:00:00', 1100), (8, 23, '2024-09-20 16:00:00', 850),
(9, 5, '2024-09-10 12:00:00', 700), (9, 22, '2024-09-15 14:00:00', 580),
(9, 19, '2024-09-20 10:00:00', 1750), (9, 1, '2024-09-21 11:00:00', 1100),
(10, 1, '2024-10-01 10:00:00', 900), (10, 9, '2024-10-02 07:00:00', 1750),
(10, 20, '2024-10-03 11:00:00', 850),
(1, 5, '2024-09-15 18:00:00', 720), (1, 22, '2024-09-16 20:00:00', 600),
(1, 12, '2024-09-17 21:00:00', 3500), (1, 13, '2024-09-18 19:00:00', 1200),
(3, 1, '2024-10-05 10:00:00', 1150), (3, 12, '2024-10-05 14:00:00', 3600),
(3, 13, '2024-10-05 15:30:00', 1100),
(2, 5, '2024-10-01 12:00:00', 700), (2, 19, '2024-10-01 14:00:00', 1750),
(5, 1, '2024-10-02 11:00:00', 1100), (5, 2, '2024-10-02 12:00:00', 1600),
(5, 3, '2024-10-02 13:00:00', 800), (5, 4, '2024-10-02 14:00:00', 550);

INSERT INTO tags (tag_name) VALUES
('tech'), ('review'), ('smartphone'), ('laptop'), ('cooking'),
('recipe'), ('italian'), ('fitness'), ('workout'), ('gaming'),
('tutorial'), ('science'), ('experiment'), ('travel'), ('music'),
('guitar'), ('education'), ('howto');

INSERT INTO video_tags (video_id, tag_id) VALUES
(1, 1), (1, 2), (1, 3),  -- iPhone 16: tech, review, smartphone
(2, 1), (2, 2), (2, 4),  -- Laptops: tech, review, laptop
(3, 1), (3, 2), (3, 4),  -- M4 MacBook: tech, review, laptop
(4, 1), (4, 17),          -- iOS 18: tech, howto
(5, 5), (5, 6), (5, 7),  -- Carbonara: cooking, recipe, italian
(6, 5), (6, 6),           -- Meal prep: cooking, recipe
(7, 5), (7, 6),           -- Sourdough: cooking, recipe
(8, 5), (8, 6),           -- Breakfast: cooking, recipe
(9, 8), (9, 9),           -- HIIT: fitness, workout
(10, 8), (10, 9),         -- Weight training: fitness, workout
(11, 8), (11, 9),         -- Yoga: fitness, workout
(12, 10), (12, 17),       -- Elden Ring: gaming, education
(13, 10), (13, 2),        -- GTA 6: gaming, review
(14, 10), (14, 2),        -- Indie games: gaming, review
(15, 10),                 -- Speedrun: gaming
(16, 14), (16, 6),        -- Tokyo: travel, recipe
(17, 14), (17, 17),       -- Bali: travel, howto
(18, 14),                 -- Norway: travel
(19, 15), (19, 16), (19, 11), -- Guitar: music, guitar, tutorial
(20, 15), (20, 16), (20, 11), -- Wonderwall: music, guitar, tutorial
(21, 15), (21, 16), (21, 11), -- Fingerpicking: music, guitar, tutorial
(22, 12), (22, 13), (22, 17), -- Volcano: science, experiment, education
(23, 12), (23, 17),       -- Sky blue: science, education
(24, 12), (24, 13);       -- DIY Rocket: science, experiment

-- ============================================================
-- SOLUTION QUERIES
-- ============================================================

-- 1. Channel Directory
SELECT
    ch.channel_name,
    u.username AS owner,
    ch.subscriber_count,
    COUNT(v.video_id) AS video_count
FROM channels ch
JOIN users u ON ch.owner_id = u.user_id
LEFT JOIN videos v ON ch.channel_id = v.channel_id AND v.privacy = 'public'
GROUP BY ch.channel_id, ch.channel_name, u.username, ch.subscriber_count
ORDER BY ch.subscriber_count DESC;

-- 2. Video Catalog
SELECT
    v.title,
    ch.channel_name,
    DATE(v.upload_date) AS upload_date,
    CONCAT(FLOOR(v.duration_seconds / 60), ':', LPAD(v.duration_seconds % 60, 2, '0')) AS duration,
    v.views
FROM videos v
JOIN channels ch ON v.channel_id = ch.channel_id
WHERE v.privacy = 'public'
ORDER BY v.views DESC;

-- 3. User Subscriptions (user_id = 5)
SELECT
    ch.channel_name,
    s.subscribed_at,
    (SELECT COUNT(*) FROM videos WHERE channel_id = ch.channel_id AND privacy = 'public') AS video_count
FROM subscriptions s
JOIN channels ch ON s.channel_id = ch.channel_id
WHERE s.user_id = 5
ORDER BY s.subscribed_at DESC;

-- 4. Video Engagement Report
SELECT
    v.title,
    v.views,
    COALESCE(lk.like_count, 0) AS like_count,
    COALESCE(dk.dislike_count, 0) AS dislike_count,
    COALESCE(cm.comment_count, 0) AS comment_count,
    ROUND(
        (COALESCE(lk.like_count, 0) + COALESCE(cm.comment_count, 0))
        / NULLIF(v.views, 0) * 100,
    4) AS engagement_rate
FROM videos v
LEFT JOIN (SELECT video_id, COUNT(*) AS like_count FROM video_likes WHERE like_type = 'like' GROUP BY video_id) lk ON v.video_id = lk.video_id
LEFT JOIN (SELECT video_id, COUNT(*) AS dislike_count FROM video_likes WHERE like_type = 'dislike' GROUP BY video_id) dk ON v.video_id = dk.video_id
LEFT JOIN (SELECT video_id, COUNT(*) AS comment_count FROM comments GROUP BY video_id) cm ON v.video_id = cm.video_id
WHERE v.privacy = 'public'
ORDER BY engagement_rate DESC;

-- 5. Top Creators
SELECT
    ch.channel_name,
    SUM(v.views) AS total_views,
    COUNT(v.video_id) AS video_count,
    ROUND(AVG(v.views), 0) AS avg_views_per_video
FROM channels ch
JOIN videos v ON ch.channel_id = v.channel_id
WHERE v.privacy = 'public'
GROUP BY ch.channel_id, ch.channel_name
ORDER BY total_views DESC
LIMIT 5;

-- 6. Most Popular Tags
SELECT
    t.tag_name,
    COUNT(vt.video_id) AS video_count
FROM tags t
JOIN video_tags vt ON t.tag_id = vt.tag_id
GROUP BY t.tag_id, t.tag_name
ORDER BY video_count DESC
LIMIT 10;

-- 7. Comment Leaders
SELECT
    u.display_name,
    COUNT(c.comment_id) AS comment_count,
    COUNT(DISTINCT c.video_id) AS videos_commented
FROM users u
JOIN comments c ON u.user_id = c.user_id
GROUP BY u.user_id, u.display_name
ORDER BY comment_count DESC;

-- 8. Trending Videos
WITH channel_avg AS (
    SELECT
        channel_id,
        AVG(views) AS avg_views
    FROM videos
    WHERE privacy = 'public'
    GROUP BY channel_id
)
SELECT
    v.title,
    ch.channel_name,
    v.views,
    ROUND(ca.avg_views, 0) AS channel_avg_views
FROM videos v
JOIN channels ch ON v.channel_id = ch.channel_id
JOIN channel_avg ca ON v.channel_id = ca.channel_id
WHERE v.privacy = 'public'
  AND v.upload_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  AND v.views > ca.avg_views
ORDER BY v.views DESC;

-- 9. Subscriber Growth
SELECT
    ch.channel_name,
    DATE_FORMAT(s.subscribed_at, '%Y-%m') AS month,
    COUNT(*) AS new_subscribers
FROM subscriptions s
JOIN channels ch ON s.channel_id = ch.channel_id
GROUP BY ch.channel_id, ch.channel_name, month
ORDER BY ch.channel_name, month;

-- 10. Binge-Watch Detection
WITH user_channel_views AS (
    SELECT
        vh.user_id,
        v.channel_id,
        DATE(vh.watched_at) AS watch_date,
        COUNT(*) AS videos_watched
    FROM view_history vh
    JOIN videos v ON vh.video_id = v.video_id
    WHERE vh.watched_at - INTERVAL 1 DAY <= (
        SELECT MAX(watched_at) FROM view_history vh2
        WHERE vh2.user_id = vh.user_id
        AND DATE(vh2.watched_at) = DATE(vh.watched_at)
    )
    GROUP BY vh.user_id, v.channel_id, DATE(vh.watched_at)
    HAVING COUNT(*) >= 3
)
SELECT
    u.username,
    ch.channel_name,
    DATE(uvc.watch_date) AS date,
    uvc.videos_watched
FROM user_channel_views uvc
JOIN users u ON uvc.user_id = u.user_id
JOIN channels ch ON uvc.channel_id = ch.channel_id
ORDER BY uvc.videos_watched DESC;

-- 11. Video Performance Over Time
SELECT
    v.title,
    v.views,
    DATEDIFF(CURDATE(), v.upload_date) AS days_since_upload,
    ROUND(v.views / NULLIF(DATEDIFF(CURDATE(), v.upload_date), 0), 1) AS views_per_day
FROM videos v
WHERE v.privacy = 'public'
ORDER BY views_per_day DESC
LIMIT 10;

-- 12. Comment Thread (video_id = 12)
SELECT
    u.display_name AS commenter,
    c.body,
    c.created_at,
    (SELECT COUNT(*) FROM comments r WHERE r.reply_to = c.comment_id) AS reply_count
FROM comments c
JOIN users u ON c.user_id = u.user_id
WHERE c.video_id = 12 AND c.reply_to IS NULL
ORDER BY reply_count DESC, c.created_at;

-- 13. Playlist Completion
SELECT
    u.username,
    p.name AS playlist_name,
    COUNT(DISTINCT pv.video_id) AS playlist_videos,
    COUNT(DISTINCT vh.video_id) AS videos_watched
FROM users u
JOIN playlists p ON u.user_id = p.user_id
JOIN playlist_videos pv ON p.playlist_id = pv.playlist_id
LEFT JOIN view_history vh ON u.user_id = vh.user_id AND pv.video_id = vh.video_id
GROUP BY u.user_id, p.playlist_id, p.name
HAVING COUNT(DISTINCT vh.video_id) = COUNT(DISTINCT pv.video_id)
ORDER BY playlist_videos DESC;

-- 14. Cross-Channel Analysis
SELECT
    u.display_name AS watcher,
    ch.channel_name,
    COUNT(vh.view_id) AS times_watched
FROM subscriptions s
JOIN users u ON s.user_id = u.user_id
JOIN channels ch ON s.channel_id = ch.channel_id
JOIN videos v ON ch.channel_id = v.channel_id
LEFT JOIN view_history vh ON u.user_id = vh.user_id AND v.video_id = vh.video_id
GROUP BY u.user_id, ch.channel_id, u.display_name, ch.channel_name
HAVING COUNT(vh.view_id) > 0
ORDER BY times_watched DESC;

-- 15. BONUS: Creator Revenue Estimate
SELECT
    ch.channel_name,
    SUM(v.views) AS total_views,
    ROUND(SUM(v.views) / 1000 * 3, 2) AS estimated_ad_revenue,
    COALESCE(lk.total_likes, 0) AS total_likes,
    ROUND(COALESCE(lk.total_likes, 0) / 100 * 0.50, 2) AS estimated_like_bonus,
    ROUND(SUM(v.views) / 1000 * 3 + COALESCE(lk.total_likes, 0) / 100 * 0.50, 2) AS total_estimated_revenue
FROM channels ch
JOIN videos v ON ch.channel_id = v.channel_id
LEFT JOIN (SELECT video_id, COUNT(*) AS total_likes FROM video_likes WHERE like_type = 'like' GROUP BY video_id) lk ON v.video_id = lk.video_id
WHERE v.privacy = 'public'
GROUP BY ch.channel_id, ch.channel_name, lk.total_likes
ORDER BY total_estimated_revenue DESC;

-- 16. BONUS: Video Recommendation Engine (for video_id = 1)
WITH target_tags AS (
    SELECT tag_id FROM video_tags WHERE video_id = 1
),
target_commenters AS (
    SELECT DISTINCT user_id FROM comments WHERE video_id = 1
),
recommendations AS (
    -- Same tags
    SELECT
        vt.video_id AS rec_video_id,
        'shared_tag' AS reason,
        COUNT(*) * 3 AS score
    FROM video_tags vt
    JOIN target_tags tt ON vt.tag_id = tt.tag_id
    WHERE vt.video_id != 1
    GROUP BY vt.video_id

    UNION ALL

    -- Same channel
    SELECT
        v.video_id AS rec_video_id,
        'same_channel' AS reason,
        5 AS score
    FROM videos v
    WHERE v.channel_id = (SELECT channel_id FROM videos WHERE video_id = 1)
      AND v.video_id != 1

    UNION ALL

    -- Shared commenters
    SELECT
        c.video_id AS rec_video_id,
        'shared_commenter' AS reason,
        COUNT(DISTINCT c.user_id) * 2 AS score
    FROM comments c
    JOIN target_commenters tc ON c.user_id = tc.user_id
    WHERE c.video_id != 1
    GROUP BY c.video_id
    HAVING COUNT(DISTINCT c.user_id) > 0
)
SELECT
    v.title,
    v.channel_id,
    SUM(r.score) AS total_score,
    GROUP_CONCAT(DISTINCT r.reason) AS reasons
FROM recommendations r
JOIN videos v ON r.rec_video_id = v.video_id
WHERE v.privacy = 'public'
GROUP BY r.rec_video_id, v.title, v.channel_id
ORDER BY total_score DESC
LIMIT 5;

-- ============================================================
-- ADVANCED FEATURES (Milestone 4)
-- ============================================================

-- 1. View: Popular Videos
CREATE OR REPLACE VIEW popular_videos AS
SELECT
    v.video_id,
    v.title,
    ch.channel_name,
    v.views,
    v.upload_date
FROM videos v
JOIN channels ch ON v.channel_id = ch.channel_id
WHERE v.privacy = 'public' AND v.views > 100000;

SELECT * FROM popular_videos;

-- 2. Stored Procedure: Subscribe to Channel
DELIMITER //
CREATE PROCEDURE subscribe_to_channel(
    IN p_user_id INT,
    IN p_channel_id INT
)
BEGIN
    DECLARE already_subscribed INT DEFAULT 0;
    DECLARE channel_exists INT DEFAULT 0;

    -- Check channel exists
    SELECT COUNT(*) INTO channel_exists FROM channels WHERE channel_id = p_channel_id;
    IF channel_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Channel does not exist';
    END IF;

    -- Check not already subscribed
    SELECT COUNT(*) INTO already_subscribed
    FROM subscriptions WHERE user_id = p_user_id AND channel_id = p_channel_id;
    IF already_subscribed > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Already subscribed to this channel';
    END IF;

    -- Insert subscription
    INSERT INTO subscriptions (user_id, channel_id) VALUES (p_user_id, p_channel_id);

    -- Update denormalized count
    UPDATE channels SET subscriber_count = subscriber_count + 1 WHERE channel_id = p_channel_id;
END //
DELIMITER ;

-- Test it:
CALL subscribe_to_channel(7, 1);  -- Success
-- CALL subscribe_to_channel(7, 1);  -- Error: Already subscribed
-- CALL subscribe_to_channel(7, 999);  -- Error: Channel does not exist

-- 3. Trigger: Auto-increment views on view_history insert
DELIMITER //
CREATE TRIGGER increment_views_on_watch
AFTER INSERT ON view_history
FOR EACH ROW
BEGIN
    UPDATE videos SET views = views + 1 WHERE video_id = NEW.video_id;
END //
DELIMITER ;

-- 4. Window Function: Video rank by views within channel
SELECT
    v.title,
    ch.channel_name,
    v.views,
    RANK() OVER (PARTITION BY v.channel_id ORDER BY v.views DESC) AS rank_in_channel
FROM videos v
JOIN channels ch ON v.channel_id = ch.channel_id
WHERE v.privacy = 'public'
ORDER BY ch.channel_name, rank_in_channel;
