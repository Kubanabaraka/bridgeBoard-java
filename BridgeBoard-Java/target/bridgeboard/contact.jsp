<%@ page import="com.bridgeboard.dao.MessageDao" %> <%@ page
import="com.bridgeboard.model.Message" %> <%@ page
import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.CsrfUtil" %> <%@ page
import="com.bridgeboard.util.DateUtil" %> <%@ page
import="com.bridgeboard.util.FormUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %> <% User user = (User)
session.getAttribute("user"); if (user == null) {
response.sendRedirect(request.getContextPath() + "/login.jsp"); return; } if
("POST".equalsIgnoreCase(request.getMethod())) {
request.getRequestDispatcher("/messages/send").forward(request, response);
return; } request.setAttribute("pageTitle", "Messages"); MessageDao messageDao =
new MessageDao(); List<Message>
  messages = messageDao.forUser(user.getId(), 25); Map<String, List<String
    >> errors = FormUtil.consumeErrors(session); String recipient =
    request.getParameter("recipient"); String skill =
    request.getParameter("skill"); %> <%@ include file="/layouts/main_top.jsp"
    %>
    <section class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-10">
      <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-8">
        <div class="flex items-center justify-between mb-8">
          <div>
            <p class="text-sm uppercase text-indigo-500 font-semibold">Inbox</p>
            <h1 class="text-3xl font-semibold text-slate-900">Messages</h1>
          </div>
          <a
            href="<%= request.getContextPath() %>/browse.jsp"
            class="text-sm text-slate-500"
            >Find more collaborators</a
          >
        </div>
        <% if (!messages.isEmpty()) { %>
        <div class="space-y-4 max-h-96 overflow-auto pr-2">
          <% for (Message message : messages) { String senderName =
          message.getSenderName() == null ? "BB" : message.getSenderName();
          String initials = senderName.substring(0, Math.min(2,
          senderName.length())).toUpperCase(); %>
          <div class="border border-slate-100 rounded-2xl p-4 flex gap-4">
            <div
              class="h-12 w-12 rounded-full bg-indigo-50 text-indigo-600 font-semibold flex items-center justify-center"
            >
              <%= HtmlUtil.escape(initials) %>
            </div>
            <div>
              <div class="flex items-center gap-2 text-sm text-slate-500">
                <span
                  ><%= HtmlUtil.escape(message.getSenderName() == null ?
                  "Community member" : message.getSenderName()) %></span
                >
                <span>&bull;</span>
                <span
                  ><%= HtmlUtil.escape(DateUtil.format(message.getCreatedAt(),
                  "MMM dd, yyyy 'at' h:mma")) %></span
                >
              </div>
              <% if (message.getSkillTitle() != null) { %>
              <p class="text-xs text-indigo-600 font-semibold">
                Regarding <%= HtmlUtil.escape(message.getSkillTitle()) %>
              </p>
              <% } %>
              <p class="text-slate-700 mt-2 leading-relaxed">
                <%= com.bridgeboard.util.HtmlUtil.nl2br(message.getContent()) %>
              </p>
            </div>
          </div>
          <% } %>
        </div>
        <% } else { %>
        <div class="text-center py-12 text-slate-500">
          <img
            src="<%= request.getContextPath() %>/assets/images/empty-state.svg"
            alt="Empty"
            class="h-32 mx-auto mb-4"
          />
          You have no messages yet.
        </div>
        <% } %>
      </div>

      <div class="bg-white rounded-3xl border border-slate-100 shadow-xl p-8">
        <h2 class="text-2xl font-semibold text-slate-900 mb-6">
          Send a message
        </h2>
        <form
          action="<%= request.getContextPath() %>/contact.jsp"
          method="POST"
          class="space-y-5"
        >
          <input
            type="hidden"
            name="csrf_token"
            value="<%= CsrfUtil.getToken(session) %>"
          />
          <div>
            <label class="text-sm font-semibold text-slate-700"
              >Recipient user ID</label
            >
            <input type="number" name="recipient_id" value="<%=
            HtmlUtil.escape(recipient == null ? "" : recipient) %>" class="mt-1
            w-full px-4 py-3 border border-slate-200 rounded-xl"> <% if
            (errors.containsKey("recipient_id")) { %>
            <p class="text-xs text-rose-500">
              <%= HtmlUtil.escape(errors.get("recipient_id").get(0)) %>
            </p>
            <% } %>
          </div>
          <div>
            <label class="text-sm font-semibold text-slate-700"
              >Skill post ID (optional)</label
            >
            <input type="number" name="skill_post_id" value="<%=
            HtmlUtil.escape(skill == null ? "" : skill) %>" class="mt-1 w-full
            px-4 py-3 border border-slate-200 rounded-xl">
          </div>
          <div>
            <label class="text-sm font-semibold text-slate-700">Message</label>
            <textarea
              name="content"
              class="mt-1 w-full min-h-[140px] px-4 py-3 border border-slate-200 rounded-xl"
              placeholder="Introduce yourself and share what you're hoping to collaborate on."
            ></textarea>
            <% if (errors.containsKey("content")) { %>
            <p class="text-xs text-rose-500">
              <%= HtmlUtil.escape(errors.get("content").get(0)) %>
            </p>
            <% } %>
          </div>
          <button
            type="submit"
            class="w-full rounded-xl bg-indigo-600 px-6 py-3 text-white font-semibold"
          >
            Send message
          </button>
        </form>
      </div>
    </section>
    <%@ include file="/layouts/main_bottom.jsp" %>
  </String,></Message
>
