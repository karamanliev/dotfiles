-- Project-local config: use eslint_d for formatting instead of prettierd
local augroup = vim.api.nvim_create_augroup("oculus-eslint", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = augroup,
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
	callback = function(args)
		-- Disable conform (prettierd) for this buffer
		vim.b[args.buf].dont_format_on_write = true

		-- Format with eslint_d via conform on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = args.buf,
			callback = function()
				if vim.b[args.buf].skip_format_once then
					vim.b[args.buf].skip_format_once = false
					return
				end
				require("conform").format({
					bufnr = args.buf,
					formatters = { "eslint_d" },
					timeout_ms = 500,
				})
			end,
		})

		-- Manual format command
		vim.api.nvim_buf_create_user_command(args.buf, "FormatBuffer", function()
			require("conform").format({
				bufnr = args.buf,
				formatters = { "eslint_d" },
				async = true,
			})
		end, { desc = "Format buffer with eslint_d" })

		-- Write without formatting
		vim.api.nvim_buf_create_user_command(args.buf, "WriteWithoutFormat", function()
			vim.b[args.buf].skip_format_once = true
			vim.cmd("write")
		end, { desc = "Write buffer without formatting" })
	end,
})
