<%@ page import="com.bridgeboard.dao.SkillPostDao" %> <%@ page
import="com.bridgeboard.model.SkillPost" %> <%@ page
import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page import="java.util.List" %> <%
String idRaw = request.getParameter("id"); int postId = idRaw == null ? 0 :
Integer.parseInt(idRaw); SkillPostDao postDao = new SkillPostDao(); SkillPost
post = postDao.findById(postId); if (post == null) {
response.sendRedirect(request.getContextPath() + "/404.jsp"); return; }
request.setAttribute("pageTitle", post.getTitle()); User user = (User)
session.getAttribute("user"); %> <%@ include file="/layouts/main_top.jsp" %>
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
        <div class="flex gap-3">
          <% if (user != null) { %>
          <a
            href="<%= request.getContextPath() %>/contact.jsp?recipient=<%= post.getUserId() %>&skill=<%= post.getId() %>"
            class="flex-1 inline-flex items-center justify-center rounded-xl bg-indigo-600 px-5 py-3 text-white font-semibold"
            >Message owner</a
          >
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
      </div>
    </div>
  </div>
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
