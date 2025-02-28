-- Debugger
return {
    'mfussenegger/nvim-dap',
    dependencies = {
        -- UI
        { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
        -- Installs dependencies
        'williamboman/mason.nvim',
        'jay-babu/mason-nvim-dap.nvim',
        -- Language specific debuggers
        'mfussenegger/nvim-dap-python',
    },
    keys = {
        {
            '<Leader>ds',
            function() require('dap').continue() end,
            desc = '[D]ebug [S]tart/Continue',
        },
    },
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')

        -- Keybindings
        vim.keymap.set('n', '<Leader>dt', dap.terminate, { desc = '[D]ebug [T]erminate session.' })
        vim.keymap.set('n', '<Leader>dr', dap.restart, { desc = '[D]ebug [R]estart session.' })
        vim.keymap.set('n', '<Leader>db', dap.toggle_breakpoint, { desc = '[D]ebug Toggle [B]reakpoint' })
        vim.keymap.set('n', '<Leader>dl', dapui.toggle, { desc = '[D]ebug See [L]ast session result.' })
        vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
        vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
        vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
        vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
        vim.keymap.set('n', '<F4>', dap.run_to_cursor, { desc = 'Debug: Run to cursor' })

        -- Installs all dependencies with mason
        require('mason-nvim-dap').setup({
            automatic_installation = true,
            handlers = {},
            ensure_installed = {
                'python',
            },
        })

        -- Dap setup
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
