package com.bridgeboard.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public final class ValidationUtil {
    private ValidationUtil() {
    }

    public static void addError(Map<String, List<String>> errors, String field, String message) {
        errors.computeIfAbsent(field, key -> new ArrayList<>()).add(message);
    }

    public static boolean hasErrors(Map<String, List<String>> errors) {
        return errors != null && !errors.isEmpty();
    }
}
