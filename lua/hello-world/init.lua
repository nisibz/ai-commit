local M = {}

function M.hello()
	print("Hello World Updated!")
end

function M.setup(opts)
	-- Add any setup options here if needed
	vim.api.nvim_create_user_command("HelloWorld", function()
		M.hello()
	end, {})
end

return M
