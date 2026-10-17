 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#16130e',
    base01 = '#221e17',
    base02 = '#2e291f',
    base03 = '#676156',
    base04 = '#a79c8a',
    base05 = '#f4ede1',
    base06 = '#f4ede1',
    base07 = '#f4ede1',
    base08 = '#e5604c',
    base09 = '#a3b18a',
    base0A = '#ffc482',
    base0B = '#f2a33c',
    base0C = '#cbe996',
    base0D = '#f7c787',
    base0E = '#ffc380',
    base0F = '#ffdbb3',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f4ede1',          bg = '#16130e' })
  hi('TelescopeBorder',         { fg = '#676156',             bg = '#16130e' })
  hi('TelescopePromptNormal',   { fg = '#f4ede1',          bg = '#16130e' })
  hi('TelescopePromptBorder',   { fg = '#676156',             bg = '#16130e' })
  hi('TelescopePromptPrefix',   { fg = '#f2a33c',             bg = '#16130e' })
  hi('TelescopePromptCounter',  { fg = '#a79c8a',  bg = '#16130e' })
  hi('TelescopePromptTitle',    { fg = '#16130e',             bg = '#f2a33c' })
  hi('TelescopePreviewTitle',   { fg = '#16130e',             bg = '#ffc482' })
  hi('TelescopeResultsTitle',   { fg = '#16130e',             bg = '#a3b18a' })
  hi('TelescopeSelection',      { fg = '#f4ede1',          bg = '#2e291f' })
  hi('TelescopeSelectionCaret', { fg = '#f2a33c',             bg = '#2e291f' })
  hi('TelescopeMatching',       { fg = '#f2a33c',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f4ede1',          bg = '#16130e' })
  hi('MiniPickBorder',         { fg = '#676156',             bg = '#16130e' })
  hi('MiniPickPrompt',   { fg = '#f4ede1',          bg = '#16130e' })
  hi('MiniPickPromptPrefix',   { fg = '#f2a33c',             bg = '#16130e' })
  hi('MiniPickBorderText',    { fg = '#16130e',             bg = '#f2a33c' })
  hi('MiniPickMatchCurrent',      { fg = '#f4ede1',          bg = '#2e291f' })
  hi('MiniPickPromptCaret', { fg = '#f2a33c',             bg = '#2e291f' })
  hi('MiniPickMatchRanges',       { fg = '#f2a33c',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
