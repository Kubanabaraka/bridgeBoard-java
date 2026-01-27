<%@ page import="com.bridgeboard.dao.CategoryDao" %>
<%@ page import="com.bridgeboard.dao.SkillPostDao" %>
<%@ page import="com.bridgeboard.model.Category" %>
<%@ page import="com.bridgeboard.model.SkillPost" %>
<%@ page import="com.bridgeboard.model.User" %>
<%@ page import="com.bridgeboard.util.CsrfUtil" %>
<%@ page import="com.bridgeboard.util.FormUtil" %>
<%@ page import="com.bridgeboard.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.getRequestDispatcher("/posts/update").forward(request, response);
        return;
    }
    String idRaw = request.getParameter("id");
    int postId = idRaw == null ? 0 : Integer.parseInt(idRaw);
    SkillPostDao postDao = new SkillPostDao();
    SkillPost post = postDao.findById(postId);
    if (post == null || post.getUserId() != user.getId()) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }
    request.setAttribute("pageTitle", "Edit post");
    CategoryDao categoryDao = new CategoryDao();
    List<Category> categories = categoryDao.findAll();
    Map<String, List<String>> errors = FormUtil.consumeErrors(session);
%>
<%@ include file="/layouts/main_top.jsp" %>
<section class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
    <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-10 space-y-6">
        <div>
            <p class="text-sm uppercase text-indigo-500 font-semibold">Update your post</p>
            <h1 class="text-3xl font-semibold text-slate-900">Edit skill post</h1>
        </div>
        <form action="<%= request.getContextPath() %>/edit_post.jsp" method="POST" enctype="multipart/form-data" class="space-y-5">
            <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>">
            <input type="hidden" name="post_id" value="<%= post.getId() %>">
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Title</label>
                <input type="text" name="title" value="<%= HtmlUtil.escape(post.getTitle()) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                <% if (errors.containsKey("title")) { %>
                    <p class="text-sm text-rose-500 mt-1"><%= HtmlUtil.escape(errors.get("title").get(0)) %></p>
                <% } %>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Category</label>
                <select name="category_id" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                    <option value="">Select category</option>
                    <% for (Category category : categories) { %>
                        <option value="<%= category.getId() %>" <%= post.getCategoryId() != null && post.getCategoryId() == category.getId() ? "selected" : "" %>><%= HtmlUtil.escape(category.getName()) %></option>
                    <% } %>
                </select>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Description</label>
                <textarea name="description" class="w-full min-h-[140px] px-4 py-3 border border-slate-200 rounded-xl"><%= HtmlUtil.escape(post.getDescription()) %></textarea>
                <% if (errors.containsKey("description")) { %>
                    <p class="text-sm text-rose-500 mt-1"><%= HtmlUtil.escape(errors.get("description").get(0)) %></p>
                <% } %>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-semibold text-slate-700 mb-2">Location</label>
                    <input type="text" name="location" value="<%= HtmlUtil.escape(post.getLocation() == null ? "" : post.getLocation()) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl" placeholder="Remote / Austin">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Price min</label>
                        <input type="number" step="0.01" name="price_min" value="<%= post.getPriceMin() == null ? "" : post.getPriceMin().toPlainString() %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Price max</label>
                        <input type="number" step="0.01" name="price_max" value="<%= post.getPriceMax() == null ? "" : post.getPriceMax().toPlainString() %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                    </div>
                </div>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Status</label>
                <select name="status" class="w-full px-4 py-3 border border-slate-200 rounded-xl">
                    <option value="active" <%= "active".equals(post.getStatus()) ? "selected" : "" %>>Active</option>
                    <option value="paused" <%= "paused".equals(post.getStatus()) ? "selected" : "" %>>Paused</option>
                    <option value="closed" <%= "closed".equals(post.getStatus()) ? "selected" : "" %>>Closed</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Add images</label>
                <input type="file" name="images" multiple accept="image/*" class="w-full text-sm">
            </div>
            <div class="flex gap-3">
                <button type="submit" class="flex-1 bg-indigo-600 text-white rounded-xl px-6 py-3 font-semibold">Update post</button>
                <a href="<%= request.getContextPath() %>/dashboard.jsp" class="inline-flex items-center justify-center rounded-xl border border-slate-200 px-6 py-3 text-slate-700">Cancel</a>
            </div>
        </form>
    </div>
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
