local M = {}

function M.hello()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local new_line = line:sub(1, col) .. "Hello World Updated!" .. line:sub(col + 1)
	vim.api.nvim_set_current_line(new_line)
end

function M.setup(opts)
	-- Add any setup options here if needed
	vim.api.nvim_create_user_command("HelloWorld", function()
		M.hello()
	end, {})
end

return M
