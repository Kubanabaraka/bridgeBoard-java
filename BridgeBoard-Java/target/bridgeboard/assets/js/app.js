document.addEventListener("DOMContentLoaded", () => {
  const toggleBtn = document.querySelector("[data-mobile-toggle]");
  const mobileMenu = document.querySelector("[data-mobile-menu]");

  if (toggleBtn && mobileMenu) {
    toggleBtn.addEventListener("click", () => {
      const hidden = mobileMenu.hasAttribute("hidden");
      if (hidden) {
        mobileMenu.removeAttribute("hidden");
      } else {
        mobileMenu.setAttribute("hidden", "hidden");
      }
    });
  }
});
