-- Awesome config (~/.config/awesome/rc.lua)
-- byte @ n-co.de

-- Most of this is fairly self explanatory, using the API. I've stolen
-- code from so many places it's hard to attribute any of it. Someday.
-- Change the variables as you see fit. You probably want to download
-- the theme I use that is provided somewhere near, as it is contains
-- all the icons the widgets use.

-- The only real thing to note is how I achieve the borders between
-- wibox and windows, without specifying a wibox border. I used
-- awful.screen.padding to set a top and bottom gap, but the only way
-- I could think to fill it was by setting the exact pixels of the
-- wallpaper behind it to the appropriate color. The result being that
-- some wallpaper modification is in order to get it looking right.
-- I set the wibox heights as 13 pixels, so at the 14th rox of pixels
-- from the bottom and top, I draw a solid blue border. Border color
-- is #659fdb (I'm consistent with colors), and it's not hard to do by
-- cracking open GIMP.

-- Oh, I make use of the yeganesh wrapper for dmenu, to provide a
-- launcher similar to what dwm recommends. The code is trivial and
-- can be found at n-co.de, somewhere. The arguments keep it looking
-- pretty.

require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("vicious")
--require("shifty")

-- {{{ Variables
-- Theme: 
beautiful.init(awful.util.getdir("config") .. "/theme/theme.lua")

local terminal = "urxvtc"
local editor = "vim"
local editor_cmd = terminal .. " -e " .. editor
local web_browser = "chromium"
local file_browser = "thunar"
local spawn_yeganesh = "dmenu_run"  ..
                       " -fn '".. beautiful.font_alt .. "'"  ..
                       " -nb '".. beautiful.bg_normal.. "'"  ..
                       " -nf '".. beautiful.fg_normal.. "'"  ..
                       " -sb '".. beautiful.bg_focus .. "'"  ..
                       " -sf '".. beautiful.fg_focus .. "'"

-- Keys:
local altkey = "Mod1"
local modkey = "Mod4"

layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Tags
tags = { names = { "main", "web", "misc " },
         layout = { layouts[1], layouts[1], layouts[2], layouts[1], layouts[3] } }

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- }}}

-- {{{ Widgets

-- Containers
topbar = {}
bottombar = {}

-- Generic widgets
clock = awful.widget.textclock({align = "right"}, "%a %b %d, %I:%M %p")
mysystray = widget({ type = "systray" })
seperator = widget({ type = "textbox" })
seperator.text = " | "
spacer = widget({ type = "textbox" })
spacer.width = 6

-- Set all the icons needed
-- For some reason, type "imagebox" inflates the images and seems
-- to offer no way to resize them down. So a textbox is set with
-- a background image to do the job right.

cpuicon = widget ({ type = "textbox" })
cpuicon.bg_image = image(beautiful.widget_cpu)
cpuicon.bg_align = "middle"
cpuicon.width = 8
tempicon = widget ({ type = "textbox" })
tempicon.bg_image = image(beautiful.widget_temp)
tempicon.bg_align = "middle"
tempicon.width = 8
memicon = widget ({ type = "textbox" })
memicon.bg_image = image(beautiful.widget_mem)
memicon.bg_align = "middle"
memicon.width = 8
netdownicon = widget ({ type = "textbox" })
netdownicon.bg_image = image(beautiful.widget_netdown)
netdownicon.bg_align = "middle"
netdownicon.width = 8
netupicon = widget ({ type = "textbox" })
netupicon.bg_image = image(beautiful.widget_netup)
netupicon.bg_align = "middle"
netupicon.width = 8
mailicon = widget ({ type = "textbox" })
mailicon.bg_image = image(beautiful.widget_mail)
mailicon.bg_align = "middle"
mailicon.width = 8
clockicon = widget ({ type = "textbox" })
clockicon.bg_image = image(beautiful.widget_clock)
clockicon.bg_align = "middle"
clockicon.width = 8
mpdicon = widget ({ type = "textbox" })
mpdicon.bg_align = "middle"

-- Create some widgets...
cpuinfo = widget ({ type = "textbox" })
cputemp = widget ({ type = "textbox" })
meminfo = widget ({ type = "textbox" })
netdowninfo = widget ({ type = "textbox" })
netupinfo = widget ({ type = "textbox" })
mailinfo = widget ({ type = "textbox" })
mpdinfo = widget ({ type = "textbox" })

-- ... And register them
vicious.register(cpuinfo, vicious.widgets.cpu, "$1% / $2% / $3% / $4%")
vicious.register(cputemp, vicious.widgets.thermal, "$1 C", 19, "thermal_zone0")
vicious.cache(vicious.widgets.mem)
vicious.register(meminfo, vicious.widgets.mem, "$1% ($2Mb)", 5)
vicious.cache(vicious.widgets.net)
vicious.register(netdowninfo, vicious.widgets.net, "${eth0 down_kb}", 
3)
vicious.register(netupinfo, vicious.widgets.net, "${eth0 up_kb}", 3)
vicious.register(mailinfo, vicious.widgets.gmail,
  function (widget, args)
    if args["{count}"] == 0 then
      mailicon.bg_image = image(beautiful.widget_mail)
      return 0
    else
      mailicon.bg_image = image(beautiful.widget_newmail)
      return args["{count}"]
    end
  end, 61)

-- MPD widget. Hides icon and text when nothing is playing.
vicious.register(mpdinfo, vicious.widgets.mpd,
  function (widget, args)
    if args["{state}"] == "Stop" then
      mpdicon.bg_image = nil
      mpdicon.width = 0 
      return ""
    else
      mpdicon.bg_image = image(beautiful.widget_mpd)
      mpdicon.width = 8
      return "MPD: " .. args["{Artist}"] .. ' - ' .. args["{Title}"]
    end
  end)
  

-- Create a wibox for each screen and add it
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Set a screen margin, for borders
    awful.screen.padding( screen[s], {top = 1, bottom = 1} )

    -- Create the layout box, taglist, and tasklist widgets
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist( function(c)
                      local text, bg, status_image, icon = awful.widget.tasklist.label.currenttags(c,s)
                      return text, bg, status_image, nil
                      end, mytasklist.buttons)

    -- Create the bars
    topbar[s] = awful.wibox({
                position = "top", screen = s, height = 13,
                fg = beautiful.fg_normal, bg = beautiful.bg_normal,
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
    })
    bottombar[s] = awful.wibox({
                position = "bottom", screen = s, height = 13,
                fg = beautiful.fg_normal, bg = beautiful.bg_normal,
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal
    })

    -- Fill the bars with widgets
    right_aligned = { layout = awful.widget.layout.horizontal.rightleft}
    if s == 1 then table.insert(right_aligned, mysystray) end
    table.insert(right_aligned, mylayoutbox[s])
    topbar[s].widgets = {
        mytaglist[s],
        { mylayoutbox[s], spacer, mysystray,
          layout = awful.widget.layout.horizontal.rightleft
        },
	mytasklist[s],
        layout = awful.widget.layout.horizontal.leftright,
        height = 13
    }
    bottombar[s].widgets = { 
      { spacer, mpdicon, spacer, mpdinfo,
        layout = awful.widget.layout.horizontal.leftright
      },
      spacer, clock, spacer, clockicon, seperator, mailinfo, spacer,
      mailicon, seperator, netupinfo, spacer, netupicon, spacer, netdowninfo,
      spacer, netdownicon, seperator, meminfo, spacer, memicon,
      seperator, cputemp, spacer, tempicon, seperator, cpuinfo, spacer, cpuicon,
      layout = awful.widget.layout.horizontal.rightleft,
      height = 13
   }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function() end ),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Program shortcuts
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "p", function () awful.util.spawn_with_shell(spawn_yeganesh) end),
    awful.key({ modkey,           }, "q", function () awful.util.spawn(file_browser) end),
    awful.key({ modkey,           }, "w", function () awful.util.spawn(web_browser) end),
    
    -- Layout presets (dwm-style)
    awful.key({ modkey,           }, "f", function () awful.layout.set( awful.layout.suit.floating ) end),
    awful.key({ modkey,           }, "t", function () awful.layout.set( awful.layout.suit.tile     ) end),
    awful.key({ modkey,           }, "m", function () awful.layout.set( awful.layout.suit.max ) end),
    awful.key({ modkey, "Shift"   }, "m", function () awful.layout.set( awful.layout.suit.max.fullscreen ) end),

    -- Moving between layouts
    awful.key({ modkey,           }, "Up",  function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey,           }, "Down", function () awful.layout.inc(layouts,  1) end),

    -- Music (MPC) controls
    awful.key({ altkey, "Shift"   }, "Up", function () awful.util.spawn_with_shell("mpc volume +5") end),
    awful.key({ altkey, "Shift"   }, "Down", function () awful.util.spawn_with_shell("mpc volume -5") end),
    awful.key({ altkey, "Shift"   }, "Left", function () awful.util.spawn_with_shell("mpc prev") end),
    awful.key({ altkey, "Shift"   }, "Right", function () awful.util.spawn_with_shell("mpc next") end),

    -- Standard keys
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit   ),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Lua Prompt
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey, "Shift"   }, "u",      function (c) c.urgent = not c.urgent          end),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true, size_hints_honor = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- Only float windows have a border
for s = 1, screen.count() do screen[s]:add_signal("arrange", function ()
  local clients = awful.client.visible(s)
  local layout = awful.layout.getname(awful.layout.get(s))
  if #clients > 0 then
    for _, c in pairs(clients) do
      if awful.client.floating.get(c) or layout == "floating" then
        c.border_width = beautiful.floating_border_width
        c.border_color = beautiful.border_color
        c.above = true
      else
        c.border_width = 0
      end
    end
  end
end)
end
  
-- }}}
