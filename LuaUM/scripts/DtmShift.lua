--[[ Date+Time Shift ]]--

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
local bit = bit64
--local band, bor = bit.band, bit.bor
local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local far = far
local F = far.Flags

----------------------------------------
--local context, ctxdata = context, ctxdata

--local types = ctxdata.config.types

local utils = require 'context.utils.useUtils'
--local numbers = require 'context.utils.useNumbers'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local isFlag, delFlag = utils.isFlag, utils.delFlag

--local n2s = numbers.n2s

local addNewData = tables.extend

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
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
  locale = {
    kind = 'load',
    --pdir = "scripts\\Rh_Scripts\\LuaUM\\",
  },
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
  local DBox = Config.DBox
  local isSmall = DBox.Flags and isFlag(DBox.Flags, F.FDLG_SMALLDIALOG)

  local I, J = isSmall and 0 or 3, isSmall and 0 or 1
  local H = DBox.Height - (isSmall and 1 or 2)
  local W = DBox.Width  - (isSmall and 0 or 2)
  local M = bshr(W, 1) -- Medium -- Width/2
  local Q = bshr(M, 1) -- Quarta -- Width/4
  W = W - 2 - (isSmall and 0 or 2)
  local A, B = I + 2, M + 2
  -- Some controls' sizes:
  local T = 12 -- Text field
  local S = 4  -- Small numbers
  local G = 6  -- Large numbers

  local Caption = L:caption(DBox.Caption or "Dialog")

  local D = dialog.NewDialog() -- Форма окна:
                    -- 1          2     3    4   5  6  7  8  9  10
                    -- Type      X1    Y1   X2  Y2  L  H  M  F  Data
  D._             = {DI.DBox,     I,    J, W+2,  H, 0, 0, 0, 0, Caption}
  --[[
  -- Свойства набранного слова:
  D.sep           = {DI.Text,     0,   J1,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"TypedWord"}
  D.txtCharEnum   = {DI.Text,     A, J1+1, M-T,  0, 0, 0, 0, 0, L:config"CharEnum"}
  D.edtCharEnum   = {DI.Edit,   M-T, J1+1,   M,  0, 0, 0, 0, 0, ""}
  if isAuto then
  D.txtCharsMin   = {DI.Text, B+S+1, J1+1, W-1,  0, 0, 0, 0, 0, L:config"CharsMin"}
  D.edtCharsMin   = {DI.Edit,     B, J1+1, B+S,  0, 0, 0, 0, 0, ""}
  end
  D.chkUseMagic   = {DI.Check,    A, J1+2,   M,  0, 0, 0, 0, 0, L:config"UseMagic"}
  D.chkUsePoint   = {DI.Check,    A, J1+3,   M,  0, 0, 0, 0, 0, L:config"UsePoint"}
  D.chkUseInside  = {DI.Check,    B, J1+3,   W,  0, 0, 0, 0, 0, L:config"UseInside"}
  D.chkUseOutside = {DI.Check,    B, J1+2,   W,  0, 0, 0, 0, 0, L:config"UseOutside"}
  -- Свойства отбора слов:
  D.sep           = {DI.Text,     0,   J2,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"WordsFind"}
  D.txtFindKind   = {DI.Text,     A, J2+1,   Q,  0, 0, 0, 0, 0, L:config"FindKind"}
  D.cbxFindKind   = {DI.Combo,  Q+1, J2+1,   M,  0,
                     ListItems(Config, "FindKind", L), 0, 0, DIF.ComboList, ""}
  D.txtFindsMax   = {DI.Text,     B, J2+1, W-S,  0, 0, 0, 0, 0, L:config"FindsMax"}
  D.edtFindsMax   = {DI.Edit,   W-S, J2+1, W-1,  0, 0, 0, 0, 0, ""}
  D.txtMinLength  = {DI.Text, B+S+1, J2+2, W-1,  0, 0, 0, 0, 0, L:config"MinLength"}
  D.edtMinLength  = {DI.Edit,     B, J2+2, B+S,  0, 0, 0, 0, 0, ""}
  --D.txtMinLength  = {DI.Text,     B, J2+2, W-S,  0, 0, 0, 0, 0, L:config"MinLength"}
  --D.edtMinLength  = {DI.Edit,   W-S, J2+2, W-1,  0, 0, 0, 0, 0, ""}
  D.chkPartFind   = {DI.Check,    B, J2+3,   W,  0, 0, 0, 0, 0, L:config"PartFind"}
  D.chkMatchCase  = {DI.Check,    B, J2+4,   W,  0, 0, 0, 0, 0, L:config"MatchCase"}
  D.txtLinesView  = {DI.Text,     A, J2+2,   M,  0, 0, 0, 0, 0, L:config"LinesView"}
  D.txtLinesUp    = {DI.Text,   A+1, J2+3, M-G,  0, 0, 0, 0, 0, L:config"LinesUp"}
  D.edtLinesUp    = {DI.Edit,   M-G, J2+3,   M,  0, 0, 0, 0, 0, ""}
  D.txtLinesDown  = {DI.Text,   A+1, J2+4, M-G,  0, 0, 0, 0, 0, L:config"LinesDown"}
  D.edtLinesDown  = {DI.Edit,   M-G, J2+4,   M,  0, 0, 0, 0, 0, ""}
  -- Свойства сортировки:
  D.sep           = {DI.Text,     0,   J3,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"WordsSort"}
  D.txtSortKind   = {DI.Text,     A, J3+1,   Q,  0, 0, 0, 0, 0, L:config"SortKind"}
  D.cbxSortKind   = {DI.Combo,  Q+1, J3+1,   M,  0,
                     ListItems(Config, "SortKind", L), 0, 0, DIF.ComboList, ""}
  D.txtSortsMin   = {DI.Text,     B, J3+1, W-S,  0, 0, 0, 0, 0, L:config"SortsMin"}
  D.edtSortsMin   = {DI.Edit,   W-S, J3+1, W-1,  0, 0, 0, 0, 0, ""}
  -- Свойства списка слов:
  D.sep           = {DI.Text,     0,   J4,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"WordsList"}
  if not isAuto then
  D.txtListsMax   = {DI.Text,     B, J4+1, W-S,  0, 0, 0, 0, 0, L:config"ListsMax"}
  D.edtListsMax   = {DI.Edit,   W-S, J4+1, W-1,  0, 0, 0, 0, 0, ""}
  end
  D.chkSlabMark   = {DI.Check,    A, J4+1,   M,  0, 0, 0, 0, 0, L:config"SlabMark"}
  if not isAuto then
  D.chkHotChars   = {DI.Check,    A, J4+2,   M,  0, 0, 0, 0, 0, L:config"HotChars"}
  D.chkActionAlt  = {DI.Check,    A, J4+3,   M,  0, 0, 0, 0, 0, L:config"ActionAlt"}
  end
  if not isAuto then
  D.chkEmptyList  = {DI.Check,    B, J4+2,   W,  0, 0, 0, 0, 0, L:config"EmptyList"}
  D.chkEmptyStart = {DI.Check,    B, J4+3,   W,  0, 0, 0, 0, 0, L:config"EmptyStart"}
  end
  -- Свойства завершения слова:
  D.sep           = {DI.Text,     0,   J5,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"TypedCmpl"}
  D.txtTrailers   = {DI.Text,     A, J5+1, M-T,  0, 0, 0, 0, 0, L:config"Trailers"}
  D.edtTrailers   = {DI.Edit,   M-T, J5+1,   M,  0, 0, 0, 0, 0, ""}
  if isAuto then
  D.chkUndueOut   = {DI.Check,    B, J5+1,   W,  0, 0, 0, 0, 0, L:config"UndueOut"}
  else
  D.chkLoneAuto   = {DI.Check,    A, J5+2,   M,  0, 0, 0, 0, 0, L:config"LoneAuto"}
  D.chkTailOnly   = {DI.Check,    B, J5+2,   W,  0, 0, 0, 0, 0, L:config"TailOnly"}
  end
  --]]
  -- Кнопки управления:
  D.sep           = {DI.Text,     0,  H-2,   0,  0, 0, 0, 0, DIF.SeparLine, ""}
  --D.chkEnabled    = {DI.Check,    A,  H-1,   M,  0, 0, 0, 0, 0, L:config"Enabled"}
  D.btnOk         = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel     = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Cancel"}

  return D
end -- Dlg

local ConfigGuid = win.Uuid("") -- TODO: Задать GUID

-- Настройка.
function unit.TimeShiftDlg (Data)
  local Config = Configure(Data)
  local HelpTopic = Config.Custom.help.tlink
  -- Локализация:
  LocData = locale.getData(Config.Custom)
  logShow(LocData)
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
  local DBox = Config.DBox
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
return unit.TimeShiftDlg()
--return unit
--------------------------------------------------------------------------------
