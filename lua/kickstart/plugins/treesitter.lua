return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local TS = require 'nvim-treesitter'

      local ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'go',
        'gomod',
        'gosum',
        'gowork',
      }
      TS.install(ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local bufnr = args.buf
          local ft = vim.bo[bufnr].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return
          end

          -- Auto-install missing parser, then start highlighting once it's ready.
          if #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.so', false) == 0 then
            TS.install({ lang }):await(function()
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  pcall(vim.treesitter.start, bufnr, lang)
                end
              end)
            end)
            return
          end

          pcall(vim.treesitter.start, bufnr, lang)

          if ft ~= 'ruby' then
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end

          if ft == 'ruby' then
            vim.bo[bufnr].syntax = 'ON'
          end
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
