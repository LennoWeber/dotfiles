 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#fbfaf1',
    base01 = '#efeee6',
    base02 = '#e9e8e0',
    base03 = '#75786b',
    base04 = '#45483d',
    base05 = '#1b1c17',
    base06 = '#1b1c17',
    base07 = '#1b1c17',
    base08 = '#ba1a1a',
    base09 = '#26694f',
    base0A = '#586247',
    base0B = '#4f642c',
    base0C = '#92d4b5',
    base0D = '#b7cf8b',
    base0E = '#c1cbaa',
    base0F = '#dde7c5',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#1b1c17',          bg = '#fbfaf1' })
  hi('TelescopeBorder',         { fg = '#75786b',             bg = '#fbfaf1' })
  hi('TelescopePromptNormal',   { fg = '#1b1c17',          bg = '#fbfaf1' })
  hi('TelescopePromptBorder',   { fg = '#75786b',             bg = '#fbfaf1' })
  hi('TelescopePromptPrefix',   { fg = '#4f642c',             bg = '#fbfaf1' })
  hi('TelescopePromptCounter',  { fg = '#45483d',  bg = '#fbfaf1' })
  hi('TelescopePromptTitle',    { fg = '#fbfaf1',             bg = '#4f642c' })
  hi('TelescopePreviewTitle',   { fg = '#fbfaf1',             bg = '#586247' })
  hi('TelescopeResultsTitle',   { fg = '#fbfaf1',             bg = '#26694f' })
  hi('TelescopeSelection',      { fg = '#1b1c17',          bg = '#e9e8e0' })
  hi('TelescopeSelectionCaret', { fg = '#4f642c',             bg = '#e9e8e0' })
  hi('TelescopeMatching',       { fg = '#4f642c',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#1b1c17',          bg = '#fbfaf1' })
  hi('MiniPickBorder',         { fg = '#75786b',             bg = '#fbfaf1' })
  hi('MiniPickPrompt',   { fg = '#1b1c17',          bg = '#fbfaf1' })
  hi('MiniPickPromptPrefix',   { fg = '#4f642c',             bg = '#fbfaf1' })
  hi('MiniPickBorderText',    { fg = '#fbfaf1',             bg = '#4f642c' })
  hi('MiniPickMatchCurrent',      { fg = '#1b1c17',          bg = '#e9e8e0' })
  hi('MiniPickPromptCaret', { fg = '#4f642c',             bg = '#e9e8e0' })
  hi('MiniPickMatchRanges',       { fg = '#4f642c',             bold = true })
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
