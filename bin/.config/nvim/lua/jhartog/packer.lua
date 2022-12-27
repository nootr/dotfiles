vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    -- 📦 packer - A package manager
    use('wbthomason/packer.nvim')

    -- 🔭 telescope - A fuzzy finder
    use({
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { {'nvim-lua/plenary.nvim'} }
    })

    -- 🚦 lualine - A statusline
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- 📻 gruvbox baby - A color scheme
    use "luisiacc/gruvbox-baby"

    -- 🌳 treesitter - A syntax highlighter
    use({'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'})

    -- 💬 lsp zero - A Language Server collection
    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    }

    -- ⚪ vim better whitespace - A trailing whitespace highlighter
    use('ntpeters/vim-better-whitespace')

    -- 🔏 signify - All things git
    use('mhinz/vim-signify')

    -- 🗣️ nvim notify - Beautiful notifications
    use('rcarriga/nvim-notify')

    -- 📁 carbon - A file explorer
    use 'SidOfc/carbon.nvim'
end)
