<%@ page import="com.bridgeboard.dao.FavoriteDao" %> <%@ page
import="com.bridgeboard.dao.SkillPostDao" %> <%@ page
import="com.bridgeboard.model.SkillPost" %> <%@ page
import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.CsrfUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page import="java.util.List" %> <%
String idRaw = request.getParameter("id"); int postId = idRaw == null ? 0 :
Integer.parseInt(idRaw); SkillPostDao postDao = new SkillPostDao(); SkillPost
post = postDao.findById(postId); if (post == null) {
response.sendRedirect(request.getContextPath() + "/404.jsp"); return; }
request.setAttribute("pageTitle", post.getTitle()); User user = (User)
session.getAttribute("user"); boolean isOwner = user != null && post.getUserId() == user.getId();
FavoriteDao favoriteDao = new FavoriteDao(); boolean isFavorite = user != null && favoriteDao.exists(user.getId(), post.getId());
%> <%@ include file="/layouts/main_top.jsp" %>
<section class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-8">
  <div
    class="bg-white rounded-3xl border border-slate-100 shadow-xl overflow-hidden"
  >
    <div class="grid md:grid-cols-2 gap-6">
      <div class="p-6">
        <% if (post.getImages() != null && !post.getImages().isEmpty()) { %>
        <img
          src="<%= request.getContextPath() %>/<%= post.getImages().get(0) %>"
          alt="<%= HtmlUtil.escape(post.getTitle()) %>"
          class="w-full h-72 object-cover rounded-2xl"
        />
        <% } else { %>
        <img
          src="<%= request.getContextPath() %>/assets/images/empty-state.svg"
          alt="Empty"
          class="w-full h-72 object-cover rounded-2xl"
        />
        <% } %>
      </div>
      <div class="p-6 space-y-4">
        <div class="space-y-1">
          <p class="text-sm uppercase text-indigo-500 font-semibold">
            <%= HtmlUtil.escape(post.getCategoryName() == null ? "General" :
            post.getCategoryName()) %>
          </p>
          <h1 class="text-3xl font-semibold text-slate-900">
            <%= HtmlUtil.escape(post.getTitle()) %>
          </h1>
        </div>
        <p class="text-slate-600">
          <%= HtmlUtil.escape(post.getDescription()) %>
        </p>
        <div class="flex flex-wrap gap-4 text-sm text-slate-500">
          <span
            >Location: <%= HtmlUtil.escape(post.getLocation() == null ? "Remote"
            : post.getLocation()) %></span
          >
          <span>Status: <%= HtmlUtil.escape(post.getStatus()) %></span>
        </div>
        <div class="bg-slate-50 rounded-2xl p-4">
          <p class="text-sm text-slate-500">Hosted by</p>
          <div class="flex items-center gap-3 mt-2">
            <img src="<%= request.getContextPath() %>/<%=
            HtmlUtil.escape(post.getUserAvatar() == null ?
            "assets/images/profile-default.svg" : post.getUserAvatar()) %>"
            class="h-12 w-12 rounded-full object-cover" alt="Avatar">
            <div>
              <p class="font-semibold text-slate-900">
                <%= HtmlUtil.escape(post.getUserName() == null ? "Member" :
                post.getUserName()) %>
              </p>
            </div>
          </div>
        </div>
        <div class="flex flex-wrap gap-3">
          <% if (user != null) { %>
          <a
            href="<%= request.getContextPath() %>/contact.jsp?recipient=<%= post.getUserId() %>&skill=<%= post.getId() %>"
            class="flex-1 inline-flex items-center justify-center rounded-xl bg-indigo-600 px-5 py-3 text-white font-semibold"
            >Message owner</a
          >
          <form
            action="<%= request.getContextPath() %>/favorites/toggle"
            method="POST"
            class="inline-flex"
          >
            <input
              type="hidden"
              name="csrf_token"
              value="<%= CsrfUtil.getToken(session) %>"
            />
            <input type="hidden" name="post_id" value="<%= post.getId() %>" />
            <button
              type="submit"
              class="inline-flex items-center justify-center rounded-xl border border-slate-200 px-5 py-3 text-slate-700"
            >
              <%= isFavorite ? "Remove favorite" : "Save to favorites" %>
            </button>
          </form>
          <% } else { %>
          <a
            href="<%= request.getContextPath() %>/login.jsp"
            class="flex-1 inline-flex items-center justify-center rounded-xl bg-indigo-600 px-5 py-3 text-white font-semibold"
            >Log in to message</a
          >
          <% } %>
          <a
            href="<%= request.getContextPath() %>/browse.jsp"
            class="inline-flex items-center justify-center rounded-xl border border-slate-200 px-5 py-3 text-slate-700"
            >Back to browse</a
          >
        </div>
        <% if (user != null && !isOwner) { %>
        <div class="bg-white rounded-2xl border border-slate-100 p-5 shadow-sm">
          <h3 class="text-lg font-semibold text-slate-900 mb-3">Request an exchange</h3>
          <form action="<%= request.getContextPath() %>/exchanges/request" method="POST" class="space-y-3">
            <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>" />
            <input type="hidden" name="post_id" value="<%= post.getId() %>" />
            <div class="grid sm:grid-cols-2 gap-3">
              <div>
                <label class="text-sm text-slate-600">Exchange type</label>
                <select name="exchange_type" class="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2">
                  <option value="trade">Trade</option>
                  <option value="paid">Paid</option>
                  <option value="free">Free</option>
                </select>
              </div>
              <div>
                <label class="text-sm text-slate-600">Agreed price (optional)</label>
                <input
                  type="number"
                  step="0.01"
                  name="agreed_price"
                  class="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2"
                  placeholder="0.00"
                />
              </div>
            </div>
            <div>
              <label class="text-sm text-slate-600">Notes</label>
              <textarea
                name="notes"
                rows="3"
                class="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2"
                placeholder="Share your proposal and availability"
              ></textarea>
            </div>
            <button
              type="submit"
              class="inline-flex items-center justify-center rounded-xl bg-slate-900 px-5 py-3 text-white font-semibold"
            >
              Send request
            </button>
          </form>
        </div>
        <% } %>
      </div>
    </div>
  </div>
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
