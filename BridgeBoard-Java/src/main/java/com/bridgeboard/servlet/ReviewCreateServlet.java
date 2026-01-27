package com.bridgeboard.servlet;

import com.bridgeboard.dao.ReviewDao;
import com.bridgeboard.dao.SkillExchangeDao;
import com.bridgeboard.model.Review;
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

@WebServlet(name = "ReviewCreateServlet", urlPatterns = "/reviews/create")
public class ReviewCreateServlet extends HttpServlet {
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
        int rating = parseInt(request.getParameter("rating"));
        String comment = trim(request.getParameter("comment"));

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
            FlashUtil.put(session, "error", "You are not allowed to review this exchange.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        if (!"completed".equals(exchange.getStatus())) {
            FlashUtil.put(session, "error", "Only completed exchanges can be reviewed.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        if (rating < 1 || rating > 5) {
            FlashUtil.put(session, "error", "Rating must be between 1 and 5.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        ReviewDao reviewDao = new ReviewDao();
        if (reviewDao.forExchangeAndReviewer(exchangeId, user.getId()) != null) {
            FlashUtil.put(session, "error", "You already reviewed this exchange.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        int revieweeId = isRequester ? exchange.getProviderId() : exchange.getRequesterId();

        Review review = new Review();
        review.setExchangeId(exchangeId);
        review.setReviewerId(user.getId());
        review.setRevieweeId(revieweeId);
        review.setRating(rating);
        review.setComment(comment.isEmpty() ? null : comment);

        int reviewId = reviewDao.create(review);
        if (reviewId <= 0) {
            FlashUtil.put(session, "error", "Unable to submit review.");
            response.sendRedirect(request.getContextPath() + "/exchanges.jsp");
            return;
        }

        FlashUtil.put(session, "success", "Review submitted.");
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
