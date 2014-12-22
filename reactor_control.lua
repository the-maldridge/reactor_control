local screen =  peripheral.wrap('top')
local reactor = peripheral.wrap('BigReactors-Reactor_1')
local energy_max = 10000000
local color = false

screen.setTextScale(0.5)
local sx, sy = screen.getSize()

-- I'm not sure how the wrap works, so I'm going to close over the metatable access
local statistics = {
   {
      fmt = 'Online | %s',
      f = function()
	     if color then
		if reactor.getActive() then
		   return tostring(colors.green + "ONLINE")
		else
		   return tostring(colors.red + "OFFLINE")
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

local function redraw()
   screen.clear()
   screen.setCursorPos(1, 1)

   for i, stat in ipairs(statistics) do
      screen.setCursorPos(math.floor(sx / 2) - stat.fmt:find('|'), i + 1)
      screen.write(string.format(stat.fmt, stat.f()))
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
