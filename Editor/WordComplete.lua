--[[ Word Completion ]]--

----------------------------------------
--[[ description:
  -- Word Completion.
  -- Завершение слов.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  far2,
  Rh Utils, RectMenu.
  -- areas: editor.
--]]
----------------------------------------
--[[ idea from:
*. Word Completion plugin.
   (Word completion in editor.)
   © 1999, Andrey Tretjakov etc.
--]]
--------------------------------------------------------------------------------

local require = require
local setmetatable = setmetatable

----------------------------------------
local bit = bit64
--local band, bor = bit.band, bit.bor
local bshl, bshr = bit.lshift, bit.rshift

local t_sort = table.sort

----------------------------------------
local win, far, editor = win, far, editor
local F = far.Flags

local CompareString = win.CompareString
local EditorGetInfo = editor.GetInfo
local EditorSetPos  = editor.SetPosition
local EditorGetStr  = editor.GetString
local EditorInsText = editor.InsertText

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local lua = require 'context.utils.useLua'
local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'
--local strings = require 'context.utils.useStrings'
local colors = require 'context.utils.useColors'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local isFlag, delFlag = utils.isFlag, utils.delFlag

local abs = math.abs
local min2, max2 = numbers.min2, numbers.max2

local addNewData = tables.extend

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"
local macUt = require "Rh_Scripts.Utils.Macro"
local menUt = require "Rh_Scripts.Utils.Menu"

----------------------------------------
--local fkeys = require "far2.keynames"
--local InputRecordToName = fkeys.InputRecordToName

local keyUt = require "Rh_Scripts.Utils.Keys"

local isVKeyChar = keyUt.isVKeyChar
local IsModAlt, IsModShift = keyUt.IsModAlt, keyUt.IsModShift
local GetModBase = keyUt.GetModBase

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "WordComplete"
unit.ScriptAutoName = "AutoComplete"
unit.ScriptCodeName = "CodeComplete"
unit.ScriptPath = "scripts\\Rh_Scripts\\Editor\\"

---------------------------------------- ---- Custom
unit.DefCustom = {
  name = unit.ScriptName,
  path = unit.ScriptPath,

  label = "WC",

  help   = { topic = unit.ScriptName, },
  locale = { kind = 'load', },
} -- DefCustom

----------------------------------------
unit.DefOptions = {
  useSuit  = false,
  SuitName = unit.ScriptName,
  BaseDir  = "Rh_Scripts.Editor",
  WorkDir  = unit.ScriptName,
  FileName = "kit_config",
} -- DefOptions

---------------------------------------- ---- Config
local SelectedBG = colors.Colors.navy
local Colors = menUt.MenuColors()
local StdColors = Colors.Standard
local AngleColor = colors.make(colors.getFG(StdColors.normal),
                               colors.getFG(StdColors.disable) )
                               --type(StdColors.normal) )

unit.DefCfgData = { -- Конфигурация по умолчанию:
  Enabled = true,
  -- Свойства набранного слова:
  CharEnum = "%w_",  -- Допустимые символы слова.
  CharsMin = 0,      -- Минимальное число набранных символов слова.
  UseMagic = false,  -- Использование "магических" модификаторов.
  UsePoint = false,  -- Использование символа '.' как "магического".
  UseInside  = true, -- Использование внутри слов.
  UseOutside = true, -- Использование вне слов.
  -- Свойства отбора слов:
     -- Вид поиска слов:
     --: обычный | неограниченный | чередующийся | балансируемый.
     --: "customary" | "unlimited" | "alternate" | "trimmable".
  FindKind  = "alternate",
  FindsMax  = 100,   -- Максимальное число слов.
  MinLength = 4,     -- Минимальная длина слова.
  PartFind  = false, -- Поиск частей слова.
  MatchCase = false, -- Учёт регистра символов.
  LinesUp   = 1000,  -- Число просматриваемых строк выше текущей строки.
  LinesDown = 500,   -- Число просматриваемых строк ниже текущей строки.
  -- Свойства сортировки:
     -- Вид сортировки слов:
     --: по мере поиска | посимвольно | по близости | по частотности.
     --: "searching" | "character" | "closeness" | "frequency".
  SortKind = "character",
  SortsMin = 4,           -- Минимальное число слов для сортировки.
  -- Свойства списка слов:
  ListsMax = 16,    -- Максимальное число слов в списке.
  SlabMark = true,  -- Маркировка набранного слова.
  HotChars  = true,  -- Выбор слова с помощью Alt+<горячая буква>.
  ActionAlt = true,  -- Использование Alt для дополнительных действий.
  EmptyList  = false, -- Возможность пустого списка.
  EmptyStart = false, -- Возможность пустого начального списка.
  SelectedBG = SelectedBG, -- Цвет фона выделенного элемента списка.
  AngleColor = AngleColor, -- Цвет угла списка у позиции курсора.
  -- Свойства завершения слова:
  Trailers = ",:;.?!",-- Символы-завершители.
  UndueOut = false,   -- Отмена завершения при неверных клавишах.
  LoneAuto = false,   -- Автодополнение при одном слове в списке.
  TailOnly = false,   -- Добавление только ненабранной части слова.
} -- DefCfgData

----------------------------------------
unit.AutoCfgData = { -- Конфигурация для авто-режима:
  Enabled = true,
  -- Свойства набранного слова:
  CharEnum = "%w_",
  CharsMin = 4,
  UseMagic = false,
  UsePoint = false,
  UseInside  = false,
  UseOutside = false,
  -- Свойства отбора слов:
  FindKind  = "alternate",
  FindsMax  = 8,
  MinLength = 4,
  PartFind  = false,
  MatchCase = false,
  LinesUp   = 500,
  LinesDown = 100,
  -- Свойства сортировки:
  SortKind = "searching",
  SortsMin = 16,
  -- Свойства списка слов:
  ListsMax = 1,
  SlabMark = true,
  HotChars  = false,
  ActionAlt = false,
  EmptyList  = false,
  EmptyStart = false,
  SelectedBG = SelectedBG,
  AngleColor = AngleColor,
  -- Свойства завершения слова:
  Trailers = "",
  UndueOut = true,
  LoneAuto = false,
  TailOnly = false,
  -- Специальные параметры:
  Custom = {
    isAuto = true,
    --isSmall = false,
    name = unit.ScriptAutoName,
    --help   = { topic = unit.ScriptName, },
    locale = { kind = 'load', file = unit.ScriptName, },
  }, --
  --[[
  Options = {
    SuitName = unit.ScriptAutoName,
  }, --
  --]]
} -- AutoCfgData

----------------------------------------
unit.CodeCfgData = { -- Конфигурация для кодо-режима:
  Enabled = true,
  -- Свойства набранного слова:
  CharEnum = "%w_",
  CharsMin = 4,
  UseMagic = false,
  UsePoint = false,
  UseInside  = false,
  UseOutside = false,
  -- Свойства отбора слов:
  FindKind  = "alternate",
  FindsMax  = 8,
  MinLength = 4,
  PartFind  = false,
  MatchCase = false,
  LinesUp   = 500,
  LinesDown = 100,
  -- Свойства сортировки:
  SortKind = "searching",
  SortsMin = 16,
  -- Свойства списка слов:
  ListsMax = 1,
  SlabMark = true,
  HotChars  = false,
  ActionAlt = false,
  EmptyList  = false,
  EmptyStart = false,
  SelectedBG = SelectedBG,
  AngleColor = AngleColor,
  -- Свойства завершения слова:
  Trailers = "",
  UndueOut = true,
  LoneAuto = false,
  TailOnly = false,
  -- Специальные параметры:
  Custom = {
    isAuto = true,
    --isSmall = false,
    name = unit.ScriptCodeName,
    --help   = { topic = unit.ScriptName },
    locale = { kind = 'load', file = unit.ScriptName },
  }, --
  -- [[
  Options = {
    useSuit = true,
    --SuitName = unit.ScriptCodeName,
  }, --
  --]]
} -- CodeCfgData

---------------------------------------- ---- Types
unit.DlgTypes = { -- Типы элементов диалога:
  Enabled = "chk",
  -- Свойства набранного слова:
  CharEnum = "edt",
  CharsMin = { Type = "edt", Format = "number",
               Range = { min = 0, max = 10 }, },
  UseMagic = "chk",
  UsePoint = "chk",
  UseInside  = "chk",
  UseOutside = "chk",
  -- Свойства отбора слов:
  MinLength = { Type = "edt", Format = "number",
                Range = { min = 2, max = 9 }, },
  FindsMax = { Type = "edt", Format = "number",
               Range = { min =  8, max = 500 }, },
  PartFind = "chk",
  MatchCase = "chk",
  FindKind = { Type = "cbx", Prefix = "FK_";
               "customary", "unlimited", "alternate", "trimmable" },
  LinesUp   = { Type = "edt", Format = "number",
                Range = { min = 0, max = 10000 }, },
  LinesDown = { Type = "edt", Format = "number",
                Range = { min = 0, max = 10000 }, },
  -- Свойства сортировки:
  SortKind = { Type = "cbx", Prefix = "SK_";
               "searching", "character", "closeness", "frequency" },
  SortsMin = { Type = "edt", Format = "number",
               Range = { min = 2, max = 50 }, },
  -- Свойства списка слов:
  ListsMax = { Type = "edt", Format = "number",
               Range = { min = 1, max = 100 }, },
  SlabMark = "chk",
  HotChars = "chk",
  ActionAlt = "chk",
  EmptyList  = "chk",
  EmptyStart = "chk",
  -- Свойства завершения слова:
  Trailers = "edt",
  UndueOut = "chk",
  LoneAuto = "chk",
  TailOnly = "chk",
} -- DlgTypes

---------------------------------------- ---- Popup
local usercall = farUt.usercall
--local unit.RunMenu = require "Rh_Scripts.RectMenu.RectMenu"
unit.RunMenu = usercall(nil, require, "Rh_Scripts.RectMenu.RectMenu")

---------------------------------------- ---- Keys
-- Названия действий.
local A_Cancel  = "Cancel"
local A_Replace = "Replace"
local A_Insert  = "Insert"
local E_Shared  = "Shared"

unit.CompleteKeys = { -- Клавиши завершения слова:
  { BreakKey = "Tab",           Action = A_Replace, },
  { BreakKey = "ShiftTab",      Action = A_Insert,  },
  { BreakKey = "ShiftEnter",    Action = A_Insert,  },
  { BreakKey = "ShiftNumEnter", Action = A_Insert,  },
} --- CompleteKeys

unit.LocalUseKeys = { -- Клавиши локального использования:
  { BreakKey = "CtrlEnter",       Action = A_Replace, Effect = E_Shared, },
  { BreakKey = "CtrlShiftEnter",  Action = A_Insert,  Effect = E_Shared, },
} --- LocalUseKeys

---------------------------------------- Main class
local TMain = {
  Guid       = win.Uuid("64b26458-1e8b-4844-9585-becfb1ce8de3"),
  ConfigGuid = win.Uuid("642eb0fd-d297-4855-bd87-dcecfc55bcc4"),
  PopupGuid  = false,
}
local MMain = { __index = TMain }

TMain.PopupGuid = TMain.Guid

-- Создание объекта основного класса.
local function CreateMain (ArgData)

  if ArgData == "AutoCfgData" then
    ArgData = unit.AutoCfgData
  elseif ArgData == "CodeCfgData" then
    ArgData = unit.CodeCfgData
  end

  local self = {
    ArgData   = addNewData(ArgData, unit.DefCfgData),

    Custom    = false,
    Options   = false,
    History   = false,
    CfgData   = false,
    DlgTypes  = unit.DlgTypes,
    LocData   = false,

    Assist    = false,

    -- Текущее состояние:
    --Error     = false,    -- Текст ошибки
    Menu      = false,    -- CfgData.Menu or {}

    Popup     = false,    -- Всплывающее меню-список
    Pattern   = false,    -- Паттерны поиска
    Current   = false,    -- Текущие данные

    Words     = false,    -- Список слов
    Items     = false,    -- Список пунктов меню
    Props     = false,    -- Свойства меню

    ActItem   = false,    -- Выбранный пункт меню
    ItemPos   = false,    -- Позиция выбранного пункта меню
    Action    = false,    -- Выбранное действие
    Effect    = false,    -- Выбранный эффект
  } --- self

  self.ArgData.Custom = self.ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(self.ArgData, "ArgData")
  self.Custom = datas.customize(self.ArgData.Custom, unit.DefCustom)
  self.Options = addNewData(self.ArgData.Options, unit.DefOptions)

  self.History = datas.newHistory(self.Custom.history.full)
  self.CfgData = self.History:field(self.Custom.history.field)

  self.Menu = self.CfgData.Menu or {}
  local Menu = self.Menu
  Menu.CompleteKeys = Menu.CompleteKeys or unit.CompleteKeys
  Menu.LocalUseKeys = Menu.LocalUseKeys or unit.LocalUseKeys

  setmetatable(self.CfgData, { __index = self.ArgData })
  --logShow(self.CfgData, "CfgData")

  locale.customize(self.Custom)
  --logShow(self.Custom, "Custom")

  return setmetatable(self, MMain)
end -- CreateMain

---------------------------------------- Dialog
do
  local dialog = require "far2.dialog"
  local dlgUt = require "Rh_Scripts.Utils.Dialog"

  local DI = dlgUt.DlgItemType
  local DIF = dlgUt.DlgItemFlag
  local ListItems = dlgUt.ListItems

function TMain:ConfigForm () --> (dialog)
  local DBox = self.DBox
  local isAuto = self.Custom.isAuto
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

  local J1 = J  + 1
  local J2 = J1 + DBox.cSlab + 2; local J3 = J2 + DBox.cFind + 2
  local J4 = J3 + DBox.cSort + 2; local J5 = J4 + DBox.cList + 2

  local L = self.L
  local D = dialog.NewDialog() -- Форма окна:
                    -- 1          2     3    4   5  6  7  8  9  10
                    -- Type      X1    Y1   X2  Y2  L  H  M  F  Data
  D._             = {DI.DBox,     I,    J, W+2,  H, 0, 0, 0, 0,
                     L:caption(isAuto and "DlgAuto" or "Dialog")}
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
                     ListItems(self, "FindKind", L), 0, 0, DIF.ComboList, ""}
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
                     ListItems(self, "SortKind", L), 0, 0, DIF.ComboList, ""}
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
  -- Кнопки управления:
  D.sep           = {DI.Text,     0,  H-2,   0,  0, 0, 0, 0, DIF.SeparLine, ""}
  D.chkEnabled    = {DI.Check,    A,  H-1,   M,  0, 0, 0, 0, 0, L:config"Enabled"}
  D.btnOk         = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel     = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Cancel"}

  return D
end -- ConfigForm

function TMain:ConfigBox ()

  local isAuto  = self.Custom.isAuto
  local isSmall = self.Custom.isSmall
  if isSmall == nil then isSmall = true end

  -- Область:
  local DBox = {
    cSlab     = 3,
    cFind     = 4,
    cSort     = 1,
    cList     = isAuto and 1 or 3,
    cCmpl     = isAuto and 1 or 2,

    Width     = 0,
    Height    = 0,
    Flags     = isSmall and F.FDLG_SMALLDIALOG or nil,
  } -- DBox
  self.DBox = DBox

  DBox.Width  = 2 + 36*2 -- Edge + 2 columns
          -- Edge + (sep+Btns) + group separators and
  DBox.Height = 2 + 2 + 5*2 + -- group empty lines + group item lines
                DBox.cSlab + DBox.cFind + DBox.cSort + DBox.cList + DBox.cCmpl
  if not isSmall then
    DBox.Width, DBox.Height = DBox.Width + 4*2, DBox.Height + 1*2
  end

  return DBox
end ---- ConfigBox

function unit.ConfigDlg (Data)

  local _Main = CreateMain(Data)
  if not _Main then return end

  _Main:Localize() -- Локализация

  local DBox = _Main:ConfigBox()
  if not DBox then return end

  local HelpTopic = _Main.Custom.help.tlink

  local D = _Main:ConfigForm()
  dlgUt.LoadDlgData(_Main.CfgData, _Main.ArgData, D, _Main.DlgTypes)
  local iDlg = dlgUt.Dialog(_Main.ConfigGuid, -1, -1,
                            DBox.Width, DBox.Height, HelpTopic, D, DBox.Flags)
  --logShow(D, "D", 3)
  if D.btnOk and iDlg == D.btnOk.id then
    dlgUt.SaveDlgData(_Main.CfgData, _Main.ArgData, D, _Main.DlgTypes)
    --logShow(_Main, "Config", 3)
    _Main.History:save()

    return true
  end
end ---- ConfigDlg

end -- do
---------------------------------------- Main making

---------------------------------------- ---- KitSuit
do
  local TextTemplate = require "Rh_Scripts.Editor.TextTemplate"

-- -- Make templates kit.
-- -- Формирование набора шаблонов.
function TMain:MakeKit ()

  local ArgData = self.ArgData
  local Custom  = ArgData.Custom

  local Data = {
    Enabled     = ArgData.Enabled,
    -- Свойства набранного слова:
    CharEnum    = ArgData.CharEnum,
    CharsMin    = ArgData.CharsMin,
    UseMagic    = ArgData.UseMagic,
    UsePoint    = ArgData.UsePoint,
    UseInside   = ArgData.UseInside,
    UseOutside  = ArgData.UseOutside,

    Custom = {
      isAuto = Custom.isAuto,
      --isSmall = false,
      name = Custom.name,
      help   = { topic = TextTemplate.ScriptName, },
      locale = { kind = 'load', file = TextTemplate.ScriptName, },
    }, --

    --[[
    Options = { -- TODO: использовать unit.DefOptions
      SuitName = unit.ScriptCodeName,
    }, --
    --]]

  } -- Data

  self.Assist = TextTemplate.Execute(Data)

  -- TODO: Реализовать завершение кода:
  -- !. Шаблонами будут подходящие слова, выводимые затем в виде списка.
  -- !. Реализовать поддержку пункта меню apply вместо вывода слова!
  -- !. Заменить метод обработки шаблонов self.Assist:ProcessTemplates
  -- на свой метод вывода списка подходящих слов.

  return true
end -- MakeKit

end -- do

---------------------------------------- ---- Prepare
do
-- Localize data.
-- Локализация данных.
function TMain:Localize ()
  self.LocData = locale.getData(self.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not self.LocData then return end

  self.L = locale.make(self.Custom, self.LocData)

  return self.L
end ---- Localize

end -- do
do
  local setBG = colors.setBG
  local HighlightOff = menUt.HighlightOff

function TMain:MakeProps ()

  local Cfg = self.CfgData

  -- Свойства меню:
  local Props = self.Menu.Props or {}
  self.Menu.Props = Props
  Props.Title = ""
  --Props.Title = "Completion"
  Props.Flags = F.FMENU_WRAPMODE
  Props.Flags = HighlightOff(Props.Flags)

  -- Клавиши локального использования:
  self.Menu.BreakUseKeys = menUt.ParseMenuHandleKeys(self.Menu.LocalUseKeys)

  -- Свойства RectMenu:
  local RM = Props.RectMenu or {}
  Props.RectMenu = RM
  RM.Cols = 1
  RM.BoxKind = "S"
  RM.Shadowed = false
  --RM.MenuOnly = true
  RM.ReuseItems = true
  --RM.ReuseProps = true

  local SelectedBG = Cfg.SelectedBG
  local SelColors = Colors.Selected
  RM.Colors = {
    Selected = {
      normal  = setBG(SelColors.normal, SelectedBG),
      hlight  = setBG(SelColors.hlight, SelectedBG),
      marked  = setBG(SelColors.marked, SelectedBG),
      grayed  = setBG(SelColors.grayed, SelectedBG),
      disable = setBG(SelColors.disable, SelectedBG),
    }, --

    BorderAngle = Cfg.AngleColor or nil,
  } -- RM.Colors

  RM.MenuEdge = 0 --1
  RM.AltHotOnly = true

  do -- Значения для списка-меню:
    local Info = EditorGetInfo()
    local BoxLen = RM.BoxKind and 2 or 0
    local CurPos = far.AdvControl(F.ACTL_GETCURSORPOS)

    self.Popup = {
      LenH = BoxLen + bshl(RM.MenuEdge, 1),
                    --+ (Cfg.HotChars and 2 or 0),
      LenV = BoxLen + bshl(bshr(RM.MenuEdge, 1), 1),
      PosX = max2(CurPos.X - (Info.CurPos  - Info.LeftPos), 0),
      PosY = max2(CurPos.Y - (Info.CurLine - Info.TopScreenLine), 0),
      --PosY = CurPos.Y > Info.CurLine - Info.TopScreenLine and 1 or 0,
    } -- Popup

  end -- do

  -- Свойства набранного слова:
  -- Свойства отбора слов:
  -- Свойства сортировки:
  -- Свойства списка слов:
  -- Свойства завершения слова:

  -- Свойства меню:
  if Cfg.HotChars then
    Props.Flags = delFlag(Props.Flags, F.FMENU_SHOWAMPERSAND)
  end
end -- MakeProps

end -- do

-- Подготовка.
-- Preparing.
function TMain:Prepare ()

  self:MakeProps()

  return self:MakeKit()
end -- Prepare

---------------------------------------- ---- List
-- Поиск слов в шаблоне.
function TMain:SearchSuitWords () --> (table)
  --[[
  local Kits = unit.KitSuit[self.Options.SuitName]
  if not Kits then return end
  --logShow(Kits, self.Options.SuitName, 1)

  local Cfg, CurCfg = self.CfgData, self.Current

  -- Таблица слов с дополнительной информацией:
  local t = { Stat = {}, Link = { Line = CurCfg.CurLine } }

  return t
  --]]
end -- SearchSuitWords

-- Поиск слов в тексте.
function TMain:SearchTextWords () --> (table)

  local Cfg, CurCfg = self.CfgData, self.Current
  local Word, Slab = CurCfg.Word, CurCfg.Slab
  local MaxLine, MinLen = CurCfg.MaxLine, Cfg.MinLength
  local wCtr, wMax = 0, CurCfg.WordsMax
  local wMid, GetLine = bshr(wMax, 1), CurCfg.GetLine

  local Limited = Cfg.FindKind ~= "unlimited"
  local Trimmed = Cfg.FindKind == "trimmable"

  -- Таблица слов с дополнительной информацией:
  local t = { Stat = {}, Link = { Line = CurCfg.CurLine }, }
  local Stat = t.Stat -- Статистика встречаемости
  local Link = t.Link -- "Ссылочная" информация

  --logShow({ CurCfg.Slab, Slab }, "Slab")
  local SlabPat = self.Ctrl:asPattern(Slab) -- Подготовка Slab для поиска
  local BasePat = ("(%s%s+)"):format(SlabPat, self.Ctrl.CharsSet)
  local StartPat = '^'..BasePat
  local MatchPat = self.Ctrl.SeparSet..BasePat
  self.Pattern = {
    Slab = SlabPat,
    Base = BasePat,
    Start = StartPat,
    Match = MatchPat,
  } --
  --logShow(self.Pattern, "SearchWords Patterns")

  -- Поиск слов в строке.
  local function MatchLineWords (s, Line) --> (number)
    local k = 0 -- Число найденных слов в строке

    -- Отбор найденного слова.
    local function MakeWord (w)
      if w:len() < MinLen then return end
      local v = Stat[w] -- Статистика по слову
      if v then
        v.Count = v.Count + 1
      elseif w ~= Word then
        --logShow({ k, w, v }, "New Word")
        k = k + 1
        t[#t+1] = w
        -- Информация для frequency-сортировки:
        -- число повторений, номер строки + место по порядку:
        Stat[w] = { Count = 1, Line = Line, Slot = k, }
      end
    end -- MakeWord

    if Cfg.PartFind then
      for w in s:gmatch(BasePat) do MakeWord(w) end
    else
      local v = s:match(StartPat)
      if v then MakeWord(v) end
      for w in s:gmatch(MatchPat) do MakeWord(w) end
    end

    return k
  end -- function MatchLineWords

  -- Поиск слов в текущей строке.
  Link.Line = CurCfg.CurLine
  wCtr = wCtr + MatchLineWords(GetLine(), 0)
  if Limited and wCtr >= wMax then return t end
  --logShow(t, "SearchWords")

  if Cfg.FindKind == "alternate" then
    -- Поиск поочерёдно сверху / снизу.
    local LineU, LineD = Link.Line, Link.Line
    local LinesUp, LinesDown = Cfg.LinesUp, Cfg.LinesDown
    for k = 1, max2(LinesUp, LinesDown) do
      LineU = LineU - 1
      if LineU >= 0 and k <= LinesUp then
        wCtr = wCtr + MatchLineWords(GetLine(LineU), -k)
        if wCtr >= wMax then return t end
      end
      LineD = LineD + 1
      if LineD < MaxLine and k <= LinesDown then
        wCtr = wCtr + MatchLineWords(GetLine(LineD),  k)
        if wCtr >= wMax then return t end
      end
    end

  else -- Other kinds
    -- Поиск слов в строках выше.
    local Line = Link.Line
    Link.Up = #t+1
    for k = 1, Cfg.LinesUp do
      Line = Line - 1
      if Line < 0 then break end
      wCtr = wCtr + MatchLineWords(GetLine(Line), -k)
      if Limited and wCtr >= wMax then return t end
      if Trimmed and wCtr >= wMid then break end
    end
    --logShow(t, "SearchWords")

    Limited = Limited or Trimmed
    -- Поиск слов в строках ниже.
    Line = Link.Line
    Link.Down = #t+1
    for k = 1, Cfg.LinesDown do
      Line = Line + 1
      if Line >= MaxLine then break end
      wCtr = wCtr + MatchLineWords(GetLine(Line),  k)
      if Limited and wCtr >= wMax then return t end
    end
    --logShow(t, "SearchWords")
  end -- if FindKind

  return t
end -- SearchTextWords

-- Поиск слов, подходящих к текущему.
function TMain:SearchWords () --> (table)
  if self.Options.useSuit then
    return self:SearchSuitWords()
  else
    return self:SearchTextWords()
  end
end -- SearchWords

do
  -- Сортировка таблицы строк: по частотности.
  local function SortByFreq (t) --> (table)
    local f = t.Stat
    --logShow(t, "SortByFreq", 2)
    --local flog = dbg.open("tab_sort.txt")
    --flog:logtab(t, "t", 3)
    --flog:close()

    -- Сравнение слов по статистике:
    local function StatCmp (w1, w2) --> (bool)
      local f1, f2 = f[w1], f[w2]
      --logShow({ tostring(w1), f1, tostring(w2), f2 }, "StatCmp", 1)
      return f1.Count > f2.Count or
             f1.Count == f2.Count and
               (abs(f1.Line) < abs(f2.Line) or
                f1.Line == f2.Line and f1.Slot < f2.Slot)
    end --
    t_sort(t, StatCmp)

    return t
  end -- SortByFreq

  -- Сортировка таблицы строк: по близости.
  local function SortByNear (t) --> (table)
    local tLen  = #t
    local tUp   = min2(t.Link.Up,   tLen)
    local tDown = min2(t.Link.Down, tLen)
    if tUp >= tLen or tDown >= tLen or tUp >= tDown then return t end

    local n = t.n
    local u = { n = n }
    for k = 1, tUp - 1 do u[#u+1] = t[k] end
    if #u > n then return u end

    local uLen = tDown - tUp
    local dLen = tLen - tDown + 1
    local Count = min2(uLen, dLen)
    for k = 0, Count - 1 do
       u[#u+1] = t[tUp+k]
       u[#u+1] = t[tDown+k]
       if #u > n then return u end
    end
    if uLen == dLen then return u end

    if uLen > dLen then
      for k = tUp + Count, tDown - 1 do u[#u+1] = t[k] end
    else -- dLen < uLen
      for k = tDown + Count, tLen do u[#u+1] = t[k] end
    end

    return u
  end -- SortByNear

  -- Сортировка таблицы строк: посимвольная.
  local function SortByChar (t) --> (table)
    -- Сравнение слов посимвольно без учёта регистра:
    local function CharCmp (w1, w2) --> (bool)
      --logShow({ w1, w2 }, "CharCmp")
      return CompareString(w1, w2, nil, "S") < 0
    end --
    t_sort(t, CharCmp)

    return t
  end -- SortByChar

-- Сортировка таблицы строк.
function TMain:SortWords () --> (table)

  local Cfg = self.CfgData
  local FindKind, SortKind = Cfg.FindKind, Cfg.SortKind

  local t = self.Words
  if t.n < Cfg.SortsMin then SortKind = "searching" end

  -- По мере поиска (без сортировки):
  if SortKind == "searching" then return t end
  -- По близости (расстоянию до текущей строки):
  if SortKind == "closeness" and
     FindKind ~= "alternate" then return SortByNear(t) end
  -- По встречаемости (частотности):
  if SortKind == "frequency" then return SortByFreq(t) end
  --logShow(t, #t)
  --logShow(t, "Words on Sort")
  -- Предварительная сортировка:
  if FindKind == "unlimited" then SortByFreq(t) end

  local u
  if t.n ~= #t then
    --u = {} -- Список слов:
    u = { n = t.n } -- Список слов:
    for k = 1, t.n do u[k] = t[k] end
  else
    u = t
  end

  return SortByChar(u) -- Посимвольно (по алфавиту)
end -- SortWords

end -- do

---------------------------------------- ---- Menu
do
  local SharedMatch = "^(%s+)%s*\n%%1%s*"

-- Поиск общей части строк.
function TMain:SharedPart () --> (string)

  local Set = self.Ctrl.CharsSet
  local NoCase = not self.CfgData.MatchCase
  local SharedPat = SharedMatch:format(Set, Set, Set)
  self.Pattern.Shared = SharedPat

  local t = self.Words
  local s = t[1]
  if NoCase then s = s:lower() end
  for k = 2, t.n do
    local w = t[k]
    if NoCase then w = w:lower() end
    s = (s..'\n'..w):match(SharedPat)
    if not s then return "" end
  end

  return s
end -- SharedPart

end -- do

do
  local HotCharsStr = "1234567890abcdefghijklmnopqrstuvwxyz"
  local HotCharsLen = #HotCharsStr -- Digits and latin chars only

  local ItemHotFmt = "&%s "
  --local ItemHotFmt, ItemHotLen = "&%s | ", 4
  local ItemTextFmt = ItemHotFmt.."%s"
  local s_sub = string.sub

-- Заполнение пункта списка-меню.
function TMain:MakePopupItem (Index) --> (table)

  local Word = self.Words[Index]

  local Text = Word
  if self.CfgData.HotChars and Index <= HotCharsLen then
    Text = ItemTextFmt:format(s_sub(HotCharsStr, Index, Index), Word)
  end

  local Item = {
    text = Text,
    Word = Word,
  } ---

  return Item, Text
end -- MakePopupItem

end -- do
do
  local ItemHotLen = 2

-- Заполнение списка-меню.
function TMain:MakePopupMenu () --> (table)

  local Cfg = self.CfgData

  -- Создание таблицы пунктов меню.
  local Count = self.Words.n --or #self.Words
  --logShow(self.Words, "Words for Items")
  local Width, Height = 0, Count
  if Count == 0 and
     (not Cfg.EmptyList or -- Не пустой список слов или
      -- Не пустой список слов при первоначальном показе
      self.Current.StartMenu and not Cfg.EmptyStart) then
    return
  end

  --local Words = self.Words
  --logShow(self.Words, "Words for Items")
  local Items = {}
  for k = 1, Count do
    local Text
    Items[#Items+1], Text = self:MakePopupItem(k)
    Width = max2(Width, Text:len())
  end
  self.Items = Items
  if Cfg.HotChars then Width = Width - 1 end

  -- Определение области маркировки.
  local function MakeSlabMark ()
    --logShow(self.Pattern, "Patterns")
    local SlabPat = self.Pattern.Slab
    local SlabLen = self.Current.Slab:len()

    if Cfg.HotChars then    -- text ~= Word:
      return Cfg.UseMagic and { " "..SlabPat } or
             { ItemHotLen + 1, ItemHotLen + SlabLen }
    else                    -- text == Word:
      return Cfg.UseMagic and { SlabPat } or { 1, SlabLen }
    end
  end --

  -- Задание параметров меню RectMenu.
  local Props = self.Props
  Props.Id = Props.Id or self.PopupGuid
  Props.HelpTopic = self.Custom.help.tlink

  local RM = Props.RectMenu
  --logShow(RM, "RectMenu Props")
  if Cfg.SlabMark then RM.TextMark = MakeSlabMark() end -- Маркировка
  -- Расчёт позиции и размера окна:
  local Info, Popup = EditorGetInfo(), self.Popup
  Width, Height = Width + Popup.LenH, Height + Popup.LenV
  --[[
  local Rect, CursorPos = GetFarRect(), far.AdvControl(F.ACTL_GETCURSORPOS)
  logShow({ Info, Rect, CursorPos }, "Window info")
  --]]
  local Pos = {
    x = Info.CurPos  - Info.LeftPos       + Popup.PosX,
    y = Info.CurLine - Info.TopScreenLine + Popup.PosY,
    angle = "",
  } ---
  --logShow({ RM.MenuEdge, Width, Height, Pos, Info }, "Position")
  if Pos.y <= Height then
    Pos.y = Pos.y + 1
    Pos.angle = "T"
  else
    Pos.y = Pos.y - Height
    Pos.angle = "B"
  end
  -- Warning: "<" & "+1" instead of "<=" because editor may have scroll bar.
  if Pos.x + Width + 1 < Info.WindowSizeX then
    --Pos.x = Pos.x 
    Pos.angle = Pos.angle.."L"
  else
    Pos.x = Pos.x - Width - 1
    Pos.angle = Pos.angle.."R"
  end
  RM.Position = Pos

  local Colors = RM.Colors
  if Colors.BorderAngle then
    Colors.Borders = { [Pos.angle] = Colors.BorderAngle, }
  end
  --logShow(RM.Position, "RectMenu Position")
  --logShow(Items, "Items")

  return true
end -- MakePopupMenu

end -- do

do
  local chrUt = require "Rh_Scripts.Utils.Character"

  local CharControl = chrUt.CharControl

-- Формирование списка-меню слов.
function TMain:MakeWordsList () --> (table)

  local Cfg = self.CfgData

  self.Items = false -- Сброс меню (!)

  -- Базовая информация о редакторе:
  local Info = EditorGetInfo() -- Сохранение базовой позиции
  --logShow(Info, "Editor Info")
  self.Ctrl = CharControl(Cfg) -- Функции управления словом

-- 1. Анализ текущего набранного слова.

  -- Получение слова под курсором (CurPos is 0-based):
  local CurCfg = self.Current
  CurCfg.Line = EditorGetStr(nil, 0, 2) or ""
  CurCfg.Pos  = Info.CurPos -- 1-based!
  CurCfg.Word, CurCfg.Slab = self.Ctrl:atPosWord(CurCfg.Line, CurCfg.Pos)
  --logShow(CurCfg) -- Проверка на выход:
  if not self.Ctrl:isWordUse(CurCfg.Word, CurCfg.Slab) then return end

  --if CurCfg.Word then logShow(CurCfg) end
  CurCfg.Frag = CurCfg.Line:sub(1, CurCfg.Pos - 1)

-- 2. Отбор подходящих слов для завершения.

  -- Число слов для отбора:
  local Popup = self.Popup
  local lMax = Info.CurLine - Info.TopScreenLine      -- Учёт случаев:
  lMax = max2(Info.WindowSizeY - lMax - 2, lMax)        -- список сверху
  lMax = min2(Cfg.ListsMax, max2(lMax - Popup.LenV, 1)) -- список снизу
  CurCfg.WordsMax = max2(Cfg.FindsMax, lMax)

  -- Информация для работы со строками файла (Line number is 0-based):
  CurCfg.CurLine, CurCfg.MaxLine = Info.CurLine, Info.TotalLines
  CurCfg.GetLine = function (n) return EditorGetStr(nil, n or 0, 2) end

  -- Поиск подходящих слов в строках файла:
  local Words = self:SearchWords(); self.Words = Words
  --logShow(self.Words, "Words", 1)

  EditorSetPos(nil, Info) -- Восстановление базовой позиции

  -- Задание максимального числа слов
  if #Words == 0 then return end
  Words.n = min2(#Words, lMax) -- Максимальное число слов
  local wLink = Words.Link -- Информация для closeness-сортировки
  wLink.Up, wLink.Down = wLink.Up or Words.n, wLink.Down or Words.n
  --logShow(self.Words, "Words", 2)

-- 3. Сортировка собранных слов.

  self:SortWords() -- Сортировка собранных слов
  --logShow(self.Words, "Words", 1)

-- 4. Подготовка списка-меню слов.

  CurCfg.Shared = self:SharedPart() -- Общая часть слов
  --if Word then logShow(CurCfg) end

  return self:MakePopupMenu()
end -- MakeWordsList

end -- do

---------------------------------------- Main control
local function InsText (text)
  return EditorInsText(nil, text)
end --

---------------------------------------- ---- Action
-- Текст для завершения.
function TMain:CompletionText ()
  local Complete = self.ActItem.Word

  if self.Effect == E_Shared then
    return Complete:sub(1, self.Current.Shared:len())
  end

  return Complete
end ---- CompletionText
do
  -- Удаление Count символов:
  local EC_Actions = macUt.Actions.editor.cycle
  local DelText  = EC_Actions.del
  local BackText = EC_Actions.bs

-- Завершение слова.
function TMain:ApplyWordAction () --> (bool | nil)

  local Complete = self:CompletionText()
  if Complete == "" then return false end
  if self.Action ~= A_Replace and self.Action ~= A_Insert then return end

  local Word, Slab = self.Current.Word, self.Current.Slab
  local SLen = Slab:len()
  --logShow({ Complete, Word, Word:len(), Slab, SLen }, Action, 1)

  if self.Action == A_Replace then -- Удаление конца
    if not DelText(nil, Word:len() - SLen) then return end
  end

  if self.CfgData.TailOnly then -- Только добавление остатка:
    if not InsText(Complete:sub(SLen + 1, -1)) then return end
  else -- Замена слова выбранным:
    if not BackText(nil, SLen) then return end
    if not InsText(Complete) then return end
  end

  editor.Redraw()

  return true
end -- ApplyWordAction

end -- do

---------------------------------------- ---- Show
-- Показ меню заданного вида.
function TMain:ShowMenu () --> (item, pos)
  return usercall(nil, unit.RunMenu,
                  self.Props, self.Items, self.Menu.CompleteKeys)
  --return unit.RunMenu(self.Props, self.Items, self.Menu.CompleteKeys)
end ----

do
  local LuaCards    = lua.regex.Cards
  --local LuaCardsSet = lua.regex.CardsSet

  -- Флаги.
  local CloseFlag  = { isClose = true }
  local CancelFlag = { isCancel = true }
  local CompleteFlags = { isRedraw = false, isRedrawAll = true }

  -- Символы спец. клавиш:
  local SpecKeyChars = {
    Decimal   = '.',
    Multiply  = '*',
    Add       = '+',
    Subtract  = '-',
    Divide    = '/',
  } --- SpecKeyChars

  -- Названия действий клавиш.
  local KeyActionNames = {
    Del       = "del",
    BS        = "bs",
    -- Arrows:
    Left      = "left",
    Right     = "right",
    Up        = "up",
    Down      = "down",
    -- Numpad:
    NumDel    = "del",
    Num4      = "left",
    Num6      = "right",
    Num8      = "up",
    Num2      = "down",
  } --- KeyActionNames

  local KeyActions = macUt.Actions.editor.plain

function TMain:AssignEvents () --> (bool | nil)

  local Cfg = self.CfgData
  local Menu, Popup = self.Menu, self.Popup

  --logShow(Cfg, "Cfg", 1)
  self.Props, self.Items = self.Menu.Props -- Информация о меню

  -- Обработка нажатия клавиши --
  Popup.PressKey = false -- Нажатая клавиша

  -- Обработчик нажатия клавиши.
  local function KeyPress (VirKey, ItemPos)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end

    -- Предварительный анализ клавиши.
    Popup.PressKey = Cfg.UndueOut and VirKey or false
    local VKey = VirKey.VirtualKeyCode
    local VMod = GetModBase(VirKey.ControlKeyState)
    --logShow({ VKey, VMod, SKey }, "VirKey", 1, "xv2")

    local function MakeUpdate () -- Обновление!
      Popup.PressKey = false
      farUt.RedrawAll()
      -- Формирование нового списка-меню слов.
      self:MakeWordsList()
      --logShow(self.Words, "MakeUpdate")
      --logShow(self.Items, "MakeUpdate")
      if not self.Items then return nil, CloseFlag end
      --logShow(ItemPos, hex(FKey))
      return { self.Props, self.Items, Menu.CompleteKeys }, CompleteFlags
    end -- MakeUpdate

    -- Учёт нажатия клавиш локального использования.
    local Index = Menu.BreakUseKeys[SKey]
    --logShow({ SKey, Index }, "BreakUseKeys")
    if Index and ItemPos then
      --logShow({ Index, ItemPos }, Effect)
      self.ActItem, self.ItemPos = self.Items[ItemPos], ItemPos
      --self.Effect = E_Shared -- DEBUG only
      local KeyData = Menu.LocalUseKeys[Index]
      self.Effect = KeyData.Effect or E_Shared
      self.Action = KeyData.Action or A_Replace
      if self:ApplyWordAction() == nil then return end

      return MakeUpdate()
    end -- if Index

    --logShow(VirKey, "Info on Key Press: before")
    if not (VMod == 0 or IsModShift(VMod)) and
       not (Cfg.ActionAlt and IsModAlt(VMod)) then
      --logShow(VirKey, "Info on Key Press: inner")
      return nil, Cfg.UndueOut and CancelFlag or nil
    end
    --logShow(VirKey, "Info on Key Press: after")

    -- Учёт нажатия клавиш действий.
    local Name = KeyActionNames[VirKey.KeyName]
    --logShow(Name, VirKey.KeyName)
    if Name then
      if not KeyActions[Name](EditorGetInfo()) then return end
      --logShow(Name, VirKey.KeyName)
      return MakeUpdate()
    end
    if IsModAlt(VMod) then
      return nil, Cfg.UndueOut and CancelFlag or nil
    end

    --logShow(VirKey, "Info on Key Press: Spec")
    -- Учёт нажатия клавиш-символов.
    local SpecKeyChar = SpecKeyChars[SKey]
    if not SpecKeyChar and not isVKeyChar(VKey) then
      --logShow({ VirKey, Cfg.UndueOut, CancelFlag }, "Key is not Char")
      return nil, Cfg.UndueOut and CancelFlag or nil
    end

    --logShow(VirKey, "Info on Key Press: Char")
    local Char = SpecKeyChar or VirKey.UnicodeChar
    --logShow(Char, hex(VKey))
    if Cfg.Trailers:find(Char, 1, true) and
       not (Cfg.UseMagic and
            (LuaCards:find(Char, 1, true) or
             Cfg.UsePoint and Char == '.') ) then
      --logShow(Char, Cfg.Trailers)
      if ItemPos then
        self.ActItem, self.ItemPos = self.Items[ItemPos], ItemPos
        self.Effect, self.Action = false, A_Replace
        if self:ApplyWordAction() == nil then return end
      end
      if not InsText(Char) then return end
      return nil, CancelFlag
    end

    if not InsText(Char) then return end
    if Cfg.OnCharPress then Cfg.OnCharPress(VirKey, Char) end

    return MakeUpdate()
  end -- KeyPress

  --editor.Select({ BlockType = "BTYPE_NONE" }) -- Снятие выделения

  -- Назначение обработчика:
  local RM = self.Props.RectMenu
  RM.OnKeyPress = KeyPress
end -- AssignEvents

end --
do
  local EditorProcKey = editor.ProcessInput

-- Цикл вывода меню слов до выбора.
function TMain:ShowLoop () --> (bool | nil)

  local Cfg, Popup = self.CfgData, self.Popup
  --logShow(Cfg, "Cfg", 1)

  -- Информация о меню:
  self.Items = false
  self.Props = self.Menu.Props

  repeat
    -- Формирование начального списка-меню --
    self.Current = { StartMenu = true }
    self:MakeWordsList()
    self.Current.StartMenu = nil
    --logShow({ self.Props, self.Items }, "Word Completion")

    -- Сброс текущего выбора
    --self.Action, self.Effect = false, false
    --self.ActItem, self.ItemPos = false, false

    -- Управление списком --
    if self.Items and #self.Items == 1 and Cfg.LoneAuto then
      self.ActItem, self.ItemPos = self.Items[1], 1
      --logShow({ self.ItemPos, self.ActItem }, "Lone AutoCompletion")
    else
      self.ActItem, self.ItemPos = self:ShowMenu()
      if not self.Items or not self.ActItem then
        if Popup.PressKey then EditorProcKey(nil, Popup.PressKey) end
        return false
      end -- Отмена по Esc
      editor.Select(nil, F.BTYPE_NONE) -- Снятие выделения
    end

    -- Выполнение выбранного действия --
    self.Action = self.ActItem.Action or A_Replace -- По умолчанию -- Выбор по Enter
    --logShow({ self.Action, self.ItemPos, self.ActItem }, "Completion Action")

    -- Реакция на отмену: Закрытие без всякого выбора.
    if self.Action == A_Cancel then return false end

    if self.ItemPos then
      self.Effect = self.ActItem.Effect
      --logShow({ Action, Pos, Items }, "Making Action")
      self.ActItem = self.Items[self.ItemPos]
      if self:ApplyWordAction() == nil then return end
    end
  until not self.Effect

  return true
end -- ShowLoop

end -- do

---------------------------------------- ---- Run
function TMain:Run () --> (bool | nil)

  self:AssignEvents()

  --editor.Select({ BlockType = "BTYPE_NONE" }) -- Снятие выделения

  return self:ShowLoop()
end -- Run

---------------------------------------- main

function unit.Execute (Data) --> (bool | nil)

  local _Main = CreateMain(Data)
  if not _Main then return end

  --logShow(Data, "Data", 2)
  --logShow(_Main, "Config", "_d2")
  --logShow(_Main.CfgData, "CfgData", 2)
  if not _Main.CfgData.Enabled then return end

  _Main:Prepare()
  if _Main.Error then return nil, _Main.Error end

  return _Main:Run()
end ---- Execute

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
