-- This file contains configures packer. packer is a plugin manager for neovim.
-- To install packer, check https://github.com/wbthomason/packer.nvim for
-- instructions.
--
-- Make sure to run :PackerSync after modifying this file or to update plugins.
-- Sometimes, I've to run :TSUpdate too to fix any issues caused by updated plugins.
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself.
	use "wbthomason/packer.nvim"

	-- Plugins often require external tooling. For example black, rust-analyzer
	-- or language servers. Mason is a plug for (un)installing dependencies and
	-- keeping them up to date.
	-- https://github.com/williamboman/mason.nvim
	use "williamboman/mason.nvim"
	use "williamboman/mason-lspconfig.nvim"
	use "neovim/nvim-lspconfig"

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		'nvim-lua/plenary.nvim',
	}

	-- Plugin that cares about rust-analyzer and other Rust related tools.
	use 'simrat39/rust-tools.nvim'

	use {
		-- Auto complete plugin.
		'hrsh7th/nvim-cmp',

		-- A bunch of complection sources which are input to nvim-cmp.
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-nvim-lua',
		'hrsh7th/cmp-nvim-lsp-signature-help',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-calc',
	}

	use 'nvim-treesitter/nvim-treesitter'

	use 'jose-elias-alvarez/null-ls.nvim'

	-- This is just a theme.
	use 'arcticicestudio/nord-vim'

	-- Plug to (un)comment visual selections easily.
	use 'preservim/nerdcommenter'

	use {
		'phaazon/hop.nvim', branch = 'v2'
	}
	use 'lewis6991/impatient.nvim'
	use 'junegunn/vim-easy-align'

	-- Plug to select code and get permalink to Github and other git frontends.
	use 'ruifm/gitlinker.nvim'
	use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } }

	use {
		"nvim-neotest/neotest",
		requires = {
			"antoinemadec/FixCursorHold.nvim",
			'rouge8/neotest-rust',
		}
	}

	use 'lewis6991/gitsigns.nvim'
	use 'nvim-treesitter/nvim-treesitter-context'
	use 'cbochs/portal.nvim'

end)
