require('telescope').setup {
  pickers = {
    lsp_document_symbols = {
      symbol_width = 50,
      ignore_symbols = "variable",
    },

    lsp_workspace_symbols = {
      symbol_width = 50,
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
    return require('telescope.utils').buffer_dir()
  end
  ret = string.gsub(ret, '%s+$', '')
  return ret
end

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>tt', function() builtin.find_files{cwd=get_repo_root()} end, {})
vim.keymap.set('n', '<leader>tg', function() builtin.live_grep{cwd=get_repo_root()} end, {})
vim.keymap.set('n', '<leader>tb', builtin.buffers, {})
vim.keymap.set('n', '<leader>to', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>ts', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>tS', builtin.lsp_workspace_symbols, {})
vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
