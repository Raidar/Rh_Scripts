--[[ LUM for Dialog ]]--

----------------------------------------
--[[ description:
  -- LUM for Viewer.
  -- LUM для просмотра.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils, LUM.
  -- areas: editor.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local logShow = context.ShowInfo

--local getFileType = context.detect.area.dialog

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

--------------------------------------------------------------------------------
local function LuaUserMenu (args)

  -- 1. Определение "охвата" меню.
    -- Базовое меню для главного меню.
  local BaseName = args[1]
  local Scope = { BaseName = BaseName, args = args }

  if not BaseName or BaseName ~= "Config" then
    -- Получение информации о файле в редакторе.
    Scope.FileName = "" --dialog.GetInfo().FileName
    Scope.FileType = "none" --getFileType()
    -- Функция вставки шаблона для редактора.
    Scope.InsertText = farUt.FarInsertText.dialog

  end -- if

  -- 2. Вызов пользовательского меню.
  --local LUM = require "Rh_Scripts.LuaUM.LUM"
  local LUM = farUt.urequire "Rh_Scripts.LuaUM.LUM"
  local Config = require "Rh_Scripts.LuaDUM.LuaDUMer"
  Config.Scope = Scope

  return LUM(Config)

end ---- LuaUserMenu

--return LuaUserMenu(...)
return farUt.usercall(nil, LuaUserMenu, ...)
--------------------------------------------------------------------------------
