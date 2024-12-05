local M = {}

local todo_id = 1

function M.fetch_todo()
	local curl_cmd = string.format("curl -s https://jsonplaceholder.typicode.com/todos/%d", todo_id)
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

local function get_openai_api_key()
	return os.getenv("OPENAI_API_KEY")
end

local function get_git_diff()
	local diff = vim.fn.system("git diff")
	if vim.v.shell_error ~= 0 or diff == "" then
		vim.notify("No git diff available", vim.log.levels.WARN)
		return nil
	end
	return diff
end

local function call_openai_api(diff)
	local api_key = get_openai_api_key()
	if not api_key then
		vim.notify("OpenAI API key not found in .env", vim.log.levels.WARN)
		return
	end

	local curl_cmd = string.format(
		"curl -s -X POST https://api.openai.com/v1/engines/davinci-codex/completions "
			.. "-H 'Content-Type: application/json' "
			.. "-H 'Authorization: Bearer %s' "
			.. '-d \'{"prompt": "%s", "max_tokens": 100}\'',
		api_key,
		vim.fn.escape(diff, '"')
	)

	local response = vim.fn.system(curl_cmd)
	local success, decoded = pcall(vim.json.decode, response)

	if not success then
		vim.notify("Failed to decode OpenAI response", vim.log.levels.ERROR)
		return
	end

	if decoded.choices and decoded.choices[1] then
		return decoded.choices[1].text
	else
		vim.notify("No valid response from OpenAI", vim.log.levels.ERROR)
	end
end

function M.generate_commit_message()
	local diff = get_git_diff()
	if not diff then
		return
	end

	local commit_message = call_openai_api(diff)
	if commit_message then
		vim.api.nvim_set_current_line(commit_message)
	end
end

function M.setup(opts)
	opts = opts or {} -- Ensure opts is a table
	-- Set the todo_id from options or default to 1
	todo_id = opts.todo_id or 1
	vim.api.nvim_create_user_command("HelloWorld", function()
		M.hello()
	end, {})

	vim.api.nvim_create_user_command("FetchTodo", function()
		M.fetch_todo()
	end, {})

	vim.api.nvim_create_user_command("GenerateCommitMessage", function()
		M.generate_commit_message()
	end, {})
end

return M
