package com.bridgeboard.servlet;

import com.bridgeboard.dao.MessageDao;
import com.bridgeboard.dao.SkillPostDao;
import com.bridgeboard.dao.UserDao;
import com.bridgeboard.model.Message;
import com.bridgeboard.model.User;
import com.bridgeboard.util.CsrfUtil;
import com.bridgeboard.util.FlashUtil;
import com.bridgeboard.util.FormUtil;
import com.bridgeboard.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MessageSendServlet", urlPatterns = "/messages/send")
public class MessageSendServlet extends HttpServlet {
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
            response.sendRedirect(request.getContextPath() + "/contact.jsp");
            return;
        }

        String recipientRaw = trim(request.getParameter("recipient_id"));
        String skillRaw = trim(request.getParameter("skill_post_id"));
        String content = trim(request.getParameter("content"));

        Map<String, List<String>> errors = new HashMap<>();
        int recipientId = 0;
        if (recipientRaw.isEmpty()) {
            ValidationUtil.addError(errors, "recipient_id", "Recipient is required.");
        } else {
            recipientId = Integer.parseInt(recipientRaw);
        }
        if (content.length() < 5) {
            ValidationUtil.addError(errors, "content", "Message must be at least 5 characters.");
        }

        if (ValidationUtil.hasErrors(errors)) {
            FormUtil.setErrors(session, errors);
            response.sendRedirect(request.getContextPath() + "/contact.jsp");
            return;
        }

        UserDao userDao = new UserDao();
        if (userDao.findById(recipientId) == null) {
            FlashUtil.put(session, "error", "Recipient not found.");
            response.sendRedirect(request.getContextPath() + "/contact.jsp");
            return;
        }

        Integer skillPostId = null;
        if (!skillRaw.isEmpty()) {
            skillPostId = Integer.parseInt(skillRaw);
            SkillPostDao postDao = new SkillPostDao();
            if (postDao.findById(skillPostId) == null) {
                FlashUtil.put(session, "error", "Skill post not found.");
                response.sendRedirect(request.getContextPath() + "/contact.jsp");
                return;
            }
        }

        MessageDao messageDao = new MessageDao();
        Message message = new Message();
        message.setSenderId(user.getId());
        message.setRecipientId(recipientId);
        message.setSkillPostId(skillPostId);
        message.setContent(content);
        message.setRead(false);
        messageDao.create(message);

        FlashUtil.put(session, "success", "Message sent.");
        response.sendRedirect(request.getContextPath() + "/contact.jsp");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
