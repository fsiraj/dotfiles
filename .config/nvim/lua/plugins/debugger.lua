-- Debugger
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',
    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    -- Add your own debuggers here
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    {
      '<Leader>ds',
      function() require('dap').continue() end,
      desc = '[D]ebug [S]tart/Continue',
    },
    {
      '<Leader>dt',
      function() require('dap').terminate() end,
      desc = '[D]ebug [T]erminate session.',
    },
    {
      '<Leader>dr',
      function() require('dap').restart() end,
      desc = '[D]ebug [R]estart session.',
    },
    {
      '<leader>db',
      function() require('dap').toggle_breakpoint() end,
      desc = '[D]ebug Toggle [B]reakpoint',
    },
    {
      '<Leader>dl',
      function() require('dapui').toggle() end,
      desc = '[D]ebug See [L]ast session result.',
    },
    {
      '<F5>',
      function() require('dap').continue() end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function() require('dap').step_into() end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function() require('dap').step_over() end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function() require('dap').step_out() end,
      desc = 'Debug: Step Out',
    },
    {
      '<F4>',
      function() require('dap').run_to_cursor() end,
      desc = 'Debug: Run to cursor',
    },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    -- Installs all dependencies with mason
    require('mason-nvim-dap').setup({
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'python',
      },
    })

    -- Dap setup
    --  see |:help dap.repl.open()| for defaults
    local repl = require('dap.repl')
    repl.commands = vim.tbl_extend('force', repl.commands, {
      -- Add a new alias for the existing .exit command
      help = { '.h', '.help' },
      into = { '.i', '.into' },
      next_ = { '.o', '.over' },
      out = { '.out' },
      exit = {},
      custom_commands = {
        ['.restart'] = dap.restart,
        ['.terminate'] = dap.terminate,
      },
    })

    -- Dap UI setup
    --  see |:help nvim-dap-ui|
    dapui.setup({
      layouts = {
        {
          elements = {
            { id = 'stacks', size = 0.2 },
            { id = 'breakpoints', size = 0.2 },
            { id = 'scopes', size = 0.3 },
            { id = 'watches', size = 0.3 },
          },
          position = 'left',
          size = 40,
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          position = 'bottom',
          size = 16,
        },
      },
    })

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and {
          Breakpoint = '',
          BreakpointCondition = '',
          BreakpointRejected = '',
          LogPoint = '',
          Stopped = '',
        }
      or {}
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    -- Launch dapui automatically when dap starts
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Python specific config
    local python_path = vim.fs.joinpath(
      vim.fn.stdpath('data'), ---@diagnostic disable-line
      'mason',
      'packages',
      'debugpy',
      'venv',
      'bin',
      'python'
    )
    require('dap-python').setup(python_path)
  end,
}
