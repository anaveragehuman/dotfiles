-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Hotkey popup widget
local hotkeys_popup = require("awful.hotkeys_popup.widget")
require("awful.hotkeys_popup.keys")

-- Switcher preview
local switcher = require("awesome-switcher-preview")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to another config.
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
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
                preset = naughty.config.presets.critical,
                title = "Oops, an error occurred!",
                text = tostring(err)
            })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
beautiful.init(gears.filesystem.get_configuration_dir() .. "/theme/theme.lua")

terminal = "xterm"
editor = "nvim" or "vim" or os.getenv("EDITOR")
editor_cmd = terminal .. " -e " .. editor

-- Usually, Mod4 is the key with a logo between Control and Alt.
-- To change it, use xmodmap or other tools to remap Mod4 to another key.
-- You can use another modifier like Mod1, but it may cause undesired effects.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Hide borders from windows when not tiled.
for s = 1, screen.count() do
    screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        -- No borders with only one visible client or in maximized layout
        if #clients > 1 and layout ~= "max" then
            for _, c in pairs(clients) do -- Floaters always have borders
                if not awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width
                    c.border_color = beautiful.border_focus
                end
            end
        end
    end)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "Hotkeys", function() return false, hotkeys_popup.show_help end},
    { "Manual", terminal .. " -e man awesome" },
    { "Edit config", editor_cmd .. " " .. awesome.conffile },
    { "Reload", awesome.restart },
    { "Quit", function() awesome.quit() end},
}

sessionmenu = {
    { "Lock", "physlock -ms" },
    { "Reboot", "sudo shutdown -r now" },
    { "Power Off", "sudo shutdown -h now" },
}

mymainmenu = awful.menu(
    {
        items = {
            { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "Session", sessionmenu },
    }})

mylauncher = awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = mymainmenu
    })

menubar.utils.terminal = terminal
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(" | %a %F %R ")

-- Create a battery widget
local function battery()
    fh = io.popen("acpi | cut -d, -f 2,3 -", "r")
    batterywidget:set_text(" |" .. fh:read("*l") .. " | ")
    fh:close()
end

batterywidget = wibox.widget.textbox()
batterywidgettimer = gears.timer({ timeout = 30 })
batterywidgettimer:connect_signal("timeout", function() battery() end)
batterywidgettimer:start()
battery()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
    )
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
    )
-- }}}

-- {{{ Wallpaper
local function set_wallpaper()
    os.execute('/usr/bin/feh --randomize --bg-max --no-fehbg "'..wp_path..'"')
end

wp_timeout = 900
wp_path = "/mnt/Data/sync/wallpapers/"
wp_timer = gears.timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function() set_wallpaper() end)
wp_timer:start()
-- }}}

-- {{{ Mouse bindings
root.buttons(
    gears.table.join(
        awful.button({ }, 3, function() mymainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
        )
    )
-- }}}

-- {{{ Adding and removing screens
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper()

    -- Each screen has its own tag table.
    awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(
        gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)
        ))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            batterywidget,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help  ),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j", function ()
        awful.client.focus.byidx( 1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "k", function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),

    awful.key({ modkey,           }, "w", function () mymainmenu:show()               end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ "Mod1",           }, "Tab", function () switcher.switch( 1, "Alt_L", "Tab", "ISO_Left_Tab") end),
    awful.key({ "Mod1", "Shift"   }, "Tab", function () switcher.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab") end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function() awful.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", function() awesome.quit() end),

    awful.key({ modkey,           }, "l",     function() awful.tag.incmwfact( 0.05) end),
    awful.key({ modkey,           }, "h",     function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift"   }, "h",     function() awful.tag.incnmaster( 1)   end),
    awful.key({ modkey, "Shift"   }, "l",     function() awful.tag.incnmaster(-1)   end),
    awful.key({ modkey, "Control" }, "h",     function() awful.tag.incncol( 1)      end),
    awful.key({ modkey, "Control" }, "l",     function() awful.tag.incncol(-1)      end),
    awful.key({ modkey,           }, "space", function() awful.layout.inc(1)        end),
    awful.key({ modkey, "Shift"   }, "space", function() awful.layout.inc(-1)       end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ modkey }, "r", function() awful.spawn("rofi -modi run -show run -fuzzy -regex")   end),
    awful.key({ modkey }, "p", function() awful.spawn("rofi -modi drun -show drun -fuzzy -regex") end),

    awful.key({ modkey }, "x", function()
        awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
    end),

    awful.key({ "Control", "Mod1" }, "l",     function () awful.util.spawn("physlock -ms") end),
    awful.key({                   }, "Print", function () awful.spawn("xfce4-screenshooter --save /tmp --fullscreen") end),
    awful.key({ "Shift"           }, "Print", function () awful.spawn("xfce4-screenshooter --save /tmp --region")     end)
    )

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen()                      ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    -- The client currently has the input focus, so it cannot be minimized, since minimized clients can't have the focus.
    awful.key({ modkey,           }, "n",      function (c) c.minimized = true               end),
    awful.key({ modkey,           }, "m",      function (c)
        c.maximized = not c.maximized
        c:raise()
    end)
    )

-- Bind all key numbers to tags.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9, function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function ()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end)
        )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            size_hints_honor = false,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    { rule_any = {
            instance = {
                "copyq",    -- Includes session name in class.
            },
            class = {
                "Arandr",
                "Wpa_gui",
                "pinentry",
                "pyStopwatch"
            },

            name = {
                "Event Tester",  -- xev.
            },
    }, properties = { floating = true }},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
        not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
        )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- vim: foldmethod=marker foldlevel=0
