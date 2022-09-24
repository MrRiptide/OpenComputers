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
  robot.select(15)
  component.crafting.craft()
  charge_value = charge_value + 1
end

function chargeGlowstone()
  -- glowstone is stored in slot 13, tome in slot 15
  robot.select(15)
  robot.transferTo(1)
  robot.select(13)
  robot.transferTo(2,1)
  robot.select(15)
  component.crafting.craft()
  charge_value = charge_value + 1
end

function charge()
  print("Starting a recharging cycle, current charge is " .. charge_value)
  local glowstone = component.inventory_controller.getStackInInternalSlot(13).size
  local redstone = component.inventory_controller.getStackInInternalSlot(14).size
  while redstone > 5 and charge_value < 900 do
    chargeRedstone()
    redstone = redstone - 1
  end
  while glowstone > 5 and charge_value < 900 do
    chargeGlowstone()
    glowstone = glowstone - 1
  end
end

function refill()
  local glowstone = component.inventory_controller.getStackInInternalSlot(13).size
  local redstone = component.inventory_controller.getStackInInternalSlot(14).size
  if glowstone < 5 then
    external_glowstone = component.inventory_controller.getStackInSlot(sides.front,2).size
    robot.select(13)
    component.inventory_controller.suckFromSlot(sides.front, 2, math.max(0,external_glowstone - 1 - robot.count()))
  end
  if redstone < 5 then 
    external_redstone = component.inventory_controller.getStackInSlot(sides.front,1).size
    robot.select(14)
    component.inventory_controller.suckFromSlot(sides.front, 1, math.max(0,external_redstone - 1 - robot.count()))
  end
end

function processLoop()
  charge_value = getCharge()
  while (true) do
    if charge_value > 500 then
      -- if less than 5 nether stars
      local nether_stars = component.inventory_controller.getStackInInternalSlot(4).size
      if nether_stars < 5 then
        print("crafting a nether star")
        robot.select(15)
        robot.transferTo(1)
        robot.select(4)
        robot.transferTo(2,1)
        component.crafting.craft()
        charge_value = charge_value - 256
        nether_stars = nether_stars + 1
      end
      if nether_stars > 3 then
        robot.select(4)
        component.inventory_controller.dropIntoSlot(sides.up, 1, nether_stars - 3)
      end
      -- if less than 20 dirt
      local dirt = component.inventory_controller.getStackInInternalSlot(8).size
      if dirt < 20 then
        print("crafting dirt")
        robot.select(15)
        robot.transferTo(1)
        robot.select(8)
        robot.transferTo(2,1)
        component.crafting.craft()
        charge_value = charge_value - 4
        dirt = dirt + 32
      end
      if dirt > 10 then
        robot.select(8)
        component.inventory_controller.dropIntoSlot(sides.up, 2, dirt - 10)
      end
    else
      charge()
      refill()
    end
  end
end

processLoop()
