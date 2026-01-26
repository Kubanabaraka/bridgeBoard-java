package com.bridgeboard.util;

import jakarta.servlet.http.HttpSession;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class FormUtil {
    private static final String OLD_INPUT = "old_input";
    private static final String ERRORS = "flash_errors";

    private FormUtil() {
    }

    public static void setOldInput(HttpSession session, Map<String, String> input) {
        session.setAttribute(OLD_INPUT, new HashMap<>(input));
    }

    @SuppressWarnings("unchecked")
    public static Map<String, String> getOldInput(HttpSession session) {
        Object value = session.getAttribute(OLD_INPUT);
        if (value instanceof Map) {
            return (Map<String, String>) value;
        }
        return Collections.emptyMap();
    }

    public static void clearOldInput(HttpSession session) {
        session.removeAttribute(OLD_INPUT);
    }

    public static void setErrors(HttpSession session, Map<String, List<String>> errors) {
        session.setAttribute(ERRORS, errors);
    }

    @SuppressWarnings("unchecked")
    public static Map<String, List<String>> consumeErrors(HttpSession session) {
        Object value = session.getAttribute(ERRORS);
        session.removeAttribute(ERRORS);
        if (value instanceof Map) {
            return (Map<String, List<String>>) value;
        }
        return Collections.emptyMap();
    }

    public static String old(HttpSession session, String key) {
        return getOldInput(session).getOrDefault(key, "");
    }
}
