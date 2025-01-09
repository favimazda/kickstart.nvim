return {
  'rcarriga/nvim-dap-ui',
  dependencies = 'nvim-neotest/nvim-nio',
  opts = {
    icons = {
      expanded = '󰅀',
      collapsed = '󰅂',
      current_frame = '󰅂',
    },
    layouts = {
      {
        position = 'left',
        size = 50,
        elements = {
          { id = 'scopes', size = 0.5 },
          { id = 'statcks', size = 0.3 },
          { id = 'breakpoints', size = 0.2 },
        },
      },
      {
        position = 'right',
        size = 50,
        elements = {
          { id = 'console', size = 1.0 },
        },
      },
      {
        position = 'bottom',
        size = 20,
        elements = {
          { id = 'repl', size = 1.0 },
        },
      },
    },
    expand_lines = false,
    controls = {
      enabled = false,
    },
    floating = {
      border = 'rounded',
    },
    render = {
      indent = 2,
      -- Hide variable types as C++'s are verbose
      max_type_length = 0,
    },
  },
  keys = {
    {
      '<A-p>',
      function()
        require('dapui').toggle { reset = true }
      end,
      desc = 'Toggle DAP UI',
    },
  },
}
