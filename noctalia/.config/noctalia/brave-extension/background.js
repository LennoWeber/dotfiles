const POLL_MS = 2000;
let lastPayload = "";

function hexToRgb(hex) {
  const value = hex.replace("#", "");
  if (value.length !== 6) {
    return [17, 20, 23];
  }
  return [
    parseInt(value.slice(0, 2), 16),
    parseInt(value.slice(2, 4), 16),
    parseInt(value.slice(4, 6), 16),
  ];
}

async function loadColors() {
  const response = await fetch(chrome.runtime.getURL("colors.json"));
  if (!response.ok) {
    throw new Error(`colors.json HTTP ${response.status}`);
  }
  return response.json();
}

async function applyTheme() {
  const colors = await loadColors();
  const payload = JSON.stringify(colors);
  if (payload === lastPayload) {
    return;
  }
  lastPayload = payload;

  const surface = hexToRgb(colors.surface);
  const surfaceVariant = hexToRgb(colors.surface_variant || colors.surface);
  const surfaceHigh = hexToRgb(colors.surface_high || colors.surface_variant || colors.surface);
  const onSurface = hexToRgb(colors.on_surface);
  const onSurfaceVariant = hexToRgb(colors.on_surface_variant || colors.on_surface);
  const primary = hexToRgb(colors.primary);
  const outline = hexToRgb(colors.outline || colors.surface_variant || colors.surface);
  const mode = colors.mode === "light" ? "light" : "dark";

  await chrome.theme.update({
    colors: {
      frame: surface,
      frame_inactive: surfaceVariant,
      toolbar: surface,
      toolbar_field: surfaceHigh,
      toolbar_field_text: onSurface,
      toolbar_field_border: outline,
      toolbar_text: onSurface,
      tab_background_text: onSurfaceVariant,
      tab_text: onSurface,
      bookmark_text: onSurface,
      ntp_background: surface,
      ntp_text: onSurface,
      ntp_link: primary,
      button_background: surfaceHigh,
    },
    properties: {
      color_scheme: mode,
    },
  });
}

async function tick() {
  try {
    await applyTheme();
  } catch (error) {
    console.warn("[Noctalia Brave Theme]", error);
  }
}

chrome.runtime.onInstalled.addListener(tick);
setInterval(tick, POLL_MS);
tick();
