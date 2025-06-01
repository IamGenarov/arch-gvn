-- init.lua completo corregido con alcance global

-- Módulo para compilar/ejecutar
_G.run_commands = {
    run_c = function()
        local filename = vim.fn.expand('%')
        local output = vim.fn.expand('%:r')
        vim.cmd('w')
        vim.cmd('split | terminal gcc "'..filename..'" -o "'..output..'" && ./'..output)
    end,

    run_python = function()
        local filename = vim.fn.expand('%')
        vim.cmd('w')
        vim.cmd('split | terminal python3 "'..filename..'"')
    end,

    run_asm = function()
        local filename = vim.fn.expand('%')
        local output = vim.fn.expand('%:r')
        vim.cmd('w')
        vim.cmd('split | terminal nasm -f elf64 "'..filename..'" -o "'..output..'.o" && ld "'..output..'.o" -o "'..output..'" && ./'..output)
    end
}

-- Instalar packer automáticamente si no está
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- Autocomando para recargar plugins al guardar
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost init.lua source <afile> | PackerSync
    augroup end
]])

-- Configuración de plugins
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use {
        'nvim-tree/nvim-tree.lua',
        requires = 'nvim-tree/nvim-web-devicons',
    }
    use {
        "akinsho/toggleterm.nvim",
        tag = '*',
        config = function()
            require("toggleterm").setup()
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- Mapeos principales
vim.keymap.set('n', '<C-e>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Configuración de plugins
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

require("toggleterm").setup{
    size = 20,
    open_mapping = [[<c-\>]],
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    persist_size = true,
    direction = "horizontal"
}

-- Tema visual
vim.opt.background = "dark"
vim.cmd([[colorscheme habamax]])
vim.cmd([[highlight Normal guibg=#000000 ctermbg=0]])
vim.cmd([[highlight NormalNC guibg=#000000 ctermbg=0]])
vim.cmd([[highlight NvimTreeNormal guibg=#000000 ctermbg=0]])
vim.cmd([[highlight NvimTreeEndOfBuffer guibg=#000000 ctermbg=0]])
vim.cmd([[highlight Cursor guifg=#000000 guibg=#ffffff]])

-- Atajos para compilar/ejecutar con Ctrl+r
vim.api.nvim_create_autocmd("FileType", {
    pattern = "c",
    callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", "<C-r>", ":lua _G.run_commands.run_c()<CR>", { noremap=true, silent=true })
        print("C configurado: Ctrl+r para compilar/ejecutar")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", "<C-r>", ":lua _G.run_commands.run_python()<CR>", { noremap=true, silent=true })
        print("Python configurado: Ctrl+r para ejecutar")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "asm",
    callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", "<C-r>", ":lua _G.run_commands.run_asm()<CR>", { noremap=true, silent=true })
        print("ASM configurado: Ctrl+r para ensamblar/ejecutar")
    end,
})

-- Mensaje inicial
print("Configuración cargada. Usa:")
print("- Ctrl+e para NvimTree")
print("- Ctrl+r para ejecutar código")
print("- Ctrl+\\ para terminal flotante")
