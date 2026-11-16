return {
  { -- Highlight, edit, and navigate code
    -- NOTE: This uses the `main` branch rewrite of nvim-treesitter (the old `master` branch
    -- and its `nvim-treesitter.configs` module are frozen). Highlighting and indent are now
    -- enabled per-buffer via a FileType autocmd instead of `highlight`/`indent` opts.
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
      require('nvim-treesitter').install(ensure_installed)

      -- Languages that rely on vim regex highlighting / indent rules instead
      local no_ts_indent = { ruby = true }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
        callback = function(args)
          local buf, ft = args.buf, args.match
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return
          end

          -- Auto-install parsers for languages that aren't installed yet (like `auto_install = true`)
          local available = require('nvim-treesitter').get_available()
          if not vim.list_contains(require('nvim-treesitter').get_installed(), lang) then
            if vim.list_contains(available, lang) then
              require('nvim-treesitter').install(lang):await(function()
                if vim.api.nvim_buf_is_valid(buf) then
                  pcall(vim.treesitter.start, buf, lang)
                end
              end)
            end
            return
          end

          if not pcall(vim.treesitter.start, buf, lang) then
            return
          end

          if ft == 'ruby' then
            vim.bo[buf].syntax = 'on' -- additional_vim_regex_highlighting
          end
          if not no_ts_indent[ft] then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects (use its `main` branch too)
  },
}
-- vim: ts=2 sts=2 sw=2 et
