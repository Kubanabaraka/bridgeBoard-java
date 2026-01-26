package com.bridgeboard.servlet;

import com.bridgeboard.dao.SkillPostDao;
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

@WebServlet(name = "PostDeleteServlet", urlPatterns = "/posts/delete")
public class PostDeleteServlet extends HttpServlet {
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
            FlashUtil.put(session, "error", "Invalid request.");
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));
        SkillPostDao dao = new SkillPostDao();
        dao.delete(postId, user.getId());
        FlashUtil.put(session, "success", "Post removed.");
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
    }
}
