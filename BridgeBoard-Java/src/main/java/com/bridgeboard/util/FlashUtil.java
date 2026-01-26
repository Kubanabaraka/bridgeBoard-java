package com.bridgeboard.util;

import jakarta.servlet.http.HttpSession;

public final class FlashUtil {
    private FlashUtil() {
    }

    public static void put(HttpSession session, String key, Object value) {
        session.setAttribute("flash_" + key, value);
    }

    public static Object consume(HttpSession session, String key) {
        Object value = session.getAttribute("flash_" + key);
        session.removeAttribute("flash_" + key);
        return value;
    }

    public static Object peek(HttpSession session, String key) {
        return session.getAttribute("flash_" + key);
    }
}
