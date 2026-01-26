<%@ page import="com.bridgeboard.dao.SkillPostDao" %> <%@ page
import="com.bridgeboard.dao.UserDao" %> <%@ page
import="com.bridgeboard.model.SkillPost" %> <%@ page
import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.CsrfUtil" %> <%@ page
import="com.bridgeboard.util.FormUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %> <% if
("POST".equalsIgnoreCase(request.getMethod())) {
request.getRequestDispatcher("/profile/update").forward(request, response);
return; } User currentUser = (User) session.getAttribute("user"); String idRaw =
request.getParameter("id"); Integer profileId = null; if (idRaw != null &&
!idRaw.isBlank()) { profileId = Integer.parseInt(idRaw); } UserDao userDao = new
UserDao(); User profileUser = profileId == null ? currentUser :
userDao.findById(profileId); if (profileUser == null) {
response.sendRedirect(request.getContextPath() + "/404.jsp"); return; } boolean
canEdit = currentUser != null && currentUser.getId() == profileUser.getId();
request.setAttribute("pageTitle", canEdit ? "My profile" :
profileUser.getName()); SkillPostDao postDao = new SkillPostDao();
List<SkillPost>
  posts = postDao.forUser(profileUser.getId()); Map<String, List<String
    >> errors = FormUtil.consumeErrors(session); %> <%@ include
    file="/layouts/main_top.jsp" %>
    <section class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-8">
      <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-8">
        <div class="flex flex-col md:flex-row gap-6 md:items-center">
          <img src="<%= request.getContextPath() %>/<%=
          HtmlUtil.escape(profileUser.getAvatarPath() == null ?
          "assets/images/profile-default.svg" : profileUser.getAvatarPath()) %>"
          alt="Avatar" class="h-24 w-24 rounded-full object-cover">
          <div class="flex-1">
            <h1 class="text-3xl font-semibold text-slate-900">
              <%= HtmlUtil.escape(profileUser.getName()) %>
            </h1>
            <p class="text-slate-500">
              <%= HtmlUtil.escape(profileUser.getLocation() == null ? "Remote" :
              profileUser.getLocation()) %>
            </p>
            <p class="text-slate-600 mt-3">
              <%= HtmlUtil.escape(profileUser.getBio() == null ? "" :
              profileUser.getBio()) %>
            </p>
          </div>
          <% if (canEdit) { %>
          <a
            href="#edit-profile"
            class="inline-flex items-center gap-2 rounded-xl bg-indigo-600 px-5 py-3 text-white font-semibold"
            >Edit profile</a
          >
          <% } %>
        </div>
      </div>

      <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-8">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-2xl font-semibold text-slate-900">Skill posts</h2>
          <a
            href="<%= request.getContextPath() %>/browse.jsp"
            class="text-sm text-indigo-600 font-semibold"
            >Browse community</a
          >
        </div>
        <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          <% for (SkillPost post : posts) { %> <% request.setAttribute("post",
          post); %>
          <jsp:include page="/partials/post_card.jsp" />
          <% } %> <% if (posts.isEmpty()) { %>
          <div
            class="bg-slate-50 rounded-2xl border border-dashed border-slate-200 p-10 text-center"
          >
            <img
              src="<%= request.getContextPath() %>/assets/images/empty-state.svg"
              alt="Empty"
              class="h-32 mx-auto mb-4"
            />
            <p class="text-slate-500">No posts yet.</p>
          </div>
          <% } %>
        </div>
      </div>

      <% if (canEdit) { %>
      <div
        id="edit-profile"
        class="bg-white rounded-3xl border border-slate-100 shadow-xl p-8"
      >
        <h2 class="text-2xl font-semibold text-slate-900 mb-6">
          Update profile
        </h2>
        <form
          action="<%= request.getContextPath() %>/profile.jsp"
          method="POST"
          enctype="multipart/form-data"
          class="space-y-5"
        >
          <input
            type="hidden"
            name="csrf_token"
            value="<%= CsrfUtil.getToken(session) %>"
          />
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-2"
              >Name</label
            >
            <input
              type="text"
              name="name"
              value="<%= HtmlUtil.escape(profileUser.getName()) %>"
              class="w-full px-4 py-3 border border-slate-200 rounded-xl"
            />
            <% if (errors.containsKey("name")) { %>
            <p class="text-sm text-rose-500 mt-1">
              <%= HtmlUtil.escape(errors.get("name").get(0)) %>
            </p>
            <% } %>
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-2"
              >Location</label
            >
            <input type="text" name="location" value="<%=
            HtmlUtil.escape(profileUser.getLocation() == null ? "" :
            profileUser.getLocation()) %>" class="w-full px-4 py-3 border
            border-slate-200 rounded-xl">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-2"
              >Bio</label
            >
            <textarea
              name="bio"
              class="w-full min-h-[120px] px-4 py-3 border border-slate-200 rounded-xl"
            >
<%= HtmlUtil.escape(profileUser.getBio() == null ? "" : profileUser.getBio()) %></textarea
            >
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-2"
              >Avatar</label
            >
            <input
              type="file"
              name="avatar"
              accept="image/*"
              class="w-full text-sm"
            />
          </div>
          <button
            type="submit"
            class="w-full bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl px-6 py-3 font-semibold"
          >
            Save changes
          </button>
        </form>
      </div>
      <% } %>
    </section>
    <%@ include file="/layouts/main_bottom.jsp" %>
  </String,></SkillPost
>
