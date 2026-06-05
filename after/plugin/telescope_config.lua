require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close,
        ["<C-n>"] = require("telescope.actions.layout").cycle_layout_prev,
        ["<C-u>"] = false,
        ["<C-d>"] = false,
        ["<C-f>"] = false,
        ["<C-k>"] = false,
        ["<C-h>"] = require("telescope.actions").preview_scrolling_left,
        ["<C-j>"] = require("telescope.actions").preview_scrolling_down,
        ["<C-k>"] = require("telescope.actions").preview_scrolling_up,
        ["<C-l>"] = require("telescope.actions").preview_scrolling_right,
        ["<C-_>"] = require("telescope.actions.generate").which_key {
          keybind_width = 13,
          name_width = 40,
          max_height = 0.5,
          separator = " ",
        },
      },
    },
    cycle_layout_list = {"vertical", "horizontal"},
    layout_config = { height = .95, width = .9 },
  },
  pickers = {
    lsp_document_symbols = {
      symbol_width = 0.8,
      ignore_symbols = "variable",
    },

    lsp_workspace_symbols = {
      symbol_width = 50,
      ignore_symbols = "variable",
    },

    lsp_dynamic_workspace_symbols = {
      fname_width = .3,
      symbol_width = .6,
      ignore_symbols = "variable",
    },
  },

  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
  },
}

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

function get_repo_root()
  local ret = vim.fn.system { "git", "rev-parse", "--show-toplevel" }
  if vim.v.shell_error ~= 0 then
    return vim.uv.cwd()
  end
  ret = string.gsub(ret, '%s+$', '')
  return ret
end

function lsp_path_display(opts, path)
  local Path = require "plenary.path"
  local utils = require("telescope.utils")

  local rel_to_cwd = "./" .. Path:new(path):make_relative(vim.uv.cwd())
  local rel_to_git = Path:new(path):make_relative(get_repo_root())

  if #rel_to_cwd < #path then
    path = rel_to_cwd
  end

  if #rel_to_git < #path then
    path = rel_to_git
  end

  local parts = vim.split(path, utils.get_separator())
  local filename = table.remove(parts) -- pop

  local start = 1
  for i, part in ipairs(parts) do
    if part == "include" then
      start = i + 1
      break
    end
  end

  parts[#parts + 1] = filename

  if start > 1 then
    return "<" .. table.concat(vim.list_slice(parts, start), "/") .. ">"
  else
    return path
  end
end

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>tt', function() builtin.find_files{cwd=get_repo_root(), hidden=true} end, {})
vim.keymap.set('n', '<leader>tg', function() builtin.live_grep{cwd=get_repo_root(), hidden=true} end, {})
vim.keymap.set('n', '<leader>tb', builtin.buffers, {})
vim.keymap.set('n', '<leader>to', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>ts', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>tS', function() builtin.lsp_dynamic_workspace_symbols{layout_strategy="vertical", path_display=lsp_path_display} end, {})
vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
