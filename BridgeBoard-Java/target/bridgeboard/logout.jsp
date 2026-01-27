<% if ("POST".equalsIgnoreCase(request.getMethod())) {
request.getRequestDispatcher("/auth/logout").forward(request, response); return;
} response.sendRedirect(request.getContextPath() + "/index.jsp"); %>
