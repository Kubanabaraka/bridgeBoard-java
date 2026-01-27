<%@ page import="com.bridgeboard.dao.ReviewDao" %> <%@ page
import="com.bridgeboard.dao.SkillExchangeDao" %> <%@ page
import="com.bridgeboard.dao.SkillPostDao" %> <%@ page
import="com.bridgeboard.dao.UserDao" %> <%@ page
import="com.bridgeboard.model.Review" %> <%@ page
import="com.bridgeboard.model.SkillExchange" %> <%@ page
import="com.bridgeboard.model.SkillPost" %> <%@ page
import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.CsrfUtil" %> <%@ page
import="com.bridgeboard.util.DateUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page import="java.util.List" %> <%
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
request.setAttribute("pageTitle", "Exchanges");
SkillExchangeDao exchangeDao = new SkillExchangeDao();
SkillPostDao postDao = new SkillPostDao();
UserDao userDao = new UserDao();
ReviewDao reviewDao = new ReviewDao();
List<SkillExchange> exchanges = exchangeDao.forUser(user.getId());
%> <%@ include file="/layouts/main_top.jsp" %>
<section class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-8">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-sm uppercase text-indigo-500 font-semibold">Track</p>
      <h1 class="text-3xl font-semibold text-slate-900">Skill exchanges</h1>
    </div>
    <a
      href="<%= request.getContextPath() %>/browse.jsp"
      class="text-sm text-indigo-600 font-semibold"
      >Find new exchanges</a
    >
  </div>

  <% if (!exchanges.isEmpty()) { %>
  <div class="space-y-6">
    <% for (SkillExchange exchange : exchanges) {
        SkillPost post = postDao.findById(exchange.getSkillPostId());
        boolean isRequester = exchange.getRequesterId() == user.getId();
        boolean isProvider = exchange.getProviderId() == user.getId();
        int otherUserId = isRequester ? exchange.getProviderId() : exchange.getRequesterId();
        User otherUser = userDao.findById(otherUserId);
        Review existingReview = reviewDao.forExchangeAndReviewer(exchange.getId(), user.getId());
    %>
    <div class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm">
      <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4">
        <div class="space-y-2">
          <p class="text-xs uppercase text-indigo-500 font-semibold">
            <%= HtmlUtil.escape(exchange.getStatus()) %>
          </p>
          <h3 class="text-xl font-semibold text-slate-900">
            <%= HtmlUtil.escape(post == null ? "Skill post" : post.getTitle()) %>
          </h3>
          <p class="text-sm text-slate-600">
            With <%= HtmlUtil.escape(otherUser == null ? "Member" : otherUser.getName()) %>
            • Requested <%= HtmlUtil.escape(DateUtil.format(exchange.getRequestedAt(), "MMM dd, yyyy")) %>
          </p>
        </div>
        <div class="flex flex-wrap gap-2">
          <% if (post != null) { %>
          <a
            href="<%= request.getContextPath() %>/post_detail.jsp?id=<%= post.getId() %>"
            class="inline-flex items-center gap-2 rounded-xl border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-700"
            >View post</a
          >
          <% } %>
          <% if ("pending".equals(exchange.getStatus()) && isProvider) { %>
          <form action="<%= request.getContextPath() %>/exchanges/status" method="POST">
            <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>" />
            <input type="hidden" name="exchange_id" value="<%= exchange.getId() %>" />
            <input type="hidden" name="action" value="accept" />
            <button class="inline-flex items-center gap-2 rounded-xl bg-emerald-600 px-4 py-2 text-sm font-semibold text-white" type="submit">Accept</button>
          </form>
          <form action="<%= request.getContextPath() %>/exchanges/status" method="POST">
            <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>" />
            <input type="hidden" name="exchange_id" value="<%= exchange.getId() %>" />
            <input type="hidden" name="action" value="reject" />
            <button class="inline-flex items-center gap-2 rounded-xl border border-rose-200 px-4 py-2 text-sm font-semibold text-rose-600" type="submit">Reject</button>
          </form>
          <% } %>
          <% if ("accepted".equals(exchange.getStatus())) { %>
          <form action="<%= request.getContextPath() %>/exchanges/status" method="POST">
            <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>" />
            <input type="hidden" name="exchange_id" value="<%= exchange.getId() %>" />
            <input type="hidden" name="action" value="complete" />
            <button class="inline-flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white" type="submit">Mark completed</button>
          </form>
          <% } %>
          <% if ("pending".equals(exchange.getStatus()) || "accepted".equals(exchange.getStatus())) { %>
          <form action="<%= request.getContextPath() %>/exchanges/status" method="POST">
            <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>" />
            <input type="hidden" name="exchange_id" value="<%= exchange.getId() %>" />
            <input type="hidden" name="action" value="cancel" />
            <button class="inline-flex items-center gap-2 rounded-xl border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-700" type="submit">Cancel</button>
          </form>
          <% } %>
        </div>
      </div>

      <% if ("completed".equals(exchange.getStatus()) && existingReview == null) { %>
      <div class="mt-4 border-t border-slate-100 pt-4">
        <h4 class="text-sm font-semibold text-slate-900 mb-2">Leave a review</h4>
        <form action="<%= request.getContextPath() %>/reviews/create" method="POST" class="grid gap-3 sm:grid-cols-3">
          <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>" />
          <input type="hidden" name="exchange_id" value="<%= exchange.getId() %>" />
          <div>
            <label class="text-xs text-slate-500">Rating</label>
            <select name="rating" class="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2">
              <option value="5">5 - Excellent</option>
              <option value="4">4 - Great</option>
              <option value="3">3 - Good</option>
              <option value="2">2 - Fair</option>
              <option value="1">1 - Poor</option>
            </select>
          </div>
          <div class="sm:col-span-2">
            <label class="text-xs text-slate-500">Comment</label>
            <input
              type="text"
              name="comment"
              class="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2"
              placeholder="Share feedback"
            />
          </div>
          <div class="sm:col-span-3">
            <button class="inline-flex items-center gap-2 rounded-xl bg-indigo-600 px-4 py-2 text-sm font-semibold text-white" type="submit">Submit review</button>
          </div>
        </form>
      </div>
      <% } else if (existingReview != null) { %>
      <p class="mt-4 text-sm text-slate-500">You already reviewed this exchange.</p>
      <% } %>
    </div>
    <% } %>
  </div>
  <% } else { %>
  <div class="text-center py-16 bg-white rounded-3xl border border-slate-100">
    <img
      src="<%= request.getContextPath() %>/assets/images/empty-state.svg"
      alt="Empty"
      class="h-40 mx-auto mb-4"
    />
    <p class="text-lg font-semibold text-slate-900">No exchanges yet</p>
    <p class="text-slate-500">Send a request from any skill post to get started.</p>
  </div>
  <% } %>
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
