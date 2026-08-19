const THEME_STORAGE_KEY = "theme";

function storedTheme() {
  const stored = localStorage.getItem(THEME_STORAGE_KEY);
  return stored === "light" || stored === "dark" ? stored : null;
}

function preferredTheme() {
  return (
    storedTheme() ?? (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
  );
}

function applyTheme(theme) {
  document.documentElement.setAttribute("data-theme", theme);
}

function syncToggle(button, theme) {
  const dark = theme === "dark";
  const icon = button.querySelector("i");

  const label = dark ? "Switch to light theme" : "Switch to dark theme";

  button.setAttribute("aria-pressed", dark.toString());
  button.setAttribute("aria-label", label);
  button.setAttribute("title", label);
  if (icon) icon.className = dark ? "fa-solid fa-sun" : "fa-solid fa-moon";
}

const button = document.querySelector("[data-theme-toggle]");
if (button) {
  syncToggle(button, document.documentElement.getAttribute("data-theme") || preferredTheme());

  button.addEventListener("click", () => {
    const next = document.documentElement.getAttribute("data-theme") === "dark" ? "light" : "dark";
    localStorage.setItem(THEME_STORAGE_KEY, next);
    applyTheme(next);
    syncToggle(button, next);
  });

  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", (event) => {
    if (storedTheme()) return;
    const theme = event.matches ? "dark" : "light";
    applyTheme(theme);
    syncToggle(button, theme);
  });
}
