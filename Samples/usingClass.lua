--[[ class model ]]--

----------------------------------------
--[[ description:
  -- Проверка class-модели.
  -- Checking class model.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Samples.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local typUtils = require "Rh_Scripts.Utils.typUtils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local class = typUtils.class

local myClass = class:new(12, 45)
myClass.i = 1
myClass.s = "text"
myClass.value = 64

function myClass:init (initvar)
  self.initvar = initvar or 8
end ----

function myClass:setvalue (v)
  self.value = v
end

--logShow(myClass, "myClass", 0)

assert(myClass[1] == 12)
assert(myClass[2] == 45)
assert(myClass.i == 1)
assert(myClass.s == "text")
assert(myClass.value == 64)

local myObj = myClass:new(10)

--logShow(myObj, "myObj", 1)

assert(myObj.initvar == 10)

myObj:setvalue(128)

--logShow(myObj, "myObj", 1)

assert(myObj.value == 128)

far.Message("It's OK !", "Class model")

--------------------------------------------------------------------------------
