# 🚀 BridgeBoard Database - Quick Start Guide

## Step 1: Create the Database ⚙️

```bash
# Connect to PostgreSQL
psql -U postgres

# Or execute SQL file directly
psql -U postgres -f sql/bridgeboard_db_pg.sql
```

Or from PostgreSQL prompt:

```sql
\i sql/bridgeboard_db_pg.sql
```

## Step 2: Configure Database Connection 🔧

Edit: `src/main/resources/db.properties`

```properties
db.url=jdbc:postgresql://localhost:5432/bridgeboard_db
db.user=postgres
db.password=YOUR_POSTGRES_PASSWORD_HERE
```

**⚠️ IMPORTANT:** Replace `YOUR_POSTGRES_PASSWORD_HERE` with your actual PostgreSQL password!

## Step 3: Compile the Project 📦

```bash
cd /home/baraka/Java_Project/BridgeBoard-Java
mvn clean compile
```

## Step 4: Test Database Connection 🧪

```bash
mvn exec:java -Dexec.mainClass="com.bridgeboard.test.DatabaseConnectionTest"
```

### Expected Output ✅

```
======================================================================
  BRIDGEBOARD DATABASE CONNECTION TEST
======================================================================

✓ PostgreSQL JDBC Driver loaded successfully
✅ DATABASE CONNECTION SUCCESSFUL!
  Connected to: jdbc:postgresql://localhost:5432/bridgeboard_db

Tables found:
  1. users [TABLE]
  2. categories [TABLE]
  3. skill_posts [TABLE]
  4. messages [TABLE]
  5. skill_exchanges [TABLE]
  6. reviews [TABLE]
  7. favorites [TABLE]

Total tables: 7
✅ Test 4 PASSED: Tables listed successfully
```

## Database Tables Overview 📊

| Table               | Purpose                  | Key Relationships               |
| ------------------- | ------------------------ | ------------------------------- |
| **users**           | User accounts            | Parent of all user-related data |
| **categories**      | Skill categories         | Referenced by skill_posts       |
| **skill_posts**     | Skill offerings/requests | References users & categories   |
| **messages**        | User communications      | References users & posts        |
| **skill_exchanges** | Exchange transactions    | References users & posts        |
| **reviews**         | User ratings             | References exchanges & users    |
| **favorites**       | Bookmarked posts         | References users & posts        |

## Key Files 📁

```
BridgeBoard-Java/
├── sql/
│   └── bridgeboard_db_pg.sql           # Database creation script
├── src/main/
│   ├── java/com/bridgeboard/
│   │   ├── util/
│   │   │   └── DatabaseConnection.java  # JDBC connection manager
│   │   └── test/
│   │       └── DatabaseConnectionTest.java  # Connection test
│   └── resources/
│       └── db.properties               # Database configuration
└── DATABASE_DESIGN.md                  # Complete documentation
```

## Troubleshooting 🔍

### Issue 1: Connection Failed

```
❌ Access denied for user 'root'@'localhost'
```

**Solution:** Update password in db.properties

### Issue 2: Database Not Found

```
❌ Unknown database 'bridgeboard_db'
```

**Solution:** Run `sql/bridgeboard_db_pg.sql` first

### Issue 3: PostgreSQL Not Running

```
❌ Communications link failure
```

**Solution:**

```bash
# Linux/Mac
sudo systemctl start postgresql

# Windows (as Admin)
net start postgresql-x64-13
```

### Issue 4: Driver Not Found

```
❌ PostgreSQL JDBC Driver not found
```

**Solution:** Run `mvn clean install`

## Verify Database Creation 🔎

```bash
psql -U postgres -d bridgeboard_db -c "\dt"
```

Expected output:

```
+---------------------------+
| Tables_in_bridgeboard_db  |
+---------------------------+
| categories                |
| favorites                 |
| messages                  |
| reviews                   |
| skill_exchanges           |
| skill_posts               |
| users                     |
+---------------------------+
```

## Next Steps ⏭️

✅ **COMPLETED:**

- ✓ Database design
- ✓ Table creation
- ✓ JDBC connection setup
- ✓ Connection testing

⏸️ **WAITING (Do NOT implement yet):**

- ⏸️ CRUD operations (INSERT, UPDATE, DELETE, SELECT)
- ⏸️ Data Access Objects (DAO classes)
- ⏸️ Business logic
- ⏸️ Authentication system

**STOP HERE** and wait for next instruction before implementing any database operations!

## Help & Documentation 📚

- Full documentation: `DATABASE_DESIGN.md`
- SQL schema: `sql/bridgeboard_db_pg.sql`
- Connection class: `src/main/java/com/bridgeboard/util/DatabaseConnection.java`
- Test class: `src/main/java/com/bridgeboard/test/DatabaseConnectionTest.java`

---

**Ready for Phase 2: CRUD Operations Implementation**
