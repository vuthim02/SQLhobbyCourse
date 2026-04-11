# Project: YouTube Database
## Intermediate/Advanced Level — Weeks 1-5 Skills

---

## OVERVIEW

Design and build a complete database schema that models the YouTube platform. You will model users, channels, videos, comments, likes, subscriptions, playlists, and view history. Then write analytics queries that mirror real YouTube reporting.

**Skills tested:** Schema design, M:N relationships, self-referencing tables, complex JOINs, window functions, CTEs, aggregations, CASE WHEN, subqueries.

---

## MILESTONE 1: Schema Design (Day 1-2)

### Required Entities

Your schema must support:

| Entity | Key Attributes |
|--------|---------------|
| **Users** | username, email, display_name, avatar_url, created_at, is_verified |
| **Channels** | channel_name, description, created_at, subscriber_count (denormalized) |
| **Videos** | title, description, upload_date, duration, views, privacy (public/unlisted/private) |
| **Comments** | body, created_at, likes, reply_to (self-referencing for nested comments) |
| **Likes/Dislikes** | User can like/dislike a video (one per user per video) |
| **Subscriptions** | User subscribes to channel, subscribed_at |
| **Playlists** | name, description, created_at |
| **Playlist_Videos** | Videos in a playlist with position/order |
| **View_History** | User watched a video at a specific time, for how long |
| **Tags** | Video tags (M:N between videos and tags) |

### Design Requirements
- A user can own exactly one channel (1:1)
- A channel can have many videos (1:N)
- A video can have many comments (1:N, self-referencing for replies)
- A user can subscribe to many channels; a channel has many subscribers (M:N)
- A video can be in many playlists; a playlist has many videos (M:N with position)
- A video can have many tags; a tag applies to many videos (M:N)
- Proper FK constraints with appropriate ON DELETE behavior
- UNIQUE constraints where appropriate (username, email)

### Deliverable
Create `schema.sql` — all CREATE TABLE statements.

---

## MILESTONE 2: Seed Data (Day 2-3)

Insert realistic data:
- **10 users** with realistic usernames and emails
- **8 channels** (one user has no channel, one user has 2 channels — wait, 1:1 means max 1)
- **25 videos** across channels, with varying view counts (0 to 10M+)
- **40+ comments** (including at least 10 reply-to-parent comments)
- **50+ subscriptions**
- **8 playlists** with 3-5 videos each
- **30+ view history** records
- **15 tags** assigned to videos

### Deliverable
Create `seed.sql` — all INSERT statements.

---

## MILESTONE 3: Reporting Queries (Day 3-5)

Create `queries.sql` with solutions to ALL of the following:

### Basic Queries ⭐

1. **Channel Directory** — List all channels with owner username, subscriber count, and video count, sorted by subscriber count descending.

2. **Video Catalog** — List all public videos with channel name, upload date, duration, and views, sorted by views descending.

3. **User Subscriptions** — For a given user, list all channels they're subscribed to, with subscription date and channel video count.

### Intermediate Queries ⭐⭐

4. **Video Engagement Report** — For each video, show: title, views, like_count, dislike_count, comment_count, and engagement_rate = (likes + comments) / views * 100.

5. **Top Creators** — Find the top 5 channels by total views across all their videos. Show channel name, total views, video count, and average views per video.

6. **Most Popular Tags** — Find the top 10 most-used tags. Show tag name and the number of videos using it.

7. **Comment Leaders** — Find users who have made the most comments. Show display_name, comment count, and the number of distinct videos they've commented on.

### Advanced Queries ⭐⭐⭐

8. **Trending Videos** — Find videos uploaded in the last 30 days (use CURDATE()) with more views than the channel's average views per video. Show title, channel, views, and channel average.

9. **Subscriber Growth** — For each channel, show the number of new subscribers per month (use DATE_FORMAT on subscribed_at).

10. **Binge-Watch Detection** — Find users who watched 3 or more videos from the same channel within a 24-hour window. Show username, channel, and count.

11. **Video Performance Over Time** — For each video, calculate views per day since upload: views / DATEDIFF(CURDATE(), upload_date). Find the top 10 by this metric.

12. **Comment Thread** — For a given video, show all top-level comments with their reply count (self-join on comments). Show comment author, body, created_at, and number of replies.

13. **Playlist Completion** — Find users who have viewed every video in at least one of their playlists. Show username, playlist name, and video count.

14. **Cross-Channel Analysis** — Find users who are subscribed to channels owned by other users they ALSO watch. Show the user, the channel they're subscribed to, and how many times they've watched that channel's videos.

### Bonus Challenge ⭐⭐⭐⭐

15. **Creator Revenue Estimate** — Estimate revenue for each channel:
    - $3 per 1000 views (CPM)
    - Bonus $0.50 per 100 likes
    - Show channel name, total views, estimated ad revenue, estimated like bonus, and total estimated revenue.
    - Rank channels by estimated revenue.

16. **Video Recommendation Engine** — For a given video, find the top 5 "recommended" videos based on:
    - Same tags (weight: 3 points per shared tag)
    - Same channel (weight: 5 points)
    - Commented by users who also commented on the target video (weight: 2 points per shared commenter)
    - Show recommended video title, score breakdown, and total score, ordered by score DESC.

---

## MILESTONE 4: Advanced Features (Day 6)

1. Create a view `popular_videos` — all public videos with > 100,000 views
2. Create a stored procedure `subscribe_to_channel(user_id, channel_id)` that:
   - Checks user isn't already subscribed
   - Checks the channel exists
   - Inserts the subscription
   - Updates the channel's denormalized subscriber_count
3. Create a trigger that automatically increments a video's view count when a new row is inserted into view_history
4. Write a query using a window function to show each video's rank by views within its channel

---

## DELIVERABLES CHECKLIST

- [ ] `schema.sql` — All CREATE TABLE statements (runs without errors)
- [ ] `seed.sql` — Realistic data meeting all minimums
- [ ] `queries.sql` — All 16 query solutions with comments
- [ ] `advanced.sql` — Views, procedures, triggers (Milestone 4)
- [ ] `README.md` — Design decisions, ER diagram (ASCII or image)

---

## GRADING RUBRIC

| Criteria | Excellent (5) | Good (3-4) | Needs Work (1-2) |
|----------|--------------|------------|-----------------|
| **Schema Design** | All entities, PKs, FKs, self-references correct | 1-2 relationship issues | Missing major entities or FKs |
| **Seed Data** | Meets all minimums, realistic | Some data missing | Minimal data |
| **Basic Queries** | All 3 correct | 1-2 errors | Most incorrect |
| **Intermediate Queries** | All 4 correct | 2-3 correct | 0-1 correct |
| **Advanced Queries** | 5+ correct | 3-4 correct | 0-2 correct |
| **Bonus** | Both correct and creative | 1 correct | Neither attempted |
| **Advanced Features** | View + procedure + trigger all work | 2 of 3 work | 0-1 work |

---

## GETTING STARTED

```bash
mysql -u root -p
CREATE DATABASE youtube_db;
USE youtube_db;
source schema.sql;
source seed.sql;
source queries.sql;
```

---

## HINTS

- Self-referencing: comments.reply_to references comments.comment_id
- Engagement rate: use NULLIF(views, 0) to avoid division by zero
- For binge-watch detection, use window functions with LAG/LEAD on view timestamps
- The recommendation engine query requires aggregating scores from three different relationship patterns
- For Milestone 4 trigger, use NEW.video_id to update the correct video row

---

**⚠️ Do not look at the solution until you've attempted all queries yourself.**
