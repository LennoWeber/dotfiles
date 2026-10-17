 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#f5f0e6',
    base01 = '#ece5d6',
    base02 = '#e6dcc8',
    base03 = '#938a78',
    base04 = '#6e6555',
    base05 = '#26211a',
    base06 = '#26211a',
    base07 = '#26211a',
    base08 = '#c93f2e',
    base09 = '#6f8f5a',
    base0A = '#cb7e26',
    base0B = '#b26a0f',
    base0C = '#427e1b',
    base0D = '#8d540c',
    base0E = '#815018',
    base0F = '#ad6b1f',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#26211a',          bg = '#f5f0e6' })
  hi('TelescopeBorder',         { fg = '#938a78',             bg = '#f5f0e6' })
  hi('TelescopePromptNormal',   { fg = '#26211a',          bg = '#f5f0e6' })
  hi('TelescopePromptBorder',   { fg = '#938a78',             bg = '#f5f0e6' })
  hi('TelescopePromptPrefix',   { fg = '#b26a0f',             bg = '#f5f0e6' })
  hi('TelescopePromptCounter',  { fg = '#6e6555',  bg = '#f5f0e6' })
  hi('TelescopePromptTitle',    { fg = '#f5f0e6',             bg = '#b26a0f' })
  hi('TelescopePreviewTitle',   { fg = '#f5f0e6',             bg = '#cb7e26' })
  hi('TelescopeResultsTitle',   { fg = '#f5f0e6',             bg = '#6f8f5a' })
  hi('TelescopeSelection',      { fg = '#26211a',          bg = '#e6dcc8' })
  hi('TelescopeSelectionCaret', { fg = '#b26a0f',             bg = '#e6dcc8' })
  hi('TelescopeMatching',       { fg = '#b26a0f',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#26211a',          bg = '#f5f0e6' })
  hi('MiniPickBorder',         { fg = '#938a78',             bg = '#f5f0e6' })
  hi('MiniPickPrompt',   { fg = '#26211a',          bg = '#f5f0e6' })
  hi('MiniPickPromptPrefix',   { fg = '#b26a0f',             bg = '#f5f0e6' })
  hi('MiniPickBorderText',    { fg = '#f5f0e6',             bg = '#b26a0f' })
  hi('MiniPickMatchCurrent',      { fg = '#26211a',          bg = '#e6dcc8' })
  hi('MiniPickPromptCaret', { fg = '#b26a0f',             bg = '#e6dcc8' })
  hi('MiniPickMatchRanges',       { fg = '#b26a0f',             bold = true })
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
