<%@ page import="com.bridgeboard.util.CsrfUtil" %> <%@ page
import="com.bridgeboard.util.FormUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %> <% request.setAttribute("pageTitle", "Create an account"); Map<String,
  List<String
  >> errors = FormUtil.consumeErrors(session); %> <%@ include
  file="/layouts/main_top.jsp" %>
  <section class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
    <div
      class="bg-white rounded-3xl border border-slate-100 shadow-xl overflow-hidden grid md:grid-cols-2"
    >
      <div
        class="bg-gradient-to-br from-indigo-600 to-teal-500 text-white p-10 flex flex-col gap-6"
      >
        <h1 class="text-3xl font-bold">Join BridgeBoard</h1>
        <p class="text-indigo-100">
          Showcase what you can teach, learn from neighbors, and build your
          creative network.
        </p>
        <ul class="space-y-3 text-indigo-100">
          <li class="flex items-center gap-3">
            <span
              class="inline-flex h-8 w-8 items-center justify-center rounded-full bg-white/20"
              >1</span
            >
            Create a beautiful profile
          </li>
          <li class="flex items-center gap-3">
            <span
              class="inline-flex h-8 w-8 items-center justify-center rounded-full bg-white/20"
              >2</span
            >
            Publish unlimited skill offers
          </li>
          <li class="flex items-center gap-3">
            <span
              class="inline-flex h-8 w-8 items-center justify-center rounded-full bg-white/20"
              >3</span
            >
            Message community members
          </li>
        </ul>
      </div>
      <div class="p-10">
        <form
          action="<%= request.getContextPath() %>/auth/register"
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
              >Full name</label
            >
            <input type="text" name="name" value="<%=
            HtmlUtil.escape(FormUtil.old(session, "name")) %>" class="w-full
            px-4 py-3 border border-slate-200 rounded-xl focus:ring-2
            focus:ring-indigo-100" placeholder="Alex Rivera"> <% if
            (errors.containsKey("name")) { %>
            <p class="text-sm text-rose-500 mt-1">
              <%= HtmlUtil.escape(errors.get("name").get(0)) %>
            </p>
            <% } %>
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-2"
              >Email</label
            >
            <input type="email" name="email" value="<%=
            HtmlUtil.escape(FormUtil.old(session, "email")) %>" class="w-full
            px-4 py-3 border border-slate-200 rounded-xl focus:ring-2
            focus:ring-indigo-100" placeholder="you@email.com"> <% if
            (errors.containsKey("email")) { %>
            <p class="text-sm text-rose-500 mt-1">
              <%= HtmlUtil.escape(errors.get("email").get(0)) %>
            </p>
            <% } %>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-2"
                >Password</label
              >
              <input
                type="password"
                name="password"
                class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100"
              />
              <% if (errors.containsKey("password")) { %>
              <p class="text-sm text-rose-500 mt-1">
                <%= HtmlUtil.escape(errors.get("password").get(0)) %>
              </p>
              <% } %>
            </div>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-2"
                >Confirm password</label
              >
              <input
                type="password"
                name="password_confirmation"
                class="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-2"
              >Location</label
            >
            <input type="text" name="location" value="<%=
            HtmlUtil.escape(FormUtil.old(session, "location")) %>" class="w-full
            px-4 py-3 border border-slate-200 rounded-xl focus:ring-2
            focus:ring-indigo-100" placeholder="Austin, TX">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-2"
              >Bio</label
            >
            <textarea
              name="bio"
              class="w-full min-h-[120px] px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-100"
              placeholder="Describe your experience & what you're excited to share."
            >
<%= HtmlUtil.escape(FormUtil.old(session, "bio")) %></textarea
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
            Create account
          </button>
          <p class="text-sm text-slate-500 text-center">
            Already a member?
            <a
              href="<%= request.getContextPath() %>/login.jsp"
              class="text-indigo-600 font-semibold"
              >Log in</a
            >
          </p>
        </form>
      </div>
    </div>
  </section>
  <%@ include file="/layouts/main_bottom.jsp" %>
