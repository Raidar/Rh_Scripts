--[[ Text Templates ]]--

----------------------------------------
--[[ description:
  -- Text Templates.
  -- Текстовые шаблоны.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  far2,
  LF context,
  Rh Utils.
  -- areas: editor.
--]]
----------------------------------------
--[[ idea from:
  truemac plugin.
  (true macro processor.)
  (c) 2000, raVen.
  Home: http://raven.elk.ru/
--]]
--------------------------------------------------------------------------------

local type, unpack = type, unpack
local pairs, ipairs = pairs, ipairs
local tostring = tostring
local require, pcall = require, pcall
local setmetatable = setmetatable

----------------------------------------
local bit = bit64
--local band, bor = bit.band, bit.bor
local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local win, far, regex = win, far, regex
local F = far.Flags

local EditorGetInfo = editor.GetInfo
local EditorSetPos  = editor.SetPosition
local EditorGetStr  = editor.GetString
local EditorInsText = editor.InsertText
local EditorRedraw  = editor.Redraw

----------------------------------------
local context = context
local detect = context.detect

local utils = require 'context.utils.useUtils'
local strings = require 'context.utils.useStrings'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local newFlags = utils.newFlags
local isFlag, delFlag = utils.isFlag, utils.delFlag

local addNewData = tables.extend

----------------------------------------
local luaUt = require "Rh_Scripts.Utils.luaUtils"
local extUt = require "Rh_Scripts.Utils.extUtils"
local farUt = require "Rh_Scripts.Utils.farUtils"
local macUt = require "Rh_Scripts.Utils.macUtils"

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--logShow(context, "context", 3)

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Config
local DefCfgData = { -- Конфигурация по умолчанию:
  Enabled = true,
  -- Свойства набранного слова:
  CharEnum = "%S",   -- Допустимые символы слова.
  CharsMin = 0,      -- Минимальное число набранных символов слова.
  UseMagic = false,  -- Использование "магических" модификаторов.
  UsePoint = false,  -- Использование символа '.' как "магического".
  UseInside  = true, -- Использование внутри слов.
  UseOutside = true, -- Использование вне слов.
} --- DefCfgData

----------------------------------------
local AutoCfgData = { -- Конфигурация для авто-режима:
  Enabled = true,
  -- Свойства набранного слова:
  CharEnum = ".",
  --CharEnum = "%S",
  CharsMin = 2,
  UseMagic = false,
  UsePoint = false,
  UseInside  = true,
  UseOutside = true,
  Custom = {
    isAuto = true,
    --isSmall = false,
    name = "AutoTemplate",
    --options = {
    --  KitName  = "AutoTemplate",
    --},
  }, --
} --- AutoCfgData
unit.AutoCfgData = AutoCfgData

---------------------------------------- Types
-- Типы элементов диалогов:
local DlgTypes = {
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
} --- DlgTypes

---------------------------------------- Configure
local ScriptName = "TextTemplate"
local ScriptPath = "scripts\\Rh_Scripts\\Editor\\"

local DefCustom = {
  name = ScriptName,
  path = ScriptPath,

  label = "TT",

  help   = { topic = ScriptName },
  locale = { kind = 'load' },
} --- DefCustom

local DefOptions = {
  KitName  = "TextTemplate",
  BaseDir  = "Rh_Scripts.Editor",
  WorkDir  = "TextTemplate",
  FileName = "kit_config",
} ---

-- Обработка конфигурации.
local function Configure (ArgData)
  -- 1. Заполнение ArgData.
  local ArgData = ArgData == "AutoCfgData" and AutoCfgData or ArgData
  ArgData = addNewData(ArgData, DefCfgData)
  ArgData.Custom = ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(ArgData, "ArgData")
  local Custom = datas.customize(ArgData.Custom, DefCustom)
  --Custom.options.KitName = Custom.options.KitName or Custom.name
  addNewData(Custom.options, DefOptions)
  --logShow(ArgData, "ArgData")
  -- 2. Заполнение конфигурации.
  local History = datas.newHistory(Custom.history.full)
  local CfgData = History:field(Custom.history.field)
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
end -- Configure

---------------------------------------- Locale
local L -- Класс сообщений локализации

---------------------------------------- Dialog
local dialog = require "far2.dialog"
local dlgUt = require "Rh_Scripts.Utils.dlgUtils"

local DI = dlgUt.DlgItemType
local DIF = dlgUt.DlgItemFlag

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
  --local G = 6  -- Large numbers

  local J1 = J  + 1
  local Caption = L:caption(isAuto and "DlgAuto" or "Dialog")

  local D = dialog.NewDialog() -- Форма окна:
                    -- 1          2     3    4   5  6  7  8  9  10
                    -- Type      X1    Y1   X2  Y2  L  H  M  F  Data
  D._             = {DI.DBox,     I,    J, W+2,  H, 0, 0, 0, 0, Caption}
  -- Свойства набранного слова:
  --D.sep           = {DI.Text,     0,   J1,   0,  0, 0, 0, DIF.SeparLine, L:fmtsep"TypedWord"}
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
  -- Кнопки управления:
  D.sep           = {DI.Text,     0,  H-2,   0,  0, 0, 0, 0, DIF.SeparLine, ""}
  D.chkEnabled    = {DI.Check,    A,  H-1,   M,  0, 0, 0, 0, 0, L:config"Enabled"}
  D.btnOk         = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel     = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Cancel"}

  return D
end -- Dlg

local ConfigGuid = win.Uuid("6227affb-5e24-42ce-9ec0-106868fad0ba")

-- Настройка конфигурации.
function unit.ConfigDlg (Data)
  -- Конфигурация:
  local Config = Configure(Data)
  local HelpTopic = Config.Custom.help.tlink
  -- Локализация:
  local LocData = locale.getData(Config.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not LocData then return end
  L = locale.make(Config.Custom, LocData)
  -- Конфигурация:
  local isAuto  = Config.Custom.isAuto
  local isSmall = Config.Custom.isSmall
  --if isSmall == nil then isSmall = true end
  -- Подготовка:
  Config.DBox = {
    cSlab = 3,
    Flags = isSmall and F.FDLG_SMALLDIALOG or nil,
    Width = 0, Height = 0,
  } --
  local DBox = Config.DBox
  DBox.Width  = 2 + 36*2 -- Edge + 2 columns
          -- Edge + (sep+Btns) + group separators and
  DBox.Height = 2 + 2 + 1*2 + -- group empty lines + group item lines
                DBox.cSlab
  if not isSmall then
    DBox.Width, DBox.Height = DBox.Width + 4*2, DBox.Height + 1*2
  end

  -- Настройка:
  local D = Dlg(Config)
  local cData, aData, Types = Config.CfgData, Config.ArgData, Config.DlgTypes
  dlgUt.LoadDlgData(cData, aData, D, Types) -- Загрузка конфигурации
  local iDlg = dlgUt.Dialog(ConfigGuid, -1, -1,
                            DBox.Width, DBox.Height, HelpTopic, D, DBox.Flags)
  if D.btnOk and iDlg == D.btnOk.id then
    dlgUt.SaveDlgData(cData, aData, D, Types) -- Сохранение конфигурации
    Config.History:save() -- Сохранение файла

    return true
  end
end ---- ConfigDlg

---------------------------------------- Regex
local far_find, far_gsub = regex.find, regex.gsub

local find = {
  none = 0,
  lua  = function (s, pat) return s:cfind(pat) end,
  far  = function (s, pat, flags) return far_find(s, pat, 1, flags) end,
} --- find
find.none = find.lua

local gsub = {
  none = function (s, pat, res) return res end,
  lua  = function (s, pat, res) return s:gsub(pat, res, 1) end,
  far  = function (s, pat, res, flags) return far_gsub(s, pat, res, 1, flags) end,
} --- gsub

-- Поиск строки с учётом вида регэкспа.
local function sfind (s, pat, flags, regex) --> (number | nil)
  if find[regex] then return find[regex](s, pat, flags) end
end --

-- Глобальная замена в строке с учётом вида регэкспа.
local function sgsub (s, pat, res, flags, regex) --> (number | nil)
  if res and gsub[regex] then return gsub[regex](s, pat, res, flags) end
end --

---------------------------------------- Templates
local TplKits = {} -- Наборы шаблонов

-- MAYBE: Сделать загрузку в зависимости от типа текущего файла!!??

local format = string.format
local prequire, newprequire = luaUt.prequire, luaUt.newprequire

local CharControl = extUt.CharControl

-- Fill table with templates.
-- Заполнение таблицы шаблонов.
local function FillTemplatesData (Config)
  --far.Message("Load text templates", "Update")
  local Options = Config.Custom.options
  local Kit = TplKits[Options.KitName]
  --logShow(Kit, "Kit", 2)
  if Kit then return end -- TODO: Убрать в случае избират. загрузки.
  --local dorequire = newprequire -- For separate use!
  local dorequire = Kit == false and newprequire or prequire
  local FullDir = format("%s.%s.", Options.BaseDir, Options.WorkDir)
  local typesBind = dorequire(FullDir..Options.FileName)
  if typesBind == nil then return end -- No templates

  Kit = {}; TplKits[Options.KitName] = Kit
  local Cfg = Config.CfgData

  for k, v in pairs(typesBind) do
    local n = type(v) == 'string' and v ~= "" and v or tostring(k)
    Kit[k] = dorequire(FullDir..n)

    local w = Kit[k]
    if w then
      w.regex = (w.regex == nil or w.regex == true) and "lua" or w.regex or "none"
      addNewData(w, DefCfgData)
      --if not w.CharEnum and Cfg then w.CharEnum = Cfg.CharEnum end
      --if Cfg then addNewData(w, Cfg) end -- For separate use!
      --if k == 'source' then logShow({ Cfg, w }, "Fill: "..k, 1) end
      w.CharControl = CharControl(w)
    end
  end
  --logShow(Kit, "Kit", 2)

  return Kit
end -- FillTemplatesData

---------------------------------------- Words
local makeplain = strings.makeplain

local cfgFirstType = detect.use.configType
local cfgNextType  = detect.use.configNextType

-- Find templates in line.
-- Поиск шаблонов в строке.
local function FindTemplate (Config) --> (table)
  local Kit = TplKits[Config.Custom.options.KitName]
  if not Kit then return end
  --logShow(Kit, Config.Custom.options.KitName, 1)
  local Cfg = Config.CfgData
  --logShow(Cfg, "FindTemplate", "d2 t")
  local CfgCur = Cfg.Current
  local CurSlab = CfgCur.Slab -- CfgCur.Frag

  local t, tLast = {} -- Результаты поиска
  -- Цикл поиска по всем подходящим типам:
  local tp = cfgFirstType(CfgCur.FileType, Kit)
  while tp do
    --logShow(t, tp)
    local Tpls, noSkip = Kit[tp], true
    --logShow(Tpls, tp, 1)
    --logShow({ Tpls, Cfg, Cfg.CharEnum }, tp, 1)

    local Word, Slab
    local Ctrl = Cfg.CharEnum ~= Tpls.CharEnum and Tpls.CharControl
    if Ctrl then
      Word, Slab = Ctrl:atPosWord(CfgCur.Line, CfgCur.Pos)
      noSkip = Ctrl:isWordUse(Word, Slab) -- Проверка на пропуск
      --[[
      logShow({ { Word, Slab, noSkip },
                { Cfg.CharEnum, Cfg.UseInside,
                  Cfg.UseOutside, Cfg.CharsMin },
                { Ctrl.cfg.CharEnum, Ctrl.cfg.UseInside,
                  Ctrl.cfg.UseOutside, Ctrl.cfg.CharsMin } }, tp, 2)
      --]]
    end

    if noSkip then
      local q = 0 -- (!)
      local D_rex = Tpls.regex
      -- Цикл поиска по всем шаблонам:
      for k, v in ipairs(Tpls) do
        local f = v.find
        local regex = (v.regex == nil or
                       v.regex == true) and D_rex or
                      (v.regex or "none")
        if regex == "none" then f = makeplain(f) end -- plain!
        f = f.."$"
        local p = sfind(CurSlab, f, v.flags, regex)
        --logShow({ p, f, v, t[#t] }, tp)
        if p then
          if Ctrl then q = sfind(Slab, f, v.flags, regex) end
          --logShow({ k, f, t[#t] }, tp)

          -- Отбор с макс. длиной совпадения (мин. нач. позицией):
          local is_p =       (not tLast or p == 1 or tLast.Pos  > p)
          local is_q = q and (not tLast or q == 1 or tLast.qPos > q)

          if Ctrl and is_q or not Ctrl and is_p then
            tLast = {
              Tpl = v, Find = f, Pos = p, qPos = q, regex = regex,
              Type = tp, Index = k, --Tpls = Tpls, -- DEBUG
            } --
            --logShow({ k, f, t[#t], tLast }, tp)
            if #t == 0 then
              t[1] = tLast
            elseif (Ctrl and q and q == 1 and t[#t].qPos == 1) or
                   (not Ctrl   and p == 1 and t[#t].Pos  == 1) then
              t[#t+1] = tLast
            else
              t[#t] = tLast
            end
          end
        end -- if p
      end -- for
    end -- if noSkip
    tp = cfgNextType(tp, Kit)
  end -- while

  --if #t > 0 then logShow(t, "FindTemplate") end
  --if #t > 0 then logShow(t[#t], t[#t] and tostring(t[#t].Type)) end
  --if #t > 0 then logShow(t[#t], Config.Custom.options.KitName) end
  --logShow(Kit[Type], Type)
  return tLast and t or nil
end -- FindTemplate

---------------------------------------- Apply
local EC_Actions = macUt.MacroActions.editor.cycle
local DelChars = EC_Actions.del
--local BackChars = EC_Actions.bs

local RunMacro = macUt.RunMacro

local function RunPlain (text) --> (bool)
  if not EditorInsText(nil, text) then return end
  EditorRedraw()
  return true
end --

-- Apply found template.
-- Применение найденного шаблона.
local function ApplyTemplate (Cfg)
  --logShow(Cfg, "Cfg", "d2 t")
  --logShow(Cfg.Template, "Template", "d1 t")
  local CfgCur, CfgTpl = Cfg.Current, Cfg.Template
  local Tpl, Find, Pos = CfgTpl.Tpl, CfgTpl.Find, CfgTpl.Pos
  
  local Line = CfgCur.Slab:sub(Pos, -1)
  local DelLen = Line:len()
  CfgCur.Delete = Line

-- 1. Учёт способа вставки шаблона: замена или добавление.
  local res, isOk = Tpl.replace or Tpl.macro or Tpl.plain
  --logShow(Tpl, res, 2)

-- 2. Учёт использования регулярных выражений.
  res = sgsub(Line, Find, res, Tpl.flags, CfgTpl.regex)
  CfgTpl.Result = res or Line
  --logShow({ CfgCur }, "CfgCur", 2)

-- 3. Вставка шаблона в текст с учётом его вида.
  local kind = Tpl.kind --or (Tpl.replace and "macro")
  --logShow({ kind, Tpl, res }, "Apply", "d1 t")

  if Tpl.apply then  -- Apply-function
    --logShow(Tpl, "apply", 2)
    if Tpl.params then
      isOk, res = pcall(Tpl.apply, Cfg, unpack(Tpl.params))
    else
      isOk, res = pcall(Tpl.apply, Cfg, Tpl.param)
    end
    --logShow({ isOk, res }, "apply", 2)
    if not isOk then
      far.Message(res, "Error using "..DefCustom.Name, nil, "wl")
      return
    end
    if type(res) ~= 'string' then return false end
    kind = Tpl.as or "macro"
  end -- if
  --logShow({ kind, Tpl, res }, "Apply", "d1 t")

  local RunTpl
  if     Tpl.macro or kind == "macro" then -- Macro-template
    RunTpl = RunMacro
  elseif Tpl.plain or kind == "plain" then -- Plain template
    RunTpl = RunPlain
  end

  if RunTpl then
    if not Tpl.add then -- Замена
      EditorSetPos(nil, { CurPos = CfgCur.Frag:len() - DelLen })
      --logShow({ res, CfgCur.Frag:len(), DelLen }, "RunTpl")
      if not DelChars(nil, DelLen) then return end

      --logShow(res, "RunTpl")
      return RunTpl(res)
    end
  end

  return false
end -- ApplyTemplate

---------------------------------------- Make
local function MakeTemplate (Config) --> (bool | nil)

--[[ 1. Конфигурирование TextTemplate ]]
  local Cfg = Config.CfgData

--[[ 1.1. Анализ текущей строки ]]

  --logShow(Cfg, "CfgData")
  local Ctrl = CharControl(Cfg) -- Функции управления словом
  --logShow(Ctrl, "CharControl")

  local Info = EditorGetInfo() -- Базовая информация о редакторе
  --logShow(Info, "Editor Info")

  -- Получение текущего слова под курсором (CurPos is 0-based):
  local CfgCur = Cfg.Current
  CfgCur.Line = EditorGetStr(nil, -1, 2) or ""
  CfgCur.Pos  = Info.CurPos + 1 -- 0-based!
  local Word, Slab = Ctrl:atPosWord(CfgCur.Line, CfgCur.Pos)
  -- Проверки: внутри слова, вне слова, мин. число символов:
  --logShow({ Word, Word:len(), Slab, Slab:len(), Cfg }, "Make", 2)
  if not Ctrl:isWordUse(Word, Slab) then return end -- Проверка на выход

  CfgCur.Word, CfgCur.Slab = Word, Slab
  --if Word then logShow(Cfg.Current) end
  CfgCur.Frag = CfgCur.Line:sub(1, CfgCur.Pos - 1)

--[[ 2. Управление шаблоном TextTemplate ]]

--[[ 2.1. Поиск шаблонов в строке ]]
  -- Получение подходящего шаблона:
  local CfgTpl = FindTemplate(Config)
  if not CfgTpl then return false end
  --logShow(CfgTpl, "Templates", "d1 t")
  --Cfg.Templates = CfgTpl

--[[ 2.2. Обработка найденных шаблонов ]]
  local k, isOk = 1, false
  -- Поиск по всем до первого сработавшего:
  while isOk == false and k <= #CfgTpl do
    Cfg.Template, k = CfgTpl[k], k + 1
    isOk = ApplyTemplate(Cfg)
  end --

  return isOk
end -- MakeTemplate

---------------------------------------- main
local curFileType = detect.area.current

function unit.Execute (Data) --> (bool | nil)
--[[ 1. Разбор параметров ]]
  -- Конфигурация:
  local Config = Configure(Data)
  local CfgData = Config.CfgData
  --logShow(Data, "Data", 2)
  --logShow(Config, "Config", "_d2")
  --logShow(CfgData, "CfgData", 2)
  --logShow(Config.ArgData, "ArgData", 2)
  if not CfgData.Enabled then return end
  if not CfgData.CharEnum then CfgData.CharEnum = "%S" end
                    --| Тип текущего файла, открытого в редакторе:
  CfgData.Current = { FileType = CfgData.FileType or curFileType() }

  -- Формирование таблицы шаблонов
  FillTemplatesData(Config)

--[[ 2. Вызов с параметрами ]]
  return MakeTemplate(Config)
end ---- Execute

-- Сброс шаблонов для перезагрузки из файлов.
function unit.Update ()
  for k in pairs(TplKits) do TplKits[k] = false end
  far.Message("Templates will be reloaded!", "Update text templates")
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
