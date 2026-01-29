<%@ page import="com.bridgeboard.dao.FavoriteDao" %> <%@ page
import="com.bridgeboard.dao.MessageDao" %> <%@ page
import="com.bridgeboard.dao.SkillExchangeDao" %> <%@ page
import="com.bridgeboard.dao.SkillPostDao" %> <%@ page
import="com.bridgeboard.model.Message" %> <%@ page
import="com.bridgeboard.model.SkillPost" %> <%@ page
import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.DateUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page
import="com.bridgeboard.util.CsrfUtil" %> <%@ page import="java.util.List" %> <%
User user = (User) session.getAttribute("user"); if (user == null) {
response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
request.setAttribute("pageTitle", "Dashboard"); SkillPostDao postDao = new
SkillPostDao(); MessageDao messageDao = new MessageDao(); FavoriteDao favoriteDao = new FavoriteDao();
SkillExchangeDao exchangeDao = new SkillExchangeDao();
List<SkillPost> posts = postDao.forUser(user.getId()); List<Message>
    messages = messageDao.forUser(user.getId(), 10);
int favoriteCount = favoriteDao.countForUser(user.getId());
int exchangeCount = exchangeDao.countForUser(user.getId());
int pendingExchangeCount = exchangeDao.countPendingForUser(user.getId());
%> <%@ include
    file="/layouts/main_top.jsp" %>
    <section class="bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-8">
        <div
          class="relative overflow-hidden rounded-3xl border border-slate-100 bg-gradient-to-r from-indigo-600 via-indigo-500 to-teal-500 text-white p-8"
        >
          <div class="flex flex-col lg:flex-row gap-6 items-center">
            <img
              src="<%= request.getContextPath() %>/assets/images/dashboard-banner.svg?v=teal-20260129"
              alt="Dashboard"
              class="w-full lg:w-1/2 rounded-2xl shadow-2xl border border-white/30"
            />
            <div class="flex-1 space-y-4">
              <p class="text-sm uppercase tracking-widest text-white/70">
                Welcome back
              </p>
              <h1 class="text-3xl font-semibold">
                Hey <%= HtmlUtil.escape(user.getName()) %> 👋
              </h1>
              <p class="text-white/80">
                Keep your skill posts fresh, respond to new requests, and
                explore new opportunities.
              </p>
              <div class="flex flex-wrap gap-4">
                <a
                  href="<%= request.getContextPath() %>/create_post.jsp"
                  class="inline-flex items-center gap-2 bg-white text-indigo-600 px-5 py-3 rounded-xl font-semibold"
                  >Create new post</a
                >
                <a
                  href="<%= request.getContextPath() %>/browse.jsp"
                  class="inline-flex items-center gap-2 border border-white/50 px-5 py-3 rounded-xl"
                  >Browse community</a
                >
              </div>
            </div>
          </div>
        </div>

        <div class="grid lg:grid-cols-3 gap-6">
          <div
            class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm"
          >
            <div class="flex items-center gap-4">
              <div
                class="h-16 w-16 rounded-2xl bg-indigo-50 flex items-center justify-center text-2xl font-semibold text-indigo-700"
              >
                <%= HtmlUtil.escape((user.getName() == null ? "BB" :
                user.getName()).substring(0, Math.min(2, user.getName() == null
                ? 2 : user.getName().length())).toUpperCase()) %>
              </div>
              <div>
                <p class="text-lg font-semibold text-slate-900">
                  <%= HtmlUtil.escape(user.getName()) %>
                </p>
                <p class="text-sm text-slate-500">
                  <%= HtmlUtil.escape(user.getLocation() == null ? "Remote" :
                  user.getLocation()) %>
                </p>
              </div>
            </div>
            <p class="text-slate-600 mt-4">
              <%= HtmlUtil.escape(user.getBio() == null ? "Share a short introduction to tell the community what you love to teach." : user.getBio()) %>
            </p>
            <a
              href="<%= request.getContextPath() %>/profile.jsp"
              class="inline-flex items-center gap-2 text-indigo-600 font-semibold mt-4"
              >Edit profile</a
            >
          </div>
          <div
            class="lg:col-span-2 bg-white rounded-2xl border border-slate-100 p-6 shadow-sm"
          >
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-xl font-semibold text-slate-900">Your posts</h2>
              <a
                href="<%= request.getContextPath() %>/create_post.jsp"
                class="text-sm text-indigo-600 font-semibold"
                >Add new</a
              >
            </div>
            <% if (!posts.isEmpty()) { %>
            <div class="space-y-4">
              <% for (SkillPost post : posts) { %>
              <div
                class="border border-slate-100 rounded-2xl p-4 flex flex-col md:flex-row gap-4 items-start md:items-center"
              >
                <div class="flex-1">
                  <p class="text-lg font-semibold text-slate-900">
                    <%= HtmlUtil.escape(post.getTitle()) %>
                  </p>
                  <p class="text-sm text-slate-500 line-clamp-2 mt-1">
                    <%= HtmlUtil.escape(post.getDescription()) %>
                  </p>
                </div>
                <div class="flex gap-3">
                  <a
                    href="<%= request.getContextPath() %>/edit_post.jsp?id=<%= post.getId() %>"
                    class="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-slate-200 text-sm font-semibold"
                    >Edit</a
                  >
                  <form
                    action="<%= request.getContextPath() %>/delete_post.jsp"
                    method="POST"
                    onsubmit="return confirm('Delete this post?');"
                  >
                    <input
                      type="hidden"
                      name="csrf_token"
                      value="<%= CsrfUtil.getToken(session) %>"
                    />
                    <input
                      type="hidden"
                      name="post_id"
                      value="<%= post.getId() %>"
                    />
                    <button
                      type="submit"
                      class="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-rose-200 text-sm font-semibold text-rose-600"
                    >
                      Delete
                    </button>
                  </form>
                </div>
              </div>
              <% } %>
            </div>
            <% } else { %>
            <div class="text-center py-16">
              <img
                src="<%= request.getContextPath() %>/assets/images/empty-state.svg"
                alt="Empty"
                class="h-40 mx-auto mb-4"
              />
              <p class="text-lg font-semibold text-slate-900">No posts yet</p>
              <p class="text-slate-500">
                Share your first skill offering to connect with members.
              </p>
            </div>
            <% } %>
          </div>
        </div>

        <div class="grid md:grid-cols-3 gap-6">
          <div class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm">
            <p class="text-sm uppercase text-slate-500">Favorites</p>
            <p class="text-3xl font-semibold text-slate-900 mt-2"><%= favoriteCount %></p>
            <a href="<%= request.getContextPath() %>/favorites.jsp" class="text-sm text-indigo-600 font-semibold mt-3 inline-flex">View saved posts</a>
          </div>
          <div class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm">
            <p class="text-sm uppercase text-slate-500">Exchanges</p>
            <p class="text-3xl font-semibold text-slate-900 mt-2"><%= exchangeCount %></p>
            <a href="<%= request.getContextPath() %>/exchanges.jsp" class="text-sm text-indigo-600 font-semibold mt-3 inline-flex">Track exchanges</a>
          </div>
          <div class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm">
            <p class="text-sm uppercase text-slate-500">Pending requests</p>
            <p class="text-3xl font-semibold text-slate-900 mt-2"><%= pendingExchangeCount %></p>
            <a href="<%= request.getContextPath() %>/exchanges.jsp" class="text-sm text-indigo-600 font-semibold mt-3 inline-flex">Review pending</a>
          </div>
        </div>

        <div class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold text-slate-900">
              Recent messages
            </h2>
            <a
              href="<%= request.getContextPath() %>/contact.jsp"
              class="text-sm text-indigo-600 font-semibold"
              >Open inbox</a
            >
          </div>
          <% if (!messages.isEmpty()) { %>
          <div class="space-y-4">
            <% for (Message message : messages) { String senderName =
            message.getSenderName() == null ? "BB" : message.getSenderName();
            String initials = senderName.substring(0, Math.min(2,
            senderName.length())).toUpperCase(); %>
            <div class="border border-slate-100 rounded-2xl p-4 flex gap-4">
              <div
                class="h-12 w-12 rounded-full bg-indigo-50 flex items-center justify-center text-indigo-600 font-semibold"
              >
                <%= HtmlUtil.escape(initials) %>
              </div>
              <div>
                <p class="text-sm text-slate-500">
                  <%= HtmlUtil.escape(message.getSenderName() == null ? "Community member" : message.getSenderName()) %> • <%= HtmlUtil.escape(DateUtil.format(message.getCreatedAt(), "MMM dd, yyyy")) %>
                </p>
                <% if (message.getSkillTitle() != null) { %>
                <p class="text-xs text-indigo-600 font-semibold">
                  Regarding: <%= HtmlUtil.escape(message.getSkillTitle()) %>
                </p>
                <% } %>
                <p class="text-slate-700 mt-1">
                  <%= com.bridgeboard.util.HtmlUtil.nl2br(message.getContent())
                  %>
                </p>
              </div>
            </div>
            <% } %>
          </div>
          <% } else { %>
          <div class="text-center py-10 text-slate-500">No messages yet.</div>
          <% } %>
        </div>
      </div>
    </section>
    <%@ include file="/layouts/main_bottom.jsp" %>
  </Message></SkillPost
>
