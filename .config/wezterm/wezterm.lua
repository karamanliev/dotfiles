local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local is_macos = function()
	return wezterm.target_triple:find("darwin") ~= nil
end

config = {
	enable_wayland = true,
	front_end = "WebGpu",
	disable_default_key_bindings = true,

	-- color_scheme = "Tokyo Night Moon",
	window_background_opacity = 0.95,
	wezterm.on("update-status", function(window)
		local overrides = window:get_config_overrides() or {}
		if window:is_focused() then
			overrides.color_scheme = "Tokyo Night"
			-- overrides.window_background_opacity = 0.9
		else
			overrides.color_scheme = "Tokyo Night Moon"
			-- overrides.window_background_opacity = 0.8
		end
		window:set_config_overrides(overrides)
	end),

	font = wezterm.font("Operator Mono", { weight = 325, stretch = "Normal", style = "Normal" }),
	font_size = 15,
	adjust_window_size_when_changing_font_size = false,

	-- window_decorations = "RESIZE",
	window_decorations = is_macos() and "RESIZE" or "NONE",

	initial_rows = 46,
	initial_cols = is_macos() and 160 or 180,
	window_close_confirmation = "NeverPrompt",

	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	prefer_to_spawn_tabs = false,
	use_fancy_tab_bar = false,

	keys = {
		{ key = "T", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "W", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
		{ key = "N", mods = "CTRL", action = act.SpawnWindow },
		{ key = "V", mods = "CTRL", action = act.PasteFrom("Clipboard") },
		{ key = "C", mods = "CTRL", action = act.CopyTo("Clipboard") },
		{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
		{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
		{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	},
}

return config
