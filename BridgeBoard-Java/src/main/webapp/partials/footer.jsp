<footer class="bg-white border-t border-slate-200 mt-16">
  <div
    class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex flex-col md:flex-row gap-6 md:items-center md:justify-between"
  >
    <div>
      <p class="text-lg font-semibold text-slate-900">BridgeBoard</p>
      <p class="text-sm text-slate-500">
        Connecting neighbors through skill sharing.
      </p>
    </div>
    <div class="text-sm text-slate-500 flex flex-wrap gap-4">
      <a
        href="<%= request.getContextPath() %>/browse.jsp"
        class="hover:text-slate-900"
        >Browse</a
      >
      <a
        href="<%= request.getContextPath() %>/contact.jsp"
        class="hover:text-slate-900"
        >Contact</a
      >
      <a href="mailto:hello@bridgeboard.local" class="hover:text-slate-900"
        >hello@bridgeboard.local</a
      >
    </div>
    <p class="text-xs text-slate-400">
      &copy; <%= java.time.Year.now() %> BridgeBoard. All rights reserved.
    </p>
  </div>
</footer>
