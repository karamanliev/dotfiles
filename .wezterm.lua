local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
	enable_wayland = true,
	front_end = "WebGpu",
	-- disable_default_key_bindings = true,

	-- color_scheme = "Tokyo Night Moon",
	window_background_opacity = 0.95,
	wezterm.on("update-status", function(window)
		local overrides = window:get_config_overrides() or {}
		if window:is_focused() then
			overrides.color_scheme = "Tokyo Night Moon"
			-- overrides.window_background_opacity = 0.9
		else
			overrides.color_scheme = "Tokyo Night Storm"
			-- overrides.window_background_opacity = 0.8
		end
		window:set_config_overrides(overrides)
	end),

	font = wezterm.font("Operator Mono", { weight = 325, stretch = "Normal", style = "Normal" }),
	font_size = 15,
	adjust_window_size_when_changing_font_size = false,

	-- window_decorations = "RESIZE",
	window_decorations = "NONE",

	initial_rows = 46,
	initial_cols = 180,
	window_close_confirmation = "NeverPrompt",

	enable_tab_bar = false,
}

return config
