-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Runs preLaunchTask / postDebugTask if present
    { 'stevearc/overseer.nvim', config = true },
    'rcarriga/nvim-dap-ui',
  },
  keys = {
    {
      '<leader>db',
      function()
        local dap = require 'dap'
        -- Clear and Close the REPL buffer
        dap.repl.clear()
        -- Ensure the REPL is open before appending data
        dap.repl.open()

        local build_command = 'cmake --build ./build --target vrhri'
        local build_job = vim.fn.jobstart(build_command, {
          stdout_buffered = false,
          stderr_buffered = false,
          on_stdout = function(_, data)
            if data then
              for _, line in ipairs(data) do
                dap.repl.append(line)
              end
            end
          end,
          on_stderr = function(_, data)
            if data then
              for _, line in ipairs(data) do
                dap.repl.append('[stderr] ' .. line)
              end
            end
          end,
        })

        if build_job <= 0 then
          print 'Failed to start build job.'
        end
      end,
      desc = 'DAP Build',
    },
    {
      '<leader>dw',
      function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.scopes, { border = 'rounded' })
      end,
      desc = 'DAP Scopes',
    },
    {
      '<F1>',
      function()
        require('dap.ui.widgets').hover(nil, { border = 'rounded' })
      end,
      desc = 'DAP Hover',
    },
    { '<F4>', '<CMD>DapTerminate<CR>', desc = 'DAP Terminate' },
    { '<F5>', '<CMD>DapContinue<CR>', desc = 'DAP Continue' },
    {
      '<F6>',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to Cursor',
    },
    { '<F9>', '<CMD>DapToggleBreakpoint<CR>', desc = 'Toggle Breakpoint' },
    { '<F10>', '<CMD>DapStepOver<CR>', desc = 'Step Over' },
    { '<F11>', '<CMD>DapStepInto<CR>', desc = 'Step Into' },
    { '<F12>', '<CMD>DapStepOut<CR>', desc = 'Step Out' },
    {
      '<F17>',
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<F21>',
      function()
        vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(input)
          require('dap').set_breakpoint(input)
        end)
      end,
      desc = 'Conditional Breakpoint',
    },
  },
  config = function()
    -- Signs
    for _, group in pairs {
      'DapBreakpoint',
      'DapBreakpointCondition',
      'DapBreakpointRejected',
      'DapLogPoint',
    } do
      vim.fn.sign_define(group, { text = '●', texthl = group })
    end

    -- Setup

    -- Decides when and how to jump when stopping at a breakpoint
    -- The order matters!
    --
    -- (1) If the line with the breakpoint is visible, don't jump at all
    -- (2) If the buffer is opened in a tab, jump to it instead
    -- (3) Else, create a new tab with the buffer
    --
    -- This avoid unnecessary jumps
    require('dap').defaults.fallback.switchbuf = 'usevisible,usetab,newtab'

    -- Adapters
    -- C, C++, Rust
    require 'custom.plugins.dap.codelldb'
    -- Python
    -- require 'plugins.dap.debugpy'
    -- JS, TS
    -- require 'plugins.dap.js-debug-adapter'
  end,
}
