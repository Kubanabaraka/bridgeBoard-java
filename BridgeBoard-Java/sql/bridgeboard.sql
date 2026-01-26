-- BridgeBoard database schema & seed data
DROP DATABASE IF EXISTS `bridgeboard`;
CREATE DATABASE `bridgeboard` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `bridgeboard`;

-- Users table
CREATE TABLE `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(120) NOT NULL,
  `email` VARCHAR(190) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `bio` TEXT NULL,
  `avatar_path` VARCHAR(255) NULL,
  `location` VARCHAR(120) NULL,
  `role` ENUM('member','admin') NOT NULL DEFAULT 'member',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_users_email` (`email`),
  INDEX `idx_users_name` (`name`)
) ENGINE=InnoDB;

-- Categories table
CREATE TABLE `categories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(80) NOT NULL,
  `slug` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `icon_path` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_categories_slug` (`slug`)
) ENGINE=InnoDB;

-- Skill posts table
CREATE TABLE `skill_posts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `category_id` INT UNSIGNED NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `location` VARCHAR(120) NULL,
  `price_min` DECIMAL(10,2) NULL,
  `price_max` DECIMAL(10,2) NULL,
  `images` JSON NULL,
  `status` ENUM('active','paused','closed') NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_skill_user` (`user_id`),
  KEY `idx_skill_category` (`category_id`),
  KEY `idx_skill_location` (`location`),
  KEY `idx_skill_created` (`created_at`),
  FULLTEXT KEY `ft_skill_title_desc` (`title`, `description`),
  CONSTRAINT `fk_skill_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_skill_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Messages table
CREATE TABLE `messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sender_id` INT UNSIGNED NOT NULL,
  `recipient_id` INT UNSIGNED NOT NULL,
  `skill_post_id` INT UNSIGNED NULL,
  `content` TEXT NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_msg_sender` (`sender_id`),
  KEY `idx_msg_recipient` (`recipient_id`),
  CONSTRAINT `fk_msg_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_msg_recipient` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_msg_post` FOREIGN KEY (`skill_post_id`) REFERENCES `skill_posts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Seed data
INSERT INTO `users` (`name`, `email`, `password_hash`, `bio`, `location`, `avatar_path`) VALUES
('Alice Nguyen', 'alice@example.com', '$2y$12$L6VJ7Q8WBEXAMPLEziejr1enlVVwZjPU6YewsG32IOzBSSo4mF', 'Experienced guitar teacher focused on beginner musicians.', 'Austin, TX', 'assets/images/profile-alice.svg'),
('Ben Carter', 'ben@example.com', '$2y$12$R4nQc7Lw9PRETENDHASHnmm4Y315IziwheZZz4jo5uZ5lFwfqVV', 'Frontend engineer offering React pair-programming and reviews.', 'Remote', 'assets/images/profile-ben.svg'),
('Camila Ortiz', 'camila@example.com', '$2y$12$AAlpQ9GHASHEDPASS1234567890ABCDE', 'UX designer passionate about accessibility and prototyping.', 'Denver, CO', NULL);

INSERT INTO `categories` (`name`, `slug`, `description`, `icon_path`) VALUES
('Music', 'music', 'Lessons and jam sessions for instruments and vocals.', 'assets/images/category-music.svg'),
('Programming', 'programming', 'Coding mentorship, debugging, and reviews.', 'assets/images/category-programming.svg'),
('Art & Design', 'design', 'Illustration, UX, and visual storytelling.', 'assets/images/category-design.svg'),
('Wellness', 'wellness', 'Yoga, fitness, and wellbeing guidance.', 'assets/images/category-wellness.svg');

INSERT INTO `skill_posts` (`user_id`, `category_id`, `title`, `description`, `location`, `price_min`, `price_max`, `images`, `status`) VALUES
(1, 1, 'Beginner Acoustic Guitar Lessons', 'Two 45-minute sessions per week covering chords, rhythm, and learning your first songs.', 'Austin, TX', 20.00, 40.00, '["assets/images/post_guitar_1.svg"]', 'active'),
(2, 2, 'React Pair-programming & Testing', 'Hands-on code review, component architecture best practices, and unit testing setup.', 'Remote', 35.00, 70.00, '["assets/images/post_react_1.svg"]', 'active'),
(3, 3, 'UX Portfolio Critique', 'One-on-one critique sessions with actionable feedback on flows, visuals, and storytelling.', 'Denver, CO', 0.00, 0.00, '["assets/images/post_ux_1.svg"]', 'active');

INSERT INTO `messages` (`sender_id`, `recipient_id`, `skill_post_id`, `content`) VALUES
(2, 1, 1, 'Hi Alice! I would love to trade React mentoring for your guitar sessions.'),
(3, 2, 2, 'Ben, are you open to reviewing a Figma prototype during our session?');
