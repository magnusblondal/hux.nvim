local M = {}

local function setup_path()
  if (not M.opts.path_to_obsidian) then
    vim.notify("Path to Obsidian Vault not set. Cannot save notes", vim.log.levels.WARN)
    return false
  end
  local path = M.opts.path_to_obsidian
  local notes_folder_path = vim.fn.expand(path) -- Expand to full path
  -- Ensure the folder exists
  vim.fn.mkdir(notes_folder_path, "p")
  M.file_path = notes_folder_path .. "/"
  return true
end

local function get_visual_selection()
  local _, start_line, start_col, _ = unpack(vim.fn.getpos("v"))
  local _, end_line, end_col, _ = unpack(vim.fn.getpos("."))
  -- Handle situation where selection is made in reverse
  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  -- Adjust end_col to include the last character in the selection
  if start_line ~= end_line then
    end_col = end_col + 1
  end

  -- Extract the selected text
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then return "" end
  if #lines == 1 then
    return string.sub(lines[1], start_col, end_col - 1)
  end
  lines[1] = string.sub(lines[1], start_col)
  lines[#lines] = string.sub(lines[#lines], 1, end_col - 1)
  return table.concat(lines, "\n")
end

local function body(note, timestamp)
  local created = "created: " .. timestamp .. "\n"
  local last_mod = "last modified: " .. timestamp .. "\n"
  local aliases = "aliases: \n"
  local tags = "tags: in\n"
  return "---\n\n" .. created .. last_mod .. aliases .. tags .. "---\n\n" .. note
end

local function file_name(note, timestamp)
  local maxLength = 15
  local length = math.min(maxLength, string.len(note))
  local trimmedNote = string.sub(note, 1, length)
  local sanitizedNote = trimmedNote:gsub("\n", ""):gsub("%s+", " "):gsub(" ", "_")
  local fileName = timestamp .. "-" .. sanitizedNote .. ".md"
  return fileName:gsub("_%.md", ".md")
end

local function full_path(f_name)
  return M.file_path .. f_name
end

local function can_write()
  if (not M.opts.path_to_obsidian) then
    vim.notify("Path to Obsidian Vault not set. Cannot save notes", vim.log.levels.WARN)
  end
  return M.opts.path_to_obsidian
end

local function write(f_name, f_body)
  local f_path = full_path(f_name)
  local file = io.open(f_path, "w")
  if file then
    file:write(f_body .. "\n")
    file:close()
    vim.notify(("Note saved to " .. f_path), vim.log.levels.INFO)
  else
    vim.notify("Error saving note", vim.log.levels.WARN)
  end
end

local function proc_note(note)
  if (not can_write()) then
    return
  end
  local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
  local f_name = file_name(note, timestamp)
  local f_body = body(note, timestamp)
  write(f_name, f_body)
end

function M.setup(opts)
  M.opts = opts or {}
  vim.api.nvim_create_user_command("HuxNote", M.note_command, { desc = "Write args as note", nargs = 1 })
  vim.api.nvim_create_user_command("HuxBuffer", M.note_from_visual,
    { desc = "Write current buffer as note to Obsidian" })
  M.path_valid = setup_path()
end

function M.note_command(args)
  proc_note(args.args)
end

function M.note_from_visual()
  proc_note(get_visual_selection())
end

function M.note_from_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local note = table.concat(lines, "\n")
  proc_note(note)
end

return M
