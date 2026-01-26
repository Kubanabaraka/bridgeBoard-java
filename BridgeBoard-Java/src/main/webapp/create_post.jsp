<%@ page import="com.bridgeboard.dao.CategoryDao" %>
<%@ page import="com.bridgeboard.model.Category" %>
<%@ page import="com.bridgeboard.model.User" %>
<%@ page import="com.bridgeboard.util.CsrfUtil" %>
<%@ page import="com.bridgeboard.util.FormUtil" %>
<%@ page import="com.bridgeboard.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.getRequestDispatcher("/posts/store").forward(request, response);
        return;
    }
    request.setAttribute("pageTitle", "Create skill post");
    CategoryDao categoryDao = new CategoryDao();
    List<Category> categories = categoryDao.findAll();
    Map<String, List<String>> errors = FormUtil.consumeErrors(session);
%>
<%@ include file="/layouts/main_top.jsp" %>
<section class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
    <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-10 space-y-6">
        <div>
            <p class="text-sm uppercase text-indigo-500 font-semibold">Share your skill</p>
            <h1 class="text-3xl font-semibold text-slate-900">Create a new post</h1>
        </div>
        <form action="<%= request.getContextPath() %>/create_post.jsp" method="POST" enctype="multipart/form-data" class="space-y-5">
            <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>">
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Title</label>
                <input type="text" name="title" value="<%= HtmlUtil.escape(FormUtil.old(session, "title")) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                <% if (errors.containsKey("title")) { %>
                    <p class="text-sm text-rose-500 mt-1"><%= HtmlUtil.escape(errors.get("title").get(0)) %></p>
                <% } %>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Category</label>
                <select name="category_id" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                    <option value="">Select category</option>
                    <% for (Category category : categories) { %>
                        <option value="<%= category.getId() %>" <%= String.valueOf(category.getId()).equals(FormUtil.old(session, "category_id")) ? "selected" : "" %>><%= HtmlUtil.escape(category.getName()) %></option>
                    <% } %>
                </select>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Description</label>
                <textarea name="description" class="w-full min-h-[140px] px-4 py-3 border border-slate-200 rounded-xl"><%= HtmlUtil.escape(FormUtil.old(session, "description")) %></textarea>
                <% if (errors.containsKey("description")) { %>
                    <p class="text-sm text-rose-500 mt-1"><%= HtmlUtil.escape(errors.get("description").get(0)) %></p>
                <% } %>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-semibold text-slate-700 mb-2">Location</label>
                    <input type="text" name="location" value="<%= HtmlUtil.escape(FormUtil.old(session, "location")) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl" placeholder="Remote / Austin">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Price min</label>
                        <input type="number" step="0.01" name="price_min" value="<%= HtmlUtil.escape(FormUtil.old(session, "price_min")) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Price max</label>
                        <input type="number" step="0.01" name="price_max" value="<%= HtmlUtil.escape(FormUtil.old(session, "price_max")) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                    </div>
                </div>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Images</label>
                <input type="file" name="images" multiple accept="image/*" class="w-full text-sm">
            </div>
            <div class="flex gap-3">
                <button type="submit" class="flex-1 bg-indigo-600 text-white rounded-xl px-6 py-3 font-semibold">Publish post</button>
                <a href="<%= request.getContextPath() %>/dashboard.jsp" class="inline-flex items-center justify-center rounded-xl border border-slate-200 px-6 py-3 text-slate-700">Cancel</a>
            </div>
        </form>
    </div>
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
