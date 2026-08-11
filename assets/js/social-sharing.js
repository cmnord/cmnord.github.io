document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-native-share]").forEach((shareButton) => {
    if (!navigator.share) return;

    shareButton.hidden = false;
    shareButton.addEventListener("click", async () => {
      try {
        await navigator.share({
          title: shareButton.dataset.shareTitle,
          url: shareButton.dataset.shareUrl,
        });
      } catch (error) {
        if (error.name !== "AbortError") console.error(error);
      }
    });
  });
});
