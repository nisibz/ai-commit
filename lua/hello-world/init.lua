local M = {}

function M.fetch_todo()
	local curl_cmd = "curl -s https://jsonplaceholder.typicode.com/todos/1"
	local response = vim.fn.system(curl_cmd)
	local success, decoded = pcall(vim.json.decode, response)

	if not success then
		vim.notify("Failed to decode JSON response", vim.log.levels.ERROR)
		return
	end

	-- Format the response as a string
	local formatted_response = string.format(
		"Todo #%d: %s (User: %d, Completed: %s)",
		decoded.id,
		decoded.title,
		decoded.userId,
		tostring(decoded.completed)
	)

	-- Insert at current cursor position
	local line = vim.api.nvim_get_current_line()
	local _, col = unpack(vim.api.nvim_win_get_cursor(0))
	local new_line = line:sub(1, col) .. formatted_response .. line:sub(col + 1)
	vim.api.nvim_set_current_line(new_line)
end

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

	vim.api.nvim_create_user_command("FetchTodo", function()
		M.fetch_todo()
	end, {})
end

return M
