---@class neoline.sections
---@field modes neoline.sections.modes
local M = {}
local utils = require("neo-line.utils")

local lsp_diagnostics_map = {
  [vim.diagnostic.severity.ERROR] = {
    hl = "LspDiagnosticsError",
    icon = " ",
  },
  [vim.diagnostic.severity.WARN] = {
    hl = "LspDiagnosticsWarning",
    icon = " ",
  },
  [vim.diagnostic.severity.HINT] = {
    hl = "LspDiagnosticsHint",
    icon = " ",
  },
  [vim.diagnostic.severity.INFO] = {
    hl = "LspDiagnosticsInformation",
    icon = " ",
  },
}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("neo-line.sections." .. k)
    return t[k]
  end,
})

---@param with_icon? boolean
function M.filepath(with_icon)
  local ret = { " " }
  local fpath = utils.current_filepath()
  if fpath and fpath ~= "." then
    local sep = package.config:sub(1, 1)
    local parts = vim.split(fpath, "[\\/]")
    if #parts > 4 then
      -- local delim = utils.hl("@comment", "\\···\\") .. utils.hl("Normal")
      local delim = utils.hl("@comment", "[…]") .. utils.hl("Normal")
      parts = { parts[1], delim, parts[#parts - 1], parts[#parts] }
      table.insert(ret, table.concat(parts, sep))
    else
      table.insert(ret, string.format("%%<%s", fpath))
    end
  end
  if with_icon then
    local hlname = "NeoLineFolderIcon"
    vim.api.nvim_set_hl(0, hlname, { link = "WarningMsg" })
    table.insert(ret, 2, utils.hl(hlname, "󱉭 " .. utils.hl("Normal")))
  end
  return table.concat(ret)
end

---@param with_icon? boolean
function M.filename(with_icon)
  local fname = vim.fn.expand("%:t")
  if fname == "" then
    return ""
  end
  local ret = {
    utils.hl("@comment", " ➔ "),
    utils.hl("Normal"),
    fname,
  }
  if with_icon then
    table.insert(ret, 2, M.fileicon(fname))
  end
  return table.concat(ret)
end

---@param fname? string
function M.fileicon(fname)
  local hname = "NeoLineIcon"
  fname = fname or vim.fn.expand("%:t")
  local DevIcon = require("nvim-web-devicons")
  if DevIcon.has_loaded() then
    local icon = DevIcon.get_icon(fname)
    local _, color = DevIcon.get_icon_color(fname)
    vim.api.nvim_set_hl(0, hname, { fg = color })
    return table.concat({
      utils.hl(hname),
      icon,
      " ",
    })
  else
    return "🧷"
  end
end

function M.lineinfo()
  return "%P %l:%c "
end

function M.filetype()
  return table.concat({
    M.modes:color(true),
    require("neo-line.config").separator_style[1],
    M.modes:color(),
    string.format("%s ", vim.bo.filetype):upper(),
  })
end

function M.fill()
  return utils.hl("StatusLine")
end

function M.separator()
  return "%=" .. utils.hl("StatusLine")
end

function M.lsp_diagnostics_count()
  local result = ""
  for level, opt in pairs(lsp_diagnostics_map) do
    local count = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
    if count ~= 0 then
      result = result .. " " .. utils.hl(opt.hl) .. opt.icon .. count
    end
  end
  return result .. utils.hl("Normal")
end

return M
