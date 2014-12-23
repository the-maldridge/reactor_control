local screen =  peripheral.wrap('top')
local reactor = peripheral.wrap('BigReactors-Reactor_1')
local energy_max = 10000000

screen.setTextScale(0.5)
local sx, sy = screen.getSize()

-- I'm not sure how the wrap works, so I'm going to close over the metatable access
local statistics = {
   {
      fmt = 'Online | %s',
      f = function()
	     if term.isColor() then
		if reactor.getActive() then
		   return "{green}ONLINE"
		else
		   return "{red}OFFLINE"
		end
	     else
		return tostring(reactor.getActive())
	  end
   },
   {
      fmt = 'Energy Stored | %d RF',
      f = reactor.getEnergyStored
   },
   {
      fmt = 'Energy Produced | %d RF/t',
      f = reactor.getEnergyProducedLastTick
   },
   {
      fmt = 'Fuel Temperature | %d Centigrade',
      f = reactor.getFuelTemperature
   },
   {
      fmt = 'Casing Temperature | %d Centigrade',
      f = reactor.getCasingTemperature
   },
   {
      fmt = 'Fuel Reactivity | %d%%',
      f = reactor.getFuelReactivity
   },
   {
      fmt = 'Fuel Amount | %d mB',
      f = reactor.getFuelAmount
   },
   {
      fmt = 'Waste Amount | %d mB',
      f = reactor.getWasteAmount
   },
   {
      fmt = 'Fuel Consumption | %d mB/t',
      f = reactor.getFuelConsumedLastTick
   }
}

local function color_write(screen, col_table, str)
   assert(col_table.white, 'the color white must exist')
   screen.setTextColor(col_table.white)
   
   while #str > 0 do
      local pos_left, pos_right = str:find('{'), str:find('}')
      
      if pos_left then
	 assert(pos_right and pos_right > pos_left, 'if we find a left bracket we must also find a right bracket')
	 
	 local before = str:sub(1, pos_left - 1)
	 local col = str:sub(pos_left + 1, pos_right - 1)
	 
	 assert(col_table[col], 'col_table must contain the bracketed phrase')
	 
	 screen.write(before)
	 screen.setTextColor(col_table[col])
	 
	 str = str:sub(pos_right + 1)
      else
	 screen.write(str)
	 
	 str = ''
      end
   end
   
   screen.setTextColor(col_table.white)
end

local function redraw()
   screen.clear()
   screen.setCursorPos(1, 1)

   for i, stat in ipairs(statistics) do
      screen.setCursorPos(math.floor(sx / 2) - stat.fmt:find('|'), i + 1)
      if term.isColor() then
	 color_write(screen, colors, string.format(stat.fmt, stat.f()))
      else
	 screen.write(string.format(stat.fmt, stat.f()))
      end
   end 

   screen.setCursorPos(1, sy)
   screen.write('Hold Ctrl+T to terminate...')
end

local function update()
   local energy_curr = reactor.getEnergyStored()
   local energy_frac = energy_curr / energy_max

   local is_online = reactor.getActive()
   reactor.setAllControlRodLevels(100 * energy_frac ^ (1 / 9))

   if energy_frac > 0.8 and is_online then
      reactor.setActive(false)
   elseif energy_frac < 0.5 and not is_online then
      reactor.setActive(true)
   end
end

while true do
   update()
   redraw()
   os.sleep(1)
end
