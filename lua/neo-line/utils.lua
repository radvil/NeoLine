local M = {}

---@param suffix? string[] | string
function M.hl(name, suffix)
  local hl = { "%#", name, "#" }
  if type(suffix) == "table" then
    vim.list_extend(hl, suffix)
  elseif type(suffix) == "string" then
    table.insert(hl, suffix)
  end
  return table.concat(hl)
end

function M.current_filepath()
  return vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")
end

---@param fname? string
function M.basepath(fname)
  fname = fname or vim.fn.expand("%:t")
  return vim.fs.basename(fname) or ""
end

return M
