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

vim.keymap.set({ "x", "o" }, "af", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "if", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "aa", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@parameter.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ia", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@parameter.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ac", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ic", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set("n", "<leader>sa", function()
  require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
end)

vim.keymap.set("n", "<leader>Sa", function()
  require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.inner"
end)

vim.keymap.set("n", "<leader>sf", function()
  require("nvim-treesitter-textobjects.swap").swap_next "@function.outer"
end)

vim.keymap.set("n", "<leader>Sf", function()
  require("nvim-treesitter-textobjects.swap").swap_previous "@function.outer"
end)

vim.keymap.set("n", "<leader>ss", function()
  require("nvim-treesitter-textobjects.swap").swap_next "@statement.outer"
end)

vim.keymap.set("n", "<leader>Ss", function()
  require("nvim-treesitter-textobjects.swap").swap_previous "@statement.outer"
end)

vim.keymap.set({ "n", "x", "o" }, "]]", function()
  require("nvim-treesitter-textobjects.move").goto_next_start({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[[", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "][", function()
  require("nvim-treesitter-textobjects.move").goto_next_end({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[]", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]m", function()
  require("nvim-treesitter-textobjects.move").goto_next_start({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[m", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]M", function()
  require("nvim-treesitter-textobjects.move").goto_next_end({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[M", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end({"@class.outer", "@function.outer"}, "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]?", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@conditional.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[?", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@conditional.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]s", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
end)

vim.keymap.set({ "n", "x", "o" }, "[s", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@local.scope", "locals")
end)
