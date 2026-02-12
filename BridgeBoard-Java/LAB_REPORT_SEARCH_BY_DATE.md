# LAB REPORT: SEARCH (SELECT BY DATE) FEATURE

## BridgeBoard – Community Skill Exchange Platform

---

# 1. Search Feature Overview

## 1.1 Purpose of Search

The SEARCH (SELECT by Date) feature allows users to retrieve skill post records from the database based on the `created_at` date field. This is a **read-only** operation that queries the `skill_posts` table using SQL `SELECT` with a `WHERE` clause filtered by date. The feature supports two modes:

1. **Single Date Search** – Retrieves all skill posts created on a specific date.
2. **Date Range Search (Bonus)** – Retrieves all skill posts created within a date range using `BETWEEN`.

## 1.2 Why the `created_at` Field Was Chosen

The `created_at` column was chosen for the search feature because:

- It already exists in the `skill_posts` table as a `TIMESTAMPTZ` (timestamp with time zone) column.
- It is automatically set to `NOW()` when a record is inserted, making it a reliable and consistent field.
- Every skill post has a non-null `created_at` value, ensuring all records are searchable.
- Searching by creation date is a natural and intuitive way for users to find posts.

## 1.3 How It Enhances the CRUD System

The existing BridgeBoard system already supports full CRUD operations:

| Operation | Implementation |
|-----------|---------------|
| **C**reate | `PostCreateServlet` → `SkillPostDao.create()` |
| **R**ead | `browse.jsp`, `post_detail.jsp` → `SkillPostDao.findById()`, `latest()` |
| **U**pdate | `PostUpdateServlet` → `SkillPostDao.update()` |
| **D**elete | `PostDeleteServlet` → `SkillPostDao.delete()` |

The new **Search by Date** feature extends the Read operation by adding targeted, parameter-based retrieval. Instead of simply listing all posts, users can now filter posts by date—making the system more usable and practical.

---

# 2. Database Process

## 2.1 Description of the Date Column

The `created_at` column in the `skill_posts` table is defined as:

```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

- **Type:** `TIMESTAMPTZ` – stores date and time with timezone information.
- **Constraint:** `NOT NULL` – every record must have a creation timestamp.
- **Default:** `NOW()` – automatically set to the current timestamp on insert.

This column was **not added** for this lab—it already existed in the original schema.

## 2.2 Sample Data Explanation

The database contains 11 skill post records with different `created_at` dates spanning from January 15, 2026 to February 12, 2026. This spread ensures meaningful search results can be demonstrated:

| ID | Title | Created At |
|----|-------|------------|
| 9 | Web Development Tutoring Available | 2026-01-15 |
| 10 | Looking for Guitar Lessons | 2026-01-20 |
| 2 | Offering System Design Services | 2026-01-26 |
| 4 | English Speaker | 2026-01-29 |
| 3 | Experienced Forex trader | 2026-01-29 |
| 5 | I am a young data analyst | 2026-01-30 |
| 6 | I am a data analyst | 2026-01-30 |
| 11 | Graphic Design Services | 2026-02-01 |
| 12 | Photography Workshop Exchange | 2026-02-05 |
| 13 | Python Programming Help Needed | 2026-02-10 |
| 7 | Communication skills specialist | 2026-02-12 |

Some dates have multiple records (e.g., 2026-01-29 has 2 posts), which demonstrates that the search correctly returns multiple results.

## 2.3 SQL to Verify Records Before Search

The following SQL was used to verify records exist in the database before performing the search:

```sql
SELECT id, title, created_at::date
FROM skill_posts
ORDER BY created_at;
```

[Screenshot 1: skill_posts table showing created_at column]

[Screenshot 2: Sample records with different dates]

## 2.4 Database State

- **Total records:** 11
- **Date range span:** January 15, 2026 – February 12, 2026
- **No tables were dropped or recreated** – only INSERT statements were used to add sample data.

---

# 3. Java Implementation

## 3.1 SQL SELECT Query

### Single Date Search

```sql
SELECT sp.*, u.name AS user_name, u.avatar_path, c.name AS category_name
FROM skill_posts sp
LEFT JOIN users u ON u.id = sp.user_id
LEFT JOIN categories c ON c.id = sp.category_id
WHERE CAST(sp.created_at AS DATE) = ?
ORDER BY sp.created_at DESC
```

**Explanation:**
- The `CAST(sp.created_at AS DATE)` converts the `TIMESTAMPTZ` column to a pure `DATE` for comparison, since `created_at` stores both date and time.
- The `?` is a parameter placeholder used by `PreparedStatement` to prevent SQL injection.
- `LEFT JOIN` with `users` and `categories` retrieves the user name and category name for display.
- Results are ordered by `created_at DESC` (newest first).

### Date Range Search (Bonus)

```sql
SELECT sp.*, u.name AS user_name, u.avatar_path, c.name AS category_name
FROM skill_posts sp
LEFT JOIN users u ON u.id = sp.user_id
LEFT JOIN categories c ON c.id = sp.category_id
WHERE CAST(sp.created_at AS DATE) BETWEEN ? AND ?
ORDER BY sp.created_at DESC
```

**Explanation:**
- Uses SQL `BETWEEN` clause with two parameter placeholders for the start and end dates.
- Both boundary dates are inclusive.

## 3.2 PreparedStatement Usage

The DAO methods use `PreparedStatement` exclusively (never raw `Statement`):

```java
public List<SkillPost> searchByDate(LocalDate date) {
    List<SkillPost> posts = new ArrayList<>();
    String sql = "SELECT sp.*, u.name AS user_name, u.avatar_path, c.name AS category_name " +
        "FROM skill_posts sp " +
        "LEFT JOIN users u ON u.id = sp.user_id " +
        "LEFT JOIN categories c ON c.id = sp.category_id " +
        "WHERE CAST(sp.created_at AS DATE) = ? " +
        "ORDER BY sp.created_at DESC";
    try (Connection conn = DbUtil.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        // Convert LocalDate to java.sql.Date for JDBC parameter binding
        stmt.setDate(1, java.sql.Date.valueOf(date));
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                posts.add(map(rs));
            }
        }
    } catch (Exception e) {
        System.err.println("Error in searchByDate: " + e.getMessage());
    }
    return posts;
}
```

**Key points:**
- `PreparedStatement` with `?` placeholders prevents SQL injection.
- `java.sql.Date.valueOf(date)` converts `LocalDate` to the JDBC-compatible `java.sql.Date` type.
- `try-with-resources` ensures `Connection`, `PreparedStatement`, and `ResultSet` are all closed automatically—no resource leaks.
- Returns an empty `ArrayList` if no records match—never returns `null`.

[Screenshot 3: Java DAO method for searchByDate]

## 3.3 Servlet Implementation

The `SearchSkillPostByDateServlet` is mapped to `/posts/search-by-date` and handles GET requests:

```java
@WebServlet(name = "SearchSkillPostByDateServlet", urlPatterns = "/posts/search-by-date")
public class SearchSkillPostByDateServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String dateParam      = trim(request.getParameter("date"));
        String startDateParam = trim(request.getParameter("start_date"));
        String endDateParam   = trim(request.getParameter("end_date"));

        // ... validation and DAO calls ...

        request.setAttribute("searchResults", results);
        request.getRequestDispatcher("/search_by_date.jsp").forward(request, response);
    }
}
```

**Responsibilities:**
1. Reads date parameters from the form submission.
2. Validates input: checks for null/empty values and invalid date formats.
3. Calls the appropriate DAO method (`searchByDate` or `searchByDateRange`).
4. Sets results as request attributes.
5. Forwards to the JSP page for display.

[Screenshot 4: Servlet implementation]

## 3.4 Result Processing

The servlet processes results using the MVC pattern:

1. **Servlet** reads form parameters and validates them.
2. **DAO** executes the query and returns a `List<SkillPost>`.
3. **Servlet** sets result list and metadata as request attributes.
4. **JSP** reads attributes and renders results in both table and card views.

Error handling includes:
- `DateTimeParseException` caught for invalid date formats.
- Null/empty parameter validation.
- Database connection errors handled in the DAO's catch block.
- Empty results display a user-friendly "No records found" message.

---

# 4. Screenshots (Placeholders)

[Screenshot 1: skill_posts table showing created_at column]

[Screenshot 2: Sample records with different dates]

[Screenshot 3: Java DAO method for searchByDate]

[Screenshot 4: Servlet implementation]

[Screenshot 5: JSP search form]

[Screenshot 6: Search input date example]

[Screenshot 7: Search results displayed]

[Screenshot 8: Empty result case]

---

# 5. Testing Results

## 5.1 Test Cases

| Test Case | Input | Expected Result | Actual Result | Status |
|-----------|-------|-----------------|---------------|--------|
| Search existing date | `date=2026-01-29` | 2 records | 2 records | PASS |
| Search date range | `start_date=2026-01-15&end_date=2026-01-30` | 7 records | 7 records | PASS |
| Search non-existing date | `date=2020-01-01` | 0 records, "No records found" | 0 records, message shown | PASS |
| Empty date input | `date=` (blank) | Error message | "Please enter a date" shown | PASS |
| Existing browse page | `/browse.jsp` | HTTP 200 | HTTP 200 | PASS |
| Existing index page | `/index.jsp` | HTTP 200 | HTTP 200 | PASS |
| Existing search page | `/search.jsp` | HTTP 200 | HTTP 200 | PASS |

## 5.2 Verification

- Searching an **existing date** returns the correct records.
- Searching a **non-existing date** returns an empty result with a user-friendly message.
- The database remains **unchanged** (read-only operation).
- All existing **CRUD operations** still work correctly.

---

# 6. Files Created / Modified

| File | Action | Purpose |
|------|--------|---------|
| `SkillPostDao.java` | **Modified** | Added `searchByDate()` and `searchByDateRange()` methods |
| `SearchSkillPostByDateServlet.java` | **Created** | New servlet handling date search requests |
| `search_by_date.jsp` | **Created** | New JSP page with search form and results display |
| `nav.jsp` | **Modified** | Added "Search by Date" navigation link |

No unrelated files were changed. No existing functionality was removed or broken.

---

# 7. Conclusion

## 7.1 How Search Improves System Usability

The Search by Date feature significantly enhances the BridgeBoard platform by allowing users to:

- **Find recent posts** by searching for today's or yesterday's date.
- **Browse historical posts** by searching for a past date.
- **Narrow results** using the date range feature to find posts within a specific period.

This transforms the system from a simple list-all approach to a more interactive, user-driven experience.

## 7.2 Challenges Faced

1. **Date type conversion:** The `created_at` column stores `TIMESTAMPTZ` (timestamp with timezone), but the search form provides only a date (`YYYY-MM-DD`). The solution was to use `CAST(sp.created_at AS DATE)` in SQL to compare only the date portion.

2. **Two search modes:** Supporting both single-date and date-range search in one servlet required careful parameter detection and validation logic.

3. **Integration with existing architecture:** The new feature had to follow the existing patterns (DAO, Servlet, JSP with scriptlets, `DbUtil` for connections) without introducing frameworks or breaking changes.

## 7.3 How Challenges Were Resolved

- Used SQL `CAST` function for clean date comparison.
- Implemented conditional logic in the servlet to detect which search mode the user is using.
- Followed the exact code patterns of existing servlets and DAO methods (same imports, same try-with-resources style, same `map()` reuse).
- Tested all existing pages after deployment to confirm zero regressions.

---

# 8. Architecture Summary

```
User → JSP Form (search_by_date.jsp)
    → HTTP GET /posts/search-by-date?date=2026-01-29
    → SearchSkillPostByDateServlet (doGet)
        → validates input
        → calls SkillPostDao.searchByDate(LocalDate)
            → PreparedStatement with parameter binding
            → CAST(created_at AS DATE) = ?
            → returns List<SkillPost>
        → sets request attributes
        → forwards to search_by_date.jsp
    → JSP renders results (table + card views)
```

**No SQL injection risk.** All queries use `PreparedStatement` with `?` placeholders.
**No resource leaks.** All JDBC resources use `try-with-resources`.
**No runtime errors.** All inputs are validated before processing.
