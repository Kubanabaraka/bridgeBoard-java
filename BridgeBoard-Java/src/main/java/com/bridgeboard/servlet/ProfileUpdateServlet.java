package com.bridgeboard.servlet;

import com.bridgeboard.dao.UserDao;
import com.bridgeboard.model.User;
import com.bridgeboard.util.CsrfUtil;
import com.bridgeboard.util.FlashUtil;
import com.bridgeboard.util.FormUtil;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ProfileUpdateServlet", urlPatterns = "/profile/update")
@MultipartConfig
public class ProfileUpdateServlet extends HttpServlet {
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
            response.sendRedirect(request.getContextPath() + "/profile.jsp");
            return;
        }

        String name = trim(request.getParameter("name"));
        String bio = trim(request.getParameter("bio"));
        String location = trim(request.getParameter("location"));

        Map<String, String> old = new HashMap<>();
        old.put("name", name);
        old.put("bio", bio);
        old.put("location", location);
        FormUtil.setOldInput(session, old);

        Map<String, List<String>> errors = new HashMap<>();
        if (name.isEmpty() || name.length() < 3) {
            ValidationUtil.addError(errors, "name", "Name must be at least 3 characters.");
        }

        if (ValidationUtil.hasErrors(errors)) {
            FormUtil.setErrors(session, errors);
            response.sendRedirect(request.getContextPath() + "/profile.jsp");
            return;
        }

        Part avatar = request.getPart("avatar");
        String avatarPath = user.getAvatarPath();
        if (avatar != null && avatar.getSize() > 0) {
            avatarPath = UploadUtil.saveSingle(avatar, getServletContext());
        }

        UserDao dao = new UserDao();
        user.setName(name);
        user.setBio(bio.isEmpty() ? null : bio);
        user.setLocation(location.isEmpty() ? null : location);
        user.setAvatarPath(avatarPath);
        dao.updateProfile(user);

        session.setAttribute("user", user);
        FlashUtil.put(session, "success", "Profile updated.");
        response.sendRedirect(request.getContextPath() + "/profile.jsp");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
