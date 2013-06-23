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
  SourceName = "LangSource",
  ResultName = "LangResult",
  FileExt = "dat",
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
    Language  = false,
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
  Options.SourceFile = FullNameFmt:format(Options.FullDir,
                                          Options.SourceName,
                                          Options.FileExt)
  Options.ResultFile = FullNameFmt:format(Options.FullDir,
                                          Options.ResultName,
                                          Options.FileExt)

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
    self.Error = Msgs.NoLocale
    return
  end

  return
end -- Prepare

---------------------------------------- ---- Work
do
  local tconcat = table.concat

-- Формирование данных в подтаблицах таблицы Language.
function TMain:FillSubData (Kind) --| Language
  local t, l = self.Language[Kind], self.Language.Liter
  if type(t) ~= 'table' or
     type(t[1]) ~= 'string' then
    return
  end

  -- Список с позициями букв в массиве
  local Len = 0
  for k, v in ipairs(t) do
    t[v] = k
    local len = v:len()
    if len > Len then Len = len end
  end
  t[0] = Len

  if Len == 1 then
    l[Kind] = tconcat(t) -- Строка букв
  end
end ---- FillSubData

end -- do

-- Заполнение Language с учётом имеющихся в нём данных.
function TMain:FillData () --| Language

  local l = self.Language

  do -- Заполнение монофтонгов
    local o = l.Order
    local t = l.Vokal
    for _, b in ipairs(o.Vokal) do
      for _, v in ipairs(l[b]) do t[#t + 1] = v end
      self:FillSubData(b)
    end
    self:FillSubData("Vokal")

    local t = l.Konal
    for _, b in ipairs(o.Konal) do
      for _, v in ipairs(l[b]) do t[#t + 1] = v end
      self:FillSubData(b)
    end
    self:FillSubData("Konal")

    self:FillSubData("Binal")
  end -- do

  do -- Формирование мультифтонгов

    -- Формирование дифтонгов
    for n, b in pairs(l.Binal_D) do
      local t = l[n]
      local c = b.Liter

      if b.Flang == "R" then
        for _, v in ipairs(l[b.Kombo]) do t[#t + 1] = v..c end
      else--if b.Flang == "L" then
        for _, v in ipairs(l[b.Kombo]) do t[#t + 1] = c..v end
      end

      self:FillSubData(n)
    end --

    -- Формирование трифтонгов -- TODO:
  end -- do

  do -- Заполнение букв
    local o = l.Order
    local t = l.Vokali
    for _, b in ipairs(o.Vokali) do
      for _, v in ipairs(l[b]) do t[#t + 1] = v end
    end
    self:FillSubData("Vokali")

    local o = l.Order
    local t = l.Konali
    for _, b in ipairs(o.Konali) do
      for _, v in ipairs(l[b]) do t[#t + 1] = v end
    end
    self:FillSubData("Konali")
  end -- do

end ---- FillData

-- Генерация морфов.
function TMain:Generate ()

  local l = self.Language
  local F = l.Formo
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
  local Options = self.Config.Custom.options

  self.Language = datas.load(Options.SourceFile, nil, 'change')
end ---- Load

-- Сохранение.
function TMain:Save ()
  local Options = self.Config.Custom.options

  local sortkind = {
    pairs = pairs, -- TEST: array + hash fields
    --pairs = allpairs, -- TEST: all fields including from metas
  } ---

  local kind = {
    --localret = true,
    --tnaming = true,
    astable = true,
    --nesting = 0,

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
