-- Pull in the wezterm API
local wezterm = require("wezterm")
-- local act = wezterm.action

-- This will hold the configuration.
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
	-- enable_scroll_bar = true,

	initial_rows = 46,
	initial_cols = 180,
	window_close_confirmation = "NeverPrompt",

	enable_tab_bar = false,
	use_fancy_tab_bar = false,
	tab_max_width = 32,
	-- hide_tab_bar_if_only_one_tab = true,

	--[[
	window_padding = {
		left = 16,
		right = 16,
		top = 8,
		bottom = 8,
	},
	--]]

	prefer_to_spawn_tabs = true,

	keys = {
		{
			key = "f",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
	},
	--[[
	keys = {
		{
			key = "w",
			mods = "CTRL",
			action = wezterm.action.CloseCurrentPane({ confirm = false }),
		},
		{
			key = "t",
			mods = "CTRL",
			action = wezterm.action.SpawnTab("CurrentPaneDomain"),
		},
		{
			key = "d",
			mods = "CTRL",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "D",
			mods = "CTRL",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "c",
			mods = "CTRL",
			action = wezterm.action_callback(function(window, pane)
				local has_selection = window:get_selection_text_for_pane(pane) ~= ""
				if has_selection then
					window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)

					window:perform_action(act.ClearSelection, pane)
				else
					window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
				end
			end),
		},
		{
			key = "v",
			mods = "CTRL",
			action = wezterm.action.PasteFrom("Clipboard"),
		},
		{
			key = "H",
			mods = "CTRL",
			action = act.AdjustPaneSize({ "Left", 5 }),
		},
		{
			key = "L",
			mods = "CTRL",
			action = act.AdjustPaneSize({ "Right", 5 }),
		},
		{
			key = "J",
			mods = "CTRL",
			action = act.AdjustPaneSize({ "Down", 5 }),
		},
		{
			key = "K",
			mods = "CTRL",
			action = act.AdjustPaneSize({ "Up", 5 }),
		},
		{
			key = "{",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(-1),
		},
		{
			key = "}",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(1),
		},
	},
--]]
	colors = {
		scrollbar_thumb = "#292e42",
	},
}

return config
