-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Deine bisherigen Keymaps (aus der vorherigen Config)
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Explorer (netrw)" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.api.nvim_set_keymap("n", "<leader>tf", "<Plug>PlenaryTestFile", { noremap = false, silent = false })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines keep cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up centered" })

-- Halbes Fenster scrollen, Cursor-Zeile/Spalte im Buffer bleibt gleich (nicht in alter remap.lua; ergänzt)
local function scroll_half_keep_cursor(direction)
  local v = vim.fn.winsaveview()
  local half = math.max(1, math.floor(vim.fn.winheight(0) / 2))
  local last = vim.fn.line("$")
  local height = vim.fn.winheight(0)
  local max_top = math.max(1, last - height + 1)
  if direction > 0 then
    v.topline = math.min(v.topline + half, max_top)
  else
    v.topline = math.max(1, v.topline - half)
  end
  vim.fn.winrestview(v)
end

vim.keymap.set("n", "<S-D>", function()
  scroll_half_keep_cursor(1)
end, { desc = "Scroll half-window down (cursor line fixed)" })
vim.keymap.set("n", "<S-U>", function()
  scroll_half_keep_cursor(-1)
end, { desc = "Scroll half-window up (cursor line fixed)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search centered" })
vim.keymap.set("n", "=ap", "ma=ap'a", { desc = "Format paragraph keep cursor" })
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>", { desc = "LSP restart" })

vim.keymap.set("n", "<leader>vwm", function()
  require("vim-with-me").StartVimWithMe()
end, { desc = "VimWithMe start" })
vim.keymap.set("n", "<leader>svwm", function()
  require("vim-with-me").StopVimWithMe()
end, { desc = "VimWithMe stop" })

vim.keymap.set("n", "<leader>lt", function()
  vim.cmd([[ PlenaryBustedFile % ]])
end, { desc = "Run tests for file" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape" })

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux sessionizer" })
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>", { desc = "Tmux sessionizer vsplit" })
vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "Tmux sessionizer new window" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Quickfix next" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Quickfix prev" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Loclist next" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Loclist prev" })

vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor" }
)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x current file" })

vim.keymap.set("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { desc = "Go: if err return" })
vim.keymap.set("n", "<leader>ea", 'oassert.NoError(err, "")<Esc>F";a', { desc = "Go: assert no error" })
vim.keymap.set(
  "n",
  "<leader>ef",
  'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj',
  { desc = "Go: log.Fatalf on error" }
)
vim.keymap.set(
  "n",
  "<leader>el",
  'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i',
  { desc = "Go: logger.Error on error" }
)

vim.keymap.set("n", "<leader>ca", function()
  require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular automaton" })

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end, { desc = "Source current file" })

vim.api.nvim_create_user_command("PrimeHelp", function()
  local help_file = vim.fn.stdpath("config") .. "/PrimeHelp.md"
  vim.cmd("vsplit " .. help_file)
end, { desc = "Open PrimeHelp.md" })
