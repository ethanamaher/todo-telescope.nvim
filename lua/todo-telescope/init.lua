local M = {}

local scanner = require("todo-telescope.scanner")
local telescope_integration = require("todo-telescope.telescope")
local config_module = require("todo-telescope.config")
local Path = require("plenary.path")

local function find_git_repo_root()
    local file_path = vim.fn.expand("%:p")
    local parent_dir = Path:new(current_path):parent():absolute()
    if not parent_dir then
        return
    end

    local repo_root_cmd = { "git", "-C", vim.fn.fnameescape(parent_dir), "rev-parse", "--show-toplevel" }
    local repo_root_list = vim.fn.systemlist(repo_root_cmd)
    local repo_root = repo_root_list and repo_root_list[1]

    if vim.vshell_error ~= nil then
        if repo_root == "" then repo_root = nil end -- handle empty output
        vim.notify("ERROR HERE", vim.log.levels.ERROR, { title="BetterGitBlame" })
    end

    if not repo_root then
        vim.notify("Could not determine Git repository root. " .. tostring(parent_dir) .. " from " .. tostring(current_path), vim.log.levels.ERROR, { title="BetterGitBlame"})
    end
    return repo_root
end

function M.scan_todos()
    local repo_root = find_git_repo_root()
    if not repo_root then return end

    if config_module.options.search_strategy == "git_grep" then
        scanner.find_todos_git_grep(repo_root, function(todo_items)
            if #todo_items == 0 then
                return
            end

            telescope_integration.show_telescope_picker(todo_items)
        end)
    else
        vim.notify("unknown search strategy", vim.log.levels.ERROR, { title="TODOTelescope" })
    end

end

function M.setup(user_opts)
    config_module.setup(user_opts)

    vim.api.nvim_create_user_command("TSScanTODO", M.scan_todos, {
        desc = "Scan project for TODOs, FIXMEs, etc."
    })
end

return M
