package com.bridgeboard.servlet;

import com.bridgeboard.dao.SkillPostDao;
import com.bridgeboard.model.SkillPost;
import com.bridgeboard.model.User;
import com.bridgeboard.util.CsrfUtil;
import com.bridgeboard.util.FlashUtil;
import com.bridgeboard.util.FormUtil;
import com.bridgeboard.util.JsonUtil;
import com.bridgeboard.util.UploadUtil;
import com.bridgeboard.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "PostCreateServlet", urlPatterns = "/posts/store")
@MultipartConfig
public class PostCreateServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            FlashUtil.put(session, "error", "Please log in to continue.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String csrf = request.getParameter("csrf_token");
        if (!CsrfUtil.isValid(session, csrf)) {
            FlashUtil.put(session, "error", "Invalid session token.");
            response.sendRedirect(request.getContextPath() + "/create_post.jsp");
            return;
        }

        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String location = trim(request.getParameter("location"));
        String categoryIdRaw = trim(request.getParameter("category_id"));
        String priceMinRaw = trim(request.getParameter("price_min"));
        String priceMaxRaw = trim(request.getParameter("price_max"));

        Map<String, String> old = new HashMap<>();
        old.put("title", title);
        old.put("description", description);
        old.put("location", location);
        old.put("category_id", categoryIdRaw);
        old.put("price_min", priceMinRaw);
        old.put("price_max", priceMaxRaw);
        FormUtil.setOldInput(session, old);

        Map<String, List<String>> errors = new HashMap<>();
        if (title.length() < 4) {
            ValidationUtil.addError(errors, "title", "Title must be at least 4 characters.");
        }
        if (description.length() < 20) {
            ValidationUtil.addError(errors, "description", "Description must be at least 20 characters.");
        }

        if (ValidationUtil.hasErrors(errors)) {
            FormUtil.setErrors(session, errors);
            response.sendRedirect(request.getContextPath() + "/create_post.jsp");
            return;
        }

        List<Part> imageParts = new ArrayList<>();
        for (Part part : request.getParts()) {
            if ("images".equals(part.getName())) {
                imageParts.add(part);
            }
        }
        List<String> imagePaths = UploadUtil.saveMultiple(imageParts, getServletContext());

        SkillPost post = new SkillPost();
        post.setUserId(user.getId());
        post.setTitle(title);
        post.setDescription(description);
        post.setLocation(location.isEmpty() ? null : location);
        post.setStatus("active");
        if (!categoryIdRaw.isEmpty()) {
            post.setCategoryId(Integer.parseInt(categoryIdRaw));
        }
        if (!priceMinRaw.isEmpty()) {
            post.setPriceMin(new BigDecimal(priceMinRaw));
        }
        if (!priceMaxRaw.isEmpty()) {
            post.setPriceMax(new BigDecimal(priceMaxRaw));
        }

        SkillPostDao dao = new SkillPostDao();
        dao.create(post, JsonUtil.toJson(imagePaths));

        FormUtil.clearOldInput(session);
        FlashUtil.put(session, "success", "Skill post published!");
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
