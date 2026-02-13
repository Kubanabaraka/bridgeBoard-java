<%@ page import="com.bridgeboard.model.SkillPost" %>
<%@ page import="com.bridgeboard.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Page title is set by the servlet; provide fallback
    if (request.getAttribute("pageTitle") == null) {
        request.setAttribute("pageTitle", "Search by Date");
    }

    // Retrieve attributes set by SearchSkillPostByDateServlet
    List<SkillPost> searchResults = (List<SkillPost>) request.getAttribute("searchResults");
    String searchDate  = (String) request.getAttribute("searchDate");
    String startDate   = (String) request.getAttribute("startDate");
    String endDate     = (String) request.getAttribute("endDate");
    String searchMode  = (String) request.getAttribute("searchMode");
    String errorMessage = (String) request.getAttribute("errorMessage");
    Integer resultCount = (Integer) request.getAttribute("resultCount");

    // Safe defaults
    if (searchResults == null) searchResults = java.util.Collections.emptyList();
    if (searchDate == null)  searchDate  = "";
    if (startDate == null)   startDate   = "";
    if (endDate == null)     endDate     = "";
    if (searchMode == null)  searchMode  = "none";
    if (resultCount == null) resultCount = 0;

    // Date formatter for display
    SimpleDateFormat displayFmt = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFmt    = new SimpleDateFormat("MMM dd, yyyy  HH:mm");
%>
<%@ include file="/layouts/main_top.jsp" %>

<section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-10">

    <!-- ============================================================ -->
    <!-- SEARCH FORM CARD                                              -->
    <!-- ============================================================ -->
    <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-8">
        <div class="mb-6">
            <p class="text-sm uppercase text-indigo-500 font-semibold">Search feature</p>
            <h1 class="text-3xl font-semibold text-slate-900">Search Skill Posts by Date</h1>
            <p class="text-slate-500 mt-1">Find skill posts created on a specific date or within a date range.</p>
        </div>

        <!-- Error message -->
        <% if (errorMessage != null) { %>
            <div class="mb-6 rounded-xl bg-red-50 border border-red-200 p-4 text-red-700 text-sm font-medium">
                <%= HtmlUtil.escape(errorMessage) %>
            </div>
        <% } %>

        <!-- ===== Single Date Search Form ===== -->
        <form action="<%= request.getContextPath() %>/posts/search-by-date" method="GET"
              class="grid gap-4 md:grid-cols-3 items-end">
            <div class="md:col-span-2">
                <label for="date" class="text-sm font-semibold text-slate-600 mb-1 block">Search by Specific Date</label>
                <input type="date" id="date" name="date"
                       value="<%= HtmlUtil.escape(searchDate) %>"
                       class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100 focus:border-indigo-400"
                       required />
            </div>
            <div>
                <button type="submit"
                        class="w-full inline-flex items-center justify-center rounded-xl bg-indigo-600 px-5 py-3 text-white font-semibold hover:bg-indigo-700 transition">
                    Search
                </button>
            </div>
        </form>

        <!-- Divider -->
        <div class="flex items-center gap-4 my-8">
            <div class="flex-1 border-t border-slate-200"></div>
            <span class="text-sm font-semibold text-slate-400 uppercase">Or search by date range</span>
            <div class="flex-1 border-t border-slate-200"></div>
        </div>

        <!-- ===== Date Range Search Form ===== -->
        <form action="<%= request.getContextPath() %>/posts/search-by-date" method="GET"
              class="grid gap-4 md:grid-cols-4 items-end">
            <div>
                <label for="start_date" class="text-sm font-semibold text-slate-600 mb-1 block">Start Date</label>
                <input type="date" id="start_date" name="start_date"
                       value="<%= HtmlUtil.escape(startDate) %>"
                       class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100 focus:border-indigo-400"
                       required />
            </div>
            <div>
                <label for="end_date" class="text-sm font-semibold text-slate-600 mb-1 block">End Date</label>
                <input type="date" id="end_date" name="end_date"
                       value="<%= HtmlUtil.escape(endDate) %>"
                       class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100 focus:border-indigo-400"
                       required />
            </div>
            <div>
                <button type="submit"
                        class="w-full inline-flex items-center justify-center rounded-xl bg-emerald-600 px-5 py-3 text-white font-semibold hover:bg-emerald-700 transition">
                    Search Range
                </button>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/posts/search-by-date"
                   class="w-full inline-flex items-center justify-center rounded-xl border border-slate-200 px-5 py-3 text-slate-700 hover:bg-slate-50 transition">
                    Reset
                </a>
            </div>
        </form>
    </div>

    <!-- ============================================================ -->
    <!-- SEARCH RESULTS                                                -->
    <!-- ============================================================ -->
    <% if (!"none".equals(searchMode)) { %>
        <!-- Results summary bar -->
        <div class="flex items-center justify-between">
            <p class="text-slate-600 text-sm font-medium">
                <% if ("single".equals(searchMode)) { %>
                    Showing <span class="font-bold text-slate-900"><%= resultCount %></span>
                    result<%= resultCount != 1 ? "s" : "" %> for date
                    <span class="font-bold text-indigo-600"><%= HtmlUtil.escape(searchDate) %></span>
                <% } else { %>
                    Showing <span class="font-bold text-slate-900"><%= resultCount %></span>
                    result<%= resultCount != 1 ? "s" : "" %> from
                    <span class="font-bold text-indigo-600"><%= HtmlUtil.escape(startDate) %></span> to
                    <span class="font-bold text-indigo-600"><%= HtmlUtil.escape(endDate) %></span>
                <% } %>
            </p>
        </div>

        <% if (!searchResults.isEmpty()) { %>
            <!-- ===== Results Table ===== -->
            <div class="bg-white rounded-3xl border border-slate-100 shadow-xl overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-slate-200">
                        <thead class="bg-slate-50">
                            <tr>
                                <th class="px-6 py-4 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-4 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Title</th>
                                <th class="px-6 py-4 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Posted By</th>
                                <th class="px-6 py-4 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Location</th>
                                <th class="px-6 py-4 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-4 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Created At</th>
                                <th class="px-6 py-4 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <% for (SkillPost post : searchResults) { %>
                                <tr class="hover:bg-slate-50 transition">
                                    <td class="px-6 py-4 text-sm text-slate-900 font-medium"><%= post.getId() %></td>
                                    <td class="px-6 py-4 text-sm text-slate-900 font-semibold">
                                        <%= HtmlUtil.escape(post.getTitle()) %>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-slate-600">
                                        <%= HtmlUtil.escape(post.getUserName() == null ? "Member" : post.getUserName()) %>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-slate-600">
                                        <%= HtmlUtil.escape(post.getLocation() == null ? "Remote" : post.getLocation()) %>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold
                                            <%= "active".equals(post.getStatus()) ? "bg-green-100 text-green-700" : "bg-slate-100 text-slate-600" %>">
                                            <%= HtmlUtil.escape(post.getStatus()) %>
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-slate-600">
                                        <%= post.getCreatedAt() != null ? timeFmt.format(post.getCreatedAt()) : "N/A" %>
                                    </td>
                                    <td class="px-6 py-4">
                                        <a href="<%= request.getContextPath() %>/post_detail.jsp?id=<%= post.getId() %>"
                                           class="text-indigo-600 hover:text-indigo-800 font-semibold text-sm">
                                            View
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ===== Card View (alternative display) ===== -->
            <h2 class="text-xl font-semibold text-slate-900 mt-6">Card View</h2>
            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                <% for (SkillPost post : searchResults) { %>
                    <% request.setAttribute("post", post); %>
                    <jsp:include page="/partials/post_card.jsp" />
                <% } %>
            </div>

        <% } else { %>
            <!-- ===== Empty State ===== -->
            <div class="bg-white rounded-3xl border border-dashed border-slate-200 flex flex-col items-center justify-center text-center py-16">
                <svg class="h-24 w-24 text-slate-300 mb-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
                <p class="text-lg font-semibold text-slate-900">No records found</p>
                <p class="text-slate-500 mt-1">
                    <% if ("single".equals(searchMode)) { %>
                        No skill posts were created on <strong><%= HtmlUtil.escape(searchDate) %></strong>.
                    <% } else { %>
                        No skill posts found between <strong><%= HtmlUtil.escape(startDate) %></strong>
                        and <strong><%= HtmlUtil.escape(endDate) %></strong>.
                    <% } %>
                </p>
                <p class="text-slate-400 text-sm mt-2">Try a different date or use the date range search.</p>
            </div>
        <% } %>
    <% } %>
</section>

<%@ include file="/layouts/main_bottom.jsp" %>
