MINV = -5
MAXV = 10

public{truev  = 5}:range(MINV, MAXV)
public{falsev = 0}:range(MINV, MAXV)

public{window_center = 0}:range(MINV, MAXV):type('slider')
public{window_width  = 1}:range(0.1, MAXV):type('slider')
public{input_voltage = 0}:range(MINV, MAXV):type('slider')
public{comp = 'inside'}:options{'above', 'inside', 'below'}

-- comp = nil
pcomp = nil

function init()
   input[1].mode('stream', 1/100) --, 1/100)
   input[1].stream = function(v)
      public.window_center = v
   end
   input[2].mode('stream', 1/100) --, 1/100)
   input[2].stream = window_compare
end

function window_compare(v)
   public.input_voltage = v
   if public.input_voltage < public.window_center - public.window_width/2 then
      public.comp = 'below'
   elseif public.input_voltage > public.window_center + public.window_width/2 then
      public.comp = 'above'
   else
      public.comp = 'inside'
   end
   update_outputs()
   pcomp = comp
end

function update_outputs()
   -- print("comparing "..public.input_voltage.." vs "..public.window_center)
   if public.comp == 'above' then
      output[1].volts = public.truev
      output[2].volts = public.falsev
      output[3].volts = public.truev
      output[4].volts = public.falsev
   elseif public.comp == 'inside' then
      output[1].volts = public.falsev
      output[2].volts = public.truev
      output[3].volts = public.falsev
      output[4].volts = public.falsev
   elseif public.comp == 'below' then
      output[1].volts = public.falsev
      output[2].volts = public.falsev
      output[3].volts = public.truev
      output[4].volts = public.truev
   end
end
