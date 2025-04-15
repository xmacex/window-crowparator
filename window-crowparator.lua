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

-- state
local window_center = 0
local input_voltage = 0
local comp          = ""
local pcomp         = ""

function log(s)
   if DEBUG then print(s) end
end

--- Initialization

function init()
   init_params()
   init_crow()
   clock.run(redraw_loop)
end

function init_params()
   params:add_taper('window_width', "window width", 0.1, 15, 1.0, 1, "v")
   params:add_taper('crow_true', "true", -5, 10, 5.0, 1, "v")
   params:add_taper('crow_false', "false", -5, 10, 0.0, 1, "v")
end

function init_crow()
   crow.input[1].mode("stream", 1/100)
   crow.input[1].stream = function(v)
      window_center = v
   end

   crow.input[2].mode("stream", 1/100)
   crow.input[2].stream = window_compare
end

--- Running things

function window_compare(v)
   input_voltage = v
   if input_voltage < window_center - params:get('window_width')/2 then
      comp = 'below'
   elseif input_voltage > window_center + params:get('window_width')/2 then
      comp = 'above'
   else
      comp = 'inside'
   end

   if comp ~= pcomp then
      log("changed "..pcomp.." -> "..comp)
      -- update_crow()
   end
   update_crow()
   pcomp = comp
end

function update_crow()
   if comp == "above" then
      crow.output[1].volts = params:get('crow_true')
      crow.output[2].volts = params:get('crow_false')
      crow.output[3].volts = params:get('crow_true')
      crow.output[4].volts = params:get('crow_false')
   elseif comp == "inside" then
      crow.output[1].volts = params:get('crow_false')
      crow.output[2].volts = params:get('crow_true')
      crow.output[3].volts = params:get('crow_false')
      crow.output[4].volts = params:get('crow_false')
   elseif comp == "below" then
      crow.output[1].volts = params:get('crow_false')
      crow.output[2].volts = params:get('crow_false')
      crow.output[3].volts = params:get('crow_true')
      crow.output[4].volts = params:get('crow_true')
   end
end

--- norns UI/screen

function redraw_loop()
   while true do
      redraw()
      clock.sleep(1/30)
   end
end

function redraw()
   screen.clear()
   draw_window()
   draw_reference()
   draw_input()
   screen.update()
end

function draw_reference()
   screen.move(0, screen.HEIGHT - YZEROV)
   screen.level(1)
   screen.line(screen.WIDTH, screen.HEIGHT - YZEROV)
   screen.stroke()
end

function draw_window()
   screen.level(4)
   screen.text(5, 30, "w")
   screen.rect(screen.WIDTH/2 - 30,
	       screen.HEIGHT - YZEROV - (window_center+params:get('window_width')/2)*YSCALE,
	       60,
	       math.max(params:get('window_width')*YSCALE, 1))
   screen.fill()
end

function draw_input()
   local y = screen.HEIGHT-YZEROV-(input_voltage*YSCALE)
   screen.level(10)
   screen.move(0, y)
   screen.text(util.round(input_voltage, 0.1), 0, y)
   screen.stroke()
   screen.circle(screen.WIDTH/2, y, 5)
   if comp == 'inside' then
      screen.fill()
   else
      screen.stroke()
   end
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
