-- TODO:
-- 	* vim.lsp.buf.complete()
-- 	* vim.diagnostics.goto_next()
-- 	* vim.diagnostics.goto_prev()
-- 	* vim.diagnostics.open_float()
--
--	* LSP for
--		* yaml
--		* json
--		* dockerfile
--		* markdown
--		* bash
require('plugins')

-- Map leader key to space bar. The leader key must be configured before any
-- keybindings involving the leader key are defined.
vim.g.mapleader = ' '
vim.cmd [[colorscheme nord]]
vim.cmd [[set noswapfile]]

-- Enable line numbers.
vim.opt.number = true

-- Highlight the line with the cursor.
vim.opt.cursorline = true

-- Always show at least 5 lines before and after cursor.
vim.opt.scrolloff = 5

-- Mason manages external dependencies, like black, rust-analyzer and language
-- servers. You've to install them manually. Either call :Mason to open the
-- interface or run :MasonInstall black.
--
-- When applicable, Mason instals binaries. You can check the location using
-- :echo stdpath("data"). In my case it was ~/.local/share/nvim/mason.
--
-- Let's say you want to add a language server for Lua. First, run :Mason and
-- install lua-language-server.
-- Next, have the plugin lspconfig configure the language server for you. Add
-- the following to this nvim configuration:
--
-- 	require('lspconfig').sumneko_lua.setup{}
--
-- Now open an Lua file and verify if a language server client is attached to
-- the buffer by running :LspInfo
require('mason').setup()

-- This plugin is a bridge between the plugins Mason and lspconfig. I don't
-- fully understand why it's needed.
require("mason-lspconfig").setup({
	-- Automatically install the language servers that are configured
	-- through lspconfig.
	automatic_installation = true
})

-- This configuration depends on lsp-config: https://github.com/neovim/nvim-lspconfig.
-- See :help lspconfig-setup

-- A language server for Python.
require('lspconfig').pyright.setup {
	before_init = function(params, config)
		-- Configure Pyright to use <project_root>/.venv/bin/python.
		--
		-- Pyright isn't aware of virtual environments. This function checks if the
		-- project root contains a .venv folder. If so, pyright is configured to
		-- use the Python interpreter from that virtual environment.
		-- As result, pyright is aware of all the dependencies in this virtual environment.
		--
		-- Poetry can be globally configured to always create virtualenv in the project root.
		-- To do so, add the following config to ~/.config/pypoetry/config.toml:
		--
		-- 	[virtualenvs]
		-- 	in-project = true
		--
		-- The code is taken from https://www.reddit.com/r/neovim/comments/wls43h/pyright_lsp_configuration_for_python_poetry/
		local Path = require "plenary.path"
		local venv = Path:new((config.root_dir:gsub("/", Path.path.sep)), ".venv")
		if venv:joinpath("bin"):is_dir() then
			config.settings.python.pythonPath = tostring(venv:joinpath("bin", "python"))
		end
	end
}

-- A language server for Bash. Make sure to install it using :MasonInstall bash-language-server
require('lspconfig').bashls.setup {}

-- A language server for Lua. Make sure to install the server :MasonInstall lua-language-server
require('lspconfig').lua_ls.setup {}

-- A language server for . Make sure to install the server :MasonInstall typescript-language-server
require 'lspconfig'.tsserver.setup {}

require 'lspconfig'.gopls.setup {}

--local cmp_nvim_lsp = require "cmp_nvim_lsp"
--require 'lspconfig'.clangd.setup {
	--capabilities = cmp_nvim_lsp.default_capabilities(),
	--cmd = {
		--"clangd",
		--"--offset-encoding=utf-16",
	--},
--}

-- Telescope is a beautiful
require('telescope').setup()

-- These few lines configure the keys to configure so called 'pickers'. They
-- open Telescope with certain data.
-- See https://github.com/nvim-telescope/telescope.nvim#pickers fore more pickers.
-- You can manually run a picker using :lua require('telescope.builtin').oldfiles()

-- Find file in workspace.
vim.keymap.set('n', '<Leader>ff', function() require('telescope.builtin').find_files() end)

-- Find incoming calls to identifier under cursor.
vim.keymap.set('n', '<Leader>ic', function() require('telescope.builtin').lsp_incoming_calls() end)

-- Search for references to identifier under cursor.
vim.keymap.set('n', '<Leader>rc', function() require('telescope.builtin').lsp_references() end)

-- Search for string in workspace.
vim.keymap.set('n', '<Leader>fg', function() require('telescope.builtin').live_grep() end)

vim.keymap.set('n', 'z=',
	function() require('telescope.builtin').spell_suggest(require('telescope.themes').get_cursor({})) end)

vim.keymap.set('n', '<Leader>fb', function() require('telescope.builtin').buffers() end)
------
-- Diagnostics
-----
-- Get the previous diagnostic closest to the cursor_position.
--nnoremap <silent> [g    <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
vim.keymap.set('n', '[g', function() vim.diagnostic.goto_prev() end)
-- Get the next diagnostic closest to the cursor_position.
--nnoremap <silent> ]g    <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
vim.keymap.set('n', ']g', function() vim.diagnostic.goto_next() end)

-- List all diagnostics in workspace.
vim.keymap.set('n', '<Leader>dn', function() require('telescope.builtin').diagnostics() end)

------
-- Language Server Protocol
-----

-- A few things to know when configuring and debuggin LSP integration.
--
-- First, make sure to set LSP log level to 'debug' when working on LSP related
-- configuration. Logs are written to ~/.cache/nvim/lsp.log.
--
-- Second, the LSP specification is big. Be aware that not every LSP server or
-- client implements the whole specification.
-- For example, I tried binding a key to vim.lsp.buf.range_formatting(). I
-- verified the key map using a Rust file and the rust-analyzer LSP server.
-- Whatever I tried, my keymap didn't work. Than,I figured out that
-- rust-analyzer doesn't support DocumentRangeFormattingProvider. To find a
-- server's capabilities,
-- run :lua =vim.lsp.get_active_clients()[1].server_capabilities
--
-- Lastly, documentation for all functions under the vim.lsp namespace is at
-- https://neovim.io/doc/user/lsp.html.
-- vim.lsp.set_log_level("DEBUG")

-- Format buffer.
-- Server: DocumentFormattingOptions
vim.keymap.set('n', '<Leader>b', function() vim.lsp.buf.format({ async = true }) end)

-- Format visual select. This key map is untested.
-- Server: documentRangeFormattingProvider
vim.keymap.set('v', '<Leader>b', function() vim.lsp.buf.format() end)

-- Show code actions in the quick fix window.
-- Server: codeActionProvider
vim.keymap.set('n', '<Leader>a', function() vim.lsp.buf.code_action() end)

-- Jump to definition of symbol under cursor.
-- Server: definitionProvider
vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end)

-- List all symbols in current document.
--
vim.keymap.set('n', 'g0', function() require('telescope.builtin').lsp_document_symbols() end)

-- Display information about symbol under cursor.
--
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end)


-- Rename symbol under cursor.
--
vim.keymap.set('n', '<leader>r', function() vim.lsp.buf.rename() end)

-- List all references to symbol under cursor.
vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end)

-- List all symbols in workspace.
vim.keymap.set('n', 'ga', function() require('telescope.builtin').lsp_workspace_symbols() end)

------
-- Auto complete
-----

-- cmp is the plugin that provides completion. It's input comes from different
-- sources. A language server can be a source if the langue server implements
-- complitionProvider. Example of other sources are the file system to auto
-- complete file paths.
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option('updatetime', 300)

require('cmp').setup({
	mapping = {
		-- Iterate through suggestions using Ctrl-p and Ctrl-n.
		['<C-p>'] = require('cmp').mapping.select_prev_item(),
		['<C-n>'] = require('cmp').mapping.select_next_item(),

		-- Or use Tab and Shift-Tab to iterate through suggestions.
		['<S-Tab>'] = require('cmp').mapping.select_prev_item(),
		['<Tab>'] = require('cmp').mapping.select_next_item(),

		['<C-S-f>'] = require('cmp').mapping.scroll_docs(-4),
		['<C-f>'] = require('cmp').mapping.scroll_docs(4),

		['<C-Space>'] = require('cmp').mapping.complete(),
		['<C-e>'] = require('cmp').mapping.close(),
		['<CR>'] = require('cmp').mapping.confirm({
			behavior = require('cmp').ConfirmBehavior.Insert,
			select = true,
		})
	},
	sources = {
		-- Autocomplete based on other words in the buffer.
		{ name = 'buffer',                 keyword_length = 2 },
		{ name = "calc" },
		-- Provided by ditmel/cmp-vim-lsp
		{ name = 'nvim_lsp',               keyword_lenght = 3 },
		-- Requires LSP server to implement signatureHelpProvider.
		{ name = 'nvim_lsp_signature_help' },
		{ name = "nvim-lua" },
		{ name = "path",                   keyword_length = 2 },
	},
	window = {
		completion = require('cmp').config.window.bordered(),
		documentation = require('cmp').config.window.bordered(),
	},
	formatting = {
		fields = { 'menu', 'abbr', 'kind' },
		format = function(entry, item)
			local menu_icon = {
				nvim_lsp = 'λ',
				vsnip = '⋗',
				buffer = 'Ω',
				path = '🖫',
			}
			item.menu = menu_icon[entry.source.name]
			return item
		end,
	},
})

require("null-ls").setup({
	sources = {
		-- Pyright, the LSP server configured for Python, doesn't support
		-- formatting. Therefore, use black.
		require("null-ls").builtins.formatting.black,

		require("null-ls").builtins.formatting.trim_newlines,
		require("null-ls").builtins.formatting.trim_whitespace,
		require("null-ls").builtins.formatting.json_tool,
		-- Make sure to install shfmt using :MasonInstall shfmt
		require("null-ls").builtins.formatting.shfmt,
	},
})


require('rust-tools').setup({
	inlay_hints = {
		auto = true
	},
	server = {
		settings = {
			--on_attach = function(_, bufnr)
			--vim.keymap.set("n", "<Leader>mc", require('rust-tools').expand_macro.expand_macro())
			--end,
			["rust-analyzer"] = {
				checkOnSave = {
					command = "clippy"
				},
			},
		}
	},
})

-- LSP Diagnostics Options Setup
local sign = function(opts)
	vim.fn.sign_define(opts.name, {
		texthl = opts.name,
		text = opts.text,
		numhl = ''
	})
end

-- Configure of the diagnostic related signs.
-- https://neovim.io/doc/user/diagnostic.html#diagnostic-signs
sign({ name = 'DiagnosticSignError', text = '' })
sign({ name = 'DiagnosticSignWarn', text = '' })
sign({ name = 'DiagnosticSignHint', text = '' })
sign({ name = 'DiagnosticSignInfo', text = '' })

--- https://neovim.io/doc/user/diagnostic.html#diagnostic-api
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = true,
	underline = true,
	severity_sort = false,
	float = {
		border = 'rounded',
		source = 'always',
		header = '',
		prefix = '',
	},
})

-- When cursor lands on a location with an error, automatically open a floating window diagnostic information.
-- focus=false to prevent cursor from focusin on floating window
vim.api.nvim_create_autocmd("CursorHold", {
	pattern = "*",
	command = "lua vim.diagnostic.open_float(nil, {focus=false})",
})

-- Treesitter Plugin Setup
require('nvim-treesitter.configs').setup {
	ensure_installed = { "lua", "rust", "toml", "python" },
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	ident = { enable = true },
	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = nil,
	}
}

require("hop").setup()
vim.keymap.set('n', 'f',
	function()
		require('hop').hint_char1({
			direction = require 'hop.hint'.HintDirection.AFTER_CURSOR,
			current_line_only = false
		})
	end)
vim.keymap.set('n', 'F',
	function()
		require('hop').hint_char1({
			direction = require 'hop.hint'.HintDirection.BEFORE_CURSOR,
			current_line_only = false
		})
	end)

require('impatient')

-- Plugin that generate sharable links to Github or other
-- git web frontends. I use it often when writing tickets
-- or discussion code via chat.
--
-- Select some code and run `<leader>gy` to generate a URL
-- that's copied to clipboard.
require("gitlinker").setup()

-- Make files requires tabs instead spaces.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "make" },
	command = "setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab"
})

--require("toggleterm").setup({
--open_mapping = [[<Leader>t]],
--direction = "float",
--})


-- Configur dap-ui.
require('dapui').setup()

-- Install listeners to automatically open and close dapui when a debugger is starts or terminates.
-- See https://github.com/rcarriga/nvim-dap-ui?tab=readme-ov-file#usage
require('dap').listeners.after.event_initialized["dapui_config"] = function()
	require('dapui').open()
end
-- CodeLLDB is a debugger for Rust. Install it using Mason.

--Find path to codelldb binary.
local codelldb                                                   = require('mason-registry').get_package("codelldb")
codelldb                                                         = codelldb:get_install_path() ..
    '/extension/adapter/codelldb'

-- Configure the CodeLLDB adapter for DAP. A lot of examples name this adapter 'lldb'.
-- Make sure to use 'codelldb' instead, otherwise plugin neotest-rust doesn't work.
require("dap").adapters.codelldb                                 = {
	-- Start the codelldb server.
	type = "server",
	port = "${port}",
	executable = {
		command = codelldb,
		args = { "--port", "${port}" },
	},
}

-- Configure DAP for Rust projects.
require('dap').configurations.rust                               = {
	{
		name = "Launch codelldb",
		type = "codelldb",
		request = "launch",
		-- TODO: Select the right binary by default
		program = function()
			vim.print("${workspaceFolder}")
			return vim.fn.input(
				"Path to executable: ",
				vim.fn.getcwd() .. "/target/debug",
				"file"
			)
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
		runInTerminal = false,
	}
}

-- Configure neotest. I use it primarily to debug tests with CodeLLDB.
require("neotest").setup({
	adapters = {
		require("neotest-rust")
	}
})

-- See :help dap
-- Toggle a breakpoint.
vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)

-- Start debugging a binary.
vim.keymap.set('n', '<Leader>ds', function() require('dap').continue() end)

-- Start debug the nearest test.
vim.keymap.set('n', '<Leader>dt', function() require("neotest").run.run({ strategy = "dap" }) end)

-- Terminate the debugger.
vim.keymap.set('n', '<Leader>dx', function() require('dap').terminate() end)

-- Toggle nvim-dap-ui.
vim.keymap.set('n', '<Leader>du', function() require('dapui').toggle() end)

--require('gitsigns').setup()
require("treesitter-context").setup()

vim.keymap.set("n", "<leader>o", "<cmd>Portal jumplist backward<cr>")
vim.keymap.set("n", "<leader>i", "<cmd>Portal jumplist forward<cr>")

-- Open doc.rs for symbol under cursor.
vim.keymap.set("n", "<leader>ed", "<cmd>RustOpenExternalDocs<cr>")
