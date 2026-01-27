<%@ page import="com.bridgeboard.dao.FavoriteDao" %> <%@ page
import="com.bridgeboard.dao.SkillPostDao" %> <%@ page
import="com.bridgeboard.model.Favorite" %> <%@ page
import="com.bridgeboard.model.SkillPost" %> <%@ page
import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.CsrfUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page import="java.util.ArrayList" %> <%@ page
import="java.util.List" %> <%
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
request.setAttribute("pageTitle", "Favorites");
FavoriteDao favoriteDao = new FavoriteDao();
SkillPostDao postDao = new SkillPostDao();
List<Favorite> favorites = favoriteDao.forUser(user.getId());
List<SkillPost> posts = new ArrayList<>();
for (Favorite fav : favorites) {
    SkillPost post = postDao.findById(fav.getSkillPostId());
    if (post != null) {
        posts.add(post);
    }
}
%> <%@ include file="/layouts/main_top.jsp" %>
<section class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-8">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-sm uppercase text-indigo-500 font-semibold">Saved</p>
      <h1 class="text-3xl font-semibold text-slate-900">Your favorites</h1>
    </div>
    <a
      href="<%= request.getContextPath() %>/browse.jsp"
      class="text-sm text-indigo-600 font-semibold"
      >Browse more skills</a
    >
  </div>

  <% if (!posts.isEmpty()) { %>
  <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
    <% for (SkillPost post : posts) { %>
    <div class="bg-white rounded-2xl border border-slate-100 p-5 shadow-sm">
      <div class="space-y-2">
        <p class="text-xs uppercase text-indigo-500 font-semibold">
          <%= HtmlUtil.escape(post.getCategoryName() == null ? "General" : post.getCategoryName()) %>
        </p>
        <h3 class="text-lg font-semibold text-slate-900">
          <%= HtmlUtil.escape(post.getTitle()) %>
        </h3>
        <p class="text-sm text-slate-600 line-clamp-2">
          <%= HtmlUtil.escape(post.getDescription()) %>
        </p>
      </div>
      <div class="flex items-center justify-between mt-4">
        <a
          href="<%= request.getContextPath() %>/post_detail.jsp?id=<%= post.getId() %>"
          class="text-sm text-indigo-600 font-semibold"
          >View details</a
        >
        <form action="<%= request.getContextPath() %>/favorites/toggle" method="POST">
          <input type="hidden" name="csrf_token" value="<%= CsrfUtil.getToken(session) %>" />
          <input type="hidden" name="post_id" value="<%= post.getId() %>" />
          <button
            type="submit"
            class="text-sm text-rose-600 font-semibold"
          >Remove</button>
        </form>
      </div>
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
    <p class="text-lg font-semibold text-slate-900">No favorites yet</p>
    <p class="text-slate-500">Save posts you want to revisit later.</p>
  </div>
  <% } %>
</section>
<%@ include file="/layouts/main_bottom.jsp" %>
