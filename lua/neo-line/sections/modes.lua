---@diagnostic disable: inject-field

---@alias neoline.vim_mode_type "n" | "no" | "v" | "V" | "^V" | "s" | "S" | "^S" | "i" | "ic" | "R" | "Rv" | "c" | "cv" | "ce" | "r" | "r?" | "!" | "t"
---@alias neoline.sections.modes.ui {name?:string; label: string; bg: string; fg: string}

---@class neoline.sections.modes
local M = {}
local utils = require("neo-line.utils")

local state = {
  bg = nil,
  fg = nil,
  mode = "n",
  separator = nil,
}

---@type neoline.sections.modes
local options = {
  default_hl_opts = {
    bg = "#f5e0dc",
    fg = "#1e1e2e",
    bold = true,
  },
  ---@type table<neoline.vim_mode_type, neoline.sections.modes.ui>
  ui = {
    n = {
      label = "Normal",
      bg = "#89b4fa",
      fg = "#1e1e2e",
    },
    ["v"] = {
      label = "Visual",
      bg = "#fab387",
      fg = "#1e1e2e",
    },
    ["V"] = {
      label = "Visual Line",
      bg = "#fab387",
      fg = "#1e1e2e",
    },
    [""] = {
      label = "Visual Block",
      bg = "#fab387",
      fg = "#1e1e2e",
    },
    ["s"] = {
      label = "Select",
      bg = "#f38ba8",
      fg = "#1e1e2e",
    },
    ["S"] = {
      label = "Select Line",
      bg = "#f38ba8",
      fg = "#1e1e2e",
    },
    [""] = {
      label = "Select Block",
      bg = "#f38ba8",
      fg = "#1e1e2e",
    },
    ["i"] = {
      label = "Insert",
      bg = "#a6e3a1",
      fg = "#1e1e2e",
    },
    ["ic"] = {
      label = "Insert Change",
      bg = "#a6e3a1",
      fg = "#1e1e2e",
    },
    ["R"] = {
      label = "Replace",
      bg = "#eba0ac",
      fg = "#1e1e2e",
    },
    ["Rv"] = {
      label = "Visual Replace",
      bg = "#eba0ac",
      fg = "#1e1e2e",
    },
    ["c"] = {
      label = "Command",
      bg = "#cba6f7",
      fg = "#1e1e2e",
    },
    ["cv"] = {
      label = "Vim Ex",
      bg = "#cba6f7",
      fg = "#1e1e2e",
    },
    ["ce"] = {
      label = "Ex",
      bg = "#cba6f7",
      fg = "#1e1e2e",
    },
    ["r"] = {
      label = "Prompt",
      bg = "#cba6f7",
      fg = "#1e1e2e",
    },
    ["rm"] = {
      label = "Moar",
      bg = "#cba6f7",
      fg = "#1e1e2e",
    },
    ["r?"] = {
      label = "Confirm",
      bg = "#cba6f7",
      fg = "#1e1e2e",
    },
    ["!"] = {
      label = "Shell",
      bg = "#74c7ec",
      fg = "#1e1e2e",
    },
    ["t"] = {
      label = "Terminal",
      bg = "#74c7ec",
      fg = "#1e1e2e",
    },
  },
}

M.augroup = vim.api.nvim_create_augroup("neoline_mode_section", { clear = true })

function M.set_hls()
  for mode, opt in pairs(options.ui) do
    local name = M.get_hl_name(mode)
    vim.api.nvim_set_hl(0, name, {
      bg = opt.bg or options.default_hl_opts.bg,
      fg = opt.fg or options.default_hl_opts.fg,
      bold = options.default_hl_opts.bold or true,
    })
    vim.api.nvim_set_hl(0, name .. ".inverted", {
      bg = nil,
      fg = opt.bg or options.default_hl_opts.bg,
    })
  end
end

---@param mode neoline.vim_mode_type
---@param inverse? boolean
function M.get_hl_name(mode, inverse)
  local opt = options.ui[mode]
  local label = opt.name or string.gsub(opt.label, "%s+", ""):lower()
  if inverse then
    return string.format("@neoline.mode.%s.inverted", label)
  end
  return string.format("@neoline.mode.%s", label)
end

function M:label()
  return string.format(" %s", options.ui[vim.api.nvim_get_mode().mode].label):upper()
end

---@param inverse? boolean
function M:color(inverse)
  return utils.hl(M.get_hl_name(state.mode or vim.api.nvim_get_mode().mode, inverse))
end

---@param mode? neoline.vim_mode_type
---@return neoline.sections.modes.ui | nil
function M:get_ui_opts(mode)
  mode = mode or state.mode or vim.api.nvim_get_mode().mode
  return options.ui[mode]
end

---@return string
function M:get()
  state.mode = vim.api.nvim_get_mode().mode
  return table.concat({
    M:color(),
    M:label(),
    M:color(true),
    require("neo-line.config").separator_style[2],
  })
end

---@param opts? neoline.sections.modes
function M.setup(opts)
  options = vim.tbl_deep_extend("force", options, opts or {}) or {}
  M.set_hls()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = M.augroup,
    callback = function()
      M.set_hls()
    end,
  })
end

setmetatable(M, {
  __call = function(m, ...)
    return m:get(...)
  end,
  __index = function(_, k)
    ---@cast options neoline.sections.modes
    return options[k]
  end,
})

return M
