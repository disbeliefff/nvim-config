vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{ "folke/tokyonight.nvim", name = "tokyonight", priority = 1000 },
	{ "nvim-telescope/telescope.nvim", tag = "0.1.6", dependencies = { "nvim-lua/plenary.nvim" } },
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{ "lewis6991/gitsigns.nvim" },
	{ "tpope/vim-fugitive" },
	{ "mhartington/formatter.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "saadparwaiz1/cmp_luasnip" },
	{ "L3MON4D3/LuaSnip" },
	{ "rafamadriz/friendly-snippets" },
	{ "kyazdani42/nvim-tree.lua" },
	{ "mbbill/undotree" },
}

require("lazy").setup(plugins, {})

require("nvim-tree").setup({
	disable_netrw = true,
	hijack_netrw = true,
	open_on_setup = false,
	auto_close = true,
	update_cwd = true,
	view = {
		width = 30,
		side = "left",
	},
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "go", "yaml", "terraform", "dockerfile" },
	highlight = { enable = true },
	indent = { enable = true },
})

require("tokyonight").setup({
	style = "night",
	transparent = true,
	terminal_colors = true,
})

vim.cmd.colorscheme("tokyonight")

require("gitsigns").setup({
	signs = {
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	numhl = false,
	linehl = false,
	watch_gitdir = { interval = 1000 },
	attach_to_untracked = true,
	current_line_blame = true,
	current_line_blame_opts = { virt_text = true, virt_text_pos = "eol", delay = 500 },
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
})

vim.keymap.set("n", "<C-g>b", require("gitsigns").preview_hunk, {})
vim.keymap.set("n", "<C-g>p", require("gitsigns").blame_line, {})
vim.keymap.set("n", "<C-g>r", require("gitsigns").reset_hunk, {})
vim.keymap.set("n", "<C-g>n", require("gitsigns").next_hunk, {})
vim.keymap.set("n", "<C-g>N", require("gitsigns").prev_hunk, {})

-- Форматирование файлов
require("formatter").setup({
	filetype = {
		lua = { require("formatter.filetypes.lua").stylua },
		go = { require("formatter.filetypes.go").gofmt },
		yaml = { require("formatter.filetypes.yaml").yamlfix },
	},
})

vim.api.nvim_exec(
	[[
  augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost * FormatWrite
  augroup END
]],
	false
)

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "gopls", "lua_ls", "terraformls" },
})

local lspconfig = require("lspconfig")
lspconfig.gopls.setup({})
lspconfig.lua_ls.setup({})
lspconfig.dockerls.setup({})
lspconfig.terraformls.setup({})

-- Настройка LuaSnip
require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = {
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "cmdline" },
	},
})

--hotkeys
vim.keymap.set("v", "<C-S-c>", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-v>", '"+p', { noremap = true, silent = true })
vim.keymap.set("i", "<C-S-v>", "<C-r>+", { noremap = true, silent = true })
vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })
vim.keymap.set("i", "<C-z>", "<C-o>u", { noremap = true, silent = true })
vim.keymap.set("v", "<BS>", '"_d', { noremap = true, silent = true })
vim.keymap.set("n", "<C-BS>", "dd", { noremap = true, silent = true })
vim.keymap.set("i", "<C-BS>", "<C-u>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>f", ":Format<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-S-Up>", "v<Up>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-Down>", "v<Down>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-Left>", "v<Left>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-Right>", "v<Right>", { noremap = true, silent = true })

vim.keymap.set("v", "<C-S-Up>", "<Up>", { noremap = true, silent = true })
vim.keymap.set("v", "<C-S-Down>", "<Down>", { noremap = true, silent = true })
vim.keymap.set("v", "<C-S-Left>", "<Left>", { noremap = true, silent = true })
vim.keymap.set("v", "<C-S-Right>", "<Right>", { noremap = true, silent = true })

vim.keymap.set("i", "<C-S-Up>", "<Esc>v<Up>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-S-Down>", "<Esc>v<Down>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-S-Left>", "<Esc>v<Left>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-S-Right>", "<Esc>v<Right>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

vim.opt.undofile = true 
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir" 

vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { noremap = true, silent = true })


vim.api.nvim_command("highlight NvimTreeNormal guibg=NONE ctermbg=NONE")
vim.api.nvim_command("highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE")

vim.cmd("set statusline+=%{FugitiveHead()}")
