package com.bridgeboard.servlet;

import com.bridgeboard.dao.UserDao;
import com.bridgeboard.model.User;
import com.bridgeboard.util.CsrfUtil;
import com.bridgeboard.util.FlashUtil;
import com.bridgeboard.util.FormUtil;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "LoginServlet", urlPatterns = "/auth/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String csrf = request.getParameter("csrf_token");
        if (!CsrfUtil.isValid(session, csrf)) {
            FlashUtil.put(session, "error", "Invalid session token.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String email = trim(request.getParameter("email"));
        String password = trim(request.getParameter("password"));

        Map<String, String> oldInput = new HashMap<>();
        oldInput.put("email", email);
        FormUtil.setOldInput(session, oldInput);

        if (email.isEmpty() || password.isEmpty()) {
            FlashUtil.put(session, "error", "Email and password are required.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        UserDao userDao = new UserDao();
        User user = userDao.findByEmail(email);
        if (user == null || user.getPasswordHash() == null || !BCrypt.checkpw(password, user.getPasswordHash())) {
            FlashUtil.put(session, "error", "Invalid credentials.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        session.setAttribute("user", user);
        FormUtil.clearOldInput(session);
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
