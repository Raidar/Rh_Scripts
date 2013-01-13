--[[ Morphs' generator ]]--

----------------------------------------
--[[ description:
  -- Morphs' generator.
  -- Генератор морфов.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  far2,
  Rh Utils.
  -- group: Common.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local setmetatable = setmetatable

----------------------------------------
--local bit = bit64
--bshr = bit.rshift

----------------------------------------
local far = far
local F = far.Flags

----------------------------------------
--local context = context

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'
local serial = require 'context.utils.useSerial'

--local allpairs = tables.allpairs
local addNewData = tables.extend

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.LuaUtils"
--local farUt = require "Rh_Scripts.Utils.FarUtils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Config
local DefCfgData = { -- Конфигурация по умолчанию:
  Enabled = true,
} --- DefCfgData
unit.DefCfgData = DefCfgData

local DefOptions = {
  KitName  = "LangData",
  --BaseDir  = nil,
  WorkDir  = "",
  SourceName = "LangSource",
  ResultName = "LangResult",
  FileExt = "dat",
} ---

---------------------------------------- Types
local DlgTypes = { -- Типы элементов диалогов:
} --- DlgTypes

---------------------------------------- Configure
local ScriptName = "MorfoGener"
local ScriptPath = "scripts\\Rh_Scripts\\Others\\"

local DefCustom = {
  name = ScriptName,
  path = ScriptPath,

  label = "MORF",
  file = "MorfoGen",

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
  addNewData(Custom.options, DefOptions)
  -- 2. Заполнение конфигурации.
  local History = datas.newHistory(Custom.history.full)
  --logShow(History, "History")
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
local LocData -- Данные локализации
local L -- Класс сообщений локализации

---------------------------------------- Dialog
local dialog = require "far2.dialog"
local dlgUt = require "Rh_Scripts.Utils.Dialog"

local DI = dlgUt.DlgItemType
local DIF = dlgUt.DlgItemFlag
--local ListItems = dlgUt.ListItems

-- Диалог конфигурации.
local function Dlg (Config) --> (dialog)
  local DBox = Config.DBox
  local isSmall = DBox.Flags and utils.isFlag(DBox.Flags, F.FDLG_SMALLDIALOG)

  local I, J = isSmall and 0 or 3, isSmall and 0 or 1
  local H = DBox.Height - (isSmall and 1 or 2)
  local W = DBox.Width  - (isSmall and 0 or 2)
  --local M = bshr(W, 1) -- Medium -- Width/2
  --local Q = bshr(M, 1) -- Quarta -- Width/4
  W = W - 2 - (isSmall and 0 or 2)
  --local A, B = I + 2, M + 2

  local D = dialog.NewDialog() -- Форма окна:
                    -- 1          2     3    4   5  6  7  8  9  10
                    -- Type      X1    Y1   X2  Y2  L  H  M  F  Data
  D._             = {DI.DBox,     I,    J, W+2,  H, 0, 0, 0, 0, L:caption"Dialog"}

  -- Кнопки управления:
  D.sep           = {DI.Text,     0,  H-2,   0,  0, 0, 0, 0, DIF.SeparLine, ""}
  --D.chkEnabled    = {DI.Check,    A,  H-1,   M,  0, 0, 0, 0, 0, L:config"Enabled"}
  D.btnOk         = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel     = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Cancel"}

  return D
end -- Dlg

local ConfigGuid = win.Uuid("")

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
  local isSmall = Config.Custom.isSmall
  if isSmall == nil then isSmall = true end
  -- Подготовка:
  Config.DBox = {
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
  --logShow(D, "D", "d3")
  if D.btnOk and iDlg == D.btnOk.id then
    dlgUt.SaveDlgData(cData, aData, D, Types) -- Сохранение конфигурации
    --logShow(Config, "Config", "d3")
    --Config.History:save() -- Внимание: пока не сохранять, только загружать?!

    return true
  end
end ---- ConfigDlg

---------------------------------------- Lang class
local TLang = { -- Информация по умолчанию:
} --- TLang
local MLang = { __index = TLang }

-- Создание объекта класса язык.
local function CreateLang (Config) --> (object)
  local self = {
    Config = Config,
    Language = false,
  } --- self
  return setmetatable(self, MLang)
end -- CreateLang

---------------------------------------- methods
local tconcat = table.concat

-- Формирование данных в подтаблицах таблицы Language.
function TLang:MakeSubData (Kind) --| Language
  local t, l = self.Language[Kind], self.Language.Liter
  l[Kind] = tconcat(t) -- Строка букв

  -- Список с позициями букв в массиве
  for k, v in ipairs(t) do t[v] = k end
end ---- MakeSubData

-- Заполнение Language с учётом имеющихся в нём данных.
function TLang:FillData () --| Language

  local l = self.Language

  do -- Заполнение Konal
    local t = l.Konal
    for _, v in ipairs(l.Sonor) do t[#t + 1] = v end
    for _, v in ipairs(l.Sinel) do t[#t + 1] = v end
  end -- do

  do -- Формирование данных
    self:MakeSubData("Vocal")
    self:MakeSubData("Konal")
    self:MakeSubData("Sonor")
    self:MakeSubData("Sinel")
    self:MakeSubData("Hemil")
  end -- do

  do -- Заполнение Yocal
    local t = l.Yocal
    local c = l.Hemal._Yocal_
    for _, v in ipairs(l.Vocal) do t[#t + 1] = c..v end
  end -- do

  do -- Заполнение Yonal
    local t = l.Jonal
    local c = l.Hemal._Jonal_
    for _, v in ipairs(l.Konal) do t[#t + 1] = v..c end
  end -- do
end ---- FillData

-- Генерация морфов.
function TLang:Generate ()
  -- TODO
end ---- Generate

---------------------------------------- Make
-- Загрузка.
function TLang:Load ()
  local Options = self.Config.Custom.options

  self.Language = datas.load(Options.SourceFile, nil, 'change')
end ---- GenerateFormo

-- Сохранение.
function TLang:Save ()
  local Options = self.Config.Custom.options

  local sortkind = {
    --compare = sortcompare,
    --pairs = ipairs, -- TEST: array fields
    --pairs = tables.hpairs, -- TEST: hash fields
    pairs = pairs, -- TEST: array + hash fields
    --pairs = allpairs, -- TEST: all fields including from metas
  } ---

  local kind = {
    --localret = true, -- TEST: local + return instead of global
    --tnaming = true, -- TEST: temporary name of table to access fields
    --astable = true, -- TEST: serialize as one table
    --nesting = 0, -- TEST: serialize data with max nesting level

    -- TEST: for simple values:
    --numwidth = 2, -- TEST: min number value width
    --keyhex = 2, -- TEST: hex width for integer key
    --valhex = 2, -- TEST: hex width for integer value
    --valhex = true, -- TEST: hex width for integer value
    --keyfloat = true, -- TEST: using pretty float for key
    valfloat = true, -- TEST: using pretty float for value
    --strlong = 80, -- TEST: long bracket strings

    --pairs = allpairs, -- TEST: all pairs
    pairs = tables.sortpairs, -- TEST: sort pairs
    --pargs = {},
    pargs = { sortkind },

    -- Параметры линеаризации
    lining = "all",
    --lining = "array",
    --lining = "hash",
    --alimit = 33,
    alimit = 60, -- TEST: length limit for line
    --acount = 5, -- TEST: max field count on line
    -- [[ TEST: max field count on line
    acount = function (n, t) --> (number)
               local l = #t
               return l > 17 and l / 3 or l > 9 and l / 2 or l
             end,--]]
    awidth = 4, -- TEST: min field width on line
--[[
  01..09 --> 1..9
  10..17 --> 5..8
  18..30 --> 6..10
--]]

    hlimit = 60, -- TEST: length limit for line
    -- [[ TEST: max field count on line
    hcount = function (n, t) --> (number)
               local l = #t
               return l > 14 and l / 3 or l > 5 and l / 2 or l
             end,--]]
    hwidth = 3, -- TEST: min field width on line
    --hwidth = 5, -- TEST: min field width on line -- for hex
--[[
  01..05 --> 1..5
  06..14 --> 3..7
  15..30 --> 5..10
--]]

    --[[ TEST: extended pretty write
    KeyToStr = serial.KeyToText,
    ValToStr = serial.ValToText,
    TabToStr = serial.TabToText,
    --]]
    serialize = serial.prettyize,
  } ---

  --logShow(self.Language, "Language", "d2")
  return datas.save(Options.ResultFile, "Data", self.Language, kind)
end ---- Save

---------------------------------------- main
local FullNameFmt = "%s%s.%s"

function unit.Execute (Data) --> (bool | nil)
--[[ 1. Разбор параметров ]]
  -- Конфигурация:
  local Config = Configure(Data)
  local CfgData = Config.CfgData
  --logShow(Data, "Data", "d2")
  --logShow(Config, "Config", "d2 _")
  --logShow(CfgData, "CfgData", "d2")
  --logShow(CfgData.Language, "Language", "d2")
  --logShow(Config.ArgData, "ArgData", "d2")
  --logShow(CfgData.Enabled, "CfgData.Enabled")

  if not CfgData.Enabled then return end

  local Custom = Config.Custom
  local Options = Custom.options
  Options.FullDir = ("%s%s"):format(Custom.base, Custom.path)
  Options.SourceFile = FullNameFmt:format(Options.FullDir,
                                          Options.SourceName,
                                          Options.FileExt)
  Options.ResultFile = FullNameFmt:format(Options.FullDir,
                                          Options.ResultName,
                                          Options.FileExt)
  --logShow(Options, "Options", "d2")

--[[ 2. Конфигурирование меню ]]
  local _Lang = CreateLang(Config)

--[[ 3. Вызов с параметрами ]]
  _Lang:Load() -- Загрузка исходных данных
  --logShow(_Lang.Language, "Language", "d2")
  _Lang:FillData() -- Заполнение автогенерируемых полей
  --logShow(_Lang.Language, "Language", "d2")
  _Lang:Generate() -- Формирование морфов
  _Lang:Save() -- Сохранение результатов

  --logShow(_Lang.Language, "w")
end ---- Execute

--------------------------------------------------------------------------------
unit.Execute(nil)
--return unit
--------------------------------------------------------------------------------
