--[[ CharsMap ]]--

----------------------------------------
--[[ description:
  -- Menu based characters map.
  -- Таблица символов на основе меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context,
  Rh Utils.
  -- group: Common.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local type = type
local setmetatable = setmetatable

----------------------------------------
local useprofiler = false
--local useprofiler = true

if useprofiler then
  require "profiler" -- Lua Profiler
  profiler.start("CharsMap.log")
end

----------------------------------------
--local win = win
--local win, far = win, far

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local divf = numbers.divf
--local divf, divm = numbers.divf, numbers.divm

--local Null = tables.Null
local addNewData = tables.extend

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

----------------------------------------
local keyUt = require "Rh_Scripts.Utils.Keys"

local IsModCtrl, IsModAlt = keyUt.IsModCtrl, keyUt.IsModAlt
--local IsModCtrlAlt = keyUt.IsModCtrlAlt

----------------------------------------
local CharsList = require "Rh_Scripts.Utils.CharsList"
local uCodeName  = CharsList.uCodeName
local uBlockName = CharsList.uBlockName

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "CharsMap"
unit.ScriptPath = "scripts\\Rh_Scripts\\Common\\"

local usercall = farUt.usercall
unit.RunMenu = usercall(nil, require, "Rh_Scripts.RectMenu.RectMenu")

---------------------------------------- ---- Custom
unit.DefCustom = {
  name = unit.ScriptName,
  path = unit.ScriptPath,

  label = unit.ScriptName,

  help   = { topic = unit.ScriptName, },
  locale = {
    kind = 'load',
  }, --
} -- DefCustom

----------------------------------------
unit.DefOptions = {
  BaseDir  = "Rh_Scripts.Common."..unit.ScriptName..".",
} -- DefOptions

--[[
local L, e1, e2 = locale.localize(unit.DefCustom)
if L == nil then
  return locale.showError(e1, e2)
end

logShow(L, "L", "wM")
--]]
---------------------------------------- ---- Config
unit.DefCfgData = { -- Конфигурация по умолчанию:
} -- DefCfgData

---------------------------------------- ---- Types
--unit.DlgTypes = { -- Типы элементов диалога:
--} -- DlgTypes

---------------------------------------- Configure

---------------------------------------- Main class
local TMain = {
  Guid       = win.Uuid("19500a29-1a9b-4b1b-833c-693d58669963"),
  ConfigGuid = win.Uuid("1991fe2b-e919-480e-8b0a-90b7c960d113"),

  Blocks     = {
    Guid       = win.Uuid("19b4271d-09c2-4671-af59-b043d1698104"),
  }, ---
}
local MMain     = { __index = TMain }
local MBlocks   = { __index = TMain.Blocks }

-- Создание объекта основного класса.
local function CreateMain (ArgData)

  local self = {
    ArgData   = addNewData(ArgData, unit.DefCfgData),
    FarArea   = farUt.GetBasicAreaType(),

    Custom    = false,
    Options   = false,
    History   = false,
    CfgData   = false,
    --DlgTypes  = unit.DlgTypes,
    LocData   = false,
    L         = false,

    RowCount = false,     -- Количество строк меню
    ColCount = false,     -- Количество стобцов меню

    -- Текущее состояние:
    Items     = false,    -- Список пунктов меню
    Props     = false,    -- Свойства меню

    --CharRows  = 0x08,     -- Количество видимых строк символов
    CharRows  = 0x10,     -- Количество видимых строк символов
    CharCols  = 0x10,     -- Количество видимых столбцов символов
    CharCount = 0x100,    -- Количество всех видимых символов
    CharPass  = 0x1000,   -- Количество символов в блоке для быстрой прокрутки

    CharMin   = 0x0000,   -- Минимальный символ
    CharMax   = 0xFFFD,   -- Максимальный символ
    --CharBase  = 0x2000,   -- Базовый символ
    --CharBase  = 0x0000,   -- Базовый символ
    DigitNum  = 4,        -- Количество цифр в CodePoint символа

    ActItem   = false,    -- Выбранный пункт меню
    ItemPos   = false,    -- Позиция выбранного пункта меню
    --Action    = false,    -- Выбранное действие
    --Effect    = false,    -- Выбранный эффект

    Blocks    = {         -- Объект: Блоки символов
      Main      = false,    -- Объект основного класса
      -- Текущее состояние:
      Items     = false,    -- Список пунктов меню
      Props     = false,    -- Свойства меню

      ActItem   = false,    -- Выбранный пункт меню
      ItemPos   = false,    -- Позиция выбранного пункта меню
    },
  } --- self
  self.Blocks.Main = self

  self.ArgData.Custom = self.ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(self.ArgData, "ArgData", "wA d2")
  self.Custom = datas.customize(self.ArgData.Custom, unit.DefCustom)
  self.Options = addNewData(self.ArgData.Options, unit.DefOptions)

  self.History = datas.newHistory(self.Custom.history.full)
  self.CfgData = self.History:field(self.Custom.history.field)

  --local CfgData = self.CfgData
  --self.Menu = CfgData.Menu or {}
  --self.Menu.CompleteKeys = self.Menu.CompleteKeys or unit.CompleteKeys
  --self.Menu.LocalUseKeys = self.Menu.LocalUseKeys or unit.LocalUseKeys

  setmetatable(self.CfgData, { __index = self.ArgData })
  --logShow(self.CfgData, "CfgData", "w")

  locale.customize(self.Custom)
  --logShow(self.Custom, "Custom")

  setmetatable(self.Blocks, MBlocks)
  return setmetatable(self, MMain)
end -- CreateMain

---------------------------------------- Dialog

---------------------------------------- Main making

---------------------------------------- ---- Init
do
  local max, min = math.max, math.min

function TMain:InitData ()
  local self = self
  --local CfgData = self.CfgData

  self.CharCount = self.CharRows * self.CharCols
  self.CharBase = min(max(self.CharBase or 0x0000, self.CharMin), self.CharMax)

  return true
end ---- InitData

  local divf = numbers.divf

-- Инициализация символа.
function TMain:InitChar ()
  local self = self

  local CfgData = self.CfgData
  --logShow(CfgData, "CfgData")

  local Char = CfgData.Char or self.CharBase
  self.Char, self.DefChar = Char, Char
  self.CharBase = divf(Char, self.CharCount) * self.CharCount --> TODO: FixCharBase!
  --logShow(self, "TMain", "w d1")

  return true
end ---- InitChar

end -- do
---------------------------------------- ---- Prepare
do
-- Localize data.
-- Локализация данных.
function TMain:Localize ()
  local self = self

  self.LocData = locale.getData(self.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not self.LocData then return end

  self.L = locale.make(self.Custom, self.LocData)

  return self.L
end ---- Localize

function TMain:MakeColors ()

  local colors = require 'context.utils.useColors'
  local basics = colors.BaseColors
  local Basis = {
    StandardFG  = basics.navy,
    --MarkedFG    = basics.red,
    MarkedFG    = basics.black,
    BorderFG    = basics.black,
    TitleFG     = basics.black,
    --StatusBarFG = basics.black,
    ScrollBarFG = basics.black,
  } --- Basis

  local menUt = require "Rh_Scripts.Utils.Menu"
  self.Colors = menUt.FormColors(Basis)

  return true
end ---- MakeColors

function TMain:MakeProps ()
  local self = self

  self.RowCount = 1 + self.CharRows + 1
  self.ColCount = 1 + self.CharCols + 1

  -- Свойства меню:
  local Props = self.CfgData.Props or {}
  self.Props = Props

  Props.Id = Props.Id or self.Guid
  Props.HelpTopic = self.Custom.help.tlink
  Props.FarArea = self.FarArea

  local L = self.LocData
  Props.Title  = L.Caption
  --Props.Bottom = L.CharsMapKeys

  -- Свойства RectMenu:
  local RM = {
    ReuseItems = true,

    Order = "H",
    --Rows = self.RowCount,
    Cols = self.ColCount,

    Fixed = {
      HeadRows = 1,
      FootRows = 1,
      HeadCols = 1,
      FootCols = 1,
    },

    --MenuEdge = 2,
    MenuAlign = "CM",

    LineMax = 1,
    TextMax = {
      [0] = 1,
      [1] = self.DigitNum,
      [self.ColCount] = self.DigitNum,
    }, --

    MaxHeight = 1 + 1 + self.RowCount + 1 + 3 + 0,

    Colors = self.Colors,

    --IsStatusBar = true,

    Edges = {
      --Bottom = 1,
      Bottom = 3,

      Texts = {
        Bottom = function (k, Rect, Item)
          if Item == nil then
            return
          end
          if     k == 1 then
            return Item.Hint
          elseif k == 3 then
            local d = Item.Data
            if type(d) == 'table' then
              local n = d.BlockName
              if not n then
                n = uBlockName(d.Char or 0)
                d.BlockName = n
              end
              return n
            end
          end
        end,
      },
    },
    IsDrawEdges = true,

    --RectItem = {
    --  TextMark = true,
    --},
  } --- RM
  Props.RectMenu = RM

  self.RectItem = {
    TextMark = true,
  } --

  return true
end ---- MakeProps

local Msgs = {
  NoLocale  = "No localization",
} ---

-- Подготовка.
-- Preparing.
function TMain:Prepare ()

  self:InitData()

  self:InitChar()

  if not self:Localize() then
    self.Error = Msgs.NoLocale
    return
    --self.LocData = {} -- DEBUG only
  end

  self:MakeColors()

  return self:MakeProps()
end ---- Prepare

end -- do
---------------------------------------- ---- Menu
do
  local uCP2s = strings.ucp2s

-- Заполнение меню.
function TMain:FillMenu () --> (table)
  local self = self

  local CharRows, CharCols = self.CharRows, self.CharCols
  local RowCount, ColCount = self.RowCount, self.ColCount

  local t = self.Items

  local Filler = "────"
  local l = (RowCount - 1) * ColCount + 1
  t[1].text                 = Filler
  t[1 + ColCount - 1].text  = Filler
  t[l].text                 = Filler
  t[l + ColCount - 1].text  = Filler

  local Order = "0123456789ABCDEF"
  for k = 1, CharCols do
    local s = Order:sub(k, k)
    t[1 + k].text = s
    t[l + k].text = s
  end

  local p = 0
  local b = self.CharBase
  for _ = 1, CharRows do
    p = p + ColCount
    --local s = uCP2s(b, true)
    t[p + 1].text        = uCP2s(b, true)
    t[p + ColCount].text = uCP2s(b + CharCols - 1, true)
    b = b + CharCols
  end

  p = 1                 -- Индекс начального пункта строки
  b = self.CharBase     -- Код символа для текущего пункта
  local U = unicode.utf8.char

  local SelChar = self.Char -- Код текущего символа
  local SelIndex            -- Индекс пункта с текущим символом

  for i = 1, CharRows do
    p = p + ColCount

    for j = 1, CharCols do
      local c = U(b)
      local f = t[p + j]

      f.text = c
      f.Hint = uCodeName(b)
      f.RectMenu = self.RectItem

      f.Data = {
        Char = b,
        char = c,
        r = i,
        c = j,
        --p = p + j,
      } --

      if not SelIndex and b == SelChar then
        SelIndex = p + j
      end

      b = b + 1
    end
  end --

  self.Props.SelectIndex = SelIndex

  return true
end ---- FillMenu

-- Формирование меню.
function TMain:MakeMenu () --> (table)
  local self = self

  local RowCount, ColCount = self.RowCount, self.ColCount

  local t = {}
  self.Items = t

  -- Формирование пунктов:
  for _ = 1, ColCount do
    for _ = 1, RowCount do
      t[#t+1] = {
        text = "",
        Label = true,
      } --
    end
  end --

  self:FillMenu() -- Таблица символов

  return true
end -- MakeMenu

-- Формирование таблицы символов.
function TMain:Make () --> (table)

  self.Items = false -- Сброс меню (!)

  return self:MakeMenu()
end -- Make

end -- do
---------------------------------------- ---- Utils
do
  local max, min = math.max, math.min

-- Limit character.
-- Ограничение символа.
function TMain:LimitChar ()
  self.Char = min(max(self.Char, self.CharMin), self.CharMax)
  self.CharBase = divf(self.Char, self.CharCount) * self.CharCount
end ---- LimitChar

end -- do
---------------------------------------- ---- Block
do
  local TBlocks = TMain.Blocks

  local max = math.max

function TBlocks:MakeProps () --| (BlocksProps)
  local self = self
  if self.Props then return end

  -- Свойства меню блоков символов:
  local Props = {}
  self.Props = Props

  local Main = self.Main
  Props.Id = Props.Id or self.Guid
  Props.HelpTopic = Main.Custom.help.tlink
  Props.FarArea = Main.FarArea

  local L = Main.LocData
  Props.Title  = L.BlocksCaption
  --Props.Bottom = L.CharsBlocksKeys

  local RangeLen = 0
  do
    local RangeName = L.BlocksColBlockRange
    local RangeNameLen  = RangeName:len()
    local RangeValueLen = 4 + 2 + 4
    if RangeNameLen >= RangeValueLen then
      RangeLen = RangeNameLen
    else
      RangeLen = RangeValueLen
      local spaces = strings.spaces
      local Delta = divf(RangeValueLen - RangeNameLen, 2)
      L.BlocksColBlockRange = spaces[Delta]..
                              RangeName..
                              spaces[RangeValueLen - RangeNameLen - Delta]
    end
  end -- do

  -- Свойства RectMenu:
  local RM = {
    ReuseItems = true,

    Order = "H",
    Cols = 2,

    Fixed = {
      HeadRows = 1,
      --FootRows = 1,
      HeadCols = 1,
      --FootCols = 1,
    },

    --MenuEdge = 2,
    MenuAlign = "CM",

    LineMax = 1,
    TextMax = {
      [1] = RangeLen,
      --[1] = max(4 + 2 + 4, L.BlocksColBlockRange:len()),
    }, --

    --MaxHeight = self.Props.RectMenu.MaxHeight,

    --Colors = self.Colors,

    --IsStatusBar = true,
  } -- RM
  Props.RectMenu = RM

  self.RectItem = {
    --TextMark = true,
    TextAlign = "CM",
  } --

  return true
end ---- MakeProps

  local uCP = CharsList.uCP
  local uData = CharsList.Data
  local uBlocks = uData and uData.Blocks or Null
  local BlockRangeFmt = "%s..%s"

function TBlocks:MakeItems () --| (BlocksItems)
  local self = self
  if self.Items then return end

  local Main = self.Main

  local L = Main.LocData

  local t = {
    { text = L.BlocksColBlockRange,
      Label = true,
      RectMenu = self.BlocksItem,
    },
    { text = L.BlocksColBlockName,
      Label = true,
      RectMenu = self.BlocksItem,
    },
  } ---

  for i = 1, #uBlocks do
    local b = uBlocks[i]
    t[#t + 1] = {
      text = BlockRangeFmt:format(uCP(b.first, true),
                                  uCP(b.last, true)),
      Label = true,
      RectMenu = self.BlocksItem,
    }
    t[#t + 1] = {
      text = b.name,
      Char = b.first,
    }
  end

  self.Items = t

  return true
end ---- MakeItems

function TBlocks:AssignEvents () --> (bool | nil)
  local self = self

  -- Обработчик нажатия клавиш.
  local function KeyPress (VirKey, ItemPos)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end
    --if SKey == "Enter" then return end
    --logShow(VirKey, SKey)

    local Data = self.Items[ItemPos]
    if not Data then return end

    if SKey == "Divide" then
      local Char = u8byte(VirKey.UnicodeChar or 0x0000)
      if Char ~= 0x0000 and
         (VirKey.StateName == "" or
          VirKey.StateName == "Shift") then
        self.Char = Char
      else
        isUpdate = false
      end
    end -- SKey

    return
  end -- KeyPress

  -- Назначение обработчиков:
  local RM = self.Props.RectMenu
  RM.OnKeyPress = KeyPress
  --RM.OnNavKeyPress = NavKeyPress
  --RM.OnSelectItem = SelectItem
  --RM.OnChooseItem = ChooseItem
end -- AssignEvents

function TBlocks:ShowMenu () --> (item, pos)
  local self = self
  return usercall(nil, unit.RunMenu,
                  self.Props, self.Items, self.Keys)
end ---- ShowMenu

  local uCharBlock = CharsList.uCharBlock

-- Choose character block.
-- Выбор блока символов.
function TMain:ChooseBlock (Data)
  --local self = self
  local Blocks = self.Blocks

  Blocks:MakeProps()
  Blocks:MakeItems()

  local Char = Data and Data.Char or 0
  Blocks.Props.SelectIndex = (uCharBlock(Char) or 1) * 2 + 2
  --logShow(Blocks.Props, uCP(Char), 1)

  Blocks.ActItem, Blocks.ItemPos = Blocks:ShowMenu()

  return Blocks.ActItem and Blocks.ActItem.Char
end ---- ChooseBlock

end -- do
---------------------------------------- ---- Input
do
  local tonumber = tonumber

function TMain:ParseInput ()
  --local self = self

  local Input = self.Input or ""
  if Input == "" then return end

  return tonumber(Input, 16)
end ---- ParseInput

function TMain:StartInput (Data)
  local self = self
  local L = self.LocData

  self.Input = ""
  self.Props.Bottom = L.InputCodePoint
  self.IsInput = true
end ---- StartInput

function TMain:StopInput (Data)
  local self = self

  self.IsInput = false
  self.Props.Bottom = ""
  self.Char = self:ParseInput() or Data.Char
end ---- StopInput

function TMain:EditInput (SKey)
  local self = self

  local Input = self.Input
  if SKey == "BS" then
    if Input ~= "" then
      Input = Input:sub(1, -2)
    end

  elseif SKey == "V" then
    local s = far.PasteFromClipboard()
    if type(s) == 'string' then
      s = (s.."0000"):match("^(%x%x%x%x)")
      if s then Input = s end
    end
  else
    if Input:len() < 4 then
      Input = Input..SKey
    end
  end

  self.Input = Input
  self.Props.Bottom = Input
end ---- EditInput

end -- do
---------------------------------------- ---- Output
do
-- Вывод символа.
function TMain:PrintChar (Data)
  --logShow(Data, "PrintChar")
  if type(Data.char) == 'string' then
    return farUt.InsertText(nil, Data.char)
  end
end ---- PrintChar

-- Сохранение данных.
function TMain:SaveData (Data)
  local self = self

  self.CfgData.Char = Data.Char

  return self.History:save()
end ---- SaveData

end -- do
---------------------------------------- ---- Events
do
  local CloseFlag  = { isClose = true }
  local CancelFlag = { isCancel = true }
  local CompleteFlags = { isRedraw = false, isRedrawAll = true }

  local u8byte, u8char = strings.u8byte, strings.u8char

  local InputActions = {
    ["1"] = true,
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["5"] = true,
    ["6"] = true,
    ["7"] = true,
    ["8"] = true,
    ["9"] = true,
    ["0"] = true,
    ["A"] = true,
    ["B"] = true,
    ["C"] = true,
    ["D"] = true,
    ["E"] = true,
    ["F"] = true,
    ["BS"] = true,
    ["V"] = true,
  } --- InputActions

  local tonumber = tonumber

  local AlterActions = {
    Alt1 = true,
    Alt2 = true,
    Alt3 = true,
    Alt4 = true,
    Alt5 = true,
    Alt6 = true,
    Alt7 = true,
    Alt8 = true,
    Alt9 = true,
    Alt0 = true,
    AltA = true,
    AltB = true,
    AltC = true,
    AltD = true,
    AltE = true,
    AltF = true,
  } --- AlterActions

function TMain:AssignEvents () --> (bool | nil)
  local self = self

  local function MakeUpdate () -- Обновление!
    farUt.RedrawAll()
    self:Make()
    --logShow(self.Items, "MakeUpdate")
    if not self.Items then return nil, CloseFlag end
    --logShow(ItemPos, hex(FKey))
    return { self.Props, self.Items, self.Keys }, CompleteFlags
  end -- MakeUpdate

  -- Обработчик нажатия клавиш.
  local function KeyPress (VirKey, ItemPos)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end
    --if SKey == "Enter" then return end
    --logShow(VirKey, SKey)

    local Data = self.Items[ItemPos].Data
    if not Data then return end

    -- TODO: Поддержка перехода на символ:
    -- - при нажатии комбинации клавиш, соответствующих символу
    --   (см. макросы для вставки символов в редактор) - через config!

    local isUpdate = true
    if SKey == "CtrlB" then
      local Char = self:ChooseBlock(Data)
      if type(Char) == 'number' then
        self.Char = Char
      else
        isUpdate = false
      end

    elseif SKey == "CtrlV" then
      local s = far.PasteFromClipboard()
      if type(s) == 'string' then
        self.Char = u8byte(s:sub(1, 1))
      else
        isUpdate = false
      end

    elseif SKey == "CtrlShiftV" then
      local s = far.PasteFromClipboard()
      if type(s) == 'string' then
        s = (s.."0000"):match("^(%x%x%x%x)")
        if s then self.Char = tonumber(s, 16) end
      else
        isUpdate = false
      end

    elseif SKey == "CtrlAltX" then
      local s = Data.char
      --local s = u8char(Data.Char)
      local Char = far.XLat(s, 1, 1)
      Char = Char and Char ~= s and u8byte(Char:sub(1, 1)) or 0x0000
      if Char ~= 0x0000 then
        self.Char = Char
      else
        isUpdate = false
      end

    elseif SKey == "Divide" then
      if self.IsInput then
        self:StopInput(Data)
        --return MakeUpdate()
      else
        self:StartInput(Data)
      end

    elseif self.IsInput then
      if InputActions[SKey] then
        self:EditInput(SKey)
      end

    elseif AlterActions[SKey] then
      self.Char = tonumber(VirKey.UnicodeChar.."000", 16)
      --logShow(self.Char, SKey)

    else
      local Char = u8byte(VirKey.UnicodeChar or 0x0000)
      if Char ~= 0x0000 and
         (VirKey.StateName == "" or
          VirKey.StateName == "Shift") then
        self.Char = Char
      else
        isUpdate = false
      end
    end -- SKey

    if isUpdate then
      self:LimitChar()
      return MakeUpdate()
    end

    return
  end -- KeyPress

  -- Обработчик нажатия клавиш навигации.
  local function NavKeyPress (AKey, VMod, ItemPos)
    --if self.IsInput then return end

    local AKey, VMod = AKey, VMod

    local Data = self.Items[ItemPos].Data
    if not Data then return end

    local isUpdate = true
    if VMod == 0 then
      --logShow({ AKey, VMod, Date }, ItemPos, "w d2")
      if AKey == "Clear" or AKey == "Multiply" then
        self.Char = self.DefChar
      elseif AKey == "Left"  and Data.c == 1 then
        self.Char = Data.Char - 1
      elseif AKey == "Right" and Data.c == self.CharCols then
        self.Char = Data.Char + 1
      elseif AKey == "Up"    and Data.r == 1 then
        self.Char = Data.Char - self.CharCols
      elseif AKey == "Down"  and Data.r == self.CharRows then
        self.Char = Data.Char + self.CharCols
      elseif AKey == "PgUp" or
             (AKey == "Home" and
              Data.r == 1 and Data.c == 1) then
        self.Char = Data.Char - self.CharCount
      elseif AKey == "PgDn" or
             (AKey == "End" and
              Data.r == self.CharRows and Data.c == self.CharCols) then
        self.Char = Data.Char + self.CharCount
      else
        isUpdate = false
      end

    elseif IsModCtrl(VMod) then -- CTRL
      if AKey == "Clear" or AKey == "Multiply" then
        self.Char = self.DefChar
      elseif AKey == "Home" then
        self.Char = self.CharMin
      elseif AKey == "End" then
        self.Char = self.CharMax
      else
        isUpdate = false
      end

    elseif IsModAlt(VMod) then -- ALT
      if AKey == "Clear" or AKey == "Multiply" then
        self.Char = self.DefChar
      elseif AKey == "Left" then
        self.Char = Data.Char - self.CharCount
      elseif AKey == "Right" then
        self.Char = Data.Char + self.CharCount
      elseif AKey == "Up" then
        self.Char = Data.Char - self.CharPass
      elseif AKey == "Down" then
        self.Char = Data.Char + self.CharPass
      elseif AKey == "PgUp" then
        local Base = divf(Data.Char, self.CharPass) * self.CharPass
        self.Char = Base + (Data.Char - self.CharBase) - self.CharPass
      elseif AKey == "PgDn" then
        local Base = divf(Data.Char, self.CharPass) * self.CharPass
        self.Char = Base + (Data.Char - self.CharBase) + self.CharPass
      else
        isUpdate = false
      end

    --elseif IsModCtrlAlt(VMod) then -- ALT+CTRL

    else
      isUpdate = false
    end

    if isUpdate then
      self:LimitChar()
      return MakeUpdate()
    end

    return
  end -- NavKeyPress

--[[
  -- Обработчик выделения пункта.
  local function SelectItem (Kind, ItemPos)
    local Data = self.Items[ItemPos].Data
    --logShow(Data, ItemPos, "w d2")
    if not Data then return end

    self.Date = Data[Data.State]
    if Data.d <= 0 then return end
    self.Date.d = Data.d

    return self:FillInfoPart()
  end -- SelectItem
--]]

  -- Обработчик выбора пункта.
  local function ChooseItem (Kind, ItemPos)
    local Data = self.Items[ItemPos].Data
    if not Data then return end

    if self.IsInput and Kind == "Enter" then
      self:StopInput(Data)

      self:LimitChar()
      return MakeUpdate()
    end

    self:SaveData(Data)

    return nil, CloseFlag
  end -- ChooseItem

  -- Назначение обработчиков:
  local RM = self.Props.RectMenu
  RM.OnKeyPress = KeyPress
  RM.OnNavKeyPress = NavKeyPress
  --RM.OnSelectItem = SelectItem
  RM.OnChooseItem = ChooseItem
end -- AssignEvents

end --
---------------------------------------- ---- Action

function TMain:Apply () --> (item, pos)
  return self:PrintChar(self.ActItem.Data)
end ---- Apply

---------------------------------------- ---- Show
-- Показ меню заданного вида.
function TMain:ShowMenu () --> (item, pos)
  return usercall(nil, unit.RunMenu, self.Props, self.Items, self.Keys)
end ---- ShowMenu

-- Вывод календаря.
function TMain:Show () --> (bool | nil)

  --local Cfg = self.CfgData

  self:Make()
  if self.Error then return nil, self.Error end

  if useprofiler then profiler.stop() end

  self.ActItem, self.ItemPos = self:ShowMenu()
  if self.ActItem then return self:Apply() end

  return true
end -- Show

---------------------------------------- ---- Run
function TMain:Run () --> (bool | nil)

  self:AssignEvents()

  return self:Show()
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
return unit
--return unit.Execute()
--------------------------------------------------------------------------------
