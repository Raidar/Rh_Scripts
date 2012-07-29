--[[ LuaEUM ]]--

----------------------------------------
--[[ description:
  -- Edit of date/time shift for subtitles.
  -- Правка сдвига даты/времени для субтитров.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Common, DateTime, Subtitles.
--]]
--------------------------------------------------------------------------------

----------------------------------------
--local context, ctxdata = context, ctxdata

--local types = ctxdata.config.types

local utils = require 'context.utils.useUtils'
--local numbers = require 'context.utils.useNumbers'
--local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

--local n2s = numbers.n2s

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow, datShow = dbg.Show, dbg.ShowData
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- DateTime
local Datim = require "Rh_Scripts.Utils.DateTime"
local newTime = Datim.newTime

---------------------------------------- Config
local PluginPath = utils.PluginPath
local ScriptPath = "scripts\\Rh_Scripts\\LuaUM\\"

-- Конфигурация по умолчанию.
local DefCfgData = {
} --- DefCfgData

---------------------------------------- Locale
local subs = require "Rh_Scripts.LuaUM.scripts.Subtitles"
local subL = subs.Locale -- Данные локализации из subs

local LocData -- Данные локализации
local L -- Класс сообщений локализации

---------------------------------------- Types
-- Типы элементов диалогов:
local DlgTypes = {
} --- DlgTypes

---------------------------------------- Configure
local FileName   = "DateTime"
local ScriptName = "DtmShift"
local ScriptPath = "scripts\\Rh_Scripts\\LuaUM\\scripts\\"

local DefCustom = {
  name = ScriptName,
  path = ScriptPath,

  --label = "DtmSh",
  file = FileName,

  help   = { topic = ScriptName },
  locale = { kind = 'load' },
} --- DefCustom

-- Обработка конфигурации.
local function Configure (ArgData)
  -- 1. Заполнение ArgData.
  local ArgData = addNewData(ArgData, DefCfgData)
  ArgData.Custom = ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(ArgData, "ArgData")
  local Custom = datas.customize(ArgData.Custom, DefCustom)
  -- 2. Заполнение конфигурации.
  local History = nil
  local CfgData = {}
--[[
  local History = datas.newHistory(Custom.history.full)
  local CfgData = History:field(Custom.history.field)
--]]
  -- 3. Дополнение конфигурации.
  setmetatable(CfgData, { __index = ArgData })
  --logShow(CfgData, "CfgData")
  local Config = { -- Конфигурация:
    Custom = Custom, History = History, DlgTypes = DlgTypes,
    CfgData = CfgData, ArgData = ArgData, --DefCfgData = DefCfgData,
  } ---
  locale.customize(Config.Custom) -- Инфо локализации
  --logShow(Config.Custom, "Custom")
--]]
  return Config
end -- Configure

---------------------------------------- Dialog
local farColors = far.Colors

local dialog = require "far2.dialog"
local dlgUt = require "Rh_Scripts.Utils.dlgUtils"

local dlg_NewDialog = dialog.NewDialog

local DI = dlgUt.DlgItemType
local DIF = dlgUt.DlgItemFlag
local ListItems = dlgUt.ListItems

-- Диалог.
local function Dlg (Config) --> (dialog)
end -- Dlg

local ConfigGuid = win.Uuid("") -- TODO: Задать GUID

-- Настройка.
function unit.TimeShiftDlg (Data)
  local Config = Configure(Data)
  local HelpTopic = Config.Custom.help.tlink
  -- Локализация:
  LocData = locale.getData(Config.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not LocData then return end
  L = locale.make(Config.Custom, LocData)
  -- Конфигурация:
  local isSmall = Config.Custom.isSmall
  if isSmall == nil then isSmall = true end
  -- Подготовка:
  Config.DBox = {
    Flags = isSmall and F.FDLG_SMALLDIALOG or nil,
    Width = 0, Height = 0,
  } --
  --DBox.Width  = 2 + 36*2 -- Edge + 2 columns
          -- Edge + (sep+Btns) + group separators and
  --DBox.Height = 2 + 2 + 5*2 + -- group empty lines + group item lines
  if not isSmall then
    DBox.Width, DBox.Height = DBox.Width + 4*2, DBox.Height + 1*2
  end

  -- Настройка:
  local D = Dlg(Config)
  local iDlg = dlgUt.Dialog(ConfigGuid, -1, -1,
                            DBox.Width, DBox.Height, HelpTopic, D, DBox.Flags)
  if D.btnOk and iDlg == D.btnOk.id then
    return true -- TODO: time class or string
  end
end ---- TimeShiftDlg

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
