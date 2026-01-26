<%@ page import="com.bridgeboard.util.FlashUtil" %> <%@ page
import="com.bridgeboard.util.HtmlUtil" %> <% String pageTitle = (String)
request.getAttribute("pageTitle"); Object success = FlashUtil.consume(session,
"success"); Object error = FlashUtil.consume(session, "error"); %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>
      <%= HtmlUtil.escape(pageTitle == null ? "BridgeBoard" : pageTitle) %>
    </title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
      rel="stylesheet"
    />
    <script>
      window.tailwind = window.tailwind || {};
      window.tailwind.config = {
        theme: {
          extend: {
            fontFamily: {
              inter: [
                "Inter",
                "system-ui",
                "-apple-system",
                "BlinkMacSystemFont",
                "Segoe UI",
                "sans-serif",
              ],
            },
            colors: {
              primary: {
                50: "#ecfeff",
                100: "#cffafe",
                200: "#a5f3fc",
                300: "#67e8f9",
                400: "#22d3ee",
                500: "#06b6d4",
                600: "#0891b2",
                700: "#0e7490",
                800: "#155e75",
                900: "#164e63",
              },
            },
          },
        },
      };
    </script>
    <script src="https://cdn.tailwindcss.com?plugins=forms,typography,line-clamp"></script>
    <link
      rel="stylesheet"
      href="<%= request.getContextPath() %>/assets/css/tailwind.css"
    />
    <script
      defer
      src="<%= request.getContextPath() %>/assets/js/app.js"
    ></script>
  </head>
  <body class="min-h-screen bg-slate-50 font-[Inter] text-slate-900">
    <div class="relative min-h-screen flex flex-col">
      <jsp:include page="/partials/nav.jsp" />

      <% if (success != null) { %>
      <div
        class="fixed top-4 right-4 z-50 bg-emerald-500 text-white px-4 py-3 rounded-lg shadow-lg"
      >
        <%= HtmlUtil.escape(String.valueOf(success)) %>
      </div>
      <% } %> <% if (error != null) { %>
      <div
        class="fixed top-4 right-4 z-50 bg-rose-500 text-white px-4 py-3 rounded-lg shadow-lg"
      >
        <%= HtmlUtil.escape(String.valueOf(error)) %>
      </div>
      <% } %>

      <main class="flex-1">
