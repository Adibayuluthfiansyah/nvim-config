local c = {
  normal = "#007acc",
  insert = "#16825d",
  visual = "#68217a",
  replace = "#c72e0f",
  command = "#68217a",
  fg = "#ffffff",
  bg = "#1e1e1e",
  muted = "#cccccc",
  dim = "#888888",
  yellow = "#ECBE7B",
  cyan = "#008080",
  green = "#98be65",
  orange = "#FF8800",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  blue = "#51afef",
  red = "#ec5f67",
}

local mode_names = {
  n = "NORMAL",
  no = "NORMAL",
  i = "INSERT",
  ic = "INSERT",
  ix = "INSERT",
  v = "VISUAL",
  V = "VISUAL LINE",
  ["\22"] = "VISUAL BLOCK",
  s = "SELECT",
  S = "SELECT LINE",
  ["\19"] = "SELECT BLOCK",
  R = "REPLACE",
  Rv = "REPLACE",
  c = "CMD",
  cv = "EX",
  ce = "EX",
  t = "TERMINAL",
}

local conditions = {
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
}

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    opts.options.component_separators = ""
    opts.options.section_separators = ""
    opts.options.theme = {
      normal = {
        a = { bg = c.normal, fg = c.fg, gui = "bold" },
        b = { bg = c.bg, fg = c.muted },
        c = { bg = c.bg, fg = c.muted },
        x = { bg = c.bg, fg = c.muted },
        y = { bg = c.bg, fg = c.muted },
        z = { bg = c.bg, fg = c.muted },
      },
      insert = {
        a = { bg = c.insert, fg = c.fg, gui = "bold" },
        b = { bg = c.bg, fg = c.muted },
        c = { bg = c.bg, fg = c.muted },
        x = { bg = c.bg, fg = c.muted },
        y = { bg = c.bg, fg = c.muted },
        z = { bg = c.bg, fg = c.muted },
      },
      visual = {
        a = { bg = c.visual, fg = c.fg, gui = "bold" },
        b = { bg = c.bg, fg = c.muted },
        c = { bg = c.bg, fg = c.muted },
        x = { bg = c.bg, fg = c.muted },
        y = { bg = c.bg, fg = c.muted },
        z = { bg = c.bg, fg = c.muted },
      },
      replace = {
        a = { bg = c.replace, fg = c.fg, gui = "bold" },
        b = { bg = c.bg, fg = c.muted },
        c = { bg = c.bg, fg = c.muted },
        x = { bg = c.bg, fg = c.muted },
        y = { bg = c.bg, fg = c.muted },
        z = { bg = c.bg, fg = c.muted },
      },
      command = {
        a = { bg = c.command, fg = c.fg, gui = "bold" },
        b = { bg = c.bg, fg = c.muted },
        c = { bg = c.bg, fg = c.muted },
        x = { bg = c.bg, fg = c.muted },
        y = { bg = c.bg, fg = c.muted },
        z = { bg = c.bg, fg = c.muted },
      },
      terminal = {
        a = { bg = c.normal, fg = c.fg, gui = "bold" },
        b = { bg = c.bg, fg = c.muted },
        c = { bg = c.bg, fg = c.muted },
        x = { bg = c.bg, fg = c.muted },
        y = { bg = c.bg, fg = c.muted },
        z = { bg = c.bg, fg = c.muted },
      },
      inactive = {
        a = { bg = c.bg, fg = c.dim },
        b = { bg = c.bg, fg = c.dim },
        c = { bg = c.bg, fg = c.dim },
        x = { bg = c.bg, fg = c.dim },
        y = { bg = c.bg, fg = c.dim },
        z = { bg = c.bg, fg = c.dim },
      },
    }

    opts.sections.lualine_a = {
      {
        function()
          local m = vim.api.nvim_get_mode().mode
          local reg = vim.fn.reg_recording()
          if reg ~= "" then
            return "● REC @" .. reg
          end
          return mode_names[m] or m:upper()
        end,
        padding = { left = 1, right = 1 },
      },
    }

    opts.sections.lualine_b = {
      { "branch", icon = " ", color = { fg = c.violet, gui = "bold" } },
      {
        "diff",
        colored = true,
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = c.green },
          modified = { fg = c.orange },
          removed = { fg = c.red },
        },
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
        diagnostics_color = {
          error = { fg = c.red },
          warn = { fg = c.yellow },
          info = { fg = c.cyan },
          hint = { fg = c.blue },
        },
      },
    }

    opts.sections.lualine_c = {
      {
        "filename",
        path = 1,
        symbols = { modified = "  ●", readonly = "  " },
        color = { fg = c.magenta, gui = "bold" },
      },
      {
        "searchcount",
        maxcount = 999,
        timeout = 500,
        color = { fg = c.yellow },
      },
      {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then
            return ""
          end
          local names = vim.tbl_map(function(v)
            return v.name
          end, clients)
          return " " .. table.concat(names, ", ")
        end,
        color = { fg = c.green, gui = "bold" },
      },
      {
        function()
          local sw = vim.bo.shiftwidth
          local et = vim.bo.expandtab
          return (et and " Spaces: " or " Tab: ") .. sw
        end,
        color = { fg = c.dim },
      },
    }

    opts.sections.lualine_x = {
      {
        function()
          local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.bo.encoding
          return " " .. enc:upper()
        end,
        color = { fg = c.green, gui = "bold" },
        cond = conditions.hide_in_width,
      },
      {
        function()
          local ff = vim.bo.fileformat
          local icons = { unix = "LF", dos = "CRLF", mac = "CR" }
          return icons[ff:lower()] or ff:upper()
        end,
        color = { fg = c.green, gui = "bold" },
      },
      {
        "filetype",
        icon_only = true,
        colored = true,
      },
    }

    opts.sections.lualine_y = {
      {
        function()
          local lnum = vim.fn.line(".")
          local col = vim.fn.col(".")
          local total = vim.fn.line("$")
          return "Ln " .. lnum .. ", Col " .. col .. (total > 0 and "/" .. total or "")
        end,
        color = { fg = c.fg },
      },
      {
        function()
          local total = vim.fn.line("$")
          if total == 0 then
            return ""
          end
          return math.floor(vim.fn.line(".") / total * 100) .. "%%"
        end,
        color = { fg = c.blue, gui = "bold" },
      },
    }

    opts.sections.lualine_z = {
      { "progress", color = { fg = c.fg, bg = c.blue, gui = "bold" } },
      {
        function()
          return " " .. os.date("%H:%M")
        end,
        color = { fg = c.fg, bg = c.blue, gui = "bold" },
      },
    }

    return opts
  end,
}
