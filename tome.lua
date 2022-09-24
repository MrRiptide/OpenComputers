local robot = require("robot")
local component = require("component")
local sides = require("sides")

-- storage slots
-- 04 | nether star
-- 08 | dirt
-- 13 | glowstone
-- 14 | redstone
-- 15 | tome
-- 16 | crafting output

function getCharge()
  return 1001 - component.inventory_controller.getStackInInternalSlot(15).damage
end

function chargeRedstone()
  -- redstone is stored in slot 14, tome in slot 15
  robot.select(15)
  robot.transferTo(1)
  robot.select(14)
  robot.transferTo(2,1)
  component.crafting.craft()
  robot.select(16)
  robot.transferTo(15)
end

function chargeGlowstone()
  -- glowstone is stored in slot 13, tome in slot 15
  robot.select(15)
  robot.transferTo(1)
  robot.select(13)
  robot.transferTo(2,1)
  robot.select(15)
  component.crafting.craft()
end

function charge()
  local glowstone = component.inventory_controller.getStackInInternalSlot(13).size
  local redstone = component.inventory_controller.getStackInInternalSlot(14).size
  if redstone > glowstone then
    if redstone > 0 then
      chargeRedstone()
    end
  else
    if glowstone > 0 then
      chargeGlowstone()
    end
  end
end

function refill()
  local glowstone = component.inventory_controller.getStackInInternalSlot(13).size
  local redstone = component.inventory_controller.getStackInInternalSlot(14).size
  if glowstone < 64 then
    local extGlowstone = component.inventory_controller.getStackInSlot(sides.front,2).size
    robot.select(13)
    component.inventory_controller.suckFromSlot(sides.front, 2, math.max(0,extGlowstone - 1 - robot.count()))
  end
  if redstone < 64 then 
    local extRedstone = component.inventory_controller.getStackInSlot(sides.front,1).size
    robot.select(14)
    component.inventory_controller.suckFromSlot(sides.front, 1, math.max(0,extRedstone - 1 - robot.count()))
  end
end

function processLoop()
  local charge = getCharge()
  while (true) do
    if charge > 500 then
      -- if less than 5 nether stars
      local nether_stars = component.inventory_controller.getStackInInternalSlot(4).size
      if nether_stars < 5 then
        robot.select(15)
        robot.transferTo(1)
        robot.select(4)
        robot.transferTo(2,1)
        component.crafting.craft()
        nether_stars = nether_stars + 1
        if nether_stars > 3 then
          component.inventory_controller.dropIntoSlot(sides.up, 1, nether_stars - 3)
        end
      end
      -- if less than 20 dirt
      local dirt = component.inventory_controller.getStackInInternalSlot(8).size
      if dirt < 20 then
        robot.select(15)
        robot.transferTo(1)
        robot.select(8)
        robot.transferTo(2,1)
        component.crafting.craft()
        dirt = dirt + 32
        if dirt > 10 then
          component.inventory_controller.dropIntoSlot(sides.up, 2, dirt - 10)
        end
      end
    else
      charge()
      refill()
    end
  end
end

processLoop()
