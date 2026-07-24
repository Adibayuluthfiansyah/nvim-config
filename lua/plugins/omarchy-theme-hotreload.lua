return {
  {
    name = "theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      local theme_path = vim.fn.stdpath("config") .. "/lua/plugins/theme.lua"
      local transparency_file = vim.fn.stdpath("config") .. "/plugin/after/transparency.lua"

      local augroup = vim.api.nvim_create_augroup("OmarchyTheme", { clear = true })

      local function reapply_transparency()
        if vim.fn.filereadable(transparency_file) == 1 then
          pcall(vim.cmd.source, transparency_file)
        end
      end

      local function refresh_lualine()
        if not _G.__lualine_build_opts then
          return
        end
        local ok, opts = pcall(_G.__lualine_build_opts)
        if not ok then
          return
        end
        local lualine_ok = pcall(require, "lualine")
        if not lualine_ok then
          return
        end
        pcall(require("lualine").setup, opts)
      end

      local function reload_theme()
        -- Clear all theme-related package caches
        package.loaded["plugins.theme"] = nil
        package.loaded["plugins.all-themes"] = nil

        -- Reload the theme spec
        local ok, theme_spec = pcall(require, "plugins.theme")
        if not ok then
          return
        end

        -- Clear highlights
        vim.cmd("highlight clear")
        if vim.fn.exists("syntax_on") then
          vim.cmd("syntax reset")
        end
        vim.o.background = "dark"

        -- Find and apply the colorscheme
        for _, spec in ipairs(theme_spec) do
          if spec[1] == "LazyVim/LazyVim" and spec.opts and spec.opts.colorscheme then
            local colorscheme = spec.opts.colorscheme
            pcall(require("lazy.core.loader").colorscheme, colorscheme)
            pcall(vim.cmd.colorscheme, colorscheme)

            reapply_transparency()
            refresh_lualine()

            vim.cmd("redraw!")
            break
          end
        end
      end

      -- Re-apply transparency on every ColorScheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = augroup,
        pattern = "*",
        callback = function()
          reapply_transparency()
        end,
      })

      -- File watcher: monitor neovim.lua for changes
      local function setup_watcher()
        local resolved = vim.fn.resolve(theme_path)
        if vim.fn.filereadable(resolved) ~= 1 then
          -- Retry after 1s in case symlink resolves to pending path
          vim.defer_fn(setup_watcher, 1000)
          return
        end

        local watcher = vim.uv.new_fs_event()
        if not watcher then
          return
        end

        local last_change = 0

        watcher:start(resolved, {}, vim.schedule_wrap(function(err, _filename, events)
          if err then
            return
          end

          -- Debounce: ignore events within 300ms of last one
          local now = vim.uv.now()
          if now - last_change < 300 then
            return
          end
          last_change = now

          if events.change or events.rename then
            -- If file was renamed/replaced, re-resolve path
            local new_resolved = vim.fn.resolve(theme_path)
            if new_resolved ~= resolved then
              watcher:stop()
              watcher:close()
              setup_watcher()
              return
            end

            -- Re-read theme.spec from disk
            package.loaded["plugins.theme"] = nil
            package.loaded["plugins.all-themes"] = nil

            local ok = pcall(function()
              -- Simulate a fresh load by re-requiring
              package.loaded["plugins.theme"] = nil
              local _, new_spec = pcall(require, "plugins.theme")
              if not new_spec then
                return
              end

              -- Find colorscheme
              local colorscheme = nil
              for _, spec in ipairs(new_spec) do
                if spec[1] == "LazyVim/LazyVim" and spec.opts and spec.opts.colorscheme then
                  colorscheme = spec.opts.colorscheme
                  break
                end
              end
              if not colorscheme then
                return
              end

              -- Clear and apply
              vim.cmd("highlight clear")
              if vim.fn.exists("syntax_on") then
                vim.cmd("syntax reset")
              end
              vim.o.background = "dark"

              pcall(require("lazy.core.loader").colorscheme, colorscheme)
              pcall(vim.cmd.colorscheme, colorscheme)

              reapply_transparency()
              refresh_lualine()
              vim.cmd("redraw!")
            end)

            if not ok then
              vim.notify("Theme hot-reload failed", vim.log.levels.ERROR)
            end
          end
        end))
      end

      setup_watcher()
    end,
  },
}
