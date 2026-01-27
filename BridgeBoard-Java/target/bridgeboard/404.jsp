<% request.setAttribute("pageTitle", "Page not found"); %> <%@ include
file="/layouts/main_top.jsp" %>
<section class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-24 text-center">
  <img
    src="<%= request.getContextPath() %>/assets/images/empty-state.svg"
    alt="Not found"
    class="h-40 mx-auto mb-6"
  />
  <h1 class="text-3xl font-semibold text-slate-900">Page not found</h1>
  <p class="text-slate-500 mt-3">
    The page you're looking for doesn't exist or has moved.
  </p>
  <a
    href="<%= request.getContextPath() %>/index.jsp"
    class="inline-flex items-center gap-2 mt-6 bg-indigo-600 text-white px-6 py-3 rounded-xl font-semibold"
    >Back to home</a
  >
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
