package com.bridgeboard.servlet;

import com.bridgeboard.dao.FavoriteDao;
import com.bridgeboard.model.User;
import com.bridgeboard.util.CsrfUtil;
import com.bridgeboard.util.FlashUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "FavoriteToggleServlet", urlPatterns = "/favorites/toggle")
public class FavoriteToggleServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String csrf = request.getParameter("csrf_token");
        if (!CsrfUtil.isValid(session, csrf)) {
            FlashUtil.put(session, "error", "Invalid session token.");
            response.sendRedirect(request.getContextPath() + "/favorites.jsp");
            return;
        }

        String postIdRaw = request.getParameter("post_id");
        int postId = 0;
        try {
            postId = Integer.parseInt(postIdRaw);
        } catch (Exception ignored) {
        }

        if (postId <= 0) {
            FlashUtil.put(session, "error", "Invalid post.");
            response.sendRedirect(request.getContextPath() + "/favorites.jsp");
            return;
        }

        FavoriteDao favoriteDao = new FavoriteDao();
        boolean exists = favoriteDao.exists(user.getId(), postId);
        boolean ok;
        if (exists) {
            ok = favoriteDao.remove(user.getId(), postId);
            FlashUtil.put(session, ok ? "success" : "error", ok ? "Removed from favorites." : "Unable to remove favorite.");
        } else {
            ok = favoriteDao.add(user.getId(), postId);
            FlashUtil.put(session, ok ? "success" : "error", ok ? "Added to favorites." : "Unable to add favorite.");
        }

        String referer = request.getHeader("Referer");
        if (referer == null || referer.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/favorites.jsp");
            return;
        }
        response.sendRedirect(referer);
    }
}
