<div align="center">

## todo-sidebar

This repo is deprecated, all continued development will be on [todo-sidebar](https://github.com/ethanamaher/todo-sidebar.nvim)

project shifted to using a sidebar window buffer instead of a telescope picker

---

# todo-telescope
</div>
a lazy nvim plugin created to find TODO, FIXME, REVIEW, etc statements in a git repo

made to make it easier to find any, kept merging too many into main and got chastised

looks for comments like below. also detects things not commented, may implement that in future
```
# TODO make this function work

# NOTE not tested

# REVIEW edge cases
```

## Features
* Search through git repo using `git grep` to find any keywords, default are `keywords = { "TODO", "FIXME", "NOTE", "REVIEW" },`
* Show relevant files and the statement highlighted in a telescope picker and preview
## Use
### `:TelescopeTodo`
* Run it in a git repo
## Setup
### Dependencies
* Neovim (developed and tested on v0.10.4)
* telescope.nvim
* plenary.nvim
### Installation
Add the following to your `lazy.nvim` plugin configuration
```lua
return {
    {
        "ethanamaher/todo-telescope.nvim",

        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },

        config = function()
            require("todo-telescope").setup({
                -- uncomment lines to use custom options
                --
                -- define custom keyword list
                -- keywords = { "TODO", "FIXME", "NOTE", "REVIEW", }
                --
                -- case sensitivity
                -- case_sensitive = false,
                --
                -- max number of results in telescop picker
                -- max_results = 500
            })
        end
    }
}


```
