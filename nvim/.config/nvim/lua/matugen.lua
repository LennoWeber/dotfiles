 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#13140f',
    base01 = '#1f201b',
    base02 = '#292a25',
    base03 = '#8f9284',
    base04 = '#c5c8b9',
    base05 = '#e4e3db',
    base06 = '#e4e3db',
    base07 = '#e4e3db',
    base08 = '#ffb4ab',
    base09 = '#92d4b5',
    base0A = '#c1cbaa',
    base0B = '#b7cf8b',
    base0C = '#92d4b5',
    base0D = '#b7cf8b',
    base0E = '#c1cbaa',
    base0F = '#dde7c5',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e4e3db',          bg = '#13140f' })
  hi('TelescopeBorder',         { fg = '#8f9284',             bg = '#13140f' })
  hi('TelescopePromptNormal',   { fg = '#e4e3db',          bg = '#13140f' })
  hi('TelescopePromptBorder',   { fg = '#8f9284',             bg = '#13140f' })
  hi('TelescopePromptPrefix',   { fg = '#b7cf8b',             bg = '#13140f' })
  hi('TelescopePromptCounter',  { fg = '#c5c8b9',  bg = '#13140f' })
  hi('TelescopePromptTitle',    { fg = '#13140f',             bg = '#b7cf8b' })
  hi('TelescopePreviewTitle',   { fg = '#13140f',             bg = '#c1cbaa' })
  hi('TelescopeResultsTitle',   { fg = '#13140f',             bg = '#92d4b5' })
  hi('TelescopeSelection',      { fg = '#e4e3db',          bg = '#292a25' })
  hi('TelescopeSelectionCaret', { fg = '#b7cf8b',             bg = '#292a25' })
  hi('TelescopeMatching',       { fg = '#b7cf8b',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e4e3db',          bg = '#13140f' })
  hi('MiniPickBorder',         { fg = '#8f9284',             bg = '#13140f' })
  hi('MiniPickPrompt',   { fg = '#e4e3db',          bg = '#13140f' })
  hi('MiniPickPromptPrefix',   { fg = '#b7cf8b',             bg = '#13140f' })
  hi('MiniPickBorderText',    { fg = '#13140f',             bg = '#b7cf8b' })
  hi('MiniPickMatchCurrent',      { fg = '#e4e3db',          bg = '#292a25' })
  hi('MiniPickPromptCaret', { fg = '#b7cf8b',             bg = '#292a25' })
  hi('MiniPickMatchRanges',       { fg = '#b7cf8b',             bold = true })
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
