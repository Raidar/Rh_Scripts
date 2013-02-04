--[[ LuaUM ]]--

----------------------------------------
--[[ description:
  -- FAR macros operation.
  -- Оперирование макросами FAR.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- used in: LUM.
  -- group: Macros, Utils.
--]]
--------------------------------------------------------------------------------
local far = far

---------------------------------------- main
-- Перезагрузка макросов.
function ReloadLuaFarMacros ()
  return far.MacroLoadAll()
end ----
--[[
-- Сохранение макросов в БД.
function SaveFarMacros ()
  return far.MacroSaveAll()
end ----
--]]
--------------------------------------------------------------------------------
