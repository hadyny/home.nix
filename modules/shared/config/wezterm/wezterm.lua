local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.initial_cols = 80
config.initial_rows = 28

config.font = wezterm.font 'Maple Mono NF'
config.font_size = 15

local appearance_themes = {
    Light = 'Catppuccin Latte',
    Dark = 'Catppuccin Mocha'
}

local appearance = wezterm.gui.get_appearance()
config.color_scheme = appearance_themes[appearance] or 'Catppuccin Mocha'

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.window_decorations = "MACOS_USE_BACKGROUND_COLOR_AS_TITLEBAR_COLOR | TITLE | RESIZE"

config.window_padding = {
  left = "20px",
  right = "20px",
  top = "20px",
  bottom = "20px",
}

return config
