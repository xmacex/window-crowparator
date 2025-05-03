---window crowparator         ↑
--                           width
-- → 1 window center
-- → 2 input
--   1 above   →
--   2 inside   →
--   3 outside →   true    false
--   4 below   →      ↓        ↓
--
-- @xmacex

DEBUG = false

-- crow voltage range
local MINV = -5
local MAXV = 10

-- screen constants
screen.HEIGHT = 64 -- naughty or nice?
screen.WIDTH  = 128
YSCALE  = screen.HEIGHT / (MAXV - MINV)
YZEROV  = screen.HEIGHT / (MAXV/(MAXV-MINV) * YSCALE)

local ui_clock = nil

function log(s)
   if DEBUG then print(s) end
end

--- Initialization

function init()
   istanbul        = screen.load_png(paths.this.lib..'windows-istanbul-128x64.png')
   istanbul_nocrow = screen.load_png(paths.this.lib..'windows-istanbul-128x64-muted.png')

   init_params()

   -- wait for crow
   function norns.crow.public.discovered()
      ui_clock = clock.run(redraw_loop)
   end

   function norns.crow.add()
      init_crow()
   end

   -- if crow is already connected, los geht's!
   if norns.crow.connected() then
      init_crow()
   end

end

function init_params()
   params:add_taper('window_width', "window width", 0.1, 15, 2.5, 1, "v")
   params:set_action('window_width', function(v) crow.public.win_wid = v end)

   params:add_taper('crow_true', "true", -5, 10, 5.0, 1, "v")
   params:set_action('crow_true', function(v) crow.public.truev = v end)

   params:add_taper('crow_false', "false", -5, 10, 0.0, 1, "v")
   params:set_action('crow_false', function(v) crow.public.falsev = v end)
end

function init_crow()
   norns.crow.loadscript('window-crowparator.lua')
end

--- norns UI/screen

function redraw_loop()
   while true do
      -- redraw()
      redraw()
      clock.sleep(1/30)
   end
end

-- function redraw()
function redraw()
   screen.clear()
   if norns.crow.connected() then
      draw_windows()
      draw_window()
      draw_input()
   else
      if ui_clock then
	 ui_clock = clock.cancel(ui_clock)
      end
      draw_windows()
      draw_no_crow_message()
   end
   screen.update()
end

function draw_windows()
   if norns.crow.connected() then
      screen.display_image(istanbul, 0, 0)
   else
      screen.display_image(istanbul_nocrow, 0, 0)
   end
end

function draw_window()
   screen.level(0)
   screen.rect(screen.WIDTH/2 - 15,
	       screen.HEIGHT - YZEROV - (crow.public.win_cen+params:get('window_width')/2)*YSCALE,
	       30,
	       math.max(params:get('window_width')*YSCALE, 1))
   screen.fill()
end

function draw_input()
   local y = screen.HEIGHT-YZEROV-(crow.public.signal*YSCALE)
   -- draw_voltage(y)
   screen.level(16)
   if crow.public.comp == 'inside' then
      -- TODO screen:blend_mode could be fun here
      if params:get('crow_true') < 0 then
	 screen.blend_mode('xor')
      end -- blend_mode resets on its own, right?
      screen.circle(screen.WIDTH/2, y, math.max(math.abs(params:get('crow_true')), 1/3)*3)
      screen.fill()
   else
      if params:get('crow_false') < 0 then
	 screen.blend_mode('xor')
      end
      screen.circle(screen.WIDTH/2, y, math.max(math.abs(params:get('crow_false')), 1/3)*3)
      screen.stroke()
   end
end

function draw_voltage(y)
   screen.move(0, y)
   screen.level(10)
   screen.text(util.round(crow.public.signal, 0.1), 0, y)
   screen.stroke()
end

function draw_no_crow_message()
   local MSG = "connect crow"
   screen.move(screen.WIDTH/2, screen.HEIGHT/2+20/2)
   screen.font_face(4)
   screen.font_size(20)
   screen.text_center(MSG, 0, 0)
   screen.stroke()
end

--- norns UI/input

function enc(n, d)
   if n == 1 then
      params:delta('window_width', d)
   elseif n == 2 then
      params:delta('crow_true', d)
   elseif n == 3 then
      params:delta('crow_false', d)
   end
end
