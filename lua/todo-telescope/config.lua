local M = {}

M.defaults = {
    keywords = { "TODO", "FIXME", "NOTE", "REVIEW" },
    case_sensitive = false,

    ignore_patterns = {
        ".git/",
    },

    git_tracked_only = true,

    max_results = 500,
    search_strategy = "git_grep",

    git_cmd = "git",

    git_grep_args = {},
}

M.options = {}

function M.setup(user_opts)
    M.options = vim.tbl_deep_extend("force", {}, M.defaults, user_opts or {})
end

return M
