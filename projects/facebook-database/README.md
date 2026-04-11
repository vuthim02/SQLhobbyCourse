# Project: Facebook Database
## Advanced Level — Weeks 3-6 Skills

---

## OVERVIEW

Design and build a database schema that models the core features of Facebook (Meta). You will model users, friendships, posts, reactions, comments, groups, events, photos, and messages. Write complex analytics queries that mirror real social media reporting.

**Skills tested:** Complex M:N relationships, self-referencing tables, recursive queries, window functions, CTEs, transactions, triggers, EXPLAIN optimization.

---

## MILESTONE 1: Schema Design (Day 1-2)

### Required Entities

| Entity | Key Attributes |
|--------|---------------|
| **Users** | username, email, first_name, last_name, dob, gender, joined_at, profile_pic, is_active |
| **Friendships** | requester_id, addressee_id, status (pending/accepted/blocked), created_at |
| **Posts** | user_id, body, created_at, privacy (public/friends/only_me), post_type (text/photo/link) |
| **Comments** | post_id, user_id, body, created_at, parent_id (nested replies) |
| **Reactions** | user_id, post_id, type (like/love/haha/wow/sad/angry) |
| **Groups** | name, description, privacy (public/private/secret), created_by, created_at |
| **Group_Members** | group_id, user_id, role (admin/moderator/member), joined_at |
| **Group_Posts** | Like posts but scoped to a group |
| **Events** | name, description, location, start_time, end_time, created_by, privacy |
| **Event_Attendees** | event_id, user_id, status (going/interested/not_going) |
| **Photos** | post_id, url, caption, uploaded_at |
| **Messages** | sender_id, receiver_id, body, sent_at (direct messaging) |

### Design Requirements
- **Friendship** is a SELF-REFERENCING M:N relationship with status tracking
- A user can create and belong to many groups (M:N with role)
- A user can create and attend many events (M:N with RSVP status)
- **Posts** have a reaction system (users react with emoji types)
- **Comments** support nested replies (self-referencing)
- **Messages** model direct conversations between two users
- Proper FK constraints, UNIQUE constraints, CHECK constraints where applicable

### Deliverable
`schema.sql` — All CREATE TABLE statements.

---

## MILESTONE 2: Seed Data (Day 2-3)

Insert realistic data:
- **15 users** with realistic profiles
- **30+ friendships** (mix of accepted, pending, blocked)
- **40+ posts** (mix of text, photo, link types; various privacy levels)
- **60+ comments** (including 15+ nested replies)
- **80+ reactions** across posts
- **5 groups** with varying membership
- **20+ group posts**
- **4 events** with attendee RSVPs
- **15+ photos** linked to posts
- **25+ messages** between user pairs

### Deliverable
`seed.sql` — All INSERT statements.

---

## MILESTONE 3: Reporting Queries (Day 3-5)

Create `queries.sql` with solutions to ALL of the following:

### Basic Queries ⭐

1. **User Directory** — List all active users with full name, email, join date, sorted by most recently joined.

2. **Friend Count** — For each user, show their accepted friend count, sorted by most friends.

3. **Post Feed** — Show all public posts with author name, post content, creation date, and reaction count, sorted by most recent.

### Intermediate Queries ⭐⭐

4. **Pending Friend Requests** — For a given user (e.g., user_id = 1), show all pending incoming and outgoing friend requests with the other user's name and request date.

5. **Most Popular Posts** — Find the top 10 posts by total reactions (count all reaction types). Show author, post preview (first 50 chars), reaction count, and comment count.

6. **Group Activity** — For each group, show group name, privacy level, member count, post count, and most recent post date.

7. **Event RSVPs** — For each event, show event name, start time, and counts of going, interested, and not_going.

### Advanced Queries ⭐⭐⭐

8. **Mutual Friends** — For two given users (e.g., user_id = 1 and user_id = 2), find all mutual friends. Show friend name and how long ago they became friends with each person.

9. **Most Active Groups** — Find groups where the average posts per member is above 0.5 (active groups). Show group name, member count, post count, and posts-per-member ratio.

10. **Reaction Breakdown** — For each user's posts, show the distribution of reaction types (how many likes, loves, hahas, wows, sads, angries across all their posts).

11. **Inactive Users** — Find users who joined more than 6 months ago but have made 0 posts, 0 comments, and 0 reactions.

12. **Photo Engagement** — For posts that have photos, compare their average reactions to posts without photos. Is there a statistically significant difference?

13. **Conversation Depth** — For each pair of users who have exchanged messages, show the total message count, first message date, last message date, and who sent the most messages.

14. **Group Admin Report** — For each group admin, show which groups they administer, member count of each, and whether the group has had posts in the last 30 days.

### Bonus Challenge ⭐⭐⭐⭐

15. **Social Graph Analysis** — Using a recursive CTE, find all users within 2 degrees of separation from a given user (i.e., their friends AND their friends' friends). Show each user's degree (1 or 2) and the path (e.g., "Alice → Bob → Carol").

16. **Content Virality Score** — Calculate a virality score for each post:
    - Base score = reactions * 1 + comments * 3
    - If post is shared by users who aren't friends with the author: +10 per non-fresharer
    - If post has a photo: +5
    - If post was made within the first hour and got 5+ reactions: +20 (early momentum)
    - Show top 10 posts by virality score with score breakdown.

17. **Friendship Network Centrality** — Using the friendship graph, calculate each user's "betweenness" approximation: count how many unique friend-of-friend paths pass through each user. Show users with the highest network centrality.

---

## MILESTONE 4: Advanced Features (Day 6)

1. Create a view `active_feed` — all posts visible to a specific user (their own posts + friends' posts + group posts from groups they're in), sorted by date.
2. Create a stored procedure `send_friend_request(requester_id, addressee_id)` that validates no existing relationship and creates a pending friendship.
3. Create a trigger that prevents a user from reacting to their own post.
4. Create an index strategy: design and create indexes for the 5 most common query patterns, then verify with EXPLAIN.

---

## DELIVERABLES CHECKLIST

- [ ] `schema.sql` — All CREATE TABLE statements (runs without errors)
- [ ] `seed.sql` — Realistic data meeting all minimums
- [ ] `queries.sql` — All 17 query solutions with comments
- [ ] `advanced.sql` — View + procedure + trigger + indexes (Milestone 4)
- [ ] `README.md` — Design decisions, ER diagram, challenges faced

---

## GRADING RUBRIC

| Criteria | Excellent (5) | Good (3-4) | Needs Work (1-2) |
|----------|--------------|------------|-----------------|
| **Schema Design** | All entities, self-refs, FKs, constraints correct | 1-2 relationship issues | Missing major entities |
| **Seed Data** | Meets all minimums, realistic social patterns | Some data gaps | Minimal data |
| **Basic Queries** | All 3 correct | 1-2 errors | Most incorrect |
| **Intermediate Queries** | All 4 correct | 2-3 correct | 0-1 correct |
| **Advanced Queries** | 5+ correct (mutual friends, virality) | 3-4 correct | 0-2 correct |
| **Bonus (15-17)** | 2+ correct | 1 correct | None attempted |
| **Advanced Features** | All 4 work correctly | 3 work | 0-2 work |

---

## GETTING STARTED

```bash
mysql -u root -p
CREATE DATABASE facebook_db;
USE facebook_db;
source schema.sql;
source seed.sql;
source queries.sql;
```

---

## HINTS

- **Friendship** is bidirectional: if A→B is accepted, B→A is also a friend. Use `(requester_id = A AND addressee_id = B) OR (requester_id = B AND addressee_id = A)`
- For mutual friends, find friends of user A who are ALSO friends of user B (INTERSECT or JOIN)
- The recursive CTE for degrees of separation needs a `visited` check to avoid infinite loops
- Virality score requires joining many tables — build it in a CTE step by step
- For the active_feed view, UNION three sources: user's own posts, friends' public posts, group posts

---

**⚠️ Do not look at the solution until you've attempted all queries yourself.**
