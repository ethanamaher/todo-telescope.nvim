local M = {}

local pickers = require("telescope.pickers")
local finders  = require("telescope.finders")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")
local previewer_utils = require("telescope.previewers.utils")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values

local Job = require("plenary.job")

local string_display = entry_display.create({
    separator = " | ",
    items = {
        { width = 35 },
        { width = 5 },
        { width = 10 },
        { remaining = true },
    },
})

local make_entry_display = function(entry)
    return string_display({
        { entry.value.file_relative, "Comment" },
        { tostring(entry.value.line_number), "Number" },
        { entry.value.keyword, "Identifier" },
        { entry.value.text, "Normal" },
    })
end

local telescope_entry = function(entry)
    return {
        value = entry,
        display = make_entry_display,
        ordinal = entry.file_relative .. ":" .. string.format("%05d", entry.line_number),
        filename = entry.file_absolute,
        lnum = entry.line_number,
        text = entry.text
    }
end

local create_previewer = function(opts)
    opts = opts or {}

    return previewers.new_buffer_previewer({
        title = opts.title or "TODO List",
        define_preview = function(self, entry, status)
            if not entry or not entry.filename or not entry.lnum then
                previewer_utils.set_preview_message(self.state.bufnr, self.state.winid, "Invalid entry for preview")
                return
            end

            local file_content
            local read_ok, result = pcall(vim.fn.readfile, entry.filename)
            if not read_ok or not result then
                return
            end
            file_content = result

            -- TODO check if file exists

            if not vim.api.nvim_buf_is_valid(self.state.bufnr) then
                return
            end

            local bufnr = self.state.bufnr
            local winid = self.state.winid
            local line_to_highlight = entry.lnum - 1

            local filetype = vim.fn.fnamemodify(entry.filename, ":e")

            vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
            vim.api.nvim_buf_set_option(bufnr, "filetype", filetype)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, file_content)
            vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

            -- TODO highlight hit keyword and put it somewhere consistent
        end,
    })
end


function M.show_telescope_picker(entries)
    if not entries or #entries == 0 then
        return
    end

    pickers.new({
        prompt_title = "TODOs",
        finder = finders.new_table({
            results = entries,
            entry_maker = telescope_entry
        }),
        sorter = sorters.get_generic_fuzzy_sorter({}),
        previewer = create_previewer({}),
        -- TODO attach_mappings
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                preview_width = 0.5,
            },
        },
        borderchars = conf.borderchars,
    }):find()
end

return M
