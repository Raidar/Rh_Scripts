--[[ LUM ]]--

----------------------------------------
--[[ description:
  -- LUM menu — Lua User Menu.
  -- Меню LUM — Пользовательское меню Lua.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context, Rh Utils.
  -- group: Menus, LUM.
--]]
--------------------------------------------------------------------------------

--local pairs, ipairs = pairs, ipairs
--local tostring = tostring
local require = require
local setmetatable = setmetatable

----------------------------------------
local context = context
local logShow = context.ShowInfo

local asBindsType = context.detect.use.configType

local utils = require 'context.utils.useUtils'
--local tables = require 'context.utils.useTables'
--local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local PluginPath = utils.PluginPath

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

local LW = require "Rh_Scripts.LuaUM.LumWork"

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Internal
--local Nameless = datas.Nameless -- Name for section/key without name

-- Формат сообщения об ошибке:
local KindErrors = {
  LuaMacro = "LuaMacro_Error",
  Plain    = "PlainText_Error",
  Macro    = "MacroText_Error",
  Script   = "LuaScript_Error",
  --Function = "Function_Error",
  Command  = "Command_Error",
  Program  = "Program_Error",
  CmdLine  = "CmdLine_Error",
  Unknown  = "UAction_Error",
} --- KindErrors

----------------------------------------
local bndUt = require "Rh_Scripts.Utils.Binding"

-- "Охват" по умолчанию.
local DefScope = {
  FileName = "",
  FirstLine = false,
  ForceLine = false,
  --InsertText = nil,
  BindFileType = bndUt.BindFileType,
  --BindCfg = nil,
  Area = "", -- Неизвестная область
  MenuView = "far.Menu", -- Вид меню
  --MenuView = "RectMenu",
} --- DefScope

---------------------------------------- Menu class
local TMenu = {
  Guid = win.Uuid("00b06fba-0bb7-4333-8025-ba48b6077435"),
}
local MMenu = { __index = TMenu }

local function CreateMenu (Config)

  -- Конфигурация LUM:
  local Config = Config or {}
  if not Config.__index then -- Загрузка конфигурации по умолчанию:
    Config.__index = (require "Rh_Scripts.LuaUM.LumCfg").GetDefConfig()
    setmetatable(Config, Config)
  end
  Config.Id = Config.Id or TMenu.Guid

  -- "Охват" LUM (область действия):
  local Scope = Config.Scope or {}; Config.Scope = Scope
  setmetatable(Scope, { __index = DefScope })
  Scope.Area = farUt.GetAreaType() -- Текущая область / Тип файла:
  Scope.FileType = Scope.FileType or Scope.BindFileType(Scope)

  local self = {
    Config    = Config,
    DefConfig = Config.__index,
    Scope     = Scope,
    DefScope  = DefScope,
  } --- self

  return setmetatable(self, MMenu)
end -- CreateMenu

---------------------------------------- Menu locale
-- Локализация меню.
function TMenu:Localize ()
  local Config, Scope = self.Config, self.Scope

  -- Сообщения: текущей конфигурации + по умолчанию:
  -- TODO: Выделить из LUM в CustomMenu его сообщения!
  Scope.LocData = locale.getDual(Config.Custom, self.DefConfig.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  -- CHECK!! as in LumCfg.lua
  --[[
  if not Scope.LocData then
    return nil, e1, e2
  end
  --]]

  local L = locale.make(Config.Custom, Scope.LocData,
                        Config.CfgData.UMenu.ShowErrorMsgs)
  Scope.Locale = L
  --[[
  do
    local LocData = L.Data
    --local LocData = Scope.LocData
    local DefData = LocData.__index
    local GenData = (DefData or tables.Null).__index
    logShow({ LocData = Scope.LocData,
              DefData = DefData,
              GenData = GenData,
              GdfData = (GenData or tables.Null).__index,
            }, "All LocData", "d1 tfn")
  end
  --]]

  -- Часто используемые тексты:
  L.MenuMenu = L:t2("UMenuMenu", "UMenuName") -- Меню
  L.MenuItem = L:t2("UMenuItem", "UMenuName") -- Пункт меню

  return L
end ---- Localize

---------------------------------------- Menu making

---------------------------------------- ---- Prepare
-- Подготовка.
-- Preparing.
function TMenu:Prepare ()

  self:Localize() -- Локализация.

  local Scope = self.Scope
  local L = Scope.Locale

  --[[ Управление настройками ]]--

  -- Определение основных файлов и папок.
  local Cfg_Data = self.Config.CfgData
  --logShow(Cfg_Data, "Cfg_Data", 2)
  local Cfg_Files = Cfg_Data.Files
  local Cfg_Basic = Cfg_Data.Basic

  Scope.HlpLink = self.Config.Custom.help.tlink or
                  self.DefCfg.Custom.help.tlink -- Файл помощи

  --[[ Выбор файла с меню ]]--
  local Args, Props

  -- Считывание привязок типов к меню.
  Args = {
    Base = PluginPath,
    DefExt = ".lua",
    Enum = Cfg_Files.MenusFile,
    Path = Cfg_Files.FilesPath,
    DefEnum = Cfg_Basic.BindsFile,
    DefPath = Cfg_Basic.CfgUMPath,
  } ---
  local BindsData, SError = LW.GetFileEnumData(Args, Props)
  if not BindsData then
    self.Error = L:et2("FileDataError", "BindsFile", SError)
    return
  end
  --logShow(BindsData, "BindsData")

  -- Файл, для которого формируется меню LUM.
  Scope.BindsType = Scope.FileType and
                    Scope.FileType ~= "none" and
                    asBindsType(Scope.FileType, BindsData, '=') or "none"

  -- TODO: Use all features: inherit + Default -- for full Menu, Props etc!!! -|v
  --Make concat order!
  --logShow(BindsData, Scope.FileType)
  --LUM_Binds = GetBindsTypeData(Scope.BindsType, BindsData) --- !?
  local LUM_Binds = BindsData[Scope.BindsType] or {} -- Таблица раздела типа
  --if not LUM_Binds then
  --  self.Error = L:et1("IniSecNotFound", Scope.BindsType, Cfg_Files.MenusFile)
  --  return
  --end
  --if not LUM_Binds.Menu then
  --  self.Error = L:et1("IniKeyNotFound", "Menu", Scope.BindsType, Cfg_Files.MenusFile)
  --  return
  --end
  --logShow(LUM_Binds, "LUM Binds Menu")

  --[[ Формирование меню ]]--

  -- TODO: Сделать как отдельный раздел по умолчанию для меню? свойств и т.д.!!! -|^
  Scope.DefMenu = BindsData.Default or {} -- Раздел по умолчанию
  local isDefault = not LUM_Binds.noDefault -- Использование умолчаний

  -- Перечисление файлов меню:
  local MenuEnum = LUM_Binds.Menu or ""
  if isDefault then -- TODO: Сделать составление меню по наследованию типов!
    MenuEnum = ("%s;%s;%s"):format(
               Scope.DefMenu.Before or "", MenuEnum, Scope.DefMenu.After or "")
  end
  -- Считывание и разбор файлов меню.
  Args = {
    Base = PluginPath,
    DefExt = ".lum",
    Enum = MenuEnum,
    Path = Cfg_Files.MenusPath,
    DefEnum = Cfg_Basic.UMenuFile,
    DefPath = Cfg_Basic.CfgUMPath,
  } ---
  Props = { Join = Scope.JoinUMenu or false, }
  --Props = { Join = Scope.JoinUMenu or false, IlkSep = ';' }
  self.Menus, SError = LW.GetFileEnumData(Args, Props)
  if not self.Menus then
    self.Error = L:et2("FileDataError", "UMenuFile", SError)
    return
  end
  --logShow(self.Menus, "self.Menus", 0)

  -- Разбор общих свойств меню.
  -- TEMP: TODO see above!!!
  self.Props = LUM_Binds.Properties or Scope.DefMenu.Properties or {}
  self.Props.Id = self.Props.Id or self.Config.Id
  if not self.Props.MenuView then
    self.Props.MenuView = Scope.MenuView
  end
  --logShow(self.Props, "Properties", 2)

  return true
end -- Prepare

---------------------------------------- ---- Show

---------------------------------------- ---- Run
local UMenu = require "Rh_Scripts.Common.CustomMenu"

function TMenu:Run ()

  local Cfg_Data = self.Config.CfgData

  local isOk, SError, ActItem = UMenu(self.Props, self.Menus, self.Config)

  --logShow({ isOk, SError }, ActItem.Kind)
  -- TODO: В CustomMenu.lua!?
  if isOk == nil and Cfg_Data.UMenu.ShowErrorMsgs then
    local L = self.Scope.Locale
    if ActItem then
      return L:et1(KindErrors[ActItem.Kind] or KindErrors.Unknown,
                   L.MenuItem, ActItem.Name, SError or "")
    else
      return L:error(SError)
    end
  end

  return isOk, SError
end ---- Run

---------------------------------------- main

function unit.Execute (Config, ShowMenu)
  local _Menu = CreateMenu(Config)
  if not _Menu then return end

  _Menu:Prepare()
  if _Menu.Error then return nil, _Menu.Error end

  if ShowMenu == 'self' then return _Menu end
  --logShow(Properties.Flags, "Flags")

  return _Menu:Run()
end ---- Execute

--------------------------------------------------------------------------------
return unit.Execute
--------------------------------------------------------------------------------
