<%@ page import="com.bridgeboard.model.User" %> <%@ page
import="com.bridgeboard.util.CsrfUtil" %> <% User navUser = (User)
session.getAttribute("user"); String ctx = request.getContextPath(); %>
<header class="bg-white/90 backdrop-blur border-b border-slate-200/80">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex items-center justify-between py-4">
      <a href="<%= ctx %>/index.jsp" class="flex items-center gap-2">
        <span
          class="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-600 text-white font-semibold"
          >BB</span
        >
        <div>
          <p class="text-lg font-semibold text-slate-900">BridgeBoard</p>
          <p class="text-xs text-slate-500">Skill Exchange Community</p>
        </div>
      </a>
      <nav
        class="hidden md:flex items-center gap-6 text-sm font-medium text-slate-600"
      >
        <a href="<%= ctx %>/browse.jsp" class="hover:text-slate-900">Browse</a>
        <a href="<%= ctx %>/search.jsp" class="hover:text-slate-900">Search</a>
        <a href="<%= ctx %>/contact.jsp" class="hover:text-slate-900"
          >Contact</a
        >
        <% if (navUser != null) { %>
        <a href="<%= ctx %>/dashboard.jsp" class="hover:text-slate-900"
          >Dashboard</a
        >
        <a href="<%= ctx %>/favorites.jsp" class="hover:text-slate-900"
          >Favorites</a
        >
        <a href="<%= ctx %>/exchanges.jsp" class="hover:text-slate-900"
          >Exchanges</a
        >
        <form action="<%= ctx %>/logout.jsp" method="POST" class="inline">
          <input
            type="hidden"
            name="csrf_token"
            value="<%= CsrfUtil.getToken(session) %>"
          />
          <button
            type="submit"
            class="inline-flex items-center gap-2 rounded-lg bg-slate-900 px-4 py-2 text-white"
          >
            Logout
          </button>
        </form>
        <% } else { %>
        <a href="<%= ctx %>/login.jsp" class="text-indigo-600">Login</a>
        <a
          href="<%= ctx %>/register.jsp"
          class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-white"
          >Join</a
        >
        <% } %>
      </nav>
      <button
        class="md:hidden inline-flex h-10 w-10 items-center justify-center rounded-lg border border-slate-200"
        data-mobile-toggle
      >
        <span class="sr-only">Toggle menu</span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
          />
        </svg>
      </button>
    </div>
    <div class="md:hidden" data-mobile-menu hidden>
      <div class="flex flex-col gap-4 pb-4 text-slate-700">
        <a href="<%= ctx %>/browse.jsp" class="hover:text-slate-900">Browse</a>
        <a href="<%= ctx %>/search.jsp" class="hover:text-slate-900">Search</a>
        <a href="<%= ctx %>/contact.jsp" class="hover:text-slate-900"
          >Contact</a
        >
        <% if (navUser != null) { %>
        <a href="<%= ctx %>/dashboard.jsp" class="hover:text-slate-900"
          >Dashboard</a
        >
        <a href="<%= ctx %>/favorites.jsp" class="hover:text-slate-900"
          >Favorites</a
        >
        <a href="<%= ctx %>/exchanges.jsp" class="hover:text-slate-900"
          >Exchanges</a
        >
        <form action="<%= ctx %>/logout.jsp" method="POST" class="inline">
          <input
            type="hidden"
            name="csrf_token"
            value="<%= CsrfUtil.getToken(session) %>"
          />
          <button
            type="submit"
            class="inline-flex items-center gap-2 rounded-lg bg-slate-900 px-4 py-2 text-white"
          >
            Logout
          </button>
        </form>
        <% } else { %>
        <a href="<%= ctx %>/login.jsp" class="text-indigo-600">Login</a>
        <a
          href="<%= ctx %>/register.jsp"
          class="inline-flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-white"
          >Join</a
        >
        <% } %>
      </div>
    </div>
  </div>
</header>
