local IFocusable = require("api.gui.IFocusable")

return class.interface("IInputHandler",
                 {
                    forward_to = "function",
                    run_actions = "function",
                    halt_input = "function",
                    update_repeats = "function",
                 },
                 IFocusable)
