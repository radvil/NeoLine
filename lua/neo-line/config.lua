local M = {}
local utils = require("neo-line.utils")
local sections = require("neo-line.sections")

---@class NeoLineOpts
---@field modes neoline.sections.modes
local defaults = {
  separator_style = { "", "" },
  custom_hls = {
    ["@neoline.fill"] = {
      fg = "#f5e0dc",
    },
    ["@neoline.text.base"] = {
      fg = "#313244",
    },
    ["@neoline.text.primary"] = {
      link = "@neoline.fill",
    },
    ["@neoline.neo-tree"] = {
      bg = "#f5e0dc",
      fg = "#313244",
      bold = true,
    },
    ["@neoline.neo-tree.filepath"] = {
      bg = "#313244",
    },
    ["@neoline.neo-tree.basepath"] = {
      bg = "#313244",
      fg = "#f5e0dc",
      bold = true,
    },
  },
  exclude_filetypes = { "dashboard" },
  ---@type table<string, string | string[] | fun(): string>
  specials = require("neo-line.specials"),
}

---@type NeoLineOpts
local options

local function init_custom_hls()
  local function init()
    for name, opt in pairs(options.custom_hls) do
      vim.api.nvim_set_hl(0, name, opt or {})
    end
  end
  init()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = M.augroup,
    callback = function()
      init()
    end,
  })
end

M.cache = {
  laststatus = vim.opt.laststatus:get(),
}

M.api = {
  active = function()
    local value = options.specials[vim.bo.filetype]
    if type(value) == "function" then
      return value()
    elseif type(value) == "table" then
      return table.concat(value)
    elseif type(value) == "string" then
      return value
    else
      return table.concat({
        sections.fill(),
        sections.modes(),
        utils.hl("Normal"),
        sections.filepath(true),
        sections.filename(true),
        utils.hl("Normal"),
        sections.lsp_diagnostics_count(),
        sections.separator(),
        sections.lineinfo(),
        sections.filetype(),
      })
    end
  end,
  inactive = function()
    return " %F"
  end,
}

---@param user_opts? NeoLineOpts
function M.setup(user_opts)
  options = vim.tbl_deep_extend("force", defaults, user_opts or {}) or {}
  init_custom_hls()
  sections.modes.setup(options.modes)
  vim.api.nvim_create_autocmd({ "BufEnter", "BufUnLoad" }, {
    desc = "show neoline active",
    group = vim.api.nvim_create_augroup("neoline_active", { clear = false }),
    callback = function()
      if vim.tbl_contains(options.exclude_filetypes, vim.bo.filetype) then
        vim.opt.laststatus = 0
      else
        vim.o.laststatus = M.cache.laststatus
        vim.cmd("setlocal statusline=%!v:lua.require('neo-line.config').api.active()")
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "BufLeave" }, {
    desc = "show neoline inactive",
    group = vim.api.nvim_create_augroup("neoline_inactive", { clear = false }),
    callback = function()
      vim.cmd("setlocal statusline=%!v:lua.require('neo-line.config').api.inactive()")
    end,
  })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "show neoline inactive",
    group = vim.api.nvim_create_augroup("neoline_hide", { clear = false }),
    pattern = options.exclude_filetypes,
    callback = function()
      vim.o.laststatus = 0
    end,
  })
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options NeoLineOpts
    return options[key]
  end,
})

return M
