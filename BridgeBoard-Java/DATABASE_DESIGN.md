# BridgeBoard Database Design Documentation

## 📚 Table of Contents
1. [Overview](#overview)
2. [Database Architecture](#database-architecture)
3. [Table Definitions](#table-definitions)
4. [Relationships](#relationships)
5. [JDBC Connection Setup](#jdbc-connection-setup)
6. [Installation Guide](#installation-guide)
7. [Testing](#testing)

---

## 🎯 Overview

**Database Name:** `bridgeboard_db`

**Purpose:** Support a community skill exchange platform where users can:
- Create accounts and manage profiles
- Post skills they offer or request
- Exchange skills with other users
- Communicate via messaging
- Review and rate skill exchanges
- Bookmark favorite posts

**Technology Stack:**
- Database: MySQL 8.0+
- Driver: MySQL Connector/J 8.0.33
- Java: JDK 11+
- Connection: JDBC (Java Database Connectivity)

---

## 🏗️ Database Architecture

### Entity-Relationship Overview

```
┌─────────────┐
│    users    │──┐
└─────────────┘  │
       │         │
       │         │
       ├─────────┼────────────┐
       │         │            │
       ▼         ▼            ▼
┌─────────────┐ ┌──────────────────┐ ┌─────────────┐
│  messages   │ │   skill_posts    │ │  favorites  │
└─────────────┘ └──────────────────┘ └─────────────┘
                        │
                        ├──────────────┐
                        │              │
                        ▼              ▼
                ┌──────────────┐ ┌────────────┐
                │ categories   │ │  exchanges │
                └──────────────┘ └────────────┘
                                       │
                                       ▼
                                 ┌─────────┐
                                 │ reviews │
                                 └─────────┘
```

### Design Principles
1. **Normalization:** Database is normalized to 3NF (Third Normal Form)
2. **Referential Integrity:** Foreign keys enforce relationships
3. **Cascading:** DELETE CASCADE ensures data consistency
4. **Indexing:** Strategic indexes for query performance
5. **Extensibility:** Design allows future feature additions

---

## 📋 Table Definitions

### Table 1: `users`
**Purpose:** Store user account information for authentication and profile management

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique user identifier |
| `name` | VARCHAR(120) | NOT NULL | Full name of the user |
| `email` | VARCHAR(190) | NOT NULL, UNIQUE | Login email (unique) |
| `password_hash` | VARCHAR(255) | NOT NULL | BCrypt hashed password |
| `bio` | TEXT | NULL | User biography |
| `avatar_path` | VARCHAR(255) | NULL | Profile picture path |
| `location` | VARCHAR(120) | NULL | City or region |
| `role` | ENUM | NOT NULL, DEFAULT 'member' | User role (member/admin) |
| `is_active` | TINYINT(1) | NOT NULL, DEFAULT 1 | Account status |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Registration date |
| `updated_at` | TIMESTAMP | NULL, ON UPDATE CURRENT_TIMESTAMP | Last profile update |

**Indexes:**
- Primary: `id`
- Unique: `email`
- Index: `name`, `location`

---

### Table 2: `categories`
**Purpose:** Organize skill posts into logical categories

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique category identifier |
| `name` | VARCHAR(80) | NOT NULL | Category display name |
| `slug` | VARCHAR(100) | NOT NULL, UNIQUE | URL-friendly identifier |
| `description` | TEXT | NULL | Category description |
| `icon_path` | VARCHAR(255) | NULL | Path to category icon |
| `display_order` | INT UNSIGNED | NOT NULL, DEFAULT 0 | Sort order for display |
| `is_active` | TINYINT(1) | NOT NULL, DEFAULT 1 | Category visibility |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Creation date |

**Indexes:**
- Primary: `id`
- Unique: `slug`
- Index: `display_order`

**Example Categories:**
- Music (guitar, piano, singing)
- Programming (Python, Java, web development)
- Art & Design (illustration, UX, graphic design)
- Wellness (yoga, fitness, meditation)

---

### Table 3: `skill_posts`
**Purpose:** Store skill offerings, requests, or exchange proposals

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique post identifier |
| `user_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | Creator of the post |
| `category_id` | INT UNSIGNED | NULL, FOREIGN KEY | Associated category |
| `title` | VARCHAR(200) | NOT NULL | Post title |
| `description` | TEXT | NOT NULL | Detailed description |
| `post_type` | ENUM | NOT NULL, DEFAULT 'offer' | Type: offer/request/exchange |
| `location` | VARCHAR(120) | NULL | Location for exchange |
| `price_min` | DECIMAL(10,2) | NULL | Minimum price (optional) |
| `price_max` | DECIMAL(10,2) | NULL | Maximum price (optional) |
| `images` | JSON | NULL | Array of image paths |
| `status` | ENUM | NOT NULL, DEFAULT 'active' | Post status |
| `views_count` | INT UNSIGNED | NOT NULL, DEFAULT 0 | View counter |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Creation date |
| `updated_at` | TIMESTAMP | NULL, ON UPDATE CURRENT_TIMESTAMP | Last update |

**Indexes:**
- Primary: `id`
- Foreign Keys: `user_id` → users.id, `category_id` → categories.id
- Index: `user_id`, `category_id`, `location`, `post_type`, `status`, `created_at`
- Fulltext: `title`, `description` (for search functionality)

**Post Types:**
- **offer:** User offers a skill to others
- **request:** User requests a skill from others
- **exchange:** User wants to trade skills

**Status Values:**
- **active:** Post is visible and accepting responses
- **paused:** Temporarily hidden from listings
- **closed:** Post is no longer active

---

### Table 4: `messages`
**Purpose:** Enable direct communication between users

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique message identifier |
| `sender_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | User sending message |
| `recipient_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | User receiving message |
| `skill_post_id` | INT UNSIGNED | NULL, FOREIGN KEY | Related post (optional) |
| `subject` | VARCHAR(200) | NULL | Message subject |
| `content` | TEXT | NOT NULL | Message content |
| `is_read` | TINYINT(1) | NOT NULL, DEFAULT 0 | Read status |
| `parent_message_id` | INT UNSIGNED | NULL, FOREIGN KEY | For threaded replies |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Send date |

**Indexes:**
- Primary: `id`
- Foreign Keys: `sender_id` → users.id, `recipient_id` → users.id, `skill_post_id` → skill_posts.id
- Index: `sender_id`, `recipient_id`, `is_read`, `parent_message_id`

**Features:**
- Direct user-to-user messaging
- Optional link to skill post (context)
- Thread support via `parent_message_id`
- Read/unread tracking

---

### Table 5: `skill_exchanges`
**Purpose:** Track skill exchange transactions and matches

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique exchange identifier |
| `requester_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | User initiating exchange |
| `provider_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | User accepting exchange |
| `skill_post_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | Related skill post |
| `exchange_type` | ENUM | NOT NULL, DEFAULT 'trade' | Type of exchange |
| `agreed_price` | DECIMAL(10,2) | NULL | Agreed price (if paid) |
| `status` | ENUM | NOT NULL, DEFAULT 'pending' | Exchange status |
| `notes` | TEXT | NULL | Exchange notes |
| `requested_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Request date |
| `responded_at` | TIMESTAMP | NULL | Response date |
| `completed_at` | TIMESTAMP | NULL | Completion date |

**Indexes:**
- Primary: `id`
- Foreign Keys: `requester_id` → users.id, `provider_id` → users.id, `skill_post_id` → skill_posts.id
- Index: `requester_id`, `provider_id`, `skill_post_id`, `status`

**Exchange Types:**
- **trade:** Skill for skill exchange
- **paid:** Monetary transaction
- **free:** No exchange required

**Status Lifecycle:**
1. **pending:** Exchange requested, awaiting response
2. **accepted:** Provider accepted the request
3. **rejected:** Provider declined the request
4. **completed:** Exchange successfully completed
5. **cancelled:** Exchange cancelled by either party

---

### Table 6: `reviews`
**Purpose:** User feedback and ratings after skill exchanges

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique review identifier |
| `exchange_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | Related exchange |
| `reviewer_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | User writing review |
| `reviewee_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | User being reviewed |
| `rating` | TINYINT UNSIGNED | NOT NULL, CHECK (1-5) | Rating score (1-5) |
| `comment` | TEXT | NULL | Review comment |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Review date |

**Indexes:**
- Primary: `id`
- Unique: (`exchange_id`, `reviewer_id`) - One review per person per exchange
- Foreign Keys: `exchange_id` → skill_exchanges.id, `reviewer_id` → users.id, `reviewee_id` → users.id
- Index: `reviewer_id`, `reviewee_id`, `rating`

**Features:**
- 5-star rating system
- Both parties can review after exchange
- Prevents duplicate reviews

---

### Table 7: `favorites`
**Purpose:** Allow users to bookmark interesting skill posts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique favorite identifier |
| `user_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | User saving favorite |
| `skill_post_id` | INT UNSIGNED | NOT NULL, FOREIGN KEY | Favorited post |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Saved date |

**Indexes:**
- Primary: `id`
- Unique: (`user_id`, `skill_post_id`) - Prevent duplicate bookmarks
- Foreign Keys: `user_id` → users.id, `skill_post_id` → skill_posts.id

---

## 🔗 Relationships

### Foreign Key Relationships

```sql
skill_posts.user_id → users.id (CASCADE DELETE)
skill_posts.category_id → categories.id (SET NULL)

messages.sender_id → users.id (CASCADE DELETE)
messages.recipient_id → users.id (CASCADE DELETE)
messages.skill_post_id → skill_posts.id (SET NULL)
messages.parent_message_id → messages.id (SET NULL)

skill_exchanges.requester_id → users.id (CASCADE DELETE)
skill_exchanges.provider_id → users.id (CASCADE DELETE)
skill_exchanges.skill_post_id → skill_posts.id (CASCADE DELETE)

reviews.exchange_id → skill_exchanges.id (CASCADE DELETE)
reviews.reviewer_id → users.id (CASCADE DELETE)
reviews.reviewee_id → users.id (CASCADE DELETE)

favorites.user_id → users.id (CASCADE DELETE)
favorites.skill_post_id → skill_posts.id (CASCADE DELETE)
```

### Cascade Behavior

**ON DELETE CASCADE:**
- When a user is deleted, all their posts, messages, exchanges, reviews, and favorites are automatically removed
- Ensures data integrity and prevents orphaned records

**ON DELETE SET NULL:**
- When a category is deleted, posts in that category have `category_id` set to NULL (uncategorized)
- When a skill post is deleted, related messages keep the conversation but lose the post reference

---

## 🔌 JDBC Connection Setup

### Architecture

```
┌─────────────────────────────────────────┐
│   Java Application Layer                │
│                                         │
│   ┌─────────────────────────────────┐  │
│   │  DatabaseConnection.java        │  │
│   │  (Connection Manager)           │  │
│   └──────────────┬──────────────────┘  │
│                  │                      │
└──────────────────┼──────────────────────┘
                   │
                   │ JDBC Driver
                   │ (mysql-connector-j)
                   │
┌──────────────────▼──────────────────────┐
│   MySQL Server                          │
│   ┌─────────────────────────────────┐  │
│   │  bridgeboard_db                 │  │
│   │  (Database)                     │  │
│   └─────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Configuration

#### db.properties
Located at: `src/main/resources/db.properties`

```properties
db.url=jdbc:mysql://localhost:3306/bridgeboard_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.user=root
db.password=your_password_here
```

**URL Parameters Explained:**
- `useSSL=false` - Disable SSL (for development)
- `serverTimezone=UTC` - Set timezone to UTC
- `allowPublicKeyRetrieval=true` - Allow password retrieval (MySQL 8+)

#### Environment Variables (Alternative)
Set these to override db.properties:
```bash
export DB_URL="jdbc:mysql://localhost:3306/bridgeboard_db?useSSL=false&serverTimezone=UTC"
export DB_USER="root"
export DB_PASSWORD="your_password"
```

### DatabaseConnection Class

**File:** `src/main/java/com/bridgeboard/util/DatabaseConnection.java`

**Features:**
1. **Driver Loading:** Automatically loads MySQL JDBC driver on class initialization
2. **Connection Management:** Provides `getConnection()` method
3. **Configuration Priority:**
   - Environment variables (highest priority)
   - db.properties file
   - Default values (lowest priority)
4. **Error Handling:** Comprehensive error messages with troubleshooting steps
5. **Resource Management:** Proper connection closing with `closeConnection()`
6. **Debugging:** `getDatabaseInfo()` method for configuration verification

**Usage Example:**
```java
Connection conn = null;
try {
    // Get connection
    conn = DatabaseConnection.getConnection();
    
    // Use connection for database operations
    // ...
    
} catch (SQLException e) {
    e.printStackTrace();
} finally {
    // Always close connection
    DatabaseConnection.closeConnection(conn);
}
```

---

## 📦 Installation Guide

### Prerequisites
- **Java:** JDK 11 or higher
- **MySQL:** MySQL 8.0 or higher
- **Maven:** For dependency management
- **IDE:** IntelliJ IDEA, Eclipse, or VS Code

### Step-by-Step Installation

#### Step 1: Start MySQL Server
```bash
# Linux/Mac
sudo systemctl start mysql

# Windows (as Administrator)
net start MySQL80
```

#### Step 2: Create Database
```bash
# Connect to MySQL
mysql -u root -p

# Or execute SQL file directly
mysql -u root -p < sql/bridgeboard_db.sql
```

#### Step 3: Update Configuration
Edit `src/main/resources/db.properties`:
```properties
db.url=jdbc:mysql://localhost:3306/bridgeboard_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.user=root
db.password=YOUR_ACTUAL_PASSWORD
```

#### Step 4: Compile Project
```bash
mvn clean compile
```

#### Step 5: Run Connection Test
```bash
mvn exec:java -Dexec.mainClass="com.bridgeboard.test.DatabaseConnectionTest"
```

Expected output:
```
======================================================================
  BRIDGEBOARD DATABASE CONNECTION TEST
======================================================================

✓ MySQL JDBC Driver loaded successfully
✅ DATABASE CONNECTION SUCCESSFUL!
✓ Connected to: jdbc:mysql://localhost:3306/bridgeboard_db

Tables found:
  1. users [TABLE]
  2. categories [TABLE]
  3. skill_posts [TABLE]
  4. messages [TABLE]
  5. skill_exchanges [TABLE]
  6. reviews [TABLE]
  7. favorites [TABLE]

Total tables: 7
✅ All tests PASSED
```

---

## 🧪 Testing

### DatabaseConnectionTest Class

**File:** `src/main/java/com/bridgeboard/test/DatabaseConnectionTest.java`

**Test Suite:**

1. **Configuration Test**
   - Verifies db.properties is loaded
   - Displays connection settings
   
2. **Basic Connection Test**
   - Attempts database connection
   - Validates connection is open and functional

3. **Metadata Test**
   - Retrieves database version info
   - Shows driver information
   - Displays JDBC version

4. **Table List Test**
   - Lists all tables in database
   - Shows table structure (columns, types)
   - Displays primary keys
   - Shows foreign key relationships

### Running Tests

```bash
# Compile
mvn clean compile

# Run test
mvn exec:java -Dexec.mainClass="com.bridgeboard.test.DatabaseConnectionTest"
```

### Troubleshooting

#### Connection Failed
```
❌ DATABASE CONNECTION FAILED!
Error Code: 1045
SQL State: 28000
Message: Access denied for user 'root'@'localhost'
```

**Solution:**
- Verify MySQL username and password in db.properties
- Check if MySQL server is running
- Ensure user has proper privileges

#### Driver Not Found
```
❌ CRITICAL ERROR: MySQL JDBC Driver not found!
```

**Solution:**
- Check pom.xml contains mysql-connector-j dependency
- Run `mvn clean install` to download dependencies
- Verify JAR is in classpath

#### Database Not Found
```
❌ Unknown database 'bridgeboard_db'
```

**Solution:**
- Run `sql/bridgeboard_db.sql` to create database
- Verify database name in db.properties URL
- Check MySQL connection with: `mysql -u root -p -e "SHOW DATABASES;"`

---

## 📊 Database Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 7 |
| Total Foreign Keys | 12 |
| Total Indexes | 25+ |
| Normalized to | 3NF |
| Character Set | UTF-8 (utf8mb4) |
| Storage Engine | InnoDB |

---

## 🔐 Security Considerations

1. **Password Hashing:** Use BCrypt (jBCrypt library) - Never store plain text passwords
2. **SQL Injection:** Use PreparedStatements (implemented in next phase)
3. **Connection Pooling:** Consider HikariCP for production (future enhancement)
4. **SSL:** Enable SSL for production environments
5. **Privilege Management:** Use dedicated MySQL user with minimal privileges

---

## 🚀 Next Steps

**Phase 2: CRUD Operations** (WAIT FOR INSTRUCTION)
- Implement UserDao with INSERT, UPDATE, DELETE, SELECT methods
- Implement SkillPostDao for post management
- Implement MessageDao for messaging
- Implement ExchangeDao for exchange tracking
- Add input validation and sanitization
- Implement PreparedStatements for SQL injection prevention

**Phase 3: Business Logic**
- User authentication and authorization
- Skill matching algorithm
- Notification system
- Search functionality

---

## 📝 Author & Version

**Project:** BridgeBoard Community Skill Exchange Platform  
**Database Version:** 1.0  
**Author:** BridgeBoard Development Team  
**Date:** January 2026  
**Academic Use:** Suitable for educational evaluation

---

## 📄 License

This is an academic project for educational purposes.

---

**END OF DATABASE DESIGN DOCUMENTATION**
