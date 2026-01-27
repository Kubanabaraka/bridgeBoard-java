-- ===================================================
-- BRIDGEBOARD DATABASE DESIGN (PostgreSQL)
-- Community Skill Exchange Platform
-- ===================================================
-- Database: bridgeboard_db
-- Purpose: Support user registration, skill posts,
--          skill exchanges, and messaging
-- ===================================================

-- Step 1: Create Database
DROP DATABASE IF EXISTS bridgeboard_db;
CREATE DATABASE bridgeboard_db;

\connect bridgeboard_db;

-- ===================================================
-- ENUM TYPES
-- ===================================================
CREATE TYPE user_role AS ENUM ('member', 'admin');
CREATE TYPE post_type AS ENUM ('offer', 'request', 'exchange');
CREATE TYPE post_status AS ENUM ('active', 'paused', 'closed');
CREATE TYPE exchange_type AS ENUM ('trade', 'paid', 'free');
CREATE TYPE exchange_status AS ENUM ('pending', 'accepted', 'rejected', 'completed', 'cancelled');

-- ===================================================
-- TABLE 1: users
-- Purpose: Store user account information
-- ===================================================
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  bio TEXT NULL,
  avatar_path VARCHAR(255) NULL,
  location VARCHAR(120) NULL,
  role user_role NOT NULL DEFAULT 'member',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_users_name ON users (name);
CREATE INDEX idx_users_location ON users (location);

-- ===================================================
-- TABLE 2: categories
-- Purpose: Organize skill posts into categories
-- ===================================================
CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL,
  icon_path VARCHAR(255) NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_categories_display ON categories (display_order);

-- ===================================================
-- TABLE 3: skill_posts
-- Purpose: Store user-created skill offerings/requests
-- ===================================================
CREATE TABLE skill_posts (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  category_id BIGINT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  post_type post_type NOT NULL DEFAULT 'offer',
  location VARCHAR(120) NULL,
  price_min NUMERIC(10,2) NULL,
  price_max NUMERIC(10,2) NULL,
  images JSONB NULL,
  status post_status NOT NULL DEFAULT 'active',
  views_count BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NULL,
  CONSTRAINT fk_skill_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_skill_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL,
  CONSTRAINT chk_price_range CHECK (price_min IS NULL OR price_max IS NULL OR price_min <= price_max)
);

CREATE INDEX idx_skill_user ON skill_posts (user_id);
CREATE INDEX idx_skill_category ON skill_posts (category_id);
CREATE INDEX idx_skill_location ON skill_posts (location);
CREATE INDEX idx_skill_type ON skill_posts (post_type);
CREATE INDEX idx_skill_status ON skill_posts (status);
CREATE INDEX idx_skill_created ON skill_posts (created_at);
CREATE INDEX idx_skill_search ON skill_posts USING GIN (to_tsvector('english', title || ' ' || description));

-- ===================================================
-- TABLE 4: messages
-- Purpose: Enable communication between users
-- ===================================================
CREATE TABLE messages (
  id BIGSERIAL PRIMARY KEY,
  sender_id BIGINT NOT NULL,
  recipient_id BIGINT NOT NULL,
  skill_post_id BIGINT NULL,
  subject VARCHAR(200) NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  parent_message_id BIGINT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_msg_sender FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_msg_recipient FOREIGN KEY (recipient_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_msg_post FOREIGN KEY (skill_post_id) REFERENCES skill_posts (id) ON DELETE SET NULL,
  CONSTRAINT fk_msg_parent FOREIGN KEY (parent_message_id) REFERENCES messages (id) ON DELETE SET NULL
);

CREATE INDEX idx_msg_sender ON messages (sender_id);
CREATE INDEX idx_msg_recipient ON messages (recipient_id);
CREATE INDEX idx_msg_post ON messages (skill_post_id);
CREATE INDEX idx_msg_read ON messages (is_read);
CREATE INDEX idx_msg_parent ON messages (parent_message_id);

-- ===================================================
-- TABLE 5: skill_exchanges
-- Purpose: Track matches/exchanges between users
-- ===================================================
CREATE TABLE skill_exchanges (
  id BIGSERIAL PRIMARY KEY,
  requester_id BIGINT NOT NULL,
  provider_id BIGINT NOT NULL,
  skill_post_id BIGINT NOT NULL,
  exchange_type exchange_type NOT NULL DEFAULT 'trade',
  agreed_price NUMERIC(10,2) NULL,
  status exchange_status NOT NULL DEFAULT 'pending',
  notes TEXT NULL,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  responded_at TIMESTAMPTZ NULL,
  completed_at TIMESTAMPTZ NULL,
  CONSTRAINT fk_exchange_requester FOREIGN KEY (requester_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_exchange_provider FOREIGN KEY (provider_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_exchange_post FOREIGN KEY (skill_post_id) REFERENCES skill_posts (id) ON DELETE CASCADE
);

CREATE INDEX idx_exchange_requester ON skill_exchanges (requester_id);
CREATE INDEX idx_exchange_provider ON skill_exchanges (provider_id);
CREATE INDEX idx_exchange_post ON skill_exchanges (skill_post_id);
CREATE INDEX idx_exchange_status ON skill_exchanges (status);

-- ===================================================
-- TABLE 6: reviews
-- Purpose: User feedback after skill exchanges
-- ===================================================
CREATE TABLE reviews (
  id BIGSERIAL PRIMARY KEY,
  exchange_id BIGINT NOT NULL,
  reviewer_id BIGINT NOT NULL,
  reviewee_id BIGINT NOT NULL,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT ux_review_exchange_reviewer UNIQUE (exchange_id, reviewer_id),
  CONSTRAINT fk_review_exchange FOREIGN KEY (exchange_id) REFERENCES skill_exchanges (id) ON DELETE CASCADE,
  CONSTRAINT fk_review_reviewer FOREIGN KEY (reviewer_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_review_reviewee FOREIGN KEY (reviewee_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX idx_review_reviewer ON reviews (reviewer_id);
CREATE INDEX idx_review_reviewee ON reviews (reviewee_id);
CREATE INDEX idx_review_rating ON reviews (rating);

-- ===================================================
-- TABLE 7: favorites
-- Purpose: Users can bookmark skill posts
-- ===================================================
CREATE TABLE favorites (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  skill_post_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT ux_favorite_user_post UNIQUE (user_id, skill_post_id),
  CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_favorite_post FOREIGN KEY (skill_post_id) REFERENCES skill_posts (id) ON DELETE CASCADE
);

CREATE INDEX idx_favorite_post ON favorites (skill_post_id);

-- ===================================================
-- UPDATED_AT TRIGGERS
-- ===================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_skill_posts_updated
BEFORE UPDATE ON skill_posts
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ===================================================
-- DESCRIBE (PostgreSQL equivalents)
-- ===================================================

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'users'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'categories'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'skill_posts'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'messages'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'skill_exchanges'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'reviews'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'favorites'
ORDER BY ordinal_position;

-- ===================================================
-- SHOW FOREIGN KEY RELATIONSHIPS
-- ===================================================

SELECT
  tc.table_name,
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS referenced_table,
  ccu.column_name AS referenced_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;

-- ===================================================
-- END OF DATABASE DESIGN (PostgreSQL)
-- ===================================================
