local M = {}

function M.get_colors()
  local function hl(name, attr, default)
    local ok, result = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and result[attr] then
      return string.format("#%06x", result[attr])
    end
    return default
  end

  local normal_fg = hl("Normal", "fg", "#ffffff")
  local normal_bg = hl("Normal", "bg", "#1e1e1e")
  local function_fg = hl("Function", "fg", "#007acc")
  local string_fg = hl("String", "fg", "#16825d")
  local keyword_fg = hl("Keyword", "fg", "#68217a")
  local error_fg = hl("Error", "fg", "#c72e0f")
  local comment_fg = hl("Comment", "fg", "#888888")
  local type_fg = hl("Type", "fg", "#ECBE7B")
  local constant_fg = hl("Constant", "fg", "#008080")
  local special_fg = hl("Special", "fg", "#98be65")
  local identifier_fg = hl("Identifier", "fg", "#FF8800")
  local preproc_fg = hl("PreProc", "fg", "#a9a1e1")
  local number_fg = hl("Number", "fg", "#c678dd")
  local boolean_fg = hl("Boolean", "fg", "#51afef")

  return {
    normal = function_fg,
    insert = string_fg,
    visual = keyword_fg,
    replace = error_fg,
    command = keyword_fg,
    fg = normal_fg,
    bg = normal_bg,
    muted = normal_fg,
    dim = comment_fg,
    yellow = type_fg,
    cyan = constant_fg,
    green = special_fg,
    orange = identifier_fg,
    violet = preproc_fg,
    magenta = number_fg,
    blue = boolean_fg,
    red = error_fg,
  }
end

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

local function hide_in_width()
  return vim.fn.winwidth(0) > 80
end

local function build_opts()
  local c = M.get_colors()

  local opts = {
    options = {
      component_separators = "",
      section_separators = "",
      theme = {
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
      },
    },
    sections = {
      lualine_a = {
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
      },
      lualine_b = {
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
      },
      lualine_c = {
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
      },
      lualine_x = {
        {
          function()
            local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.bo.encoding
            return " " .. enc:upper()
          end,
          color = { fg = c.green, gui = "bold" },
          cond = hide_in_width,
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
      },
      lualine_y = {
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
      },
      lualine_z = {
        { "progress", color = { fg = c.fg, bg = c.blue, gui = "bold" } },
        {
          function()
            return " " .. os.date("%H:%M")
          end,
          color = { fg = c.fg, bg = c.blue, gui = "bold" },
        },
      },
    },
  }

  return opts
end

-- Expose for hot-reload to rebuild lualine with new theme colors
_G.__lualine_build_opts = build_opts

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = build_opts,
}
