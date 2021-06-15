local robot = require("robot")

while robot.count(1) > 0 do
  robot.place()
  robot.swing()
end
