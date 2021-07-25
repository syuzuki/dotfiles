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

-- awful.spawn("wmname LG3D", false)

local function square(x)
    return x * x
end

local function map(f, ary)
    local result = {}

    for _, v in ipairs(ary) do
        table.insert(result, f(v))
    end

    return result
end

local function filter(f, ary)
    local result = {}

    for _, v in ipairs(ary) do
        if f(v) then
            table.insert(result, v)
        end
    end

    return result
end

local function any(ary)
    for _, v in ipairs(ary) do
        if v then
            return true
        end
    end

    return false
end

local function concat(ary)
    local result = {}

    for _, v in ipairs(ary) do
        for _, w in ipairs(v) do
            table.insert(result, w)
        end
    end

    return result
end

local function table_position(ary, x)
    for i, v in ipairs(ary) do
        if v == x then
            return i
        end
    end

    return nil
end

local function removeValue(ary, value)
    while true do
        local i = awful.util.table.hasitem(ary, value)

        if not i then
            break
        end

        table.remove(ary, i)
    end
end

local function intersection(table0, table1)
    result = {}

    for _, x in ipairs(table0) do
        if table_position(table1, x) then
            table.insert(result, x)
        end
    end

    return result
end

local function collect(iter)
    result = {}

    for x in iter do
        table.insert(result, x)
    end

    return result
end

local function compare_modifiers(modifiers0, modifiers1)
    if #modifiers0 ~= #modifiers1 then
        return false
    end

    local mods0 = awful.util.table.clone(modifiers0)

    for _, m in ipairs(modifiers1) do
        local i = awful.util.table.hasitem(mods0, m)

        if not i then
            return false
        end

        table.remove(mods0, i)
    end

    return true
end

local function ttostring(t)
    if type(t) ~= "table" then
        return tostring(t)
    end

    local ss = {}
    for k, v in pairs(t) do
        ss[#ss + 1] = ttostring(k) .. " = " .. ttostring(v)
    end

    return "{ " .. table.concat(ss, ", ") .. " }"
end

local function scale(pixels, screen)
    return math.floor(pixels * screen.dpi / 96 + 0.5)
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Oops, there were errors during startup!",
        text   = awesome.startup_errors,
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Oops, an error happened!",
            text   = err,
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper              = "/usr/share/backgrounds/archlinux/split.png"
beautiful.font                   = "sans 9"
beautiful.border_width           = scale(2, screen.primary)
beautiful.notification_icon_size = scale(32, screen.primary)

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

local function match_group(c, group)
    if awful.rules.matches(c, group) then
        return true
    end
    if group.match and group.match(c) then
        return true
    end
    return false
end

wingroups = {}

wingroups.groups = {
    {
        key  = "j",
        cmd  = terminal,
        rule = { class = "kitty" },
    },
    {
        key  = "k",
        cmd  = "firefox",
        rule = { class = "firefox" },
    },
    {
        key  = "l",
        cmd  = "evince",
        rule = { class = "Evince" },
    },
    {
        key  = ";",
        cmd  = nil,
        rule_any = {
            class = {
                "Kicad",
                "Gerbview",
                "Eeschema",
                "Pcb_calculator",
                "com-st-microxplorer-maingui-STM32CubeMX",
                "processing-app-Base",
                "bsch3v.exe",
                "lcov.exe",
                "mbe.exe",
            },
        },
    },
    -- {
    --     key  = "l",
    --     cmd  = "minecraft-launcher",
    --     ws   = "8",
    --     -- use rules_any so () is not worked like a regex in other languages
    --     rule_any = {
    --         name = {
    --             -- Launcher
    --             "^Minecraft Launcher$",
    --             -- Release
    --             "^Minecraft %d+%.%d+$",
    --             "^Minecraft %d+%.%d+%.%d+$",
    --             -- Snapshot
    --             "^Minecraft %d+%.%d+-pre%d+$",
    --             "^Minecraft %d+%.%d+%.%d+-pre%d+$",
    --             "^Minecraft %d+w%d+%a$",
    --         },
    --     },
    -- },
    {
        key     = "h",
        cmd     = nil,
        match   = function(c)
            return not any(map(function(g)
                return match_group(c, g)
            end, filter(function(g)
                return not g.special
            end, wingroups.groups)))
        end,
        special = true,
    },
    {
        key     = "y",
        cmd     = nil,
        rule    = {},
        special = true,
    },
}

wingroups.clients = {}
wingroups.grabber = nil

globalkeys = {}

local function focus_with_group(group)
    local focused_screen = awful.screen.focused()
    local focused_screen_tags = map(function(t) return t.name end, focused_screen.selected_tags)
    local screens = filter(function(s)
        return s == focused_screen or
            #intersection(map(function(t) return t.name end, s.selected_tags), focused_screen_tags) > 0
    end, collect(screen))
    local clients = filter(function(c)
        return match_group(c, group) and
            table_position(screens, c.screen) and
            table_position(c.screen.clients, c)
    end, wingroups.clients)

    if #clients == 0 then
        return
    end

    local index = 1

    if client.focus == clients[1] and #clients >= 2 then
        index = 2
    end

    clients[index]:jump_to()

    wingroups.grabber = awful.keygrabber.run(function(mod, key, event)
        if event == "release" then
            if key == "Super_R" then
                awful.keygrabber.stop(wingroups.grabber)
                wingroups.grabber = nil
            end

            return
        end

        if key ~= group.key then
            local rep = {
                [";"] = "semicolon",
                [" "] = "space",
            }
            local k = rep[key]
            if k then
                key = k
            end

            awful.keygrabber.stop(wingroups.grabber)
            wingroups.grabber = nil

            local match = false

            for _, k in ipairs(globalkeys) do
                if awful.key.match(k, mod, key) then
                    k:emit_signal("press")
                    match = true

                    break
                end
            end
            if not match and client.focus ~= nil then
                for _, k in ipairs(clientkeys) do
                    if awful.key.match(k, mod, key) then
                        k:emit_signal("press", client.focus)

                        break
                    end
                end
            end

            return
        end

        for i = index, 1, -1 do
            removeValue(wingroups.clients, clients[i])
            table.insert(wingroups.clients, 1, clients[i])
        end

        index = index % #clients + 1

        local focus = clients[index]

        focus:jump_to()
    end)
end

client.connect_signal("manage", function(c, startup)
    if awful.util.table.hasitem(wingroups.clients, c) then
        return
    end

    if any(map(function(t) return t.selected end, c:tags())) or
        #wingroups.clients == 0 then
        table.insert(wingroups.clients, 1, c)
    else
        table.insert(wingroups.clients, 2, c)
    end

    if wingroups.grabber then
        awful.keygrabber.stop(wingroups.grabber)
        wingroups.grabber = nil
    end
end)

client.connect_signal("unmanage", function(c)
    removeValue(wingroups.clients, c)

    if wingroups.grabber then
        awful.keygrabber.stop(wingroups.grabber)
        wingroups.grabber = nil
    end

    local parent = c.transient_for
    if parent then
        removeValue(wingroups.clients, parent)
        table.insert(wingroups.clients, 1, parent)
        parent:jump_to()
    end
end)

local function banish_cursor(screen)
    local scr
    if screen then
        scr = screen
    else
        local focus = client.focus
        scr = focus and focus.screen or awful.screen.focused()
    end
    local geometry = scr.geometry

    mouse.coords({ x = geometry.x + geometry.width - 1, y = geometry.y + geometry.height }, true)
end

banish_cursor(screen.primary)

local function screen_gravity(s)
    return {
        x = s.geometry.x + s.geometry.width / 2,
        y = s.geometry.y + s.geometry.height / 2,
    }
end

local function find_screen(filt)
    local primary = screen.primary
    local primary_pos = screen_gravity(primary)

    local scr = nil
    local scr_dist_sq = nil
    for s in screen do
        if s ~= primary then
            local pos = screen_gravity(s)
            local diff_sq = {
                x = square(pos.x - primary_pos.x),
                y = square(pos.y - primary_pos.y),
            }
            if filt(pos, primary_pos, diff_sq) then
                local dist_sq = diff_sq.x + diff_sq.y
                if not scr or dist_sq < scr_dist_sq then
                    scr = s
                    scr_dist_sq = dist_sq
                end
            end
        end
    end
    return scr
end

local function left_screen()
    return find_screen(function(pos, prim_pos, diff_sq) return pos.x <= prim_pos.x and diff_sq.x >= diff_sq.y end)
end

local function right_screen()
    return find_screen(function(pos, prim_pos, diff_sq) return pos.x > prim_pos.x and diff_sq.x >= diff_sq.y end)
end

local function focus_screen_if_exist(s)
    if s then
        awful.screen.focus(s)
    end
end

local function move_to_screen_if_exist(c, s)
    if s then
        c:move_to_screen(s)
    end
end

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts =
{
    awful.layout.suit.max,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
mymainmenu = awful.menu({ items = {} })

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu  = mymainmenu,
})

-- {{{ Wibox
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%F %a %H:%M", 5)

local function my_tasklist_update(w, buttons, label, data, objects, args)
    if client.focus and client.focus ~= wingroups.clients then
        removeValue(wingroups.clients, client.focus)
        table.insert(wingroups.clients, 1, client.focus)
    end

    -- update the widgets, creating them if needed
    w:reset()

    local clients = {}

    for i, c in ipairs(wingroups.clients) do
        if awful.util.table.hasitem(objects, c) then
            table.insert(clients, 1, c)
        end
    end
    for _, c in ipairs(objects) do
        if not awful.util.table.hasitem(wingroups.clients, c) then
            clients[#clients + 1] = c
        end
    end

    for i, o in ipairs(clients) do
        local cache = data[o]
        local ib, tb, ibb, tbb

        if cache then
            ib = cache.ib
            tb = cache.tb
            ibb = cache.ibb
            tbb = cache.tbb
        else
            ib = wibox.widget.imagebox()
            tb = wibox.widget.textbox()

            local ibm = wibox.container.margin(ib, scale(1, args.screen), scale(1, args.screen))
            local tbm = wibox.container.margin(tb, scale(3, args.screen), scale(3, args.screen))

            ibb = wibox.container.background()
            tbb = wibox.container.background()

            -- And all of this gets a background
            ibb:set_widget(ibm)
            ibb:buttons(awful.widget.common.create_buttons(buttons, o))
            tbb:set_widget(tbm)
            tbb:buttons(awful.widget.common.create_buttons(buttons, o))

            data[o] = {
                ib  = ib,
                tb  = tb,
                ibb = ibb,
                tbb = tbb
            }
        end

        local text, bg, bg_image, icon, args = label(o, tb)
        icon = icon or string.gsub(awesome.conffile, "[^/:]*$", "") .. "X.org.png"
        args = args or {}
        -- The text might be invalid, so use pcall
        if not tb:set_markup_silently(text) then
            tb:set_markup("<i>&lt;Invalid text&gt;</i>")
        end
        ib:set_image(icon)
        ibb:set_bg(bg)
        if type(bg_image) == "function" then
            bg_image = bg_image(tb,o,m,clients,i)
        end
        ibb:set_bgimage(bg_image)
        ibb.shape              = args.shape
        ibb.shape_border_width = args.shape_border_width
        ibb.shape_border_color = args.shape_border_color
        tbb:set_bg(bg)
        if type(bg_image) == "function" then
            bg_image = bg_image(tb,o,m,clients,i)
        end
        tbb:set_bgimage(bg_image)
        tbb.shape              = args.shape
        tbb.shape_border_width = args.shape_border_width
        tbb.shape_border_color = args.shape_border_color

        w:add(ibb)

        if i == #clients then
            w:add(tbb)
        end
   end
end

local function set_wallpaper(s)
    local wallpaper = beautiful.wallpaper
    if wallpaper then
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    awful.tag({"7", "8", "9", "0"}, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, nil)

    local w = wibox.layout.fixed.horizontal()
    w:fill_space(true)
    s.mytasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {},
        update_function = my_tasklist_update,
        layout = w,
    })

    s.mywibox = awful.wibar({ position = "top", screen = s, height = scale(16, s) })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist,
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.container.margin(wibox.widget.systray(), scale(3, s)),
            wibox.container.margin(mytextclock, scale(3, s)),
            wibox.container.margin(s.mylayoutbox, scale(3, s)),
        },
    }
end)

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey, "Shift"   }, "w", function()
        -- awful.spawn("sh -c 'lock & sleep 1; exec systemctl hibernate'")
        -- awful.spawn("sh -c 'lock & sleep 1; (($(free | perl -n -E '\\''print if s/^Swap: *\\d+ +(\\d+).*/\\1/'\\'') > 0)) || { sudo swapoff /swapfile; sudo swapon /swapfile; }; exec systemctl hibernate'")
        awful.spawn([[bash -c 'lock & sleep 1; (($(free | perl -n -E '\''print if s/^Swap: *\d+ +(\d+).*/\1/'\'') > 0)) && { sudo swapoff /swapfile; sudo swapon /swapfile; }; exec systemctl hibernate']])
    end),
    awful.key({ modkey, "Shift"   }, "e", function()
        awful.spawn("sh -c 'lock & sleep 1; exec systemctl suspend'")
    end),
    awful.key({ modkey, "Shift"   }, "r", function() awful.spawn("lock") end),

    awful.key({ modkey,           }, "space", function() awful.layout.inc( 1) end),
    awful.key({ modkey, "Shift"   }, "space", function() awful.layout.inc(-1) end),

    awful.key({ modkey }, "x",
              function()
                  awful.prompt.run {
                      prompt = "Run Lua code: ",
                      textbox = awful.screen.focused().mypromptbox.widget,
                      exe_callback = awful.util.eval,
                      history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end),

    concat(map(function(g)
        local keys = awful.key({ modkey }, g.key, function() focus_with_group(g) end)

        if g.cmd then
            keys = awful.util.table.join(keys,
                awful.key({ modkey, "Shift" }, g.key,
                function() awful.spawn(g.cmd) end))
        end

        return keys
    end, wingroups.groups)),
    awful.key({ modkey }, "c",                     banish_cursor),
    awful.key({ modkey }, "i",                     function() awful.screen.focus(screen.primary)        end),
    awful.key({ modkey }, "u",                     function() focus_screen_if_exist(left_screen())      end),
    awful.key({ modkey }, "o",                     function() focus_screen_if_exist(right_screen())     end),
    awful.key({        }, "XF86AudioLowerVolume",  function() awful.spawn("pulsemixer --change-volume -1", false) end),
    awful.key({        }, "XF86AudioRaiseVolume",  function() awful.spawn("pulsemixer --change-volume +1", false)   end),
    awful.key({        }, "XF86AudioMute",         function() awful.spawn("pulsemixer --toggle-mute", false) end),
    awful.key({ modkey }, "a",                     function() awful.spawn("pulsemixer --change-volume -1", false) end),
    awful.key({ modkey }, "s",                     function() awful.spawn("pulsemixer --change-volume +1", false)   end),
    awful.key({ modkey }, "d",                     function() awful.spawn("pulsemixer --toggle-mute", false) end),
    awful.key({        }, "XF86MonBrightnessUp",   function() awful.spawn("xbacklight-ctl up", false)   end),
    awful.key({        }, "XF86MonBrightnessDown", function() awful.spawn("xbacklight-ctl down", false) end),
    awful.key({ modkey }, "F9",                    function() awful.spawn("touchpad-toggle", false)     end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f", function(c) c.fullscreen = not c.fullscreen                     end),
    awful.key({ modkey, "Shift"   }, "c", function(c) c:kill()                                            end),
    awful.key({ modkey,           }, "g", function(c) c.floating = not c.floating                         end),
    awful.key({ modkey,           }, "n", function(c) c:swap(awful.client.getmaster())                    end),
    awful.key({ modkey, "Shift"   }, "i", function(c) c:move_to_screen(screen.primary)                    end),
    awful.key({ modkey, "Shift"   }, "u", function(c) move_to_screen_if_exist(c, left_screen())           end),
    awful.key({ modkey, "Shift"   }, "o", function(c) move_to_screen_if_exist(c, right_screen())          end),
    awful.key({ modkey, "Shift"   }, "p", function(c) c:move_to_screen()                                  end),
    awful.key({ modkey,           }, "t", function(c) c.ontop = not c.ontop                               end),
    awful.key({ modkey,           }, "m", function(c) c.maximized = not c.maximized                       end),
    awful.key({ modkey, "Control" }, "m", function(c) c.maximized_vertical = not c.maximized_vertical     end),
    awful.key({ modkey, "Shift"   }, "m", function(c) c.maximized_horizontal = not c.maximized_horizontal end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i, n in ipairs{"7", "8", "9", "0"} do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, n,
                  function()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, n,
                  function()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, n,
                  function()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                      end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, n,
                  function()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({        }, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = gears.table.join({
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width     = 0,
            border_color     = beautiful.border_normal,
            focus            = awful.client.focus.filter,
            raise            = true,
            keys             = clientkeys,
            buttons          = clientbuttons,
            screen           = awful.screen.preferred,
            placement        = awful.placement.no_overlap + awful.placement.no_offscreen,
            size_hints_honor = false,
        },
    },
    {
        rule_any = {
            instance = {
                "DTA",
                "copyq",
            },
            class = {
                "Arandr",
                "Gpick",
                "Kruler",
                "MessageWin",
                "Sxiv",
                "Wpa_gui",
                "pinentry",
                "veromix",
                "xtightvncviewer",
            },
            name = {
                "Event Tester",
            },
            role = {
                "AlarmWindow",
                "pop-up",
            },
        },
        properties = {
            floating = true,
        },
    },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2", }, },
},
    map(function(g)
        return awful.util.table.join(g, { properties = { screen = 1, tag = g.ws } })
    end, filter(function(g)
        return g.ws ~= nil
    end, wingroups.groups)))
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
        not c.size_hints.user_position and
        not c.size_hints.program_position then

        awful.placement.no_offscreen(c)
    end

    if c.floating then
        c.border_width = beautiful.border_width
    end
end)

client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end))

    awful.titlebar(c):setup {
        layout = wibox.layout.align.horizontal,
        {
            layout  = wibox.layout.fixed.horizontal,
            buttons = buttons,
            awful.titlebar.widget.iconwidget(c),
        },
        {
            layout  = wibox.layout.flex.horizontal,
            buttons = buttons,
            {
                widget = awful.titlebar.widget.titlewidget(c),
                align  = "center",
            },
        },
        {
            layout = wibox.layout.fixed.horizontal,
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
        },
    }
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

local function refresh_border_width(c)
    local tag = c.screen.selected_tag
    if (c.floating or tag and tag.layout ~= awful.layout.suit.max) and not c.maximized then
        c.border_width = beautiful.border_width
    else
        c.border_width = 0
    end
end

client.connect_signal("property::screen", refresh_border_width)
client.connect_signal("property::floating", refresh_border_width)
client.connect_signal("property::maximized", refresh_border_width)

tag.connect_signal("property::layout", function(t)
    for _, c in ipairs(t:clients()) do
        refresh_border_width(c)
    end
end)
tag.connect_signal("property::selected", function(t)
    for _, c in ipairs(t:clients()) do
        refresh_border_width(c)
    end
end)
-- }}}
