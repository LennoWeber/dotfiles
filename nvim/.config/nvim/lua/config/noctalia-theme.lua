local M = {}

local SETTINGS_PATH = vim.fn.expand("~/.local/state/noctalia/settings.toml")
local COLORS_JSON_PATH = vim.fn.expand("~/.config/noctalia/colors.json")
local PALETTES_DIR = vim.fn.expand("~/.config/noctalia/palettes")
local COLORSCHEMES_DIR = vim.fn.expand("~/.config/noctalia/colorschemes")
local COMMUNITY_PALETTES_DIR = vim.fn.expand("~/.local/state/noctalia/community-palettes")

local function read_json(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local ok_json, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_json or type(data) ~= "table" then
    return nil
  end

  return data
end

local function parse_theme_settings()
  local ok, lines = pcall(vim.fn.readfile, SETTINGS_PATH)
  if not ok then
    return {}
  end

  local in_theme = false
  local theme = {}

  for _, line in ipairs(lines) do
    if line:match("^%[theme%]") then
      in_theme = true
    elseif in_theme and line:match("^%[") and not line:match("^%[theme%.") then
      in_theme = false
    elseif in_theme then
      local key, quoted = line:match("^([%w_]+) = \"(.-)\"$")
      if key and quoted then
        theme[key] = quoted
      end
    end
  end

  return theme
end

local function theme_mode()
  local mode = vim.fn.system({ "noctalia", "msg", "theme-mode-get" })
  mode = vim.trim(mode)
  if mode == "light" then
    return "light"
  end
  return "dark"
end

local function palette_from_mode(data, mode)
  if type(data) ~= "table" then
    return nil
  end

  if type(data[mode]) == "table" then
    return data[mode]
  end

  if data.mSurface then
    return data
  end

  return nil
end

local function resolve_palette()
  local theme = parse_theme_settings()
  local mode = theme_mode()
  local source = theme.source or "builtin"
  local candidates = {}

  if source == "custom" and theme.custom_palette then
    table.insert(candidates, PALETTES_DIR .. "/" .. theme.custom_palette .. ".json")
  elseif source == "community" and theme.community_palette then
    table.insert(candidates, COMMUNITY_PALETTES_DIR .. "/" .. theme.community_palette .. ".json")
    local escaped = theme.community_palette:gsub(" ", "%%20")
    table.insert(candidates, COMMUNITY_PALETTES_DIR .. "/" .. escaped .. ".json")
  elseif theme.builtin then
    table.insert(candidates, COLORSCHEMES_DIR .. "/" .. theme.builtin .. "/" .. theme.builtin .. ".json")
  end

  table.insert(candidates, COLORS_JSON_PATH)

  for _, path in ipairs(candidates) do
    local data = read_json(path)
    local palette = palette_from_mode(data, mode)
    if palette then
      return palette
    end
  end

  return {}
end

local function build_base16(palette)
  local function pick(key, fallback)
    local value = palette[key]
    if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
      return value
    end
    return fallback
  end

  local function term(name, fallback)
    local terminal = palette.terminal
    if type(terminal) == "table" and type(terminal.normal) == "table" then
      local value = terminal.normal[name]
      if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
        return value
      end
    end
    return fallback
  end

  return {
    base00 = pick("mSurface", "#111417"),
    base01 = pick("mSurfaceVariant", "#1a1f24"),
    base02 = pick("mHover", "#252c34"),
    base03 = pick("mOutline", "#2f3944"),
    base04 = pick("mOnSurfaceVariant", "#99a3b0"),
    base05 = pick("mOnSurface", "#dce1e7"),
    base06 = pick("mOnHover", "#e8edf3"),
    base07 = pick("mOnHover", "#e8edf3"),
    base08 = pick("mError", term("red", "#e07a7a")),
    base09 = term("yellow", pick("mSecondary", "#b0a581")),
    base0A = term("yellow", pick("mPrimary", "#b0a581")),
    base0B = term("green", pick("mTertiary", "#86a88f")),
    base0C = term("cyan", pick("mTertiary", "#6f9c93")),
    base0D = term("blue", pick("mPrimary", "#8f9db0")),
    base0E = term("magenta", pick("mSecondary", "#9a93b2")),
    base0F = pick("mOnError", "#240909"),
  }
end



function M.apply()
  vim.opt.termguicolors = true
  vim.opt.background = theme_mode()
  
  pcall(vim.cmd, "colorscheme catppuccin-mocha")

  local palette = build_base16(resolve_palette())
  -- Force pure black background regardless of palette
  palette.base00 = "#000000"
  local bg = palette.base00
  local bg_alt = palette.base01
  local bg_hover = palette.base02
  local fg = palette.base05
  local fg_dim = palette.base04
  local border = palette.base03

  local function set_bg(group, color)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and type(hl) == "table" then
      hl.bg = color
      vim.api.nvim_set_hl(0, group, hl)
    else
      vim.api.nvim_set_hl(0, group, { bg = color })
    end
  end

  local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- ── Core UI backgrounds ─────────────────────────────────────────
  set_bg("Normal", bg)
  set_bg("NormalNC", bg)
  set_bg("NormalFloat", bg_alt)
  set_bg("FloatBorder", bg_alt)
  set_bg("SignColumn", bg)
  set_bg("EndOfBuffer", bg)
  set_bg("TelescopeNormal", bg_alt)
  set_bg("TelescopeBorder", bg_alt)
  set_bg("NvimTreeNormal", bg)
  set_bg("NvimTreeNormalNC", bg)
  set_bg("NeoTreeNormal", bg)
  set_bg("NeoTreeNormalNC", bg)
  set_bg("CursorLine", bg_alt)
  set_bg("ColorColumn", bg_alt)
  set_bg("CursorColumn", bg_alt)

  -- ── Line numbers ────────────────────────────────────────────────
  hi("LineNr",       { fg = border, bg = bg })
  hi("CursorLineNr", { fg = fg,    bg = bg })

  -- ── Statusline ──────────────────────────────────────────────────
  hi("StatusLine",   { fg = fg,     bg = bg_alt })
  hi("StatusLineNC", { fg = fg_dim, bg = bg })

  -- ── Separators ──────────────────────────────────────────────────
  hi("VertSplit",    { fg = border, bg = bg })
  hi("WinSeparator", { fg = border, bg = bg })

  -- ── Tabline ─────────────────────────────────────────────────────
  hi("TabLine",     { fg = fg_dim, bg = bg_alt })
  hi("TabLineSel",  { fg = fg,     bg = bg })
  hi("TabLineFill", { bg = bg })

  -- ── Diagnostics ─────────────────────────────────────────────────
  local diag_error = palette.base08
  local diag_warn  = palette.base09
  local diag_info  = palette.base0D
  local diag_hint  = palette.base0C

  hi("DiagnosticError", { fg = diag_error })
  hi("DiagnosticWarn",  { fg = diag_warn })
  hi("DiagnosticInfo",  { fg = diag_info })
  hi("DiagnosticHint",  { fg = diag_hint })
  hi("DiagnosticSignError", { fg = diag_error, bg = bg })
  hi("DiagnosticSignWarn",  { fg = diag_warn,  bg = bg })
  hi("DiagnosticSignInfo",  { fg = diag_info,  bg = bg })
  hi("DiagnosticSignHint",  { fg = diag_hint,  bg = bg })

  -- ── Pmenu (Autocomplete Popup) ──────────────────────────────────
  hi("Pmenu",      { fg = fg,     bg = bg_alt })
  hi("PmenuSel",   { fg = fg,     bg = bg_hover })
  hi("PmenuSbar",  { bg = bg_alt })
  hi("PmenuThumb", { bg = border })

  -- ── Visual / Search ─────────────────────────────────────────────
  hi("Visual",    { bg = bg_hover })
  hi("VisualNOS", { bg = bg_hover })
  hi("Search",    { fg = bg, bg = palette.base0A })
  hi("IncSearch", { fg = bg, bg = palette.base09 })

  -- ── Float border ────────────────────────────────────────────────
  hi("FloatBorder", { fg = border, bg = bg_alt })

  -- ── WhichKey ────────────────────────────────────────────────────
  set_bg("WhichKey",      bg_alt)
  set_bg("WhichKeyFloat", bg_alt)

  -- ── Noice / Notify ──────────────────────────────────────────────
  set_bg("NoiceCmdlinePopup", bg_alt)
  vim.g.colors_name = "catppuccin-noctalia"
end

function M.attach_signal()
  if vim.g.noctalia_sigusr1_attached then
    return
  end

  local uv = vim.uv or vim.loop
  if not uv or type(uv.new_signal) ~= "function" then
    return
  end

  local signal = uv.new_signal()
  if not signal then
    return
  end

  signal:start(
    "sigusr1",
    vim.schedule_wrap(function()
      M.apply()
    end)
  )

  vim.g.noctalia_sigusr1_attached = true
end

function M.attach_watchers()
  if vim.g.noctalia_watchers_attached then
    return
  end

  local uv = vim.uv or vim.loop
  if not uv or type(uv.new_fs_event) ~= "function" then
    return
  end

  local function watch(path)
    local handle = uv.new_fs_event()
    if not handle then
      return
    end

    handle:start(
      path,
      {},
      vim.schedule_wrap(function()
        M.apply()
      end)
    )
  end

  watch(SETTINGS_PATH)
  watch(PALETTES_DIR)
  watch(COLORS_JSON_PATH)

  vim.g.noctalia_watchers_attached = true
end

return M
