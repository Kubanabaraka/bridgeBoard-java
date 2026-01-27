# Title Page

**Lab Title:** Implementing CREATE (INSERT) Operation in Java Backend  
**Course / Learning Unit:** Learning Unit 6 – Java Backend Development  
**Student Name:** ******\*\*******\_\_******\*\*******  
**Registration Number:** ****\*\*****\_\_\_\_****\*\*****  
**Date:** ********\*\*********\_\_\_********\*\*********

---

# 2. Introduction

Learning Unit 6 focuses on server‑side data persistence using Java and relational databases. In this unit, students learn how to connect a Java backend to a database and execute data manipulation commands safely using JDBC and prepared statements. The CREATE (INSERT) operation is a foundational requirement in backend development because it enables the system to store new user‑generated content and application data in a structured and consistent way.
Practical Lab Report: User Management System Using Spring MVC (Login & CRUD Operations)

1. Project Overview
   Project Title
   Developing a User Management System Using Spring MVC (Login & CRUD Operations)

Introduction
This project presents the design and implementation of a User Management System developed using the Spring MVC framework. The application is a Java-based web system that enables administrators to manage users through secure authentication and complete CRUD (Create, Read, Update, Delete) operations.

The system is built following the Model–View–Controller (MVC) architectural pattern and utilizes JSP for the presentation layer, XML-based configuration for Spring MVC setup, and JDBC for database interaction with a relational database. The project demonstrates how enterprise Java web applications are structured, configured, and connected to a backend database in a clear and maintainable manner.

Purpose of the Project
The main purpose of this project is to demonstrate a practical understanding of the Spring MVC architecture by implementing a complete user management workflow. It showcases the integration of Maven, JSP, XML configuration, and JDBC to build a functional, database-driven web application that meets academic lab requirements.

2. Technology Stack
   Java

Spring MVC

Maven

JSP (JavaServer Pages)

XML Configuration

JDBC (Java Database Connectivity)

PostgreSQL (Relational Database)
(Acceptable per lab requirement: MySQL or any relational database)

3. System Architecture (Spring MVC)
   The application follows the Model–View–Controller (MVC) design pattern to ensure separation of concerns and maintainability.

Model Layer
Represents the application’s data and business logic.

Implemented using the User model class.

Contains fields such as:

userId

username

password

email

role

createdDate

View Layer
Provides the user interface of the application.

Implemented using JSP pages.

Includes the following pages:

Login page

Registration page

User list page

Edit user page

Controller Layer
Handles HTTP requests and application flow.

Acts as an intermediary between the View and Model layers.

Implements features such as:

User login

User registration

User update

User deletion

User listing

4. Database Process
   4.1 Database Creation
   Database Name: user_management_db

4.2 Table Creation SQL
CREATE TABLE users (

    user_id SERIAL PRIMARY KEY,

    username VARCHAR(50) UNIQUE NOT NULL,

    password VARCHAR(255) NOT NULL,

    email VARCHAR(100) NOT NULL,

    role VARCHAR(20),

    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

4.3 Table Structure Explanation
user_id: Primary key, auto-incremented.

username: Unique identifier used for login.

password: Stores the user’s password.

email: User’s email address.

role: Defines user role (ADMIN, USER, MANAGER).

created_date: Stores the date and time the user account was created.

4.4 Sample Data Inserted
admin / admin123

john_doe / password123

jane_smith / password123

5. Implementation Details
   5.1 XML Configuration Files
   web.xml
   Defines the DispatcherServlet.

Configures Spring MVC initialization.

Sets character encoding filters.

dispatcher-servlet.xml
Enables annotation-driven Spring MVC.

Configures component scanning for controllers and DAO classes.

Defines the JSP view resolver.

Configures the JDBC DataSource.

5.2 JDBC Database Connection
Configured in dispatcher-servlet.xml using DriverManagerDataSource.

Connection Details:

URL: jdbc:postgresql://localhost:5432/user_management_db

Username: ums_user

Password: password123

5.3 CRUD Operations (DAO Layer)
Implemented in UserDAO.java, including the following methods:

registerUser(User user) → Inserts a new user into the database.

getAllUsers() → Retrieves all users from the database.

getUserById(int id) → Fetches a single user by ID.

updateUser(User user) → Updates an existing user record.

deleteUser(int id) → Deletes a user by ID.

5.4 Login Authentication
The login form submits the username and password to /login using POST.

The DAO verifies credentials against the database.

On successful authentication: user is redirected to the user list page.

On failure: an error message is displayed on the login page.

6. Functional Requirements Mapping
   Requirement

Implemented Feature

User Login

/login (GET / POST)

User Registration

/register (GET / POST)

Edit User

/edit/{id} (GET / POST)

Delete User

/delete/{id} (GET)

View User List

/userlist (GET)

7. Screenshots section
   7.1 Project Structure (Maven)

Description:
Screenshot showing the Maven project directory structure as displayed in the VS Code file explorer, including src folders, configuration files, and dependencies.

7.2 XML Configuration Files

Description:
Screenshots displaying the contents of Spring MVC configuration files.

web.xml: Shows DispatcherServlet and filter configuration.

dispatcher-servlet.xml: Shows component scanning, view resolver, and JDBC configuration.

7.3 Database Table

Description:
Screenshots showing the users table structure and sample data using pgAdmin or psql.

7.4 Login Form

Description:
Screenshot of the login page displaying username and password input fields.

7.5 Registration Form

Description:
Screenshot of the registration page showing fields for username, password, email, and role selection.

7.6 User List Page

Description:
Screenshot displaying the list of users in a table format with edit and delete action buttons.

7.7 Edit User Page
7.8 Before and After Update/Delete
Description:
Screenshots showing the user list before and after performing update or delete operations.

8. Conclusion
   This project successfully implemented a User Management System using the Spring MVC architecture. All required functionalities—including user authentication, registration, listing, updating, and deletion—were fully developed and tested. The application clearly demonstrates proper separation of concerns through the use of Model, View, and Controller layers, supported by XML-based configuration, JSP views, and JDBC-based data persistence.

Challenges Faced and Solutions
Issue:
Permission denied for sequence users_user_id_seq during user registration.

Solution:
The issue was resolved by granting appropriate sequence permissions to the database user using the following SQL command:

GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO ums_user;

Overall, the project meets all specified lab requirements and is fully functional, well-structured, and ready for demonstration and academic evaluation.
The purpose of this lab is to demonstrate how a Java backend application performs a CREATE (INSERT) operation into a relational database using JDBC, without introducing UPDATE, DELETE, or SELECT operations.

---

# 3. Project Overview

BridgeBoard is a community skill exchange platform where users can publish skill offerings and requests. The application is implemented in Java using JSP and Servlets, with a relational database backend.

The **skill_posts** table is used in this lab because it represents the core content created by users: skill listings containing title, description, category, and pricing information. Implementing INSERT on this table allows the platform to store new skill posts submitted from the web interface.

The purpose of inserting skill posts into the database is to persist user contributions so they can later be displayed, searched, and exchanged within the platform.

---

# 4. Database Process

## 4.1 Database Creation

The database is already created and configured for the BridgeBoard project. The database name used is **bridgeboard_db**.

📸 **Screenshot Placeholder:**  
[Screenshot 1: Database created in MySQL]

---

## 4.2 Table Structure: skill_posts

The **skill_posts** table stores all user‑submitted skill listings. Each column supports a specific aspect of a post and ensures that entries are complete, structured, and valid.

**Columns and Roles:**

1. **id** – Primary key; uniquely identifies each skill post.
2. **user_id** – Foreign key; identifies the user who created the post.
3. **category_id** – Foreign key; links the post to a skill category.
4. **title** – Title of the skill post.
5. **description** – Detailed explanation of the skill offering or request.
6. **post_type** – Indicates whether the post is an offer, request, or exchange.
7. **location** – Location information for the skill exchange.
8. **price_min** – Minimum suggested price (optional).
9. **price_max** – Maximum suggested price (optional).
10. **images** – JSON list of image paths associated with the post.
11. **status** – Current state (active, paused, closed).
12. **views_count** – Counter for post views.
13. **created_at** – Timestamp for when the post was created.
14. **updated_at** – Timestamp for the last update (if any).

📸 **Screenshot Placeholder:**  
[Screenshot 2: SQL structure of skill_posts table]

---

# 5. Java Implementation

## 5.1 JDBC Database Connection

The BridgeBoard application uses JDBC to connect Java code to the database. The connection logic is centralized in a connection utility class, which loads the JDBC driver, reads database configuration, and provides a reusable method for obtaining connections.

The connection class ensures that database connectivity is consistent and secure across the application. It enables the CREATE (INSERT) operation in the DAO layer by supplying a valid connection to the database.

📸 **Screenshot Placeholder:**  
[Screenshot 3: Java database connection source]()

---

# 6. CREATE (INSERT) Operation Design

The CREATE operation inserts a new record into the **skill_posts** table when a user submits a new skill post through the interface. The Java backend uses a DAO (Data Access Object) method that accepts a `SkillPost` object and prepares an INSERT statement with placeholders.

Key design points:

- Uses **PreparedStatement** to prevent SQL injection.
- Maps Java object fields to SQL columns.
- Retrieves the generated primary key after insertion.
- Handles null values (e.g., optional category or location).

---

# 7. Implementation Steps (CREATE Only)

1. **User submits the Create Post form** in the web interface.
2. **Servlet validates inputs** and constructs a `SkillPost` object.
3. **DAO executes INSERT** using a prepared SQL statement.
4. **Database returns generated ID** for the newly inserted post.
5. **Application confirms success** and redirects the user.

---

# 8. SQL Insert Statement (Conceptual)

The INSERT operation follows this structure:

- **Target table:** `skill_posts`
- **Inserted fields:** `user_id`, `category_id`, `title`, `description`, `location`, `price_min`, `price_max`, `images`, `status`

📌 _Note:_ The exact SQL used is implemented in Java using placeholders for security.

---

# 9. Output Verification

Successful insertion is confirmed by:

- Database auto‑generated ID returned to Java.
- The new post appearing in the application after redirect.

📸 **Screenshot Placeholder:**  
[Screenshot 4: Successful insertion output]

---

# 10. Conclusion

This lab demonstrated how to implement the CREATE (INSERT) operation in a Java backend application using JDBC. The skill_posts table was selected because it represents the primary user‑generated content in BridgeBoard. The use of prepared statements ensured secure and reliable insertion into the database. The implementation completed the objective of Learning Unit 6 by successfully persisting new skill posts.

---

# 11. References

- Java SE 11 Documentation
- JDBC API Documentation
- PostgreSQL Documentation
- BridgeBoard Project Source Code
