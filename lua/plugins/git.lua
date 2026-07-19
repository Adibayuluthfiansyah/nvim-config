return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last Hunk")
        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First Hunk")

        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghB", gs.blame, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")

        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Diff: git status" },
      { "<leader>gv", "<Cmd>DiffviewFileHistory<CR>", desc = "Diff: repo history" },
      { "<leader>gV", "<Cmd>DiffviewFileHistory %<CR>", desc = "Diff: current file history" },
      { "<leader>gv", ":'<,'>DiffviewFileHistory<CR>", mode = "v", desc = "Diff: selection history" },
      {
        "<leader>gc",
        function()
          vim.ui.input({ prompt = "Compare revision (ex. main, HEAD~5, main..HEAD): " }, function(refs)
            if refs and refs:match("%S") then
              vim.cmd(("DiffviewOpen %s"):format(refs))
            end
          end)
        end,
        desc = "Diff: compare revisions",
      },
      {
        "<leader>gC",
        function()
          vim.ui.input({ prompt = "File history range (ex. HEAD~1, main..HEAD): " }, function(range)
            if range and range:match("%S") then
              vim.cmd(("DiffviewFileHistory --range=%s %%"):format(range))
            end
          end)
        end,
        desc = "Diff: file history with range",
      },
      {
        "<leader>g2",
        function()
          vim.ui.input({ prompt = "First file: " }, function(file1)
            if not file1 or not file1:match("%S") then
              return
            end
            vim.ui.input({ prompt = "Second file: " }, function(file2)
              if file2 and file2:match("%S") then
                vim.cmd(("tabnew | e %s | diffthis | vsplit %s | diffthis"):format(file1, file2))
              end
            end)
          end)
        end,
        desc = "Diff: Compare 2 files",
      },
    },
    opts = {
      diff_binaries = false,
      enhanced_diff_hl = true,
      use_icons = true,
      show_help_hints = true,
      watch_index = true,
      icons = {
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      view = {
        default = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 40,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = { diff_merges = "combined" },
            multi_file = { diff_merges = "first-parent" },
          },
        },
        win_config = {
          position = "bottom",
          height = 15,
        },
      },
      keymaps = {
        disable_defaults = false,
        view = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },
          {
            "n",
            "]c",
            function()
              return require("diffview.actions").select_next_entry()
            end,
            { desc = "Next file" },
          },
          {
            "n",
            "[c",
            function()
              return require("diffview.actions").select_prev_entry()
            end,
            { desc = "Previous file" },
          },
          {
            "n",
            "<leader>b",
            function()
              return require("diffview.actions").toggle_files()
            end,
            { desc = "Toggle file panel" },
          },
        },
        file_panel = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },
          {
            "n",
            "<cr>",
            function()
              return require("diffview.actions").select_entry()
            end,
            { desc = "Open diff" },
          },
          {
            "n",
            "-",
            function()
              return require("diffview.actions").toggle_stage_entry()
            end,
            { desc = "Stage/unstage" },
          },
        },
      },
    },
  },
}
