package com.bridgeboard.test;

import com.bridgeboard.util.DatabaseConnection;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * DatabaseConnectionTest - Test class to verify JDBC connection
 * 
 * Purpose:
 * - Test database connection to bridgeboard_db
 * - Verify PostgreSQL JDBC driver is working
 * - Display database metadata
 * - List all tables in the database
 * - NO CRUD operations performed (read-only verification)
 * 
 * This class should be run AFTER executing bridgeboard_db.sql
 * to create the database and tables.
 * 
 * @author BridgeBoard Development Team
 * @version 1.0
 */
public class DatabaseConnectionTest {
    
    /**
     * Main method to run connection tests
     * 
     * @param args Command line arguments (not used)
     */
    public static void main(String[] args) {
        System.out.println("\n" + "=".repeat(70));
        System.out.println("  BRIDGEBOARD DATABASE CONNECTION TEST");
        System.out.println("=".repeat(70) + "\n");
        
        // Test 1: Display configuration
        testDisplayConfiguration();
        
        // Test 2: Test connection
        testBasicConnection();
        
        // Test 3: Get database metadata
        testDatabaseMetadata();
        
        // Test 4: List all tables
        testListTables();
        
        // Final summary
        System.out.println("\n" + "=".repeat(70));
        System.out.println("  CONNECTION TEST COMPLETED");
        System.out.println("=".repeat(70) + "\n");
    }
    
    /**
     * Test 1: Display database configuration
     */
    private static void testDisplayConfiguration() {
        System.out.println("📋 TEST 1: Database Configuration");
        System.out.println("-".repeat(70));
        
        try {
            String info = DatabaseConnection.getDatabaseInfo();
            System.out.println(info);
            System.out.println("✅ Test 1 PASSED: Configuration loaded\n");
        } catch (Exception e) {
            System.err.println("❌ Test 1 FAILED: " + e.getMessage() + "\n");
        }
    }
    
    /**
     * Test 2: Basic connection test
     */
    private static void testBasicConnection() {
        System.out.println("🔌 TEST 2: Basic Connection Test");
        System.out.println("-".repeat(70));
        
        Connection connection = null;
        
        try {
            // Attempt to get connection
            connection = DatabaseConnection.getConnection();
            
            // Verify connection is valid
            if (connection != null && !connection.isClosed()) {
                System.out.println("✅ Connection object created successfully");
                System.out.println("✅ Connection is open and valid");
                System.out.println("✅ Test 2 PASSED: Connection established\n");
            } else {
                System.err.println("❌ Test 2 FAILED: Connection is null or closed\n");
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Test 2 FAILED: Connection error");
            System.err.println("   Error: " + e.getMessage() + "\n");
        } finally {
            // Close connection
            DatabaseConnection.closeConnection(connection);
        }
    }
    
    /**
     * Test 3: Get and display database metadata
     */
    private static void testDatabaseMetadata() {
        System.out.println("📊 TEST 3: Database Metadata");
        System.out.println("-".repeat(70));
        
        Connection connection = null;
        
        try {
            connection = DatabaseConnection.getConnection();
            DatabaseMetaData metaData = connection.getMetaData();
            
            System.out.println("Database Product: " + metaData.getDatabaseProductName());
            System.out.println("Database Version: " + metaData.getDatabaseProductVersion());
            System.out.println("Driver Name: " + metaData.getDriverName());
            System.out.println("Driver Version: " + metaData.getDriverVersion());
            System.out.println("Database URL: " + metaData.getURL());
            System.out.println("Database User: " + metaData.getUserName());
            System.out.println("JDBC Version: " + metaData.getJDBCMajorVersion() + "." 
                             + metaData.getJDBCMinorVersion());
            
            System.out.println("\n✅ Test 3 PASSED: Metadata retrieved successfully\n");
            
        } catch (SQLException e) {
            System.err.println("❌ Test 3 FAILED: Could not retrieve metadata");
            System.err.println("   Error: " + e.getMessage() + "\n");
        } finally {
            DatabaseConnection.closeConnection(connection);
        }
    }
    
    /**
     * Test 4: List all tables in the database
     */
    private static void testListTables() {
        System.out.println("📋 TEST 4: List Database Tables");
        System.out.println("-".repeat(70));
        
        Connection connection = null;
        ResultSet tables = null;
        
        try {
            connection = DatabaseConnection.getConnection();
            DatabaseMetaData metaData = connection.getMetaData();
            
            // Get catalog (database name)
            String catalog = connection.getCatalog();
            System.out.println("Database: " + catalog);
            System.out.println("\nTables found:");
            
            // Get all tables
            tables = metaData.getTables(catalog, null, "%", new String[]{"TABLE"});
            
            int tableCount = 0;
            while (tables.next()) {
                tableCount++;
                String tableName = tables.getString("TABLE_NAME");
                String tableType = tables.getString("TABLE_TYPE");
                String remarks = tables.getString("REMARKS");
                
                System.out.println("  " + tableCount + ". " + tableName + " [" + tableType + "]");
                if (remarks != null && !remarks.isEmpty()) {
                    System.out.println("     Description: " + remarks);
                }
            }
            
            if (tableCount == 0) {
                System.out.println("  ⚠️  No tables found!");
                System.out.println("  📌 Make sure to run bridgeboard_db.sql first");
                System.err.println("\n❌ Test 4 WARNING: No tables exist in database\n");
            } else {
                System.out.println("\nTotal tables: " + tableCount);
                System.out.println("✅ Test 4 PASSED: Tables listed successfully\n");
                
                // List table details
                listTableDetails(connection, catalog);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Test 4 FAILED: Could not list tables");
            System.err.println("   Error: " + e.getMessage() + "\n");
        } finally {
            try {
                if (tables != null) tables.close();
            } catch (SQLException e) {
                // Ignore
            }
            DatabaseConnection.closeConnection(connection);
        }
    }
    
    /**
     * List details for each table (columns and keys)
     * 
     * @param connection Active database connection
     * @param catalog Database name
     */
    private static void listTableDetails(Connection connection, String catalog) {
        System.out.println("\n📝 TABLE STRUCTURE DETAILS");
        System.out.println("-".repeat(70));
        
        try {
            DatabaseMetaData metaData = connection.getMetaData();
            
            // Get all tables
            ResultSet tables = metaData.getTables(catalog, null, "%", new String[]{"TABLE"});
            
            while (tables.next()) {
                String tableName = tables.getString("TABLE_NAME");
                System.out.println("\nTable: " + tableName);
                System.out.println("  Columns:");
                
                // Get columns for this table
                ResultSet columns = metaData.getColumns(catalog, null, tableName, "%");
                int colNum = 0;
                while (columns.next()) {
                    colNum++;
                    String columnName = columns.getString("COLUMN_NAME");
                    String columnType = columns.getString("TYPE_NAME");
                    int columnSize = columns.getInt("COLUMN_SIZE");
                    String nullable = columns.getString("IS_NULLABLE");
                    
                    System.out.println("    " + colNum + ". " + columnName + 
                                     " - " + columnType + "(" + columnSize + ")" +
                                     " [Nullable: " + nullable + "]");
                }
                columns.close();
                
                // Get primary keys
                ResultSet primaryKeys = metaData.getPrimaryKeys(catalog, null, tableName);
                System.out.println("  Primary Key:");
                while (primaryKeys.next()) {
                    String pkColumn = primaryKeys.getString("COLUMN_NAME");
                    System.out.println("    - " + pkColumn);
                }
                primaryKeys.close();
                
                // Get foreign keys
                ResultSet foreignKeys = metaData.getImportedKeys(catalog, null, tableName);
                boolean hasForeignKeys = false;
                while (foreignKeys.next()) {
                    if (!hasForeignKeys) {
                        System.out.println("  Foreign Keys:");
                        hasForeignKeys = true;
                    }
                    String fkColumn = foreignKeys.getString("FKCOLUMN_NAME");
                    String pkTable = foreignKeys.getString("PKTABLE_NAME");
                    String pkColumn = foreignKeys.getString("PKCOLUMN_NAME");
                    System.out.println("    - " + fkColumn + " → " + pkTable + "." + pkColumn);
                }
                foreignKeys.close();
            }
            tables.close();
            
        } catch (SQLException e) {
            System.err.println("   Error listing table details: " + e.getMessage());
        }
    }
}
