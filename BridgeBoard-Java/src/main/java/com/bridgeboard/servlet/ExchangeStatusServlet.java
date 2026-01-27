package com.bridgeboard.servlet;

import com.bridgeboard.dao.SkillExchangeDao;
import com.bridgeboard.model.SkillExchange;
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
import java.sql.Timestamp;

@WebServlet(name = "ExchangeStatusServlet", urlPatterns = "/exchanges/status")
public class ExchangeStatusServlet extends HttpServlet {
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
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        int exchangeId = parseInt(request.getParameter("exchange_id"));
        String action = trim(request.getParameter("action"));

        SkillExchangeDao exchangeDao = new SkillExchangeDao();
        SkillExchange exchange = exchangeDao.findById(exchangeId);
        if (exchange == null) {
            FlashUtil.put(session, "error", "Exchange not found.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        boolean isRequester = exchange.getRequesterId() == user.getId();
        boolean isProvider = exchange.getProviderId() == user.getId();
        if (!isRequester && !isProvider) {
            FlashUtil.put(session, "error", "You are not allowed to update this exchange.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        String status = exchange.getStatus();
        Timestamp now = new Timestamp(System.currentTimeMillis());

        if ("accept".equals(action) && isProvider && "pending".equals(status)) {
            exchange.setStatus("accepted");
            exchange.setRespondedAt(now);
        } else if ("reject".equals(action) && isProvider && "pending".equals(status)) {
            exchange.setStatus("rejected");
            exchange.setRespondedAt(now);
        } else if ("complete".equals(action) && ("accepted".equals(status) || "pending".equals(status))) {
            exchange.setStatus("completed");
            exchange.setCompletedAt(now);
        } else if ("cancel".equals(action) && ("pending".equals(status) || "accepted".equals(status))) {
            exchange.setStatus("cancelled");
        } else {
            FlashUtil.put(session, "error", "Invalid status update.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        boolean ok = exchangeDao.update(exchange);
        FlashUtil.put(session, ok ? "success" : "error", ok ? "Exchange updated." : "Unable to update exchange.");
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
}
