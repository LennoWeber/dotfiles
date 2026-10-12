-- Auto-Lang: Automatische Sprachunterstützung beim Öffnen neuer Dateitypen
--
-- 1. Treesitter-Parser werden sofort installiert (auto_install)
-- 2. LSP-Server werden automatisch via Mason installiert
-- 3. LazyVim lang extras werden zu lazyvim.json hinzugefügt (Restart nötig für
--    volle Unterstützung mit Formatter, Linter, spezielle Plugins)

local lazyvim_json = vim.fn.stdpath("config") .. "/lazyvim.json"

-- Filetype → LazyVim extra name
local ft_to_extra = {
  python = "lazyvim.plugins.extras.lang.python",
  go = "lazyvim.plugins.extras.lang.go",
  rust = "lazyvim.plugins.extras.lang.rust",
  typescript = "lazyvim.plugins.extras.lang.typescript",
  typescriptreact = "lazyvim.plugins.extras.lang.typescript",
  javascript = "lazyvim.plugins.extras.lang.typescript",
  javascriptreact = "lazyvim.plugins.extras.lang.typescript",
  java = "lazyvim.plugins.extras.lang.java",
  kotlin = "lazyvim.plugins.extras.lang.kotlin",
  scala = "lazyvim.plugins.extras.lang.scala",
  ruby = "lazyvim.plugins.extras.lang.ruby",
  php = "lazyvim.plugins.extras.lang.php",
  elixir = "lazyvim.plugins.extras.lang.elixir",
  erlang = "lazyvim.plugins.extras.lang.erlang",
  haskell = "lazyvim.plugins.extras.lang.haskell",
  ocaml = "lazyvim.plugins.extras.lang.ocaml",
  cs = "lazyvim.plugins.extras.lang.omnisharp",
  c = "lazyvim.plugins.extras.lang.clangd",
  cpp = "lazyvim.plugins.extras.lang.clangd",
  zig = "lazyvim.plugins.extras.lang.zig",
  nix = "lazyvim.plugins.extras.lang.nix",
  elm = "lazyvim.plugins.extras.lang.elm",
  gleam = "lazyvim.plugins.extras.lang.gleam",
  r = "lazyvim.plugins.extras.lang.r",
  sql = "lazyvim.plugins.extras.lang.sql",
  tex = "lazyvim.plugins.extras.lang.tex",
  json = "lazyvim.plugins.extras.lang.json",
  jsonc = "lazyvim.plugins.extras.lang.json",
  yaml = "lazyvim.plugins.extras.lang.yaml",
  toml = "lazyvim.plugins.extras.lang.toml",
  markdown = "lazyvim.plugins.extras.lang.markdown",
  dockerfile = "lazyvim.plugins.extras.lang.docker",
  ["docker-compose"] = "lazyvim.plugins.extras.lang.docker",
  terraform = "lazyvim.plugins.extras.lang.terraform",
  svelte = "lazyvim.plugins.extras.lang.svelte",
  vue = "lazyvim.plugins.extras.lang.vue",
  astro = "lazyvim.plugins.extras.lang.astro",
  prisma = "lazyvim.plugins.extras.lang.prisma",
  cmake = "lazyvim.plugins.extras.lang.cmake",
}

-- Bereits benachrichtigte Filetypes in dieser Session (keine doppelten Meldungen)
local notified = {}

local function read_lazyvim_json()
  local ok, lines = pcall(vim.fn.readfile, lazyvim_json)
  if not ok then
    return nil
  end
  local ok_json, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_json then
    return nil
  end
  return data
end

local function write_lazyvim_json(data)
  local encoded = vim.json.encode(data)
  vim.fn.writefile({ encoded }, lazyvim_json)
end

local function has_extra(data, extra_name)
  if not data or not data.extras then
    return false
  end
  for _, e in ipairs(data.extras) do
    if e == extra_name then
      return true
    end
  end
  return false
end

local function add_extra_if_missing(ft)
  local extra = ft_to_extra[ft]
  if not extra then
    return
  end
  if notified[ft] then
    return
  end

  local data = read_lazyvim_json()
  if not data then
    return
  end
  if has_extra(data, extra) then
    return
  end

  -- Extra hinzufügen
  data.extras = data.extras or {}
  table.insert(data.extras, extra)
  write_lazyvim_json(data)

  notified[ft] = true
  vim.notify(
    "🔧 " .. extra .. " hinzugefügt!\n"
      .. "Treesitter-Parser wird sofort installiert.\n"
      .. "Für volles LSP/Formatter/Linter: nvim neustarten.",
    vim.log.levels.INFO,
    { title = "Auto-Lang" }
  )
end

return {
  -- 1. Treesitter: Parser automatisch installieren
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = true,
    },
  },

  -- 2. Mason-LSPConfig: LSP-Server automatisch installieren
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_installation = true,
    },
  },

  -- 3. AutoCmd: LazyVim extras automatisch zu lazyvim.json hinzufügen
  {
    "LazyVim/LazyVim",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("AutoLangExtras", { clear = true }),
        callback = function(ev)
          -- Verzögert ausführen, damit der Buffer vollständig geladen ist
          vim.defer_fn(function()
            add_extra_if_missing(ev.match)
          end, 100)
        end,
      })
    end,
  },
}
