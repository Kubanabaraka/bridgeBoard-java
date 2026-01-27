package com.bridgeboard.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * DatabaseConnection - JDBC Connection Manager for BridgeBoard
 * 
 * Purpose:
 * - Establishes connection to PostgreSQL database (bridgeboard_db)
 * - Loads PostgreSQL JDBC driver
 * - Handles connection errors gracefully
 * - Reads database credentials from db.properties or environment variables
 * 
 * This class provides a centralized connection management system
 * for the BridgeBoard community skill exchange platform.
 * 
 * @author BridgeBoard Development Team
 * @version 1.0
 */
public final class DatabaseConnection {
    
    // Database configuration properties
    private static final Properties DB_PROPERTIES = new Properties();
    
    // JDBC driver class name for PostgreSQL
    private static final String POSTGRES_DRIVER = "org.postgresql.Driver";
    
    // Flag to track if driver is loaded
    private static boolean driverLoaded = false;
    
    // Static initialization block - loads properties and driver
    static {
        loadDatabaseProperties();
        loadJdbcDriver();
    }
    
    /**
     * Private constructor to prevent instantiation.
     * This is a utility class with static methods only.
     */
    private DatabaseConnection() {
        throw new AssertionError("DatabaseConnection is a utility class and should not be instantiated");
    }
    
    /**
     * Load database properties from db.properties file
     */
    private static void loadDatabaseProperties() {
        try (InputStream input = DatabaseConnection.class
                .getClassLoader()
                .getResourceAsStream("db.properties")) {
            
            if (input == null) {
                System.err.println("⚠️  WARNING: db.properties file not found in resources folder");
                System.err.println("   Using default database configuration or environment variables");
                return;
            }
            
            DB_PROPERTIES.load(input);
            System.out.println("✓ Database properties loaded successfully");
            
        } catch (IOException e) {
            System.err.println("❌ ERROR: Failed to load database properties");
            System.err.println("   Reason: " + e.getMessage());
        }
    }
    
    /**
    * Load PostgreSQL JDBC driver
     */
    private static void loadJdbcDriver() {
        try {
            Class.forName(POSTGRES_DRIVER);
            driverLoaded = true;
            System.out.println("✓ PostgreSQL JDBC Driver loaded successfully: " + POSTGRES_DRIVER);
        } catch (ClassNotFoundException e) {
            driverLoaded = false;
            System.err.println("❌ CRITICAL ERROR: PostgreSQL JDBC Driver not found!");
            System.err.println("   Driver class: " + POSTGRES_DRIVER);
            System.err.println("   Make sure postgresql is in your classpath");
            System.err.println("   Check pom.xml dependencies");
        }
    }
    
    /**
     * Get database connection
     * 
     * Priority order for configuration:
     * 1. Environment variables (DB_URL, DB_USER, DB_PASSWORD)
     * 2. db.properties file values
     * 3. Default values
     * 
     * @return Connection object to bridgeboard_db database
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        
        // Check if driver is loaded
        if (!driverLoaded) {
            throw new SQLException("PostgreSQL JDBC Driver not loaded. Cannot establish connection.");
        }
        
        // Get database credentials
        String url = getDatabaseUrl();
        String username = getDatabaseUsername();
        String password = getDatabasePassword();
        
        // Display connection attempt info (without password)
        System.out.println("\n" + "=".repeat(60));
        System.out.println("📡 Attempting to connect to database...");
        System.out.println("   URL: " + url);
        System.out.println("   User: " + username);
        System.out.println("=".repeat(60));
        
        try {
            // Attempt connection
            Connection connection = DriverManager.getConnection(url, username, password);
            
            // Success message
            System.out.println("✅ DATABASE CONNECTION SUCCESSFUL!");
            System.out.println("   Connected to: " + url);
            System.out.println("   Connection valid: " + connection.isValid(2));
            System.out.println("   Database: " + connection.getCatalog());
            System.out.println("=".repeat(60) + "\n");
            
            return connection;
            
        } catch (SQLException e) {
            // Detailed error message
            System.err.println("❌ DATABASE CONNECTION FAILED!");
            System.err.println("=".repeat(60));
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Message: " + e.getMessage());
            System.err.println("=".repeat(60));
            System.err.println("\n🔍 Troubleshooting Steps:");
            System.err.println("   1. Verify PostgreSQL server is running");
            System.err.println("   2. Check database 'bridgeboard_db' exists");
            System.err.println("   3. Verify username and password are correct");
            System.err.println("   4. Ensure PostgreSQL is listening on localhost:5432");
            System.err.println("   5. Check firewall settings");
            System.err.println("   6. Review db.properties configuration\n");
            
            throw e;
        }
    }
    
    /**
     * Get database URL from environment or properties
     * 
     * @return Database JDBC URL
     */
    private static String getDatabaseUrl() {
        return getConfigValue(
            "DB_URL", 
            "db.url", 
            "jdbc:postgresql://localhost:5432/bridgeboard_db"
        );
    }
    
    /**
     * Get database username from environment or properties
     * 
     * @return Database username
     */
    private static String getDatabaseUsername() {
        return getConfigValue("DB_USER", "db.user", "postgres");
    }
    
    /**
     * Get database password from environment or properties
     * 
     * @return Database password
     */
    private static String getDatabasePassword() {
        return getConfigValue("DB_PASSWORD", "db.password", "");
    }
    
    /**
     * Get configuration value with priority:
     * 1. Environment variable
     * 2. Properties file
     * 3. Default value
     * 
     * @param envKey Environment variable name
     * @param propKey Properties file key
     * @param defaultValue Default value if neither exists
     * @return Configuration value
     */
    private static String getConfigValue(String envKey, String propKey, String defaultValue) {
        // Check environment variable first
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.trim().isEmpty()) {
            return envValue;
        }
        
        // Check properties file second
        String propValue = DB_PROPERTIES.getProperty(propKey);
        if (propValue != null && !propValue.trim().isEmpty()) {
            return propValue;
        }
        
        // Return default value
        return defaultValue;
    }
    
    /**
     * Test database connection (convenience method)
     * 
     * @return true if connection successful, false otherwise
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && conn.isValid(2);
        } catch (SQLException e) {
            return false;
        }
    }
    
    /**
     * Close database connection safely
     * 
     * @param connection Connection to close
     */
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("✓ Database connection closed");
            } catch (SQLException e) {
                System.err.println("⚠️  Warning: Error closing connection - " + e.getMessage());
            }
        }
    }
    
    /**
     * Get database information (for debugging)
     * 
     * @return String with database configuration info
     */
    public static String getDatabaseInfo() {
        StringBuilder info = new StringBuilder();
        info.append("Database Configuration:\n");
        info.append("  Driver Loaded: ").append(driverLoaded).append("\n");
        info.append("  URL: ").append(getDatabaseUrl()).append("\n");
        info.append("  Username: ").append(getDatabaseUsername()).append("\n");
        info.append("  Driver: ").append(POSTGRES_DRIVER).append("\n");
        return info.toString();
    }
}
