-- ===================================================
-- BRIDGEBOARD DATABASE DESIGN
-- Community Skill Exchange Platform
-- ===================================================
-- Database: bridgeboard_db
-- Purpose: Support user registration, skill posts, 
--          skill exchanges, and messaging
-- ===================================================

-- Step 1: Create Database
DROP DATABASE IF EXISTS `bridgeboard_db`;
CREATE DATABASE `bridgeboard_db` 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE `bridgeboard_db`;

-- ===================================================
-- TABLE 1: users
-- Purpose: Store user account information
-- ===================================================
CREATE TABLE `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(120) NOT NULL COMMENT 'Full name of the user',
  `email` VARCHAR(190) NOT NULL COMMENT 'Unique email for login',
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'Hashed password using BCrypt',
  `bio` TEXT NULL COMMENT 'User biography or description',
  `avatar_path` VARCHAR(255) NULL COMMENT 'Path to profile picture',
  `location` VARCHAR(120) NULL COMMENT 'City or region',
  `role` ENUM('member','admin') NOT NULL DEFAULT 'member' COMMENT 'User role',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Account active status',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_users_email` (`email`),
  INDEX `idx_users_name` (`name`),
  INDEX `idx_users_location` (`location`)
) ENGINE=InnoDB COMMENT='Stores user account data';

-- ===================================================
-- TABLE 2: categories
-- Purpose: Organize skill posts into categories
-- ===================================================
CREATE TABLE `categories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(80) NOT NULL COMMENT 'Category display name',
  `slug` VARCHAR(100) NOT NULL COMMENT 'URL-friendly identifier',
  `description` TEXT NULL COMMENT 'Category description',
  `icon_path` VARCHAR(255) NULL COMMENT 'Path to category icon',
  `display_order` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Order for display',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Category active status',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_categories_slug` (`slug`),
  INDEX `idx_categories_display` (`display_order`)
) ENGINE=InnoDB COMMENT='Skill post categories';

-- ===================================================
-- TABLE 3: skill_posts
-- Purpose: Store user-created skill offerings/requests
-- ===================================================
CREATE TABLE `skill_posts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL COMMENT 'Creator of the post',
  `category_id` INT UNSIGNED NULL COMMENT 'Associated category',
  `title` VARCHAR(200) NOT NULL COMMENT 'Post title',
  `description` TEXT NOT NULL COMMENT 'Detailed description',
  `post_type` ENUM('offer','request','exchange') NOT NULL DEFAULT 'offer' COMMENT 'Type of post',
  `location` VARCHAR(120) NULL COMMENT 'Location for skill exchange',
  `price_min` DECIMAL(10,2) NULL COMMENT 'Minimum price (optional)',
  `price_max` DECIMAL(10,2) NULL COMMENT 'Maximum price (optional)',
  `images` JSON NULL COMMENT 'Array of image paths',
  `status` ENUM('active','paused','closed') NOT NULL DEFAULT 'active' COMMENT 'Post status',
  `views_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Number of views',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_skill_user` (`user_id`),
  KEY `idx_skill_category` (`category_id`),
  KEY `idx_skill_location` (`location`),
  KEY `idx_skill_type` (`post_type`),
  KEY `idx_skill_status` (`status`),
  KEY `idx_skill_created` (`created_at`),
  FULLTEXT KEY `ft_skill_title_desc` (`title`, `description`),
  CONSTRAINT `fk_skill_user` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_skill_category` 
    FOREIGN KEY (`category_id`) 
    REFERENCES `categories` (`id`) 
    ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='User skill posts (offers/requests)';

-- ===================================================
-- TABLE 4: messages
-- Purpose: Enable communication between users
-- ===================================================
CREATE TABLE `messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sender_id` INT UNSIGNED NOT NULL COMMENT 'User sending the message',
  `recipient_id` INT UNSIGNED NOT NULL COMMENT 'User receiving the message',
  `skill_post_id` INT UNSIGNED NULL COMMENT 'Related skill post (optional)',
  `subject` VARCHAR(200) NULL COMMENT 'Message subject',
  `content` TEXT NOT NULL COMMENT 'Message content',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Read status',
  `parent_message_id` INT UNSIGNED NULL COMMENT 'For threaded replies',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_msg_sender` (`sender_id`),
  KEY `idx_msg_recipient` (`recipient_id`),
  KEY `idx_msg_post` (`skill_post_id`),
  KEY `idx_msg_read` (`is_read`),
  KEY `idx_msg_parent` (`parent_message_id`),
  CONSTRAINT `fk_msg_sender` 
    FOREIGN KEY (`sender_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_msg_recipient` 
    FOREIGN KEY (`recipient_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_msg_post` 
    FOREIGN KEY (`skill_post_id`) 
    REFERENCES `skill_posts` (`id`) 
    ON DELETE SET NULL,
  CONSTRAINT `fk_msg_parent` 
    FOREIGN KEY (`parent_message_id`) 
    REFERENCES `messages` (`id`) 
    ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='User-to-user messaging';

-- ===================================================
-- TABLE 5: skill_exchanges
-- Purpose: Track matches/exchanges between users
-- ===================================================
CREATE TABLE `skill_exchanges` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `requester_id` INT UNSIGNED NOT NULL COMMENT 'User initiating exchange',
  `provider_id` INT UNSIGNED NOT NULL COMMENT 'User accepting exchange',
  `skill_post_id` INT UNSIGNED NOT NULL COMMENT 'Related skill post',
  `exchange_type` ENUM('trade','paid','free') NOT NULL DEFAULT 'trade' COMMENT 'Type of exchange',
  `agreed_price` DECIMAL(10,2) NULL COMMENT 'Agreed price (if paid)',
  `status` ENUM('pending','accepted','rejected','completed','cancelled') 
    NOT NULL DEFAULT 'pending' COMMENT 'Exchange status',
  `notes` TEXT NULL COMMENT 'Exchange notes or details',
  `requested_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responded_at` TIMESTAMP NULL COMMENT 'When provider responded',
  `completed_at` TIMESTAMP NULL COMMENT 'When exchange completed',
  PRIMARY KEY (`id`),
  KEY `idx_exchange_requester` (`requester_id`),
  KEY `idx_exchange_provider` (`provider_id`),
  KEY `idx_exchange_post` (`skill_post_id`),
  KEY `idx_exchange_status` (`status`),
  CONSTRAINT `fk_exchange_requester` 
    FOREIGN KEY (`requester_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_exchange_provider` 
    FOREIGN KEY (`provider_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_exchange_post` 
    FOREIGN KEY (`skill_post_id`) 
    REFERENCES `skill_posts` (`id`) 
    ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Skill exchange transactions';

-- ===================================================
-- TABLE 6: reviews
-- Purpose: User feedback after skill exchanges
-- ===================================================
CREATE TABLE `reviews` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `exchange_id` INT UNSIGNED NOT NULL COMMENT 'Related exchange',
  `reviewer_id` INT UNSIGNED NOT NULL COMMENT 'User writing review',
  `reviewee_id` INT UNSIGNED NOT NULL COMMENT 'User being reviewed',
  `rating` TINYINT UNSIGNED NOT NULL COMMENT 'Rating 1-5',
  `comment` TEXT NULL COMMENT 'Review comment',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_review_exchange_reviewer` (`exchange_id`, `reviewer_id`),
  KEY `idx_review_reviewer` (`reviewer_id`),
  KEY `idx_review_reviewee` (`reviewee_id`),
  KEY `idx_review_rating` (`rating`),
  CONSTRAINT `fk_review_exchange` 
    FOREIGN KEY (`exchange_id`) 
    REFERENCES `skill_exchanges` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_review_reviewer` 
    FOREIGN KEY (`reviewer_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_review_reviewee` 
    FOREIGN KEY (`reviewee_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `chk_rating_range` CHECK (`rating` BETWEEN 1 AND 5)
) ENGINE=InnoDB COMMENT='User reviews and ratings';

-- ===================================================
-- TABLE 7: favorites
-- Purpose: Users can bookmark skill posts
-- ===================================================
CREATE TABLE `favorites` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL COMMENT 'User saving favorite',
  `skill_post_id` INT UNSIGNED NOT NULL COMMENT 'Favorited post',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_favorite_user_post` (`user_id`, `skill_post_id`),
  KEY `idx_favorite_post` (`skill_post_id`),
  CONSTRAINT `fk_favorite_user` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_favorite_post` 
    FOREIGN KEY (`skill_post_id`) 
    REFERENCES `skill_posts` (`id`) 
    ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='User bookmarked posts';

-- ===================================================
-- DESCRIBE STATEMENTS (Table Structure Verification)
-- ===================================================

DESCRIBE `users`;
DESCRIBE `categories`;
DESCRIBE `skill_posts`;
DESCRIBE `messages`;
DESCRIBE `skill_exchanges`;
DESCRIBE `reviews`;
DESCRIBE `favorites`;

-- ===================================================
-- SHOW TABLE RELATIONSHIPS
-- ===================================================

SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    TABLE_SCHEMA = 'bridgeboard_db'
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY 
    TABLE_NAME, CONSTRAINT_NAME;

-- ===================================================
-- END OF DATABASE DESIGN
-- ===================================================
