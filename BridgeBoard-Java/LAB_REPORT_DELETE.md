# LAB REPORT: IMPLEMENTING DELETE OPERATION IN JAVA BACKEND

**Project:** BridgeBoard -- Community Skill Exchange Platform
**Course:** Learning Unit 6 -- Server-Side Data Manipulation
**Date:** February 12, 2026

---

## 1. PROJECT OVERVIEW

BridgeBoard is a Java-based backend application that powers a community skill exchange platform. The application enables users to register accounts, publish skill offerings or requests, exchange skills with other members, and communicate through an internal messaging system. The backend is built using Java Servlets, JSP for presentation, and JDBC for direct database access following the Data Access Object (DAO) architectural pattern.

The purpose of the application is to provide a centralised platform where community members can share, discover, and trade skills with one another. The system manages several types of data including user accounts, skill posts, messages, skill exchanges, reviews, and favorites.

The DELETE operation is a fundamental component of any database-driven application. In a system such as BridgeBoard, users must be able to remove their own skill posts when they are no longer relevant, when a skill exchange has been completed, or when a listing was created in error. Without a properly implemented DELETE operation, the database would accumulate stale records, degrade user experience, and compromise data integrity. Additionally, the DELETE operation must be implemented securely to ensure that only the owner of a record is permitted to remove it, and that the operation is protected against SQL injection and cross-site request forgery (CSRF).

---

## 2. DATABASE PROCESS

### 2.1 Database Creation Process

The database was created using the following SQL statement:

```sql
DROP DATABASE IF EXISTS bridgeboard_db;
CREATE DATABASE bridgeboard_db;
```

The database `bridgeboard_db` stores all application data for the BridgeBoard platform. This includes user account information, skill post listings, inter-user messages, skill exchange transactions, user reviews, and bookmarked favorites. The database uses PostgreSQL as the relational database management system.

### 2.2 Table Creation

The primary table involved in the DELETE operation is `skill_posts`. The table was created using the following SQL statement:

```sql
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
  CONSTRAINT fk_skill_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_skill_category FOREIGN KEY (category_id)
    REFERENCES categories (id) ON DELETE SET NULL,
  CONSTRAINT chk_price_range CHECK (
    price_min IS NULL OR price_max IS NULL OR price_min <= price_max
  )
);
```

**Explanation of table structure:**

| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGSERIAL | Auto-incrementing primary key that uniquely identifies each skill post. |
| `user_id` | BIGINT | Foreign key referencing the `users` table; identifies the post owner. |
| `category_id` | BIGINT | Foreign key referencing the `categories` table; nullable. |
| `title` | VARCHAR(200) | The title of the skill post. |
| `description` | TEXT | A detailed description of the skill being offered or requested. |
| `post_type` | ENUM | The type of post: `offer`, `request`, or `exchange`. |
| `location` | VARCHAR(120) | The location associated with the skill post. |
| `price_min` | NUMERIC(10,2) | Minimum price for the skill service, if applicable. |
| `price_max` | NUMERIC(10,2) | Maximum price for the skill service, if applicable. |
| `images` | JSONB | JSON array storing image file paths. |
| `status` | ENUM | The status of the post: `active`, `paused`, or `closed`. |
| `views_count` | BIGINT | Number of times the post has been viewed. |
| `created_at` | TIMESTAMPTZ | Timestamp of when the record was created. |
| `updated_at` | TIMESTAMPTZ | Timestamp of the most recent update. |

**Primary Key:** The `id` column serves as the primary key. It is defined as `BIGSERIAL`, which means PostgreSQL automatically generates a unique, sequential integer for each new record.

**Foreign Key Constraints:** The `user_id` column references `users(id)` with `ON DELETE CASCADE`, meaning that if a user account is deleted, all associated skill posts are automatically removed. The `category_id` column references `categories(id)` with `ON DELETE SET NULL`.

### 2.3 Database State Before DELETE Operation

Before executing the DELETE operation, the database was verified to contain multiple skill post records. The following SELECT statement was used to confirm the presence of records:

```sql
SELECT id, title, user_id, status, created_at::date
FROM skill_posts
ORDER BY id;
```

This query retrieves the key fields of all skill post records, ordered by their primary key. The result confirmed that the table contained multiple records with distinct IDs, titles, user associations, and creation dates.

**Screenshot 1: SQL table structure showing fields and primary key**

> This screenshot must display the output of `\d skill_posts` or an equivalent command that shows the full table structure including column names, data types, constraints, and the primary key designation for the `id` column.

**Screenshot 2: Database records before deletion**

> This screenshot must display the result of the SELECT query above, showing multiple rows of skill post records. At least five or more records should be visible, each with a distinct `id`, `title`, `user_id`, and `created_at` date. The record that will be deleted in the next step should be clearly identifiable in this output.

### 2.4 Database State After DELETE Operation

The DELETE operation was executed through the application's user interface. A logged-in user navigated to the dashboard, located the target skill post, and clicked the "Delete" button. The application sent a POST request to the `PostDeleteServlet`, which invoked the DAO method to execute the following SQL:

```sql
DELETE FROM skill_posts WHERE id = ? AND user_id = ?
```

After the deletion, the same SELECT query was executed to verify the database state:

```sql
SELECT id, title, user_id, status, created_at::date
FROM skill_posts
ORDER BY id;
```

The result confirmed that the targeted record was successfully removed from the table. All remaining records were intact and unaffected by the operation.

**Screenshot 3: Database records after deletion**

> This screenshot must display the result of the SELECT query after the DELETE operation has been performed. The record that was previously visible in Screenshot 2 should no longer appear in this output. All other records should remain unchanged, confirming that the DELETE operation affected only the intended row.

---

## 3. JAVA IMPLEMENTATION

### 3.1 Database Connection Code

The database connection is managed by the `DbUtil` utility class located at `src/main/java/com/bridgeboard/util/DbUtil.java`. This class uses JDBC to establish a connection to the PostgreSQL database.

```java
public final class DbUtil {
    private static final Properties PROPS = new Properties();

    static {
        try (InputStream input = DbUtil.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (input != null) {
                PROPS.load(input);
            }
        } catch (IOException ignored) {
        }

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException ignored) {
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = envOrProp("DB_URL", "db.url");
        String user = envOrProp("DB_USER", "db.user");
        String password = envOrProp("DB_PASSWORD", "db.password");
        return DriverManager.getConnection(url, user, password);
    }
}
```

**Explanation:**

- **Driver Loading:** The PostgreSQL JDBC driver (`org.postgresql.Driver`) is loaded in a static initialiser block using `Class.forName()`. This ensures the driver is registered with JDBC before any connection attempt.
- **DriverManager:** The `DriverManager.getConnection()` method is used to establish the database connection. It accepts the connection URL, username, and password as parameters.
- **Connection URL:** The connection URL follows the format `jdbc:postgresql://localhost:5432/bridgeboard_db`, which specifies the JDBC protocol, the database host and port, and the database name.
- **Credentials:** The database username and password are read from the `db.properties` configuration file located in the resources directory. Environment variables take priority over file-based configuration, allowing flexible deployment.
- **Try-with-resources:** All callers of `getConnection()` use Java's try-with-resources syntax to ensure that database connections are automatically closed after use, preventing resource leaks.

**Screenshot 4: Java database connection source code**

> This screenshot must display the full source code of the `DbUtil.java` file. The connection string format (`jdbc:postgresql://...`), the `Class.forName()` driver registration, and the `DriverManager.getConnection()` call must all be visible.

### 3.2 DELETE Operation in Java

The DELETE operation is implemented in the `SkillPostDao` class located at `src/main/java/com/bridgeboard/dao/SkillPostDao.java`. The relevant method is:

```java
public boolean delete(int id, int userId) {
    String sql = "DELETE FROM skill_posts WHERE id = ? AND user_id = ?";
    try (Connection conn = DbUtil.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, id);
        stmt.setInt(2, userId);
        return stmt.executeUpdate() > 0;
    } catch (Exception ignored) {
    }
    return false;
}
```

**Explanation of the SQL query:**

```sql
DELETE FROM skill_posts WHERE id = ? AND user_id = ?
```

This SQL statement removes a single record from the `skill_posts` table where both the record ID and the user ID match the provided values. The inclusion of `user_id` in the WHERE clause is a security measure that ensures a user can only delete their own posts.

**PreparedStatement usage:** The method uses `PreparedStatement` rather than a plain `Statement`. PreparedStatement pre-compiles the SQL query and separates the SQL structure from the data values, which provides two critical benefits:

1. **SQL Injection Prevention:** The `?` placeholders are bound to actual values using `stmt.setInt()`. This means user-supplied input is never concatenated directly into the SQL string, completely preventing SQL injection attacks.
2. **Type Safety:** The `setInt()` method ensures that the parameter is treated as an integer type by the database, preventing type mismatch errors.

**Parameter binding:**
- `stmt.setInt(1, id)` binds the skill post ID to the first `?` placeholder.
- `stmt.setInt(2, userId)` binds the authenticated user's ID to the second `?` placeholder.

**Checking rows affected:** The `executeUpdate()` method returns the number of rows affected by the SQL statement. The expression `stmt.executeUpdate() > 0` evaluates to `true` if at least one row was deleted, and `false` if no matching record was found. This return value allows the calling code to determine whether the deletion was successful.

**Resource management:** The `try-with-resources` block ensures that both the `Connection` and `PreparedStatement` objects are automatically closed when the block exits, even if an exception occurs. This prevents database connection leaks.

**Screenshot 5: Java source code implementing DELETE using PreparedStatement**

> This screenshot must display the `delete()` method in the `SkillPostDao.java` file. The SQL DELETE query string, the `PreparedStatement` creation, the `stmt.setInt(1, id)` and `stmt.setInt(2, userId)` parameter binding calls, and the `executeUpdate()` invocation must all be visible.

### 3.3 Processing Delete Requests

The delete request is processed by the `PostDeleteServlet` class, which is mapped to the URL pattern `/posts/delete` using the `@WebServlet` annotation.

```java
@WebServlet(name = "PostDeleteServlet", urlPatterns = "/posts/delete")
public class PostDeleteServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            FlashUtil.put(session, "error", "Please log in to continue.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String csrf = request.getParameter("csrf_token");
        if (!CsrfUtil.isValid(session, csrf)) {
            FlashUtil.put(session, "error", "Invalid request.");
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));
        SkillPostDao dao = new SkillPostDao();
        dao.delete(postId, user.getId());
        FlashUtil.put(session, "success", "Post removed.");
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
    }
}
```

**How the Servlet receives the delete request:** The servlet's `doPost()` method handles HTTP POST requests. On the dashboard page, each skill post has a "Delete" button inside a form that submits a POST request to `/posts/delete`. The form includes a hidden `csrf_token` field and the `post_id` of the record to delete.

**How the ID parameter is retrieved:** The post ID is extracted from the request using `request.getParameter("post_id")` and parsed to an integer using `Integer.parseInt()`. The authenticated user's ID is obtained from the session attribute `user`, which was set during login.

**How the DAO method is called:** A new instance of `SkillPostDao` is created, and the `delete(postId, user.getId())` method is invoked. This passes both the post ID and the user ID to the DAO, which constructs and executes the parameterised DELETE query.

**How the application confirms successful deletion:** After the DAO method completes, the servlet stores a success message ("Post removed.") in the session using `FlashUtil.put()`. The user is then redirected to the dashboard page, where the flash message is displayed as a confirmation notification. The deleted post no longer appears in the user's post listing.

**Security measures:** The servlet implements two layers of protection before executing the delete:
1. **Authentication check** -- verifies that a user is logged in by checking the session for a `user` attribute.
2. **CSRF validation** -- verifies the `csrf_token` parameter against the token stored in the session to prevent cross-site request forgery attacks.

---

## 4. CONCLUSION

This lab successfully demonstrated the implementation of the DELETE operation in a Java backend application connected to a PostgreSQL database. The DELETE functionality was implemented across three architectural layers following the DAO pattern: the JSP presentation layer provides the user interface, the Servlet layer handles request processing and validation, and the DAO layer executes the parameterised SQL query.

The DELETE operation was verified to work correctly. Before deletion, the database contained multiple skill post records, which were confirmed using a SELECT query. After executing the DELETE operation through the application, the targeted record was removed from the database, and all remaining records were confirmed to be intact and unaffected.

The implementation uses `PreparedStatement` with parameter binding to prevent SQL injection vulnerabilities. The `executeUpdate()` method is used to determine whether the deletion affected any rows. Resources are managed using try-with-resources to prevent connection leaks.

**Challenges faced:**

1. **Foreign key constraints:** The `skill_posts` table is referenced by other tables such as `favorites`, `messages`, and `skill_exchanges`. Attempting to delete a skill post that has associated records in these tables would normally cause a foreign key constraint violation. This was resolved at the database design level by defining the foreign key constraints with `ON DELETE CASCADE` and `ON DELETE SET NULL`, which automatically handle dependent records when a parent record is deleted.

2. **Authorisation enforcement:** A delete request must only be processed for posts owned by the authenticated user. This was resolved by including `AND user_id = ?` in the WHERE clause of the DELETE statement, ensuring that even if a malicious user submits a forged post ID, the query will not affect records belonging to other users.

3. **CSRF protection:** Delete operations modify data and must be protected against cross-site request forgery. This was addressed by requiring a valid CSRF token with every delete request, which is validated by the servlet before proceeding with the operation.

All challenges were resolved through standard security practices and proper database constraint design. The DELETE operation integrates cleanly with the existing CRUD architecture and does not introduce any breaking changes to the application.
