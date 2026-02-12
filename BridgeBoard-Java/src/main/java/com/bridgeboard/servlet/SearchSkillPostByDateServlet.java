package com.bridgeboard.servlet;

import com.bridgeboard.dao.SkillPostDao;
import com.bridgeboard.model.SkillPost;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * SearchSkillPostByDateServlet - Handles search requests by date.
 *
 * Supports two modes:
 *   1. Single date search  – parameter "date" (mandatory)
 *   2. Date range search   – parameters "start_date" and "end_date" (bonus)
 *
 * Flow: JSP form → this Servlet → SkillPostDao → forward results to JSP.
 *
 * Uses PreparedStatement via DAO layer (no SQL injection risk).
 */
@WebServlet(name = "SearchSkillPostByDateServlet", urlPatterns = "/posts/search-by-date")
public class SearchSkillPostByDateServlet extends HttpServlet {

    /**
     * Handle GET requests from the search-by-date form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Read parameters from the form
        String dateParam      = trim(request.getParameter("date"));
        String startDateParam = trim(request.getParameter("start_date"));
        String endDateParam   = trim(request.getParameter("end_date"));

        List<SkillPost> results = new ArrayList<>();
        String errorMessage = null;
        String searchMode = "none"; // tracks which search mode was used

        SkillPostDao dao = new SkillPostDao();

        // --- Mode 1: Date range search (if both start and end are provided) ---
        if (!startDateParam.isEmpty() && !endDateParam.isEmpty()) {
            searchMode = "range";
            try {
                LocalDate startDate = LocalDate.parse(startDateParam);
                LocalDate endDate   = LocalDate.parse(endDateParam);

                // Validate that start date is not after end date
                if (startDate.isAfter(endDate)) {
                    errorMessage = "Start date must not be after end date.";
                } else {
                    results = dao.searchByDateRange(startDate, endDate);
                }
            } catch (DateTimeParseException e) {
                errorMessage = "Invalid date format. Please use YYYY-MM-DD.";
            }

        // --- Mode 2: Single date search ---
        } else if (!dateParam.isEmpty()) {
            searchMode = "single";
            try {
                LocalDate date = LocalDate.parse(dateParam);
                results = dao.searchByDate(date);
            } catch (DateTimeParseException e) {
                errorMessage = "Invalid date format. Please use YYYY-MM-DD.";
            }

        // --- No date provided at all ---
        } else {
            // Only show error if the form was actually submitted (at least one param present)
            if (request.getQueryString() != null) {
                errorMessage = "Please enter a date to search.";
            }
        }

        // Set attributes for the JSP page
        request.setAttribute("searchResults", results);
        request.setAttribute("searchDate", dateParam);
        request.setAttribute("startDate", startDateParam);
        request.setAttribute("endDate", endDateParam);
        request.setAttribute("searchMode", searchMode);
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("resultCount", results.size());
        request.setAttribute("pageTitle", "Search by Date");

        // Forward to the JSP for display
        request.getRequestDispatcher("/search_by_date.jsp").forward(request, response);
    }

    /**
     * Utility to safely trim a parameter value.
     */
    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
