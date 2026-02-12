<%@ page import="com.bridgeboard.dao.CategoryDao" %>
<%@ page import="com.bridgeboard.dao.SkillPostDao" %>
<%@ page import="com.bridgeboard.model.Category" %>
<%@ page import="com.bridgeboard.model.SkillPost" %>
<%@ page import="com.bridgeboard.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeParseException" %>
<%
    request.setAttribute("pageTitle", "Search results");
    String q = request.getParameter("q");
    String categoryRaw = request.getParameter("category");
    String location = request.getParameter("location");
    String dateRaw = request.getParameter("date");
    String startDateRaw = request.getParameter("start_date");
    String endDateRaw = request.getParameter("end_date");

    Integer categoryId = null;
    if (categoryRaw != null && !categoryRaw.isBlank()) {
        try { categoryId = Integer.parseInt(categoryRaw); } catch (NumberFormatException ignored) {}
    }

    // Parse date parameters safely
    LocalDate searchDate = null;
    LocalDate startDate = null;
    LocalDate endDate = null;
    String dateError = null;

    if (dateRaw != null && !dateRaw.isBlank()) {
        try { searchDate = LocalDate.parse(dateRaw); } catch (DateTimeParseException e) { dateError = "Invalid date format."; }
    }
    if (startDateRaw != null && !startDateRaw.isBlank() && endDateRaw != null && !endDateRaw.isBlank()) {
        try {
            startDate = LocalDate.parse(startDateRaw);
            endDate = LocalDate.parse(endDateRaw);
            if (startDate.isAfter(endDate)) { dateError = "Start date must not be after end date."; startDate = null; endDate = null; }
        } catch (DateTimeParseException e) { dateError = "Invalid date range format."; }
    }

    CategoryDao categoryDao = new CategoryDao();
    SkillPostDao postDao = new SkillPostDao();
    List<Category> categories = categoryDao.findAll();
    List<SkillPost> posts = postDao.search(q, categoryId, location, searchDate, startDate, endDate);
%>
<%@ include file="/layouts/main_top.jsp" %>
<section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-10">
    <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-8">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-6">
            <div>
                <p class="text-sm uppercase text-indigo-500 font-semibold">Find your next collab</p>
                <h1 class="text-3xl font-semibold text-slate-900">Search results</h1>
            </div>
            <a href="<%= request.getContextPath() %>/create_post.jsp" class="inline-flex items-center gap-2 rounded-xl bg-indigo-600 px-5 py-3 text-white font-semibold">Create post</a>
        </div>
        <form action="<%= request.getContextPath() %>/search.jsp" method="GET" class="mt-6 grid gap-4 md:grid-cols-4">
            <div class="md:col-span-2">
                <label class="text-sm font-semibold text-slate-600 mb-1 block">Keyword</label>
                <input type="text" name="q" value="<%= HtmlUtil.escape(q == null ? "" : q) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100" placeholder="Guitar, UX design...">
            </div>
            <div>
                <label class="text-sm font-semibold text-slate-600 mb-1 block">Category</label>
                <select name="category" class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100">
                    <option value="">All</option>
                    <% for (Category category : categories) { %>
                        <option value="<%= category.getId() %>" <%= categoryId != null && categoryId == category.getId() ? "selected" : "" %>><%= HtmlUtil.escape(category.getName()) %></option>
                    <% } %>
                </select>
            </div>
            <div>
                <label class="text-sm font-semibold text-slate-600 mb-1 block">Location</label>
                <input type="text" name="location" value="<%= HtmlUtil.escape(location == null ? "" : location) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100" placeholder="Remote / Austin">
            </div>
            <div>
                <label class="text-sm font-semibold text-slate-600 mb-1 block">Exact Date</label>
                <input type="date" name="date" value="<%= HtmlUtil.escape(dateRaw == null ? "" : dateRaw) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100">
            </div>
            <div>
                <label class="text-sm font-semibold text-slate-600 mb-1 block">From Date</label>
                <input type="date" name="start_date" value="<%= HtmlUtil.escape(startDateRaw == null ? "" : startDateRaw) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100">
            </div>
            <div>
                <label class="text-sm font-semibold text-slate-600 mb-1 block">To Date</label>
                <input type="date" name="end_date" value="<%= HtmlUtil.escape(endDateRaw == null ? "" : endDateRaw) %>" class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100">
            </div>
            <% if (dateError != null) { %>
            <div class="md:col-span-4">
                <div class="rounded-xl bg-red-50 border border-red-200 p-3 text-red-700 text-sm font-medium"><%= HtmlUtil.escape(dateError) %></div>
            </div>
            <% } %>
            <div class="md:col-span-4 flex gap-3">
                <button type="submit" class="flex-1 inline-flex items-center justify-center rounded-xl bg-indigo-600 px-5 py-3 text-white font-semibold">Search</button>
                <a href="<%= request.getContextPath() %>/browse.jsp" class="inline-flex items-center justify-center rounded-xl border border-slate-200 px-5 py-3 text-slate-700">Reset</a>
            </div>
        </form>
    </div>

    <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <% for (SkillPost post : posts) { %>
            <% request.setAttribute("post", post); %>
            <jsp:include page="/partials/post_card.jsp" />
        <% } %>
        <% if (posts.isEmpty()) { %>
            <div class="bg-white rounded-3xl border border-dashed border-slate-200 flex flex-col items-center justify-center text-center py-16">
                <img src="<%= request.getContextPath() %>/assets/images/empty-state.svg" alt="Empty" class="h-40 mb-6">
                <p class="text-lg font-semibold text-slate-900">No matches</p>
                <p class="text-slate-500">Try adjusting filters or add a new post.</p>
            </div>
        <% } %>
    </div>
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
