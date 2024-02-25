local M = {}
local utils = require("neo-line.utils")
local sections = require("neo-line.sections")

M["neo-tree"] = table.concat({
  utils.hl("@neoline.neo-tree", " " .. " neo-tree"),
  utils.hl("@neoline.text.primary", ""),
  utils.hl("@neoline.neo-tree.filepath"),
  sections.filepath(),
  "/",
  utils.hl("@neoline.neo-tree.basepath"),
  utils.basepath(vim.loop.cwd()),
  utils.hl("@neoline.text.base", ""),
  sections.separator(),
})

return M
