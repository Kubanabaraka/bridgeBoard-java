# BridgeBoard (Java/JSP/Tomcat)

BridgeBoard is a Java/JSP/Tomcat conversion of the original PHP project. It uses JSP for rendering, JDBC for MySQL access, and session-based authentication.

## Requirements

- Java 11+
- Maven 3.8+
- MySQL 8+
- Apache Tomcat 9+

## Setup

1. Create the database:

   - Run the SQL script: `sql/bridgeboard.sql`.

2. Configure JDBC:

   - Edit `src/main/resources/db.properties`:

     ```
     db.url=jdbc:mysql://localhost:3306/bridgeboard?useSSL=false&serverTimezone=UTC
     db.user=root
     db.password=your_password
     ```

   - Or use environment variables: `DB_URL`, `DB_USER`, `DB_PASSWORD`.

3. Build the WAR:

   ```
   mvn clean package
   ```

4. Deploy to Tomcat:

   - Copy `target/bridgeboard.war` to your Tomcat `webapps` directory.
   - Start Tomcat.

5. Open in browser:

   - `http://localhost:8080/bridgeboard/index.jsp`

## Project Structure

- `src/main/java` – Servlets, DAOs, models, utilities
- `src/main/webapp` – JSP pages, assets, includes
- `sql/bridgeboard.sql` – Schema and seed data

## Notes

- Authentication uses JSP implicit `session` and stores the logged-in user with:
  - `session.setAttribute("user", userObject)`
- CSRF tokens are stored in session and embedded in forms.
- File uploads are stored under `assets/uploads` in the deployed webapp.

## URLs

- Home: `/index.jsp`
- Browse: `/browse.jsp`
- Search: `/search.jsp`
- Login: `/login.jsp`
- Register: `/register.jsp`
- Dashboard: `/dashboard.jsp`
- Profile: `/profile.jsp`
- Messages: `/contact.jsp`
