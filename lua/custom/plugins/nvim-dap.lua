-- My subroutines
local function run_task(task_label)
  local overseer = require 'overseer'
  overseer.setup {
    task_list = {
      direction = 'bottom',
      min_height = 10,
      max_height = 80,
      default_detail = 1,
    },
  }

  -- Stop and remove any existing tasks to avoid buffer conflicts
  local tasks = overseer.list_tasks { name = task_label }
  for _, task in ipairs(tasks) do
    if task:is_running() then
      task:stop()
    end
    overseer.close(task) -- Close the task output buffer
  end

  -- Fetch all tasks matching the label
  overseer.run_template({ name = task_label }, function(task)
    if not task then
      print('Task not found: ' .. task_label)
      return
    end

    -- Start the task and capture output
    task:start()

    vim.defer_fn(function()
      overseer.open { task = task, focus = true }
    end, 500)
  end)
end
-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
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
        run_task 'build'
      end,
      desc = 'DAP Build',
    },
    {
      '<leader>dc',
      function()
        run_task 'clean_target'
      end,
      desc = 'DAP Clean',
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
    require('dap').defaults.fallback.exception_breakpoints = {}

    -- Adapters
    -- C, C++, Rust
    require 'custom.plugins.dap.codelldb'
    -- Python
    -- require 'plugins.dap.debugpy'
    -- JS, TS
    -- require 'plugins.dap.js-debug-adapter'
  end,
}