document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("pre.highlight").forEach((codeBlock) => {
    const lines = codeBlock.textContent.trimEnd().split("\n");

    if (lines.length < 2) return;

    const container = codeBlock.parentElement;
    const toggle = document.createElement("button");
    const icon = document.createElement("i");

    container.classList.add("has-code-wrap-toggle");
    toggle.type = "button";
    toggle.className = "code-wrap-toggle";
    toggle.setAttribute("aria-pressed", "true");
    toggle.setAttribute("aria-label", "Disable line wrapping");
    toggle.title = "Line wrapping on";
    icon.className = "fa-solid fa-arrow-turn-down";
    icon.setAttribute("aria-hidden", "true");
    toggle.append(icon);

    toggle.addEventListener("click", () => {
      const wrapping = codeBlock.classList.toggle("code-nowrap") === false;

      toggle.setAttribute("aria-pressed", wrapping.toString());
      toggle.setAttribute(
        "aria-label",
        wrapping ? "Disable line wrapping" : "Enable line wrapping",
      );
      toggle.title = wrapping ? "Line wrapping on" : "Line wrapping off";
      icon.className = wrapping ? "fa-solid fa-arrow-turn-down" : "fa-solid fa-arrow-right-long";
    });

    container.prepend(toggle);
  });
});
