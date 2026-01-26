package com.bridgeboard.util;

import jakarta.servlet.http.HttpSession;
import java.security.SecureRandom;

public final class CsrfUtil {
    private static final String TOKEN_KEY = "csrf_token";
    private static final SecureRandom RANDOM = new SecureRandom();

    private CsrfUtil() {
    }

    public static String getToken(HttpSession session) {
        Object existing = session.getAttribute(TOKEN_KEY);
        if (existing instanceof String) {
            return (String) existing;
        }
        String token = generateToken();
        session.setAttribute(TOKEN_KEY, token);
        return token;
    }

    public static boolean isValid(HttpSession session, String token) {
        Object stored = session.getAttribute(TOKEN_KEY);
        return stored instanceof String && token != null && token.equals(stored);
    }

    private static String generateToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
