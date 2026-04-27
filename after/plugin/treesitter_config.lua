if vim.g.loaded_treesitter_config then
  return
end
vim.g.loaded_treesitter_config = true

require'nvim-treesitter'.install { "c", "cpp", "lua", "python", "vim" }
require'nvim-treesitter-textobjects'.setup {
  select = {
    enable = true,

    -- You can choose the select mode (default is charwise 'v')
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * method: eg 'v' or 'o'
    -- and should return the mode ('v', 'V', or '<c-v>') or a table
    -- mapping query_strings to modes.
    selection_modes = {
      ['@function.outer'] = 'V',
      ['@function.inner'] = 'V',
      ['@class.outer'] = 'V',
      ['@class.inner'] = 'V',
    },
    -- If you set this to `true` (default is `false`) then any textobject is
    -- extended to include preceding or succeeding whitespace. Succeeding
    -- whitespace has priority in order to act similarly to eg the built-in
    -- `ap`.
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * selection_mode: eg 'v'
    -- and should return true of false
    include_surrounding_whitespace = false,
  },

  swap = {
    enable = true,
  },

  move = {
    enable = true,
    set_jumps = true, -- whether to set jumps in the jumplist
  },
}

local select = require "nvim-treesitter-textobjects.select"
for _, m in ipairs({
  { "af", "@function.outer" },
  { "if", "@function.inner" },
  { "aa", "@parameter.outer" },
  { "ia", "@parameter.inner" },
  { "ac", "@class.outer" },
  { "ic", "@class.inner" },
}) do
  local keys, query = m[1], m[2]
  local modes = { "x", "o" }
  vim.keymap.set(modes, keys, function()
    select.select_textobject(query, "textobjects")
  end)
end

local swap = require "nvim-treesitter-textobjects.swap"
for _, m in ipairs({
  { "<leader>sa", "<leader>Sa", "@parameter.inner" },
  { "<leader>sf", "<leader>Sf", "@function.outer" },
  { "<leader>ss", "<leader>Ss", "@statement.outer" },
}) do
  local next_mapping, prev_mapping, query = m[1], m[2], m[3]
  local modes = { "n" }
  vim.keymap.set(modes, next_mapping, function() swap.swap_next(query) end)
  vim.keymap.set(modes, prev_mapping, function() swap.swap_previous(query) end)
end

local move = require "nvim-treesitter-textobjects.move"
local class_or_fn = { "@class.outer", "@function.outer" }
for _, m in ipairs({
  { "]]", "[[", "][", "[]", class_or_fn,          "textobjects" },
  { "]m", "[m", "]M", "[M", class_or_fn,          "textobjects" },
  { "]?", "[?", nil,  nil,  "@conditional.outer", "textobjects" },
  { "]s", "[s", nil,  nil,  "@local.scope",       "locals" },
}) do
  local ns, ps, ne, pe, query, source = m[1], m[2], m[3], m[4], m[5], m[6]
  local modes = { "n", "x", "o" }
  vim.keymap.set(modes, ns, function() move.goto_next_start(query, source) end)
  vim.keymap.set(modes, ps, function() move.goto_previous_start(query, source) end)
  if ne then
    vim.keymap.set(modes, ne, function() move.goto_next_end(query, source) end)
  end
  if pe then
    vim.keymap.set(modes, pe, function() move.goto_previous_end(query, source) end)
  end
end
