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
local bit = bit64
bshr = bit.rshift

----------------------------------------
local far = far
local F = far.Flags

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'
local serial = require 'context.utils.useSerial'

--local allpairs = tables.allpairs
local addNewData = tables.extend

----------------------------------------
--local farUt = require "Rh_Scripts.Utils.Utils"
--local chrUt = require "Rh_Scripts.Utils.Character"

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "MorfoGener"
unit.ScriptPath = "scripts\\Rh_Scripts\\Others\\"

---------------------------------------- ---- Custom
unit.DefCustom = {
  name = unit.ScriptName,
  path = unit.ScriptPath,

  label = unit.ScriptName,

  help   = { topic = unit.ScriptName, },
  locale = { kind = 'load', },
} --- DefCustom

unit.DefOptions = {
  KitName  = "LangData",
  --BaseDir  = nil,
  WorkDir  = "",

  AbecoName = "Abeco",
  MorfoName = "Morfo",

  ResultName = "Result",
  FileExt = "lud",
} ---

---------------------------------------- ---- Config
unit.DefCfgData = { -- Конфигурация по умолчанию:
  Enabled = true,
} --- DefCfgData

---------------------------------------- ---- Types
--unit.DlgTypes = { -- Типы элементов диалогов:
--} --- DlgTypes

---------------------------------------- Main class
local TMain = { -- Информация по умолчанию:
  --Guid       = win.Uuid(""),
  --ConfigGuid = win.Uuid(""),
} --- TMain
local MMain = { __index = TMain }

local FullNameFmt = "%s%s.%s"

-- Создание объекта основного класса.
local function CreateMain (ArgData) --> (object)
  local self = {
    ArgData   = addNewData(ArgData, unit.DefCfgData),

    Custom    = false,
    Options   = false,
    History   = false,
    CfgData   = false,
    DlgTypes  = unit.DlgTypes,
    LocData   = false,

    -- Текущее состояние:
    Language  = {},
  } --- self

  self.ArgData.Custom = self.ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(self.ArgData, "ArgData")
  self.Custom = datas.customize(self.ArgData.Custom, unit.DefCustom)
  self.Options = addNewData(self.ArgData.Options, unit.DefOptions)

  self.History = datas.newHistory(self.Custom.history.full)
  self.CfgData = self.History:field(self.Custom.history.field)

  setmetatable(self.CfgData, { __index = self.ArgData })
  --logShow(self.CfgData, "CfgData")

  locale.customize(self.Custom)
  --logShow(self.Custom, "Custom")

  local Custom = self.Custom
  local Options = self.Options
  Options.FullDir = ("%s%s"):format(Custom.base, Custom.path)
  Options.AbecoFile = FullNameFmt:format(Options.FullDir,
                                         Options.AbecoName,
                                         Options.FileExt)
  Options.MorfoFile = FullNameFmt:format(Options.FullDir,
                                         Options.MorfoName,
                                         Options.FileExt)
  Options.ResultFile = FullNameFmt:format(Options.FullDir,
                                          Options.ResultName,
                                          Options.FileExt)
  --logShow(self.Options, "Options")

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
  local isSmall = DBox.Flags and isFlag(DBox.Flags, F.FDLG_SMALLDIALOG)

  local I, J = isSmall and 0 or 3, isSmall and 0 or 1
  local H = DBox.Height - (isSmall and 1 or 2)
  local W = DBox.Width  - (isSmall and 0 or 2)
  local M = bshr(W, 1) -- Medium -- Width/2
  local Q = bshr(M, 1) -- Quarta -- Width/4
  W = W - 2 - (isSmall and 0 or 2)
  local A, B = I + 2, M + 2

  local L = self.L
  local D = dialog.NewDialog() -- Форма окна:
                    -- 1          2     3    4   5  6  7  8  9  10
                    -- Type      X1    Y1   X2  Y2  L  H  M  F  Data
  D._             = {DI.DBox,     I,    J, W+2,  H, 0, 0, 0, 0, L:caption"Dialog"}

  -- Кнопки управления:
  D.sep           = {DI.Text,     0,  H-2,   0,  0, 0, 0, 0, DIF.SeparLine, ""}
  D.chkEnabled    = {DI.Check,    A,  H-1,   M,  0, 0, 0, 0, 0, L:config"Enabled"}
  D.btnOk         = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Ok"}
  D.btnCancel     = {DI.Button,   0,  H-1,   0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Cancel"}

  return D
end -- ConfigForm

function TMain:ConfigBox ()

  local isSmall = self.Custom.isSmall
  if isSmall == nil then isSmall = true end

  -- Область:
  local DBox = {

    Width     = 0,
    Height    = 0,
    Flags     = isSmall and F.FDLG_SMALLDIALOG or nil,
  } -- DBox
  self.DBox = DBox

  DBox.Width  = 2 + 36*2 -- Edge + 2 columns
          -- Edge + (sep+Btns) + group separators and
  DBox.Height = 2 + 2 + 5*2 + -- group empty lines + group item lines
                0--DBox.cSlab + DBox.cFind + DBox.cSort + DBox.cList + DBox.cCmpl
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

local Msgs = {
  NoLocale      = "No localization",
} ---

-- Подготовка.
-- Preparing.
function TMain:Prepare ()

  if not self:Localize() then
    --self.Error = Msgs.NoLocale
    return
  end

  return
end -- Prepare

---------------------------------------- ---- Work
do
  local tconcat = table.concat

-- Формирование данных в подтаблицах таблицы Language.
function TMain:FillSubDataPos (Kind) --| Abeco
  local a = self.Language.Abeco
  local t, l = a[Kind], a.Liter
  if type(t) ~= 'table' or
     type(t[1]) ~= 'string' then
    return
  end

  -- Store positions of letters:
  local Len = 0 -- Max length of sounds
  for k, v in ipairs(t) do
    t[v] = k
    local len = v:len()
    if len > Len then Len = len end
  end
  t[0] = Len
end ---- FillSubDataPos

local sformat = string.format

-- Формирование строк из подтаблиц таблицы Language.
function TMain:FillSubDataStr (Kind) --| Abeco
  local a = self.Language.Abeco
  local o = a.Order
  local t, u = a[Kind], o[Kind]
  if type(t) ~= 'table' or
     type(t[1]) ~= 'string' then
    return
  end

  if not u then
    u = { Liter = true, YeuPat = true, NeuPat = true, }
    o[Kind] = u
  end

  local Len = t[0]

  if Len == 1 then
    -- String of letters:
    u.Literi = tconcat(t)
    -- Patterns with letters:
    u.YeuPat = sformat("[%s]", u.Literi)
    u.NeuPat = sformat("[^%s]", u.Literi)
  else
    -- MAYBE:
    --[[local b = o.Binali[Kind]
    if b then
      --logShow(b, Kind)
      --logShow({ b, o[b.kombo], o.Vokon }, Kind)
    end
    --]]
  end
end ---- FillSubDataStr

end -- do

-- Заполнение монофтонгов заданного вида.
function TMain:FillMonoSet (Kind) --| Abeco
  local a = self.Language.Abeco
  local o, t = a.Order, a[Kind]

  for _, b in ipairs(o[Kind]) do
    for _, v in ipairs(a[b]) do t[#t + 1] = v end
    self:FillSubDataPos(b)
    self:FillSubDataStr(b)
  end

  self:FillSubDataPos(Kind)
  self:FillSubDataStr(Kind)
end -- FillMonoSet

-- Формирование сочетаний с диграфными.
function TMain:FillBinoSets () --| Abeco
  local a = self.Language.Abeco
  local o = a.Order

  for n, b in pairs(o.Binali) do
    local t = a[n]
    local l = b.liter
    local f = b.flang

    if f == "R" then
      for _, v in ipairs(a[b.kombo]) do t[#t + 1] = v..l end
    else--if f == "L" then
      for _, v in ipairs(a[b.kombo]) do t[#t + 1] = l..v end
    end

    self:FillSubDataPos(n)
    self:FillSubDataStr(n)
  end --
end -- FillBinoSets

-- Заполнение букв.
function TMain:FillLiterSet (Kind) --| Abeco
  local a = self.Language.Abeco
  local o, t = a.Order, a[Kind]

  for _, b in ipairs(o[Kind]) do
    for _, v in ipairs(a[b]) do t[#t + 1] = v end
  end

  --self:FillSubDataPos(Kind)
  self:FillSubDataStr(Kind)
end -- FillLiterSet

-- Заполнение Language с учётом имеющихся в нём данных.
function TMain:FillData () --| Abeco

  local a = self.Language.Abeco

  do -- Заполнение монофтонгов
    self:FillMonoSet("Vokal")
    self:FillMonoSet("Konal")
    self:FillMonoSet("Binal")

    self:FillMonoSet("Vokon")
    self:FillMonoSet("Liter")
  end -- do

  do -- Формирование мультифтонгов
    self:FillBinoSets() -- Формирование дифтонгов
     -- MAYBE -- Формирование трифтонгов
  end -- do

  do -- Заполнение букв
    self:FillLiterSet("Vokali")
    self:FillLiterSet("Konali")
  end -- do

end ---- FillData

-- Генерация морфов.
function TMain:Generate ()

  local D = self.Language
  local a = D.Abeco
  local m = D.Morfo
  local F = D.Formo
  -- TODO
end ---- Generate

-- Формирование данных.
function TMain:Make () --> (table)

  self:FillData()

  return self:Generate()
end -- Make

---------------------------------------- ---- Load/Save
-- Загрузка.
function TMain:Load ()
  local Options = self.Options

  self.Language.Abeco = datas.load(Options.AbecoFile, nil, 'change')
  --logShow(self.Language.Abeco, "Abeco")
  self.Language.Morfo = datas.load(Options.MorfoFile, nil, 'change')
  --logShow(self.Language.Morfo, "Morfo")
end ---- Load

-- Сохранение.
function TMain:Save ()
  local Options = self.Options

  local sortkind = {
    pairs = pairs, -- TEST: array + hash fields
    --pairs = allpairs, -- TEST: all fields including from metas
  } ---

  local kind = {
    --localret = true,
    --tnaming = true,
    astable = true,
    --nesting = 0,
    strlong = 80,

    pairs = tables.sortpairs, -- TEST: sort pairs
    pargs = { sortkind },

    -- Параметры линеаризации
    lining = "all",
    --lining = "array",
    --lining = "hash",

    alimit = 60,
    acount = 5,
    awidth = 4,
    --avalth = 4,
    --avarth = 4,

    zeroln = true,
    hstrln = true,

    hlimit = 60,
    hcount = 5,
    --hwidth = 6,
    hkeyth = 2,
    hvalth = 2,
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

---------------------------------------- ---- Run
function TMain:Run () --> (bool | nil)

  --logShow(self, "TMain")

  self:Load()

  self:Make()

  self:Save()

  --logShow(_Lang.Language, "w")

  return
end -- Run

---------------------------------------- main

function unit.Execute (Data) --> (bool | nil)

  --logShow(Data, "Data", "w d2")

  local _Main = CreateMain(Data)
  --logShow(_Main, "_Main")
  if not _Main then return end

  --logShow(Data, "Data", "w d2")
  --logShow(_Main, "Config", "w _d2")
  --logShow(_Main.CfgData, "CfgData", "w d2")
  --if not _Main.CfgData.Enabled then return end

  _Main:Prepare()
  if _Main.Error then return nil, _Main.Error end

  return _Main:Run()
end ---- Execute

--------------------------------------------------------------------------------
--return unit
return unit.Execute()
--------------------------------------------------------------------------------
