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

local asBindsType = context.detect.use.configType

local utils = require 'context.utils.useUtils'
--local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local PluginPath = utils.PluginPath

----------------------------------------
local farUt = require "Rh_Scripts.Utils.farUtils"
local bndUt = require "Rh_Scripts.Utils.Binding"
local rhals = require "Rh_Scripts.Utils.FarMacEx"

local LW = require "Rh_Scripts.LuaUM.LumWork"

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Internal
local Nameless = datas.Nameless -- Name for section/key without name

-- Формат сообщения об ошибке:
local KindErrors = {
  FarSeq   = "FarSeq_Error",
  Plain    = "Plains_Error",
  Macro    = "Macros_Error",
  Script   = "Script_Error",
  --Function = "LuaFuncError",
  Command  = "OS_ExecError",
  Program  = "ProgramError",
  CmdLine  = "CmdLineError",
  Unknown  = "UActionError",
} --- KindErrors

----------------------------------------
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
local TMenu = {}
local MMenu = { __index = TMenu }

-- Создание объекта класса меню.
local function CreateMenu (Config)

  -- Конфигурация LUM:
  local Config = Config or {}
  if not Config.__index then -- Загрузка конфигурации по умолчанию:
    Config.__index = (require "Rh_Scripts.LuaUM.LumCfg").GetDefConfig()
    setmetatable(Config, Config)
  end

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

---------------------------------------- Menu control
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
function TMenu:Run ()

--[[ 1. Конфигурирование меню ]]
  local Scope  = self.Scope
  local Config = self.Config
  local DefCfg = self.DefConfig

--[[ 1.1. Управление настройками ]]

  -- Определение основных файлов и папок.
  local Cfg_Data = Config.CfgData
  --logShow(Cfg_Data, "Cfg_Data", 2)
  local Cfg_Files = Cfg_Data.Files
  local Cfg_Basic = Cfg_Data.Basic

  local L = self:Localize() -- Локализация.

  Scope.HlpLink = Config.Custom.help.tlink or
                  DefCfg.Custom.help.tlink -- Файл помощи

--[[ 1.2. Выбор файла с меню ]]
  local Args, Props

  -- Считывание привязок типов к меню.
  Args = { Base = PluginPath,
           DefExt = ".lui",
           Enum = Cfg_Files.MenusFile,
           Path = Cfg_Files.FilesPath,
           DefEnum = Cfg_Basic.BindsFile,
           DefPath = Cfg_Basic.CfgUMPath }
  --Props = { IlkSep = ';' }
  local BindsData, SError = LW.GetFileEnumData(Args, Props)
  if not BindsData then
    return L:et2("FileDataError", "BindsFile", SError)
  end
  --logShow(BindsData, "BindsData")

  -- Файл, для которого формируется меню LUM.
  --logShow(Scope.FileType, "BindsType")
  --logShow(asBindsType(Scope.FileType, BindsData, '='), Scope.FileType)
  Scope.BindsType = Scope.FileType and
                    Scope.FileType ~= "none" and
                    asBindsType(Scope.FileType, BindsData, '=') or
                    Scope.FileType or "none"

  -- TODO: Use all features: inherit + Default -- for full Menu, Aliases, Props etc!!! -|v
  --Make concat order!
  --logShow(BindsData, Scope.FileType)
  --LUM_Binds = GetBindsTypeData(Scope.BindsType, BindsData) --- !?
  local LUM_Binds = BindsData[Scope.BindsType] or {} -- Таблица раздела типа
  --if not LUM_Binds then
  --  return L:et1("IniSecNotFound", Scope.BindsType, Cfg_Files.MenusFile)
  --end
  --if not LUM_Binds.Menu then
  --  return L:et1("IniKeyNotFound", "Menu", Scope.BindsType, Cfg_Files.MenusFile)
  --end
  --logShow(LUM_Binds, "LUM Binds Menu")

--[[ 1.3. Формирование меню ]]

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
  Args = { Base = PluginPath,
           DefExt = ".lum",
           Enum = MenuEnum,
           Path = Cfg_Files.MenusPath,
           DefEnum = Cfg_Basic.UMenuFile,
           DefPath = Cfg_Basic.CfgUMPath }
  Props = { Join = Scope.JoinUMenu or false }
  --Props = { Join = Scope.JoinUMenu or false, IlkSep = ';' }
  self.Menus, SError = LW.GetFileEnumData(Args, Props)
  if not self.Menus then
    return L:et2("FileDataError", "UMenuFile", SError)
  end
  --logShow(self.Menus, "self.Menus", 0)

  -- Перечисление файлов псевдонимов:
  local AliasEnum = LUM_Binds.Alias or ""
  if isDefault and Scope.DefMenu.Alias then
    AliasEnum = ("%s;%s"):format(AliasEnum, Scope.DefMenu.Alias)
  end
  -- Считывание и разбор файлов псевдонимов.
  local AliasData
  Args = { Base = PluginPath,
           DefExt = ".lui",
           Enum = AliasEnum,
           Path = Cfg_Files.FilesPath,
           DefEnum = Cfg_Basic.AliasFile,
           DefPath = Cfg_Basic.CfgUMPath }
  AliasData, SError = LW.GetFileEnumData(Args)
  if not AliasData then
    return L:et2("FileDataError", "AliasFile", SError)
  end
  --logShow(AliasData, "AliasData")

  local AliasPart -- Раздел с псевдонимами
  if AliasData.Aliases then AliasPart = "Aliases"
  elseif AliasData[Nameless] then AliasPart = Nameless
  else
    return L:et1("AliasNotFound", Scope.FileName)
  end

  -- TODO: Aliases to Properties for CustomMenu.
  self.Aliases = AliasData[AliasPart] or {} -- Таблица раздела псевдонимов
  AliasData, AliasPart = nil, nil -- (?)

  rhals.UnQuoteRegTable(self.Aliases) -- Раскавычивание псевдонимов
  --extUt.t_gsub(self.Aliases, nil, '\n', ' ') -- Сборка в одну строку
  rhals.SpecifyAliasesItself(self.Aliases) -- Конкретизация псевдонимов
  --logShow(self.Aliases, "LUM Alias Menu")

  -- Разбор общих свойств меню.
  -- TEMP: TODO see above!!!
  self.Props = LUM_Binds.Properties or Scope.DefMenu.Properties or {}
  if not self.Props.MenuView then self.Props.MenuView = Scope.MenuView end
  self.Props.FarMacroAliases = self.Aliases
  --logShow(self.Props, "Properties", 2)

  BindsData, LUM_Binds = nil, nil -- (?)

--[[ 2. Управление меню ]]-- TODO: В CustomMenu.lua!!

  local UMenu = require "Rh_Scripts.Common.CustomMenu"

  local isOk, SError, ActItem = UMenu(self.Props, self.Menus, self.Config)

  --logShow({ isOk, SError }, ActItem.Kind)
  if isOk == nil and Cfg_Data.UMenu.ShowErrorMsgs then
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

function unit.LuaUserMenu (Config)
  local _Menu = CreateMenu(Config)

  return _Menu:Run()
end --

--------------------------------------------------------------------------------
return unit.LuaUserMenu
--------------------------------------------------------------------------------
