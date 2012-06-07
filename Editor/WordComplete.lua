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
  Word Completion plugin.
  (Word completion in editor.)
  © 1999, Andrey Tretjakov etc.
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
local EditorRedraw  = editor.Redraw
local EditorProcKey = editor.ProcessInput

----------------------------------------
--local context = context

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'
local numbers = require 'context.utils.useNumbers'
local colors = require 'context.utils.useColors'

local isFlag, delFlag = utils.isFlag, utils.delFlag

local abs = math.abs
local min2, max2 = numbers.min2, numbers.max2

local addNewData = tables.extend

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.luaUtils"
local extUt = require "Rh_Scripts.Utils.extUtils"
local farUt = require "Rh_Scripts.Utils.farUtils"
local macUt = require "Rh_Scripts.Utils.macUtils"
local menUt = require "Rh_Scripts.Utils.menUtils"

----------------------------------------
--local fkeys = require "far2.keynames"
--local InputRecordToName = fkeys.InputRecordToName

local keyUt = require "Rh_Scripts.Utils.keyUtils"

local isVKeyChar = keyUt.isVKeyChar
local IsModAlt, IsModShift = keyUt.IsModAlt, keyUt.IsModShift
local GetModBase = keyUt.GetModBase

----------------------------------------
--[[
local hex = numbers.hex8
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

local usercall = farUt.usercall
--local RunMenu = require "Rh_Scripts.RMenu.RectMenu"
local RunMenu = usercall(nil, require, "Rh_Scripts.RMenu.RectMenu")

---------------------------------------- Keys
-- Названия действий завершения.
local ActionNames = {
  Cancel  = "Cancel",
  Replace = "Replace",
  Insert  = "Insert",
} --- ActionNames
local EffectNames = {
  Shared  = "Shared",
} --- EffectNames

local A_Cancel  = ActionNames.Cancel
local A_Replace = ActionNames.Replace
local A_Insert  = ActionNames.Insert
local E_Shared  = EffectNames.Shared

local CompleteKeys = { -- Клавиши завершения слова:
  { BreakKey = "Tab",           Action = A_Replace },
  { BreakKey = "ShiftTab",      Action = A_Insert  },
  { BreakKey = "ShiftEnter",    Action = A_Insert  },
  { BreakKey = "ShiftNumEnter", Action = A_Insert  },
} --- CompleteKeys
local LocalUseKeys = { -- Клавиши локального использования:
  { BreakKey = "CtrlEnter",       Action = A_Replace, Effect = E_Shared },
  { BreakKey = "CtrlShiftEnter",  Action = A_Insert,  Effect = E_Shared },
} --- LocalUseKeys

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
  Left      = "left",
  Right     = "right",
  Up        = "up",
  Down      = "down",
  NumDel    = "del",
} --- KeyActionNames

local KeyActions = macUt.MacroActions.editor.plain

---------------------------------------- Config
local DefCfgData = { -- Конфигурация по умолчанию:
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
  -- Свойства завершения слова:
  Trailers = ",:;.?!",-- Символы-завершители.
  UndueOut = false,   -- Отмена завершения при неверных клавишах.
  LoneAuto = false,   -- Автодополнение при одном слове в списке.
  TailOnly = false,   -- Добавление только ненабранной части слова.
} --- DefCfgData

----------------------------------------
local AutoCfgData = { -- Конфигурация для авто-режима:
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
  -- Свойства завершения слова:
  Trailers = "",
  UndueOut = true,
  LoneAuto = false,
  TailOnly = false,
  -- Специальные параметры:
  Custom = {
    isAuto = true,
    --isSmall = false,
    name = "AutoComplete",
  }, --
} --- AutoCfgData
unit.AutoCfgData = AutoCfgData

---------------------------------------- Types
local DlgTypes = { -- Типы элементов диалогов:
  Enabled = "chk",
  -- Свойства набранного слова:
  CharEnum = "edt",
  CharsMin = { Type = "edt", Format = "number",
               --Default = DefCfgData.CharsMin,
               Range = { min = 0, max = 10 }, },
  UseMagic = "chk",
  UsePoint = "chk",
  UseInside  = "chk",
  UseOutside = "chk",
  -- Свойства отбора слов:
  MinLength = { Type = "edt", Format = "number",
                --Default = DefCfgData.MinLength,
                Range = { min = 2, max = 9 }, },
  FindsMax = { Type = "edt", Format = "number",
               --Default = DefCfgData.FindsMax,
               Range = { min =  8, max = 500 }, },
  PartFind = "chk",
  MatchCase = "chk",
  FindKind = { Type = "cbx", Prefix = "FK_";
               "customary", "unlimited", "alternate", "trimmable" },
  LinesUp   = { Type = "edt", Format = "number",
                --Default = DefCfgData.LinesUp,
                Range = { min = 0, max = 10000 }, },
  LinesDown = { Type = "edt", Format = "number",
                --Default = DefCfgData.LinesDown,
                Range = { min = 0, max = 10000 }, },
  -- Свойства сортировки:
  SortKind = { Type = "cbx", Prefix = "SK_";
               "searching", "character", "closeness", "frequency" },
  SortsMin = { Type = "edt", Format = "number",
               --Default = DefCfgData.SortsMin,
               Range = { min = 2, max = 50 }, },
  -- Свойства списка слов:
  ListsMax = { Type = "edt", Format = "number",
               --Default = DefCfgData.ListsMax,
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
} --- DlgTypes

---------------------------------------- Configure
local ScriptName = "WordComplete"
local ScriptPath = "scripts\\Rh_Scripts\\Editor\\"

local DefCustom = {
  name = ScriptName,
  path = ScriptPath,

  label = "WC",
  file = "WordCmpl",

  help   = { topic = ScriptName },
  locale = { kind = 'load' },
} --- DefCustom

-- Обработка конфигурации.
local function Configure (ArgData)
  -- 1. Заполнение ArgData.
  local ArgData = ArgData == "AutoCfgData" and AutoCfgData or ArgData
  ArgData = addNewData(ArgData, DefCfgData)
  ArgData.Custom = ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(ArgData, "ArgData")
  local Custom = datas.customize(ArgData.Custom, DefCustom)
  -- 2. Заполнение конфигурации.
  local History = datas.newHistory(Custom.history.full)
  local CfgData = History:field(Custom.history.field)
  local WMenu = CfgData.Menu or {}; CfgData.Menu = WMenu
  WMenu.CKeys = WMenu.CKeys or CompleteKeys
  WMenu.LKeys = WMenu.LKeys or LocalUseKeys
  -- 3. Дополнение конфигурации.
  setmetatable(CfgData, { __index = ArgData })
  --logShow(CfgData, "CfgData")
  local Config = { -- Конфигурация:
    Custom = Custom, History = History, DlgTypes = DlgTypes,
    CfgData = CfgData, ArgData = ArgData, --DefCfgData = DefCfgData,
  } ---
  locale.customize(Config.Custom) -- Инфо локализации
  --logShow(Config.Custom, "Custom")

  return Config
end --function Configure

---------------------------------------- Locale
local LocData -- Данные локализации
local L -- Класс сообщений локализации

---------------------------------------- Dialog
local dialog = require "far2.dialog"
local dlgUt = require "Rh_Scripts.Utils.dlgUtils"

local DI = dlgUt.DlgItemType
local DIF = dlgUt.DlgItemFlag
local ListItems = dlgUt.ListItems

-- Диалог конфигурации.
local function Dlg (Config) --> (dialog)
  local DBox = Config.DBox
  local isAuto = Config.Custom.isAuto
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
  local Caption = L:caption(isAuto and "DlgAuto" or "Dialog")

  local D = dialog.NewDialog() -- Форма окна:
                    -- 1          2     3    4   5  6  7  8  9  10
                    -- Type      X1    Y1   X2  Y2  L  H  M  F  Data
  D._             = {DI.DBox,     I,    J, W+2,  H, 0, 0, 0, 0, Caption}
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
  -- Кнопки управления:
  D.sep           = {DI.Text,     0,  H-2,   0,  0, 0, 0, 0, DIF.SeparLine, ""}
  D.chkEnabled    = {DI.Check,    A,  H-1,   M,  0, 0, 0, 0, 0, L:config"Enabled"}
  D.btnOk         = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel     = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Cancel"}

  return D
end --function Dlg

local ConfigGuid = win.Uuid("642eb0fd-d297-4855-bd87-dcecfc55bcc4")

-- Настройка конфигурации.
function unit.ConfigDlg (Data)
  -- Конфигурация:
  local Config = Configure(Data)
  local HelpTopic = Config.Custom.help.tlink
  -- Локализация:
  LocData = locale.getData(Config.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not LocData then return end
  L = locale.make(Config.Custom, LocData)
  -- Конфигурация:
  local isAuto = Config.Custom.isAuto
  local isSmall = Config.Custom.isSmall
  if isSmall == nil then isSmall = true end
  -- Подготовка:
  Config.DBox = {
    cSlab = 3, cFind = 4, cSort = 1,
    cList = isAuto and 1 or 3,
    cCmpl = isAuto and 1 or 2,
    Flags = isSmall and F.FDLG_SMALLDIALOG or nil,
    Width = 0, Height = 0,
  } --
  local DBox = Config.DBox
  DBox.Width  = 2 + 36*2 -- Edge + 2 columns
          -- Edge + (sep+Btns) + group separators and
  DBox.Height = 2 + 2 + 5*2 + -- group empty lines + group item lines
                DBox.cSlab + DBox.cFind + DBox.cSort + DBox.cList + DBox.cCmpl
  if not isSmall then
    DBox.Width, DBox.Height = DBox.Width + 4*2, DBox.Height + 1*2
  end

  -- Настройка:
  local D = Dlg(Config)
  local cData, aData, Types = Config.CfgData, Config.ArgData, Config.DlgTypes
  dlgUt.LoadDlgData(cData, aData, D, Types) -- Загрузка конфигурации
  local iDlg = dlgUt.Dialog(ConfigGuid, -1, -1,
                            DBox.Width, DBox.Height, HelpTopic, D, DBox.Flags)
  --logShow(D, "D", 3)
  if D.btnOk and iDlg == D.btnOk.id then
    dlgUt.SaveDlgData(cData, aData, D, Types) -- Сохранение конфигурации
    --logShow(Config, "Config", 3)
    Config.History:save()

    return true
  end
end ---- ConfigDlg

---------------------------------------- Words
local LuaCards    = extUt.const.LuaCards
--local LuaCardsSet = extUt.const.LuaCardsSet
local CharControl = extUt.CharControl

-- Поиск слов, подходящих к текущему.
local function SearchWords (Cfg, Ctrl) --> (table)
  local CfgCur = Cfg.Current
  local Word, Slab = CfgCur.Word, CfgCur.Slab
  local MaxLine, MinLen = CfgCur.MaxLine, Cfg.MinLength
  local wCtr, wMax = 0, CfgCur.WordsMax
  local wMid, GetLine = bshr(wMax, 1), CfgCur.GetLine

  local WordFind, FindKind = not Cfg.PartFind, Cfg.FindKind
  local Limited = Cfg.FindKind ~= "unlimited"
  local Trimmed = Cfg.FindKind == "trimmable"

  -- Таблица слов с дополнительной информацией:
  local t = { Stat = {}, Link = { Line = CfgCur.CurLine } }
  local Stat = t.Stat -- Статистика встречаемости
  local Link = t.Link -- "Ссылочная" информация

  --logShow({ CfgCur.Slab, Slab }, "Slab")
  local SlabPat = Ctrl:asPattern(Slab) -- Подготовка Slab для поиска
  local BasePat = ("(%s%s+)"):format(SlabPat, Ctrl.CharsSet)
  local StartPat = '^'..BasePat
  local MatchPat = Ctrl.SeparSet..BasePat
  Cfg.Patterns = { Slab = SlabPat, Base = BasePat,
                   Start = StartPat, Match = MatchPat }
  --logShow(Cfg.Patterns, "SearchWords Patterns")

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
        Stat[w] = { Count = 1, Line = Line, Slot = k }
      end
    end --function MakeWord

    if WordFind then
      local v = s:match(StartPat)
      if v then MakeWord(v) end
      for w in s:gmatch(MatchPat) do MakeWord(w) end
    else
      for w in s:gmatch(BasePat) do MakeWord(w) end
    end

    return k
  end -- function MatchLineWords

  -- Поиск слов в текущей строке.
  Link.Line = CfgCur.CurLine
  wCtr = wCtr + MatchLineWords(GetLine(), 0)
  if Limited and wCtr >= wMax then return t end
  --logShow(t, "SearchWords")

  if FindKind == "alternate" then
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
end -- SearchWords

---------------------------------------- Sort
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
local function SortWords (t, Cfg) --> (table)
  local FindKind, SortKind = Cfg.FindKind, Cfg.SortKind
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
end --function SortWords

---------------------------------------- Special
local SharedMatch = "^(%s+)%s*\n%%1%s*"

-- Поиск общей части строк.
local function SharedPart (Words, Cfg, Ctrl) --> (string)
  local Set, NoCase = Ctrl.CharsSet, not Cfg.MatchCase
  local SharedPat = SharedMatch:format(Set, Set, Set)
  Cfg.Patterns.Shared = SharedPat
  local s, w = Words[1]
  if NoCase then s = s:lower() end
  for k = 2, Words.n do
    w = Words[k]
    if NoCase then w = w:lower() end
    s = (s..'\n'..w):match(SharedPat)
    if not s then return "" end
  end -- for
  return s
end --function SharedPart

---------------------------------------- List
local HotChars = "1234567890abcdefghijklmnopqrstuvwxyz"
local HotCharsLen = HotChars:len()

local ItemHotFmt, ItemHotLen = "&%s ", 2
--local ItemHotFmt, ItemHotLen = "&%s | ", 4
local ItemTextFmt = ItemHotFmt.."%s"

local Guid = win.Uuid("64b26458-1e8b-4844-9585-becfb1ce8de3") --> Class field

-- Заполнение списка-меню.
local function PrepareMenu (Words, Cfg, Props) --> (table)
  -- Создание таблицы пунктов меню.
  local Count = Words.n --or #Words
  local Width, Height = 0, Count
  if Count == 0 and (Cfg.Current.StartMenu and
     not Cfg.EmptyStart or not Cfg.EmptyList) then
    return
  end

  local Items, Word, Text = {}
  for k = 1, Count do
    Word = Words[k]
    if Cfg.HotChars and k <= HotCharsLen then
      Text = ItemTextFmt:format(HotChars:sub(k, k), Word)
    else Text = Word end -- if
    Items[#Items+1] = { text = Text, Word = Word, } ---
    --Width = max2(Width, Word:len())
    Width = max2(Width, Text:len())
  end
  if Cfg.HotChars then Width = Width - 1 end

  -- Определение области маркировки.
  local function MakeSlabMark ()
    --logShow(Cfg.Patterns, "Cfg.Patterns")
    local SlabPat = Cfg.Patterns.Slab
    local SlabLen = Cfg.Current.Slab:len()
    if Cfg.HotChars then    -- text ~= Word:
      return Cfg.UseMagic and { " "..SlabPat } or
             { ItemHotLen + 1, ItemHotLen + SlabLen }
    else                    -- text == Word:
      return Cfg.UseMagic and { SlabPat } or { 1, SlabLen }
    end -- if
  end --

  -- Задание параметров меню RectMenu.
  local RM_Props = Props.RectMenu
  RM_Props.Guid = RM_Props.Guid or Guid
  --logShow(RM_Props, "RectMenu Props")
  if Cfg.SlabMark then RM_Props.TextMark = MakeSlabMark() end -- Маркировка
  -- Расчёт позиции и размера окна:
  local Info, WM_Cfg = EditorGetInfo(), Cfg.WordsList
  Width, Height = Width + WM_Cfg.CorLenH, Height + WM_Cfg.CorLenV
  --[[
  local Rect, CursorPos = GetFarRect(), far.AdvControl(F.ACTL_GETCURSORPOS)
  logShow({ Info, Rect, CursorPos }, "Window info")
  --]]
  local Pos = {
    x = Info.CurPos  - Info.LeftPos       + WM_Cfg.CorPosX,
    y = Info.CurLine - Info.TopScreenLine + WM_Cfg.CorPosY,
  } ---
  --logShow({ RM_Props.MenuEdge, Width, Height, Pos, Info }, "Position")
  Pos.y = Pos.y <= Height and Pos.y + 1 or Pos.y - Height
  Pos.x = Pos.x + Width + 1 < Info.WindowSizeX and Pos.x or Pos.x - Width - 1
  -- Warning: "<" & "+1" instead of "<=" because editor may have scroll bar.
  RM_Props.Position = Pos
  --[[
  local Rect, Pos = farUt.GetFarRect(), far.AdvControl(F.ACTL_GETCURSORPOS)
  logShow({ RM_Props.MenuEdge, Width, Height, Pos, Info }, "Position")
  if Pos.X + Width  >= Rect.Width  then Pos.X = Pos.X - Width - 1 end
  if Pos.Y + Height >= Rect.Height then Pos.Y = Pos.Y - Height else Pos.Y = Pos.Y + 1 end
  RM_Props.Position = { x = Pos.X, y = Pos.Y }
  --]]
  --logShow(RM_Props.Position, "RectMenu Position")
  --logShow(Items, "Items")
  return Items, Props
end --function PrepareMenu

-- Формирование списка-меню слов.
local function MakeWordsList (Cfg, Props) --> (table)
  -- Базовая информация о редакторе:
  local Info = EditorGetInfo() -- Сохранение базовой позиции
  --logShow(Info, "Editor Info")
  local Ctrl = CharControl(Cfg) -- Функции управления словом

-- 1. Анализ текущего набранного слова.

  -- Получение текущего слова под курсором (CurPos is 0-based):
  local Word, Slab = Ctrl:atPosWord(EditorGetStr(nil, -1, 2), Info.CurPos + 1)
  --logShow({ Word, Slab })
  if not Ctrl:isWordUse(Word, Slab) then return end -- Проверка на выход

  local CfgCur = Cfg.Current
  CfgCur.Word, CfgCur.Slab = Word, Slab
  --if Word then logShow(Cfg.Current) end

-- 2. Отбор подходящих слов для завершения.

  local WM_Cfg = Cfg.WordsList -- Число слов для отбора:
  local lMax = Info.CurLine - Info.TopScreenLine            -- Учёт случаев:
  lMax = max2(Info.WindowSizeY - lMax - 2, lMax)            -- список сверху
  lMax = min2(Cfg.ListsMax, max2(lMax - WM_Cfg.CorLenV, 1)) -- список снизу
  CfgCur.WordsMax = max2(Cfg.FindsMax, lMax)

  -- Информация для работы со строками файла (Line number is 0-based):
  CfgCur.CurLine, CfgCur.MaxLine = Info.CurLine, Info.TotalLines
  CfgCur.GetLine = function (n) return EditorGetStr(nil, n or -1, 2) end

  -- Поиск подходящих слов в строках файла:
  local Words = SearchWords(Cfg, Ctrl)

  EditorSetPos(nil, Info) -- Восстановление базовой позиции

  -- Задание максимального числа слов
  if #Words == 0 then return end
  Words.n = min2(#Words, lMax) -- Максимальное число слов
  local wLink = Words.Link -- Информация для closeness-сортировки
  wLink.Up, wLink.Down = wLink.Up or Words.n, wLink.Down or Words.n

  --logShow(Words, "Words", 2)

-- 3. Сортировка собранных слов.

  Words = SortWords(Words, Cfg) -- Сортировка собранных слов
  --CfgCur.Words = Words
  --logShow(Words, "Words", 1)

-- 4. Подготовка списка-меню слов.

  CfgCur.Shared = SharedPart(Words, Cfg, Ctrl) -- Общая часть слов
  --if Word then logShow(CfgCur) end

  return PrepareMenu(Words, Cfg, Props)
end --function MakeWordsList

---------------------------------------- Apply
-- Удаление Count символов:
local EC_Actions = macUt.MacroActions.editor.cycle
local DelChars = EC_Actions.del
local BackChars = EC_Actions.bs

local function InsText (text)
  return EditorInsText(nil, text)
end --

-- Завершение слова.
local function ApplyWordAction (Cfg, Complete, Action) --> (bool | nil)
  local Word, Slab = Cfg.Current.Word, Cfg.Current.Slab
  local SLen = Slab:len()
  --logShow({ Complete, Word, Word:len(), Slab, SLen }, Action, 1)

  if Action == A_Replace then -- Удаление конца
    if not DelChars(nil, Word:len() - SLen) then return end
  end

  if Cfg.TailOnly then -- Только добавление остатка:
    if not InsText(Complete:sub(SLen + 1, -1)) then return end
  else -- Замена слова выбранным:
    if not BackChars(nil, SLen) then return end
    if not InsText(Complete) then return end
  end

  EditorRedraw()
  return true
end --function ApplyWordAction

---------------------------------------- Make
local WC_Flags = { isRedraw = false, isRedrawAll = true }
local CloseFlag, CancelFlag = { isClose = true }, { isCancel = true }

local function MakeComplete (Cfg) --> (bool | nil)

  local Action, Effect -- Действие
  local PressKey -- Нажатая клавиша
  --logShow(Cfg, "Cfg", 1)
  local WMenu = Cfg.Menu
  local Props, Items = WMenu.Props -- Информация о меню
  -- Клавиши-завершители:
  local WC_Keys = WMenu.CKeys
  local LU_Keys, LB_Keys = WMenu.LKeys, WMenu.LBKeys

--[[ 1. Конфигурирование WordComplete ]]

--[[ 1.1. Управление настройками ]]
  local RM_Props = Props.RectMenu

  --local VMod, VKey, SKey -- Информация о клавише
  local Index, Complete -- Локальное использование

--[[ 2.1. Обработка нажатия клавиши ]]
  -- Обработчик нажатия клавиши.
  local function KeyPress (VirKey, SelIndex)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end

    -- Предварительный анализ клавиши.
    PressKey = Cfg.UndueOut and VirKey or false
    local VKey = VirKey.VirtualKeyCode
    local VMod = GetModBase(VirKey.ControlKeyState)
    --logShow({ VKey, VMod, SKey }, "VirKey", 1, "xv2")

    local function MakeUpdate () -- Обновление!
      PressKey = false
      farUt.RedrawAll()
      -- Формирование нового списка-меню слов.
      Items, Props = MakeWordsList(Cfg, Props)
      if not Items then return nil, CloseFlag end
      --logShow(SelIndex, hex(FKey))
      return { Props, Items, WC_Keys }, WC_Flags
    end --

    -- Учёт нажатия клавиш локального использования.
    Index = LB_Keys[SKey]
    if Index then
      Action = LU_Keys[Index].Action or A_Replace
      Effect = LU_Keys[Index].Effect or E_Shared
      --logShow({ Index, SelIndex }, Action)
      if Effect and SelIndex then
        -- Effect == E_Shared --
        Complete = Items[SelIndex].Word:sub(1, Cfg.Current.Shared:len())
        if Complete ~= "" then -- Выбор:
          ApplyWordAction(Cfg, Complete, Action)
        end
        return MakeUpdate()
      end
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
    --logShow({ Name }, VirKey.KeyName)
    if Name then
      if not KeyActions[Name](EditorGetInfo()) then return end
      --logShow(KeyAction, VirKey.KeyName)
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

    if Cfg.Trailers:find(Char, 1, true) and not (Cfg.UseMagic and
       (LuaCards:find(Char, 1, true) or Cfg.UsePoint and Char == '.')) then
      --logShow(Char, Cfg.Trailers)
      if SelIndex then
        ApplyWordAction(Cfg, Items[SelIndex].Word, A_Replace)
      end
      if not InsText(Char) then return end
      return nil, CancelFlag
    end

    if not InsText(Char) then return end
    if Cfg.OnCharPress then Cfg.OnCharPress(VirKey, Char) end

    return MakeUpdate()
  end --function KeyPress

  --editor.Select({ BlockType = "BTYPE_NONE" }) -- Снятие выделения

  -- Назначение обработчика:
  RM_Props.OnKeyPress = KeyPress

  local Item, Pos -- Выбранный пункт и его позиция

  repeat
--[[ 1.2. Формирование начального списка-меню ]]
    Cfg.Current = { StartMenu = true }
    Items, Props = MakeWordsList(Cfg, Props)
    Cfg.Current.StartMenu = nil
    --logShow({ Props, Items }, "Word Completion")

--[[ 2. Управление списком WordComplete ]]

    if Items and #Items == 1 and Cfg.LoneAuto then
      Item, Pos = Items[1], 1
      --logShow({ Pos, Item }, "Lone AutoCompletion")
    else
      --Item, Pos = RunMenu(Props, Items, WC_Keys)
      Item, Pos = usercall(nil, RunMenu, Props, Items, WC_Keys)
      if not Items or not Item then
        if PressKey then EditorProcKey(nil, PressKey) end
        return false
      end -- Отмена по Esc
      editor.Select(nil, { BlockType = "BTYPE_NONE" }) -- Снятие выделения
    end
    Action = Item.Action or A_Replace -- По умолчанию -- Выбор по Enter

--[[ 2.2. Выполнение выбранного действия ]]
    --logShow({ Action, Pos, Items }, "Completion Action")
    -- Реакция на отмену: Закрытие без всякого выбора.
    if Action == A_Cancel then return false end
    -- Реакция на неизвестное действие: Выход с ошибкой.
    --if Action ~= "Replace" and Action ~= "Insert" then return nil, Action end
    Effect = Item.Effect
    if Effect then
      Complete = Items[Pos].Word:sub(1, Cfg.Current.Shared:len())
      if Complete ~= "" then -- Выбор:
        ApplyWordAction(Cfg, Complete, Action)
        --farUt.RedrawAll() -- Обновление!
      end
    elseif Action == "Replace" or Action == "Insert" then
      --logShow({ Action, Pos, Items }, "Making Action")
      ApplyWordAction(Cfg, Items[Pos].Word, Action)
    else
      return
    end -- if
  until not Effect

  return true
end --function MakeComplete

---------------------------------------- main
local Colors = menUt.MenuColors()
local setBG = colors.setBG
local HighlightOff = menUt.HighlightOff

-- Названия элементов для изменения цвета.
local Col_MenuSelText = "COL_MENUSELECTEDTEXT"
local Col_MenuSelMark = "COL_MENUSELECTEDMARKTEXT"
local Col_MenuSelHigh = "COL_MENUSELECTEDHIGHLIGHT"

function unit.Execute (Data) --> (bool | nil)
--[[ 1. Разбор параметров ]]
  -- Конфигурация:
  local Config = Configure(Data)
  local CfgData = Config.CfgData
  --logShow(Data, "Data", 2)
  --logShow(Config, "Config", "_d2")
  --logShow(CfgData, "CfgData", 2)
  if not CfgData.Enabled then return end

  -- Свойства меню:
  local WMenu = CfgData.Menu
  local Props = WMenu.Props or {}
  WMenu.Props = Props
  Props.Title = ""
  --Props.Title = "Completion"
  Props.Flags = F.FMENU_WRAPMODE
  Props.Flags = HighlightOff(Props.Flags)

  -- Клавиши локального использования:
  WMenu.LBKeys = menUt.ParseMenuHandleKeys(WMenu.LKeys)

  -- Свойства RectMenu:
  local RM_Props = Props.RectMenu or {}
  Props.RectMenu = RM_Props
  RM_Props.Cols = 1
  RM_Props.BoxKind = "S"
  RM_Props.NoShadow = true
  --RM_Props.MenuOnly = true
  RM_Props.Colors = {
    [Col_MenuSelText] = setBG(Colors[Col_MenuSelText], 0x1),
    [Col_MenuSelMark] = setBG(Colors[Col_MenuSelMark], 0x1),
    [Col_MenuSelHigh] = setBG(Colors[Col_MenuSelHigh], 0x1),
  } --
  RM_Props.MenuEdge = 0 --1
  RM_Props.AltHotOnly = true

  -- Значения для списка-меню:
  local BoxLen = RM_Props.BoxKind and 2 or 0
  local Info = EditorGetInfo()
  local CurPos = far.AdvControl(F.ACTL_GETCURSORPOS)
  CfgData.WordsList = {
    CorLenH = BoxLen + bshl(RM_Props.MenuEdge, 1), --+ (CfgData.HotChars and 2 or 0),
    CorLenV = BoxLen + bshl(bshr(RM_Props.MenuEdge, 1), 1),
    CorPosX = max2(CurPos.X - (Info.CurPos - Info.LeftPos), 0),
    CorPosY = max2(CurPos.Y - (Info.CurLine - Info.TopScreenLine), 0),
    --CorPosY = CurPos.Y > Info.CurLine - Info.TopScreenLine and 1 or 0,
  } --
  BoxLen, Info = nil

  -- Свойства набранного слова:
  -- Свойства отбора слов:
  -- Свойства сортировки:
  -- Свойства списка слов:
  -- Свойства завершения слова:

  -- Свойства меню:
  if CfgData.HotChars then
    Props.Flags = delFlag(Props.Flags, F.FMENU_SHOWAMPERSAND)
  end

--[[ 2. Вызов с параметрами ]]
  return MakeComplete(CfgData)
end ---- Execute

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
