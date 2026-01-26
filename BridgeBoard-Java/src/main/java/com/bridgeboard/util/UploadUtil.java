package com.bridgeboard.util;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public final class UploadUtil {
    private UploadUtil() {
    }

    public static String saveSingle(Part part, ServletContext context) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }
        return savePart(part, context);
    }

    public static List<String> saveMultiple(List<Part> parts, ServletContext context) throws IOException {
        List<String> paths = new ArrayList<>();
        if (parts == null) {
            return paths;
        }
        for (Part part : parts) {
            if (part != null && part.getSize() > 0) {
                paths.add(savePart(part, context));
            }
        }
        return paths;
    }

    private static String savePart(Part part, ServletContext context) throws IOException {
        String uploadsDir = context.getRealPath("/assets/uploads");
        if (uploadsDir == null) {
            throw new IOException("Unable to resolve upload directory.");
        }
        Files.createDirectories(Paths.get(uploadsDir));

        String submitted = part.getSubmittedFileName();
        String ext = "";
        if (submitted != null && submitted.contains(".")) {
            ext = submitted.substring(submitted.lastIndexOf('.'));
        }
        String filename = UUID.randomUUID().toString().replace("-", "") + ext;
        File target = new File(uploadsDir, filename);
        part.write(target.getAbsolutePath());
        return "assets/uploads/" + filename;
    }
}
