# 1. Introduction

Learning Unit 6 introduces server-side data retrieval using Java and relational databases. In this lab, the focus is on the READ (SELECT) operation, which allows a backend application to fetch stored records for display or further processing. This lab report documents the implementation of READ (SELECT) using JDBC and emphasizes that the scope is strictly limited to SELECT only.

---

# 2. Project Overview

BridgeBoard is a Java-based backend application that supports a community skill exchange platform. For this lab, the project concentrates exclusively on retrieving existing skill post records from the database. The READ (SELECT) operation is used to access stored skill posts so they can be displayed to users or validated for academic demonstration.

---

# 3. Technology Stack

- **Java**
- **JDBC**
- **JSP** (for output presentation)
- **MySQL** (relational database)

---

# 4. Database Process

## 4.1 Database Creation

The database has already been created and is available for use. The database name used in this lab is **bridgeboard_db**.

📸 **Screenshot 1: Database created in MySQL**

---

## 4.2 Table Creation

The lab uses the **skill_posts** table to retrieve stored skill post records. The table definition (CREATE TABLE) is documented below, followed by a short explanation of each column.

**SQL CREATE TABLE (skill_posts):**

```
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
  updated_at TIMESTAMPTZ NULL
);
```

**Column Explanation:**

- **id** – Unique identifier for each skill post.
- **user_id** – Owner of the post (reference to the user).
- **category_id** – Category associated with the post.
- **title** – Short title describing the skill.
- **description** – Detailed explanation of the skill post.
- **post_type** – Indicates whether the post is an offer, request, or exchange.
- **location** – Location information for the post.
- **price_min** – Optional minimum price.
- **price_max** – Optional maximum price.
- **images** – JSON list of image paths.
- **status** – Current state of the post (active, paused, closed).
- **views_count** – Number of views for the post.
- **created_at** – Record creation timestamp.
- **updated_at** – Record update timestamp.

📸 **Screenshot 2: SQL table structure of skill_posts**

---

## 4.3 Existing Records (Before SELECT)

This lab assumes that sample data already exists in the **skill_posts** table. The system is therefore able to retrieve and display existing records without altering the data.

📸 **Screenshot 3: Existing records in skill_posts table**

---

# 5. Java Implementation

## 5.1 JDBC Database Connection

The application connects to the database using a dedicated JDBC utility class. This class loads the JDBC driver, reads database configuration, and provides a reusable connection method for SELECT queries.

📸 **Screenshot 4: Java database connection source code**

---

## 5.2 READ (SELECT) Operation Implementation

The READ operation is implemented using a SQL SELECT statement and a `PreparedStatement`. The query retrieves records from the **skill_posts** table. A `ResultSet` is then used to iterate through the returned rows, mapping each row to a Java object.

Key points:

- The SELECT statement defines the columns to retrieve.
- The `ResultSet` provides row-by-row access to the retrieved data.
- Each row is mapped into a Java model object.

📸 **Screenshot 5: Java source code for SELECT operation**

---

# 6. Displaying Retrieved Data

The retrieved records are displayed through JSP output, ensuring that the user can view the list of skill posts. The lab confirms that the retrieval process supports UI rendering or console display.

📸 **Screenshot 6: Output showing retrieved records after SELECT execution**

---

# 7. Verification of SELECT Operation

The READ operation was verified by:

- Confirming the number of records returned by the SELECT query.
- Comparing the retrieved values with the existing database contents.
- Ensuring that all expected fields are displayed accurately.

This confirms that the SELECT process functions correctly and retrieves data as required.

---

# 8. Conclusion

This lab successfully implemented the READ (SELECT) operation in a Java backend using JDBC. The system retrieved skill post records from the **skill_posts** table and displayed them correctly. Any challenges encountered were addressed through careful verification of the database connection and SQL query structure. The lab objective was fully achieved, with the focus strictly maintained on SELECT operations only.
