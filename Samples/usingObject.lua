--[[ object model ]]--

----------------------------------------
--[[ description:
  -- Проверка object-модели.
  -- Checking object model.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Samples.
--]]
--------------------------------------------------------------------------------
local _G = _G

local typUtils = require "Rh_Scripts.Utils.typUtils"

----------------------------------------
local linMsg = (require "Rh_Scripts.Utils.Logging").lineMessage

--------------------------------------------------------------------------------
local object = typUtils.object

local myObj = object:new(12, 45)
myObj.i = 1
myObj.s = "text"
myObj.value = 64

function myObj:setvalue (v)
  self.value = v
end

linMsg(myObj, "myObj", 0)

assert(myObj[1] == 12)
assert(myObj[2] == 45)
assert(myObj.i == 1)
assert(myObj.s == "text")
assert(myObj.value == 64)

local myNamedObj = object "NamedObject" (13)

linMsg(myNamedObj, "myNamedObj", 1)

assert(myNamedObj[1] == 13)
assert(myNamedObj[2] == 45)
assert(myNamedObj.i == 1)
assert(myNamedObj.s == "text")
assert(myNamedObj.value == 64)

myNamedObj:setvalue(128)

linMsg(myNamedObj, "myNamedObj", 1)

assert(myNamedObj.value == 128)

far.Message("It's OK !", "Object model")

--------------------------------------------------------------------------------
