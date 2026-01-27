<%@ page import="com.bridgeboard.model.SkillPost" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <% SkillPost post = (SkillPost)
request.getAttribute("post"); String image = null; if (post != null &&
post.getImages() != null && !post.getImages().isEmpty()) { image =
post.getImages().get(0); } if (image == null || image.isBlank()) { image =
"assets/images/empty-state.svg"; } %>
<div
  class="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden"
>
  <a
    href="<%= request.getContextPath() %>/post_detail.jsp?id=<%= post.getId() %>"
    class="block"
  >
    <img
      src="<%= request.getContextPath() %>/<%= image %>"
      alt="<%= HtmlUtil.escape(post.getTitle()) %>"
      class="h-48 w-full object-cover"
    />
    <div class="p-6 space-y-3">
      <div class="flex items-center justify-between text-xs text-slate-500">
        <span
          ><%= HtmlUtil.escape(post.getCategoryName() == null ? "General" :
          post.getCategoryName()) %></span
        >
        <span
          ><%= HtmlUtil.escape(post.getLocation() == null ? "Remote" :
          post.getLocation()) %></span
        >
      </div>
      <h3 class="text-lg font-semibold text-slate-900">
        <%= HtmlUtil.escape(post.getTitle()) %>
      </h3>
      <p class="text-sm text-slate-500 line-clamp-2">
        <%= HtmlUtil.escape(post.getDescription()) %>
      </p>
      <div class="flex items-center justify-between text-sm text-slate-500">
        <span
          >By <%= HtmlUtil.escape(post.getUserName() == null ? "Member" :
          post.getUserName()) %></span
        >
        <span class="text-indigo-600 font-semibold">View details</span>
      </div>
    </div>
  </a>
</div>
