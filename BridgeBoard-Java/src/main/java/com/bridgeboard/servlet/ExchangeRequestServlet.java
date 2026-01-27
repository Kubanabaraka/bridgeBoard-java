package com.bridgeboard.servlet;

import com.bridgeboard.dao.SkillExchangeDao;
import com.bridgeboard.dao.SkillPostDao;
import com.bridgeboard.model.SkillExchange;
import com.bridgeboard.model.SkillPost;
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
import java.math.BigDecimal;

@WebServlet(name = "ExchangeRequestServlet", urlPatterns = "/exchanges/request")
public class ExchangeRequestServlet extends HttpServlet {
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
            response.sendRedirect(request.getContextPath() + "/browse.jsp");
            return;
        }

        int postId = parseInt(request.getParameter("post_id"));
        String exchangeType = trim(request.getParameter("exchange_type"));
        String agreedPriceRaw = trim(request.getParameter("agreed_price"));
        String notes = trim(request.getParameter("notes"));

        if (postId <= 0) {
            FlashUtil.put(session, "error", "Invalid post.");
            response.sendRedirect(request.getContextPath() + "/browse.jsp");
            return;
        }

        if (!isValidExchangeType(exchangeType)) {
            exchangeType = "trade";
        }

        BigDecimal agreedPrice = null;
        if (!agreedPriceRaw.isEmpty()) {
            try {
                agreedPrice = new BigDecimal(agreedPriceRaw);
            } catch (Exception ignored) {
            }
        }

        SkillPostDao postDao = new SkillPostDao();
        SkillPost post = postDao.findById(postId);
        if (post == null) {
            FlashUtil.put(session, "error", "Post not found.");
            response.sendRedirect(request.getContextPath() + "/browse.jsp");
            return;
        }

        if (post.getUserId() == user.getId()) {
            FlashUtil.put(session, "error", "You cannot request your own post.");
            response.sendRedirect(request.getContextPath() + "/post_detail.jsp?id=" + postId);
            return;
        }

        SkillExchange exchange = new SkillExchange();
        exchange.setRequesterId(user.getId());
        exchange.setProviderId(post.getUserId());
        exchange.setSkillPostId(postId);
        exchange.setExchangeType(exchangeType);
        exchange.setAgreedPrice(agreedPrice);
        exchange.setStatus("pending");
        exchange.setNotes(notes.isEmpty() ? null : notes);

        SkillExchangeDao exchangeDao = new SkillExchangeDao();
        int exchangeId = exchangeDao.create(exchange);
        if (exchangeId <= 0) {
            FlashUtil.put(session, "error", "Unable to create exchange request.");
            response.sendRedirect(request.getContextPath() + "/post_detail.jsp?id=" + postId);
            return;
        }

        FlashUtil.put(session, "success", "Exchange request sent.");
        response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ex) {
            return 0;
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isValidExchangeType(String type) {
        return "trade".equals(type) || "paid".equals(type) || "free".equals(type);
    }
}
