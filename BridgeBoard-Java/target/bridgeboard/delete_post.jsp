<% if ("POST".equalsIgnoreCase(request.getMethod())) {
request.getRequestDispatcher("/posts/delete").forward(request, response);
return; } response.sendRedirect(request.getContextPath() + "/dashboard.jsp"); %>
