--[[ LUM for Editor ]]--

----------------------------------------
--[[ description:
  -- LUM for Editor.
  -- LUM для редактора.
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

local getFileType = context.detect.area.editor

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
    local Info = editor.GetInfo()
    if not Info then return end

    Scope.FileName = Info.FileName
    Scope.FileType = getFileType()
    -- Функция вставки шаблона для редактора.
    Scope.InsertText = farUt.FarInsertText.editor
  end -- if

  -- 2. Вызов пользовательского меню.
  --local LUM = require "Rh_Scripts.LuaUM.LUM"
  local LUM = farUt.urequire "Rh_Scripts.LuaUM.LUM"
  local Config = require "Rh_Scripts.LuaEUM.LuaEUMer"
  Config.Scope = Scope
  return LUM(Config)
end ---- LuaUserMenu

--return LuaUserMenu(...)
return farUt.usercall(nil, LuaUserMenu, ...)
--------------------------------------------------------------------------------
