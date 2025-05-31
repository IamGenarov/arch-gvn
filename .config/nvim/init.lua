-- Map <leader>e para toggle del árbol
vim.keymap.set('n', '<C-S-e>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Configuración de nvim-tree
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    side = "left",
    preserve_window_proportions = true,
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
})


vim.cmd[[colorscheme habamax]] -- o usa uno que te guste

-- Fondo negro total
vim.opt.background = "dark"
vim.cmd[[highlight Normal guibg=NONE ctermbg=NONE]]
vim.cmd[[highlight NormalNC guibg=NONE ctermbg=NONE]]
vim.cmd[[highlight NvimTreeNormal guibg=NONE ctermbg=NONE]]
