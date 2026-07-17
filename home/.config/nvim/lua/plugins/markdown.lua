return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      { 'nvim-mini/mini.icons', opts = {} },  -- standalone mini plugin, not the full suite
    },
    ft = 'markdown',  -- render-markdown supports lazy-loading on filetype
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
