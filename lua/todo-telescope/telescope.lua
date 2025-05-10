local M = {}

local pickers = require("telescope.pickers")
local finders  = require("telescope.finders")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values

local string_display = entry_display.create({
    seperator = " | ",
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
        previewer = previewers.vim_buffer_cat.new({
            title = "Code Context",
            get_buffer_by_name = function(entry)
                return entry.filename
            end,
        }),
        -- TODO attach_mappings
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                preview_width = 0.5,
            },
        },
        bordercharse = conf.borderchars,
    }):find()
end
