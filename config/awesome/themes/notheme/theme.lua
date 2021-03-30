--{{{ Import dos módulos necessários
local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
--}}}

--{{{ Define o tema
local theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/notheme"
theme.wallpaper = theme.dir .. "/tile.jpeg"
theme.font = "Noto Sans 9"
theme.fg_normal = "#E8DDCB"
theme.fg_focus = "#CDB380"
theme.fg_urgent = "#EDC390"
theme.bg_normal = "#282C34"
theme.bg_focus = "#383C44"
theme.bg_urgent = "#120900"
theme.border_normal = "#555C69"
theme.border_focus = "#ABB2BF"
theme.border_marked = "#ABB2BF"
theme.tasklist_bg_focus = "#383C44"
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.useless_gap = dpi(10)
--}}}

--{{{ cria os widgets
local markup = lain.util.markup

local keyboardlayout = awful.widget.keyboardlayout:new()

-- Textclock
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.watch("date +'%R'", 60, function(widget, stdout)
	widget:set_markup(" " .. markup.font(theme.font, stdout))
end)
-- Calendar
theme.cal = lain.widget.cal({
		attach_to = {clock},
		notification_preset = {
			font = theme.font,
			fg = theme.fg_normal,
			bg = theme.bg_normal
		}
})

-- MEM
local memicon = wibox.widget.textbox("")
local mem = lain.widget.mem({
		settings = function()
			widget:set_markup(markup.font(theme.font, " " .. mem_now.used .. "MB "))
		end
	})

-- CPU
local cpuicon = wibox.widget.textbox('')
local cpu = lain.widget.cpu({
		settings = function()
			widget:set_markup(markup.font(theme.font, " " .. cpu_now.usage .. "% "))
		end
	})

-- Battery
local baticon = wibox.widget.textbox('')
local bat = lain.widget.bat({
		settings = function()
				widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
		end
})

-- ALSA volume
local volicon = wibox.widget.textbox('')
theme.volume = lain.widget.alsa({
		settings = function()
			if volume_now.status == "off" then
				volicon:set_text('')
			elseif tonumber(volume_now.level) == 0 then
				volicon:set_text('')
			elseif tonumber(volume_now.level) <= 50 then
				volicon:set_text('')
			else
				volicon:set_text('')
			end

			widget:set_markup(markup.font(theme.font, " " .. volume_now.level .. "% "))
		end
	})

-- Separators
local spr = wibox.widget.textbox('   ')
--}}}

--{{{ função que configura os espaços virtuais
function theme.at_screen_connect(s)
	--{{{ Configura o wallpaper e o tema
	-- Quake application
	s.quake = lain.util.quake({
			app = awful.util.terminal
		})

	gears.wallpaper.maximized(theme.dir .. "/tile.jpeg", s)

	-- Tags
	awful.tag(awful.util.tagnames, s, awful.layout.layouts)

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(my_table.join(awful.button({}, 1, function()
		awful.layout.inc(1)
	end), awful.button({}, 2, function()
		awful.layout.set(awful.layout.layouts[1])
	end), awful.button({}, 3, function()
		awful.layout.inc(-1)
	end), awful.button({}, 4, function()
		awful.layout.inc(1)
	end), awful.button({}, 5, function()
		awful.layout.inc(-1)
	end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)
	--}}}

	--{{{ Wibox
	s.mywibox = wibox {
		-- get screen size and widget size to calculate centre position
		width = dpi(1350),
		height = dpi(28),
		ontop = false,
		screen = mouse.screen,
		expand = true,
		visible = true,
		bg = '#282C34',
		x = screen[1].geometry.width / 2 - 675,
		y = 10,
	}

	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,

			s.mytaglist,
			s.mypromptbox,
			wibox.widget.textbox(' '),
		},
		s.mytasklist,
		{
			spr,
			volicon,
			theme.volume,
			spr,
			memicon,
			mem,
			spr,
			cpuicon,
			cpu,
			spr,
			baticon,
			bat,
			layout = wibox.layout.fixed.horizontal,
			wibox.layout.margin(wibox.widget.systray(), 4, 4, 4, 4),
			clock,
			spr,
		}
	}
	s.mywibox:struts({left=0, right=0, top=50, bottom=0})
	--}}}
end
--}}}

return theme
