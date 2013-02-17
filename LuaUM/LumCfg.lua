--[[ LUM ]]--

----------------------------------------
--[[ description:
  -- LUM menu: Settings.
  -- Меню LUM: Настройка.
--]]
----------------------------------------
--[[ uses:
  LuaFAR, history, far2.dialog,
  Rh Utils.
  -- group: LUM.
--]]
--------------------------------------------------------------------------------

local type, assert = type, assert
local pairs, ipairs = pairs, ipairs
local require = require
--local unpack = unpack -- TEST
local setmetatable = setmetatable

----------------------------------------
local bit = bit64
local bshr = bit.rshift

----------------------------------------
local win, far = win, far
local F = far.Flags

----------------------------------------
--local context = context

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'
local colors = require 'context.utils.useColors'

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
local hex8 = dbg.hex8
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.PluginPath = utils.PluginPath
unit.ScriptPath = "scripts\\Rh_Scripts\\LuaUM\\"
unit.HelpTopic = "<"..unit.PluginPath..unit.ScriptPath..">Contents"

---------------------------------------- ---- Custom
local DefCustom = {
  help   = { tlink = unit.HelpTopic, },
  locale = { kind = 'load', },
} --- DefCustom

---------------------------------------- ---- Config
-- Поля истории конфигурации.
local HistoryFields = {
  Basic = true,
  Files = true,
  UMenu = true,
  --Custom = false,
} --- HistoryFields

-- Конфигурация по умолчанию.
local DefCfgData = {
  Basic = { -- Основные параметры:
    LuaUMName = "LuaUM",            -- Краткое имя, общее для доп. файлов утилиты.
    LuaUMPath = unit.ScriptPath,    -- Относит. путь к текущей утилите.
    --LUM_Title = "Lua User Menu"     -- Заголовок для окон диалогов.
    DefUMPath = unit.ScriptPath,    -- Путь к файлам по умолчанию.
    BindsFile = "LumBinds.lua",     -- Название файла привязок к меню (по умолчанию).
    UMenuFile = "U_NoMenu.lum",     -- Название файла с меню LUM (по умолчанию).
    CfgUMPath = unit.ScriptPath.."config\\",  -- Путь к основным файлам (по умолчанию).
  }, -- Basic
  Files = { -- Пути (относительно плагина) и названия файлов:
    FilesPath = unit.ScriptPath.."config\\",  -- Путь к основным файлам.
    MenusFile = "LumBinds.lui",               -- Название файла привязок.
    MenusPath = unit.ScriptPath.."config\\",  -- Путь к файлам с меню.
    LuaScPath = unit.ScriptPath.."scripts\\", -- Путь к Lua-скриптам.
  }, -- Files
  UMenu = { -- Параметры отображения пользовательского меню:
    MenuTitleBind = true, -- Имя типа привязки в заголовке главного меню.
    CompoundTitle = true, -- Составной заголовок меню (с заголовком надменю).
    BottomHotKeys = true, -- Основные горячие клавиши в нижней надписи меню.
    CaptAlignText = true, -- Выравнивание текста пунктов при длинных надписях.
    TextNamedKeys = true, -- Комбинации клавиш пунктов в тексте пункта меню.
    FullNamedKeys = true, -- Полные названия комбинаций клавиш в тексте пункта.
    KeysAlignText = true, -- Выравнивание названий комбо-клавиш по правому краю.
    ShowErrorMsgs = true, -- Показ окна с сообщением при ошибке вызова LUM.
    ReturnToUMenu = false,-- Возврат в текущее меню после выполнения действия.
  }, -- UMenu
} --- DefCfgData

---------------------------------------- ---- Types
-- Типы элементов диалогов:
local DlgTypes = {
  Basic = {
    DefUMPath = "edt",
    BindsFile = "edt",
    UMenuFile = "edt",
    LuaUMPath = "edt",
  }, -- Basic
  Files = {
    FilesPath = "edt",
    MenusFile = "edt",
    MenusPath = "edt",
    LuaScPath = "edt",
  }, -- Files
  UMenu = {
    MenuTitleBind = "chk",
    CompoundTitle = "chk",
    BottomHotKeys = "chk",
    CaptAlignText = "chk",
    TextNamedKeys = "chk",
    FullNamedKeys = "chk",
    KeysAlignText = "chk",
    ShowErrorMsgs = "chk",
    ReturnToUMenu = "chk",
  }, -- UMenu
} --- DlgTypes

---------------------------------------- Configure
local addNewData = tables.extend

-- Обработка конфигурации.
--[[
  -- @params:
  ArgData   - Таблица конфигурации по умолчанию.
  isLumData - Признак базовой таблицы конфигурации.
  -- @return:
  Config - Конфигурация LUM:
    History - Данные из файла конфигурации (история).
    CfgData - Данные текущей таблицы из файла конфигурации.
    ArgData - Данные таблицы со значениями по умолчанию.
--]]
function unit.Configure (ArgData, isDefData) --> (table)
  assert(type(ArgData) == 'table')
  --logShow(ArgData, "ArgData", 2)
  --logShow(getmetatable(ArgData), "ArgData meta", 2)

  local DefB = ArgData.Basic
  local DefConfig = not isDefData and unit.DefConfig or nil
  local DefData = DefConfig and DefConfig.ArgData
  --logShow(DefData, "DefData", 1)
  ArgData.Custom = {
    name = DefB.LuaUMName,
    path = DefB.LuaUMPath,
  }
  --logShow(ArgData, "ArgData")
  local Custom = datas.customize(ArgData.Custom, DefCustom)

  local History = datas.newHistory(Custom.history.full)
  local CfgData = {}
  for k, _ in pairs(HistoryFields) do
    local v = ArgData[k]
    CfgData[k] = History:field(k) -- Чтение текущих значений
    --logShow({ v, CfgData[k], (DefData or {})[k] }, k)
    -- Наследование полей:
    if DefData then -- Глобальная => По умолчанию:
      --setmetatable(v, { __index = DefData[k] }) -- Don't work
      addNewData(v, DefData[k])
    end
    -- По умолчанию => Текущая таблица:
    setmetatable(CfgData[k], { __index = v })
    --addNewData(CfgData[k], ArgData[k])
  end
  --logShow(ArgData, "ArgData")

  -- Конфигурация:
  local Config = {
    Custom = Custom,
    History = History,
    DlgTypes = DlgTypes,
    CfgData = CfgData,
    ArgData = ArgData,
    --DefData = DefData,

    __index = DefConfig,
  } ---

  locale.customize(Config.Custom) -- Инфо локализации
  --logShow(Config, "Config", 2)

  --return Config
  return DefConfig and setmetatable(Config, Config) or Config
end ---- Configure

-- Конфигурация LUM по умолчанию: Объявление + Определение
unit.DefConfig = unit.DefConfig or
                 unit.Configure(DefCfgData, true) -- Обработка

-- LUM по умолчанию.
function unit.GetDefConfig ()
  return unit.DefConfig
end ----

---------------------------------------- Locale
local LocData -- Данные локализации
local L -- Класс сообщений локализации

-- Форматы сообщений:
local CfgLocFmt = {
  caption = "%s : %s",
} --- CfgLocFmt

-- Специальные функции локализации:
local function CfgCapLoc (Index) -- Заголовок окна
  return CfgLocFmt.caption:format(L:t"UMenuName", L:caption(Index))
end

---------------------------------------- Dialog
local farColors = far.Colors

local dialog = require "far2.dialog"
local dlgUt = require "Rh_Scripts.Utils.Dialog"

local dlg_NewDialog = dialog.NewDialog

local DI = dlgUt.DlgItemType
local DIF = dlgUt.DlgItemFlag

----------------------------------------
local Dlg = {}

-- Виды диалогов:
local CfgKinds = { "Basic", "Files", "UMenu" }

function Dlg.Basic (Config, Derived) --> (dialog)
  local I, H, W = 3, 11, 58 -- Indent, Height, Width
  local M = bshr(W, 1) -- Medium -- Width/2
  local Q = bshr(M, 1) -- Quarta -- Width/4
  local T = W - Q -- Tres partes -- Width*3/4

  local D = dlg_NewDialog() -- Форма окна
                       -- 1         2   3    4   5  6  7  8  9  10
                       -- Type     X1  Y1   X2  Y2  L  H  M  F  Data
  D._                = {DI.DBox,    I,  1,   W,  H, 0, 0, 0, 0, CfgCapLoc"Basic"}
  D.txtLuaUMPath     = {DI.Text,  I+2,  2, M-1,  0, 0, 0, 0, 0, L:config"LuaUMPath"}
  D.edtLuaUMPath     = {DI.Edit,  I+2,  3, M-1,  0, 0, 0, 0, DIF.ReadOnly, ""}
  D.txtLuaUMName     = {DI.Text,  M+1,  2, W-2,  0, 0, 0, 0, 0, L:config"LuaUMName"}
  D.edtLuaUMName     = {DI.Edit,  M+1,  3,   T,  0, 0, 0, 0, DIF.ReadOnly, ""}
  D.txtLuaUMHint     = {DI.Text,  T+1,  3, W-2,  0, 0, 0, 0, 0, L:config"LuaUMHint"}
  D.sepDefault       = {DI.Text,    0,  4,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"Default"}
  D.txtDefUMPath     = {DI.Text,  I+2,  5, M-1,  0, 0, 0, 0, 0, L:config"DefUMPath"}
  D.edtDefUMPath     = {DI.Edit,  I+2,  6, M-1,  0, 0, 0, 0, DIF.ReadOnly, ""}
  D.txtUMenuFile     = {DI.Text,  M+1,  5, W-2,  0, 0, 0, 0, 0, L:config"UMenuFile"}
  D.edtUMenuFile     = {DI.Edit,  M+1,  6, W-2,  0, 0, 0, 0, DIF.ReadOnly, ""}
  D.txtBindsFile     = {DI.Text,  I+2,  7, M-1,  0, 0, 0, 0, 0, L:config"BindsFile"}
  D.edtBindsFile     = {DI.Edit,  I+2,  8, M-1,  0, 0, 0, 0, DIF.ReadOnly, ""}
  D.sep              = {DI.Text,    0,  H-2, 0,  0, 0, 0, 0, DIF.SeparLine, ""}
  --D.btnOk            = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel        = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Close"}
  if not Derived then
  D.btnFiles         = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DlgButton, L:dlgbtn"Files"}
  D.btnUMenu         = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DlgButton, L:dlgbtn"UMenu"}
  end

  return D
end ---- Basic

function Dlg.Files (Config, Derived) --> (dialog)
  local I, H, W = 3, 12, 50 -- Indent, Height, Width
  local M = bshr(W, 1) -- Medium -- Width/2

  local D = dlg_NewDialog() -- Форма окна
                       -- 1         2   3    4   5  6  7  8  9  10
                       -- Type     X1  Y1   X2  Y2  L  H  M  F  Data
  D._                = {DI.DBox,    I,  1,   W,  H, 0, 0, 0, 0, CfgCapLoc"Files"}
  D.txtMenusFile     = {DI.Text,  I+2,  2, M-1,  0, 0, 0, 0, 0, L:config"MenusFile"}
  D.edtMenusFile     = {DI.Edit,  I+2,  3, M-1,  0, 0, 0, 0, 0, ""}
  D.txtFilesPath     = {DI.Text,  I+2,  4, W-2,  0, 0, 0, 0, 0, L:config"FilesPath"}
  D.edtFilesPath     = {DI.Edit,  I+2,  5, W-2,  0, 0, 0, 0, 0, ""}
  D.txtMenusPath     = {DI.Text,  I+2,  6, W-2,  0, 0, 0, 0, 0, L:config"MenusPath"}
  D.edtMenusPath     = {DI.Edit,  I+2,  7, W-2,  0, 0, 0, 0, 0, ""}
  D.txtLuaScPath     = {DI.Text,  I+2,  8, W-2,  0, 0, 0, 0, 0, L:config"LuaScPath"}
  D.edtLuaScPath     = {DI.Edit,  I+2,  9, W-2,  0, 0, 0, 0, 0, ""}
  D.sep              = {DI.Text,    0,  H-2, 0,  0, 0, 0, 0, DIF.SeparLine, ""}
  D.btnOk            = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel        = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Close"}
  if not Derived then
  D.btnBasic         = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DlgButton, L:dlgbtn"Basic"}
  D.btnUMenu         = {DI.Button,  0,  H-1, 0,  0, 0, 0, 0, DIF.DlgButton, L:dlgbtn"UMenu"}
  end

  return D
end ---- Files

function Dlg.UMenu (Config, Derived) --> (dialog)
  local I, J, H, W = 3, 3, 16, 52 -- Indent, Addend, Height, Width

  local D = dlg_NewDialog() -- Форма окна
                       -- 1         2   3    4   5  6  7  8  9  10
                       -- Type     X1  Y1   X2  Y2  L  H  M  F  Data
  D._                = {DI.DBox,    I,  1,   W,  H, 0, 0, 0, 0, CfgCapLoc"UMenu"}
  D.sepMenuCaptions  = {DI.Text,    0,  2,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"MenuCaptions"}
  D.chkMenuTitleBind = {DI.Check, I+J,  3, W-2,  0, 0, 0, 0, 0, L:config"MenuTitleBind"}
  D.chkCompoundTitle = {DI.Check, I+J,  4, W-2,  0, 0, 0, 0, 0, L:config"CompoundTitle"}
  D.chkBottomHotKeys = {DI.Check, I+J,  5, W-2,  0, 0, 0, 0, 0, L:config"BottomHotKeys"}
  D.sepMenuItemText  = {DI.Text,    0,  6,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"MenuItemText"}
  D.chkCaptAlignText = {DI.Check, I+J,  7, W-2,  0, 0, 0, 0, 0, L:config"CaptAlignText"}
  D.chkTextNamedKeys = {DI.Check, I+J,  8, W-2,  0, 0, 0, 0, 0, L:config"TextNamedKeys"}
  D.chkFullNamedKeys = {DI.Check, I+J,  9, W-2,  0, 0, 0, 0, 0, L:config"FullNamedKeys"}
  D.chkKeysAlignText = {DI.Check, I+J, 10, W-2,  0, 0, 0, 0, 0, L:config"KeysAlignText"}
  D.sepMenuAddition  = {DI.Text,    0, 11,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"MenuAddition"}
  D.chkShowErrorMsgs = {DI.Check, I+J, 12, W-2,  0, 0, 0, 0, 0, L:config"ShowErrorMsgs"}
  D.chkReturnToUMenu = {DI.Check, I+J, 13, W-2,  0, 0, 0, 0, DIF.Disable, L:config"ReturnToUMenu"}
  D.sep              = {DI.Text,    0, H-2,  0,  0, 0, 0, 0, DIF.SeparLine, ""}
  D.btnOk            = {DI.Button,  0, H-1,  0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel        = {DI.Button,  0, H-1,  0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Close"}
  if not Derived then
  D.btnBasic         = {DI.Button,  0, H-1,  0,  0, 0, 0, 0, DIF.DlgButton, L:dlgbtn"Basic"}
  D.btnFiles         = {DI.Button,  0, H-1,  0,  0, 0, 0, 0, DIF.DlgButton, L:dlgbtn"Files"}
  end

  return D
end ---- UMenu

do

local Guid = {
  Basic = win.Uuid("06af58b5-0837-487c-891d-697a5d8c08ba"),
  Files = win.Uuid("07a36f6c-1a94-4ce1-9aad-d7908df447e5"),
  UMenu = win.Uuid("082f7e38-b5f6-46c9-a1bb-2d8919872172"),
  -- ?? = win.Uuid("0ae6f8d0-ba43-4e70-a13f-8abb7d8c49f0"),
} ---

-- Элементы с цветом COL_ROnly
local ROnly_Items = {
  -- Basic:
  txtLuaUMPath = true,
  --edtLuaUMPath = true,
  txtLuaUMName = true,
  --edtLuaUMName = true,
  txtLuaUMHint = true,
  sepDefault   = true,
  txtDefUMPath = true,
  --edtDefUMPath = true,
  txtUMenuFile = true,
  --edtUMenuFile = true,
  txtBindsFile = true,
  --edtBindsFile = true,
  -- UMenu:
  sepMenuCaptions = true,
  sepMenuItemText = true,
  sepMenuAddition = true,
} ---

  local setFG = colors.setFG
  local IndexColor = farUt.IndexColor

-- Настройка конфигурации.
local function ConfigDlg (Config, Kind, Derived)
  local cData = Config.CfgData[Kind]
  local aData = Config.ArgData[Kind]
  local Types = Config.DlgTypes[Kind]
  --logShow(Config, "ConfigDlg", "d3 _")

  if not Derived then
    -- Локализация:
    LocData = locale.getDual(Config.Custom, unit.DefConfig.Custom)
    -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
    -- if not LocData then return nil, e1, e2 end -- CHECK!! also in LUM.lua
    L = locale.make(Config.Custom, LocData)
  end -- if
  local D = Dlg[Kind](Config, Derived)

  local ROnly_Color = IndexColor(farColors.COL_DIALOGDISABLED)

  -- Установка цветов элементов.
  local function DlgGetItemColor (hDlg, ID, Color) --> (Color)
    -- Цвет элемента
    local Item = D[ID+1]
    if Item == nil then return end
    -- [[
    if ROnly_Items[Item.name] then
      local TextColor = setFG(dlgUt.GetTextColor(Color), ROnly_Color)
      return dlgUt.ChangeColor(Color, TextColor)
    end
    --]]
    --[[
    far.Show(hDlg, ID,
             hex8(Color),
             ROnly_Items[Item.name] and
             hex8(dlgUt.ChangeColor(Color, ROnly_Color)) or "none",
             Item.id, Item.name, unpack(Item))
    --]]
  end --

  -- Ссылки на обработчики событий:
  local Procs = {
    [F.DN_CTLCOLORDLGITEM] = DlgGetItemColor,
  } --- Procs

  -- Обработчик событий диалога.
  local function DlgProc (hDlg, msg, param1, param2)
    return Procs[msg] and Procs[msg](hDlg, param1, param2) or nil
  end --

  repeat -- Изменение конфигурации LUM.
    dlgUt.LoadDlgData(cData, aData, D, Types) -- Загрузка конфигурации
    local iDlg = dlgUt.Dialog(Guid[Kind],
                              -1, -1, D._[4]+4, D._[5]+2,
                              unit.HelpTopic, D, nil, DlgProc)

    if D.btnOk and iDlg == D.btnOk.id then
      dlgUt.SaveDlgData(cData, aData, D, Types) -- Сохранение конфигурации
      Config.History:save() -- Сохранение файла

      return true

    elseif not Derived then
      -- Поиск нажатой кнопки:
      for _, k in ipairs(CfgKinds) do
        local v = D["btn"..k]
        if v and iDlg == v.id then
          ConfigDlg(Config, k, true)
          break
        end
      end
    end

  until Derived or not Derived and iDlg <= D.btnCancel.id
end ---- ConfigDlg
unit.ConfigDlg = ConfigDlg

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
