package com.bridgeboard.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class DbUtil {
    private static final Properties PROPS = new Properties();

    static {
        try (InputStream input = DbUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                PROPS.load(input);
            }
        } catch (IOException ignored) {
        }
    }

    private DbUtil() {
    }

    public static Connection getConnection() throws SQLException {
        String url = envOrProp("DB_URL", "db.url");
        String user = envOrProp("DB_USER", "db.user");
        String password = envOrProp("DB_PASSWORD", "db.password");
        return DriverManager.getConnection(url, user, password);
    }

    private static String envOrProp(String envKey, String propKey) {
        String env = System.getenv(envKey);
        if (env != null && !env.isBlank()) {
            return env;
        }
        return PROPS.getProperty(propKey);
    }
}
