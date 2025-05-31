-- ~/.config/nvim/lua/plugins.lua
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- packer se puede actualizar a sí mismo
  
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' },
    tag = 'nightly'
  }

  -- Aquí puedes añadir más plugins
end)
