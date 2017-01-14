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
-- Загрузка макросов.
function LoadLuaFarMacros ()

  return far.MacroLoadAll()

end ----

-- Сохранение макросов.
function SaveLuaFarMacros ()

  return far.MacroSaveAll()

end ----
--------------------------------------------------------------------------------
