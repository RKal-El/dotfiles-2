-- {{{ Required libraries

local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local dpi = require("beautiful.xresources").apply_dpi
-- }}}

-- {{{ Startup
-- Compton
awful.spawn("picom --experimental-backends", false)
-- nm-applet
awful.spawn("nm-applet", false)
-- Battery manager
awful.spawn("xfce4-power-manager", false)
-- Print Screen
awful.spawn("flameshot", false)
--
---}}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, there were errors during startup!",
			text = awesome.startup_errors
		})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
				preset = naughty.config.presets.critical,
				title = "Oops, an error happened!",
				text = tostring(err)
			})
		in_error = false
	end)
end
-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

run_once({"urxvtd", "unclutter -root"}) -- entries must be separated by commas

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
	'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
	'xrdb -merge <<< "awesome.started:true";' ..
	-- list each of your autostart commands, followed by ; inside single quotes, followed by ..
	'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]

-- }}}

-- {{{ Variable definitions
local themes = {
	"notheme" -- 1
}

local chosen_theme = themes[1]
local modkey = "Mod4"
local altkey = "Mod1"
local terminal = "urxvtc"
local vi_focus = false -- vi-like client focus - https://github.com/lcpz/awesome-copycats/issues/275
local cycle_prev = true -- cycle trough all previous client or just the first -- https://github.com/lcpz/awesome-copycats/issues/274
local editor = os.getenv("EDITOR") or "nvim"
local gui_editor = os.getenv("gedit") or "gedit"
local browser = os.getenv("BROWSER") or "firefox"
local scrlocker = "slock"

awful.util.terminal = terminal
awful.util.tagnames = {" 1 ", " 2 ", " 3 ", " 4 ", " 5 "}
awful.layout.layouts = {awful.layout.suit.tile, awful.layout.suit.tile.bottom, awful.layout.suit.tile.left,
awful.layout.suit.tile.top, lain.layout.centerwork, awful.layout.suit.floating}

awful.util.taglist_buttons = my_table.join(awful.button({}, 1, function(t)
	t:view_only()
end), awful.button({modkey}, 1, function(t)
	if client.focus then
		client.focus:move_to_tag(t)
	end
end), awful.button({}, 3, awful.tag.viewtoggle), awful.button({modkey}, 3, function(t)
	if client.focus then
		client.focus:toggle_tag(t)
	end
end), awful.button({}, 5, function(t)
	awful.tag.viewnext(t.screen)
end), awful.button({}, 4, function(t)
	awful.tag.viewprev(t.screen)
end))

awful.util.tasklist_buttons = my_table.join(awful.button({}, 1, function(c)
	if c == client.focus then
		c.minimized = true
	else
		-- c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

		-- Without this, the following
		-- :isvisible() makes no sense
		c.minimized = false
		if not c:isvisible() and c.first_tag then
			c.first_tag:view_only()
		end
		-- This will also un-minimize
		-- the client, if needed
		client.focus = c
		c:raise()
	end

end), awful.button({}, 2, function(c)
	c:kill()
end), awful.button({}, 3, function()
	local instance = nil

	return function()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({
					theme = {
						width = dpi(250)
					}
				})
		end
	end
end), awful.button({}, 4, function()
	awful.client.focus.byidx(1)
end), awful.button({}, 5, function()
	awful.client.focus.byidx(-1)
end))

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = dpi(2)
lain.layout.cascade.tile.offset_y = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
end)
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join(
	awful.key(
		{altkey},
		"Tab",
		function()
			awful.client.focus.byidx(1)
			if _G.client.focus then
				_G.client.focus:raise()
			end
		end,
		{ description = 'Switch to next window', group = 'client' 
		}), awful.key({modkey}, "Left", awful.tag.viewprev, {
			description = "view previous",
			group = "tag"
		}), awful.key({modkey}, "Right", awful.tag.viewnext, {
			description = "view next",
			group = "tag"
		}), awful.key({modkey}, "d", function()
			for s in screen do
				s.mywibox.visible = not s.mywibox.visible
				if s.mybottomwibox then
					s.mybottomwibox.visible = not s.mybottomwibox.visible
				end
			end
		end, {
			description = "toggle wibox",
			group = "awesome"
		}), awful.key({modkey}, "t", function()
			lain.util.rename_tag()
		end, {
			description = "rename tag",
			group = "tag"
		}), awful.key({modkey, "Shift"}, "Left", function()
			lain.util.move_tag(-1)
		end, {
			description = "move tag to the left",
			group = "tag"
		}), awful.key({modkey, "Shift"}, "Right", function()
			lain.util.move_tag(1)
		end, {
			description = "move tag to the right",
			group = "tag"
		}), awful.key({modkey}, "Return", function()
			awful.util.spawn("x-terminal-emulator")
		end, {
			description = "open a terminal",
			group = "launcher"
		}), awful.key({modkey, "Control"}, "r", awesome.restart, {
			description = "reload awesome",
			group = "awesome"
		}), awful.key({modkey, "Shift"}, "q", awesome.quit, {
			description = "quit awesome",
			group = "awesome"
		}), awful.key({ modkey }, "space", function()
			awful.layout.inc(-1)
		end, {
			description = "select previous",
			group = "layout"
		}), awful.key({}, "XF86MonBrightnessUp", function()
			os.execute("xbacklight -inc 5")
		end, {
			description = "+5",
			group = "hotkeys"
		}), awful.key({}, "XF86MonBrightnessDown", function()
			os.execute("xbacklight -dec 5")
		end, {
			description = "-5%",
			group = "hotkeys"
		}), awful.key({}, "XF86AudioRaiseVolume", function()
			os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
			beautiful.volume.update()
		end, {
			description = "volume up",
			group = "hotkeys"
		}), awful.key({}, "XF86AudioLowerVolume", function()
			os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
			beautiful.volume.update()
		end, {
			description = "volume down",
			group = "hotkeys"
		}), awful.key({}, "XF86AudioMute", function()
			os.execute(
				string.format(
					"amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel
					)
				)
			beautiful.volume.update()
		end, {
			description = "toggle mute",
			group = "hotkeys"
		}), awful.key({altkey}, "space", function()
			awful.util.spawn("rofi -show drun")
		end, {
			description = "app launcher",
			group = "launcher"
		}), awful.key({modkey}, "r", function()
			awful.screen.focused().mypromptbox:run()
		end, {
			description = "execute command",
			group = "awesome"
	}))

clientkeys = my_table.join(awful.key({ modkey }, "m", lain.util.magnify_client, {
			description = "magnify client",
			group = "client"
		}), awful.key({modkey}, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, {
			description = "toggle fullscreen",
			group = "client"
		}), awful.key({modkey}, "q", function(c)
			c:kill()
		end, {
			description = "close",
			group = "client"
		}), awful.key({modkey, "Control"}, "Return", function(c)
			c:swap(awful.client.getmaster())
		end, {
			description = "move to master",
			group = "client"
		}), awful.key({modkey}, "o", function(c)
			c:move_to_screen()
		end, {
			description = "move to screen",
			group = "client"
		}), awful.key({modkey, "Control"}, "Up", function(c)
			if c.floating then
				c:relative_move(0, 0, 0, -20)
			else
				awful.client.incwfact(0.025)
			end
		end, {
			description = "Floating Resize Vertical -",
			group = "client"
		}), awful.key({modkey, "Control"}, "Down", function(c)
			if c.floating then
				c:relative_move(0, 0, 0, 20)
			else
				awful.client.incwfact(-0.025)
			end
		end, {
			description = "Floating Resize Vertical +",
			group = "client"
		}), awful.key({modkey, "Control"}, "Left", function(c)
			if c.floating then
				c:relative_move(0, 0, -20, 0)
			else
				awful.tag.incmwfact(-0.025)
			end
		end, {
			description = "Floating Resize Horizontal -",
			group = "client"
		}), awful.key({modkey, "Control"}, "Right", function(c)
			if c.floating then
				c:relative_move(0, 0, 20, 0)
			else
				awful.tag.incmwfact(0.025)
			end
		end, {
			description = "Floating Resize Horizontal +",
			group = "client"
		}), awful.key({altkey, "Control"}, "Down", function(c)
			c:relative_move(0, 20, 0, 0)
		end, {
			description = "Floating Move Down",
			group = "client"
		}), awful.key({altkey, "Control"}, "Up", function(c)
			c:relative_move(0, -20, 0, 0)
		end, {
			description = "Floating Move Up",
			group = "client"
		}), awful.key({altkey, "Control"}, "Left", function(c)
			c:relative_move(-20, 0, 0, 0)
		end, {
			description = "Floating Move Left",
			group = "client"
		}), awful.key({altkey, "Control"}, "Right", function(c)
			c:relative_move(20, 0, 0, 0)
		end, {
			description = "Floating Move Right",
			group = "client"
	}))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
clientbuttons = gears.table.join(awful.button({}, 1, function(c)
	c:emit_signal("request::activate", "mouse_click", {
			raise = true
		})
	end), awful.button({modkey}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", {
				raise = true
			})
		awful.mouse.client.move(c)
	end), awful.button({modkey}, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", {
				raise = true
			})
		awful.mouse.client.resize(c)
	end), awful.button({modkey}, 4, function(c)
		c:emit_signal("request::activate", "mouse_click", {
				raise = true
			})
		awful.client.floating.toggle(c)
	end))

	-- Set keys
	root.keys(globalkeys)
	-- }}}

	-- {{{ Rules
	-- Rules to apply to new clients (through the "manage" signal).
	awful.rules.rules = {{
			rule = {},
			properties = {
				border_width = 1,
				border_color = beautiful.border_normal,
				focus = awful.client.focus.filter,
				raise = true,
				keys = clientkeys,
				buttons = clientbuttons,
				screen = awful.screen.preferred,
				placement = awful.placement.no_overlap + awful.placement.no_offscreen,
				size_hints_honor = false
			}
		}, {
			rule_any = {
				instance = {"DTA", -- Firefox addon DownThemAll.
					"copyq", -- Includes session name in class.
				"pinentry"},
				class = {
					"Arandr", "Nautilus", "Gnome-calculator", "feh", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
					"Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
					"Wpa_gui", "veromix", "xtightvncviewer"
				},

				-- Note that the name property shown in xprop might be set slightly after creation of the client
				-- and the name shown there might not match defined rules here.
				name = {"Event Tester" -- xev.
				},
				role = {"AlarmWindow", -- Thunderbird's calendar.
					"ConfigManager", -- Thunderbird's about:config.
					"pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
				}
			},
			properties = {
				floating = true
			}
		}, {
			rule_any = {
				type = {"dialog", "normal"}
			},
			properties = {
				titlebars_enabled = false
			}
		}, {
			rule = {
				class = "Gimp",
				role = "gimp-image-window"
			},
			properties = {
				maximized = true
			}
	}}
	-- }}}

	-- {{{ Signals
	-- Signal function to execute when a new client appears.
	client.connect_signal("manage", function(c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end

		if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

	-- Enable sloppy focus, so that focus follows mouse.
	client.connect_signal("mouse::enter", function(c)
		c:emit_signal("request::activate", "mouse_enter", {
				raise = vi_focus
			})
		end)

		client.connect_signal("focus", function(c)
			c.border_color = beautiful.border_focus
		end)
		client.connect_signal("unfocus", function(c)
			c.border_color = beautiful.border_normal
		end)
		-- https://github.com/lcpz/awesome-copycats/issues/251
		-- }}}

		--{{{ Configurações que não tiveram espaço no resto do código
		beautiful.useless_gap = 4
		beautiful.gap_single_client = false

		client.connect_signal("manage", function (c)
			c.shape = function(cr,w,h)
				gears.shape.rounded_rect(cr,w,h,5)
			end
		end)

		--[[
client.connect_signal("focus", function(c) 
	c.border_color = beautiful.border_focus
	c.border_width = 1
end)
client.connect_signal("unfocus", function(c) 
	c.border_color = beautiful.border_normal
	c.border_width = 1
end)
]]--
		--}}}
