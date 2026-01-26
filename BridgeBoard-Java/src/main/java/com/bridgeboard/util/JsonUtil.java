package com.bridgeboard.util;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Collections;
import java.util.List;

public final class JsonUtil {
    private static final Gson GSON = new Gson();
    private static final Type LIST_STRING = new TypeToken<List<String>>() {}.getType();

    private JsonUtil() {
    }

    public static List<String> parseImages(String json) {
        if (json == null || json.isBlank()) {
            return Collections.emptyList();
        }
        try {
            List<String> images = GSON.fromJson(json, LIST_STRING);
            return images == null ? Collections.emptyList() : images;
        } catch (Exception ex) {
            return Collections.emptyList();
        }
    }

    public static String toJson(List<String> values) {
        if (values == null || values.isEmpty()) {
            return null;
        }
        return GSON.toJson(values);
    }
}
