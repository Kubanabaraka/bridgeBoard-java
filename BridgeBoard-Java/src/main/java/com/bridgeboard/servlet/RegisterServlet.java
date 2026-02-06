package com.bridgeboard.servlet;

import com.bridgeboard.dao.UserDao;
import com.bridgeboard.model.User;
import com.bridgeboard.util.CsrfUtil;
import com.bridgeboard.util.FlashUtil;
import com.bridgeboard.util.FormUtil;
import com.bridgeboard.util.UploadUtil;
import com.bridgeboard.util.ValidationUtil;
import org.mindrot.jbcrypt.BCrypt;

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

@WebServlet(name = "RegisterServlet", urlPatterns = "/auth/register")
@MultipartConfig
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String csrf = request.getParameter("csrf_token");
        if (!CsrfUtil.isValid(session, csrf)) {
            FlashUtil.put(session, "error", "Invalid session token.");
            response.sendRedirect(request.getContextPath() + "/register.jsp");
            return;
        }

        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email"));
        String password = trim(request.getParameter("password"));
        String confirmation = trim(request.getParameter("password_confirmation"));
        String location = trim(request.getParameter("location"));
        String bio = trim(request.getParameter("bio"));

        Map<String, String> old = new HashMap<>();
        old.put("name", name);
        old.put("email", email);
        old.put("location", location);
        old.put("bio", bio);
        FormUtil.setOldInput(session, old);

        Map<String, List<String>> errors = new HashMap<>();
        if (name.isEmpty() || name.length() < 3) {
            ValidationUtil.addError(errors, "name", "Name must be at least 3 characters.");
        }
        if (email.isEmpty() || !email.contains("@")) {
            ValidationUtil.addError(errors, "email", "Enter a valid email address.");
        }
        if (password.length() < 6) {
            ValidationUtil.addError(errors, "password", "Password must be at least 6 characters.");
        }
        if (!password.equals(confirmation)) {
            ValidationUtil.addError(errors, "password", "Passwords do not match.");
        }

        UserDao userDao = new UserDao();
        if (userDao.findByEmail(email) != null) {
            ValidationUtil.addError(errors, "email", "An account with this email already exists.");
        }

        if (ValidationUtil.hasErrors(errors)) {
            FormUtil.setErrors(session, errors);
            response.sendRedirect(request.getContextPath() + "/register.jsp");
            return;
        }

        String avatarPath = null;
        Part avatar = request.getPart("avatar");
        if (avatar != null && avatar.getSize() > 0) {
            avatarPath = UploadUtil.saveSingle(avatar, getServletContext());
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
        user.setBio(bio.isEmpty() ? null : bio);
        user.setLocation(location.isEmpty() ? null : location);
        user.setAvatarPath(avatarPath);

        int userId = userDao.create(user);
        if (userId <= 0) {
            FlashUtil.put(session, "error", "Unable to create account.");
            response.sendRedirect(request.getContextPath() + "/register.jsp");
            return;
        }

        user.setId(userId);
        session.removeAttribute("user");
        FormUtil.clearOldInput(session);
        FlashUtil.put(session, "success", "Account created successfully! Please log in.");
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
