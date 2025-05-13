local Job = require("plenary.job")

local Path = require("plenary.path")
local config

local function get_config()
    if not config then
        config = require("todo-telescope.config").options
    end
    return config
end

local M = {}

function M.find_todos_git_grep(repo_root, callback)
    local current_config = get_config()
    if not repo_root then
        callback({})
        return
    end

    local patterns = {}
    for _, kw in ipairs(current_config.keywords) do
        table.insert(patterns, "\\b" .. kw .. "\\b")
    end
    local grep_pattern = table.concat(patterns, "|")

    local git_cmd = current_config.git_cmd
    -- -i case insensitive
    local args = { "-C", repo_root, "grep", "-n", "-E", "-i" }


    table.insert(args, grep_pattern)

    local results = {}
    Job:new({
        command = git_cmd,
        args = args,
        cwd = repo_root,

        on_exit = vim.schedule_wrap(function(j, return_val)
            local output_lines = j:result() or {}
            for _, line in ipairs(output_lines) do
                -- parse git grep output <filepath>:<line_number>:<text>
                local file_rel, lnum, text = line:match("([^:]+):(%d+):(.*)")
                if file_rel and lnum and text then
                    local matched = ""
                    local search_for_kw = current_config.case_sensitive and text or text:lower()
                    for _, kw_candidate in ipairs(current_config.keywords) do
                        local kw = current_config.case_sensitive and kw_candidate or kw_candidate:lower()
                        if search_for_kw:find(kw, 1, true) then
                            matched = kw_candidate
                            break
                        end
                    end

                    -- remove leading white space
                    text = text:gsub("^%s*", '')

                    table.insert(results, {
                        file_absolute = Path:new(repo_root, file_rel):absolute(),
                        file_relative = file_rel,
                        line_number = tonumber(lnum),
                        text = text,
                        keyword = matched,
                    })
                end
            end
            callback(results)
        end)
    }):start()
end

return M
