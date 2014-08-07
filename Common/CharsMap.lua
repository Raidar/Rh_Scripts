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

local string = string

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

local CharsData = CharsList.Data
local CharsNames  = CharsData and CharsData.Names
local CharsBlocks = CharsData and CharsData.Blocks

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

---------------------------------------- ColFilter
local TColFilter = {
} ---
local MColFilter = { __index = TColFilter }

---------------------------------------- Main class
local TMain = {
  Guid       = win.Uuid("19500a29-1a9b-4b1b-833c-693d58669963"),
  ConfigGuid = win.Uuid("1991fe2b-e919-480e-8b0a-90b7c960d113"),

  Nomens     = {
    Guid       = win.Uuid("19ae6fa2-7ceb-4893-b2a7-fd8b783cc365"),
  }, ---

  Blocks     = {
    Guid       = win.Uuid("19b4271d-09c2-4671-af59-b043d1698104"),
  }, ---

} ---
local MMain     = { __index = TMain }
setmetatable(TMain.Nomens, MColFilter)
setmetatable(TMain.Blocks, MColFilter)
local MNomens   = { __index = TMain.Nomens }
local MBlocks   = { __index = TMain.Blocks }

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

    Nomens    = {         -- Объект: Символы
      Main      = false,    -- Объект основного класса

      -- Текущее состояние:
      Items     = false,    -- Список пунктов меню
      Props     = false,    -- Свойства меню
      Pattern   = "",       -- Паттерн фильтрации

      ActItem   = false,    -- Выбранный пункт меню
      ItemPos   = false,    -- Позиция выбранного пункта меню
    }, --

    Blocks    = {         -- Объект: Блоки символов
      Main      = false,    -- Объект основного класса

      -- Текущее состояние:
      Items     = false,    -- Список пунктов меню
      Props     = false,    -- Свойства меню
      Pattern   = "",       -- Паттерн фильтрации

      ActItem   = false,    -- Выбранный пункт меню
      ItemPos   = false,    -- Позиция выбранного пункта меню
    }, --

  } --- self
  self.Nomens.Main = self
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

  setmetatable(self.Nomens, MNomens)
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

  local uBlockName = CharsList.uBlockName

function TMain:MakeProps ()
  local self = self

  self.RowCount = 1 + self.CharRows + 1
  self.ColCount = 1 + self.CharCols + 1
  self.Filler = ("─"):rep(self.DigitNum)

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

    MaxHeight = 1 + 1 +
                self.RowCount +
                1 +
                (CharsBlocks and (1 + 2) or 0) +
                0,

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
    IsDrawEdges = CharsBlocks and true,

    --RectItem = {
    --  TextMark = true,
    --},
  } --- RM
  Props.RectMenu = RM

  RM.IsStatusBar = not RM.IsDrawEdges

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
  local uCP       = CharsList.uCP
  local uCodeName = CharsList.uCodeName
  
-- Заполнение меню.
function TMain:FillMenu () --> (table)
  local self = self

  local CharRows, CharCols = self.CharRows, self.CharCols
  local RowCount, ColCount = self.RowCount, self.ColCount

  local t = self.Items

  do
    -- Угловые ячейки
    local Filler = self.Filler
    local l = (RowCount - 1) * ColCount + 1
    t[1].text                 = Filler
    t[1 + ColCount - 1].text  = Filler
    t[l].text                 = Filler
    t[l + ColCount - 1].text  = Filler

    -- Начальная и конечная строки
    local Order = "0123456789ABCDEF"
    for k = 1, CharCols do
      local s = Order:sub(k, k)
      t[1 + k].text = s
      t[l + k].text = s
    end
  end -- do

  do
    -- Начальный и конечный столбцы
    local p = 0
    local b = self.CharBase
    for _ = 1, CharRows do
      p = p + ColCount
      --local s = uCP(b, true)
      t[p + 1].text        = uCP(b, true)
      t[p + ColCount].text = uCP(b + CharCols - 1, true)
      b = b + CharCols
    end
  end -- do

  do -- Символы таблицы
    local p = 1               -- Индекс начального пункта строки
    local b = self.CharBase   -- Код символа для текущего пункта
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

  end -- do

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
---------------------------------------- ---- ColFilter
do

function TColFilter:InitFilter ()
  local self = self
  local Props = self.Props

  local PatternFmt = Props.PatternFmt or " *[%s]"
  local FiltersFmt = Props.FiltersFmt or "(%d / %d)"
  Props.FmtTitle  = Props.DefTitle..PatternFmt
  if Props.DefBottom == "" then
    Props.FmtBottom = FiltersFmt
  else
    Props.FmtBottom = Props.DefBottom.." "..FiltersFmt
  end

  -- Сброс фильтра:
  self.Pattern = ""
  --self.Pattern = self.BasePattern or ""
  self.FilterCol = self.FilterCol or 1

  --self:MakeFilter()
  self:ApplyFilter()

  return true
end ---- InitFilter
  
  local function patfind (Text, Pattern)
    local Pattern = Pattern
    if Pattern:sub(-1, -1) == '%' and -- Exclude single escape character
       Pattern:sub(-2, -2) ~= '%' then Pattern = Pattern:sub(1, -2) end
    return Text:cfind(Pattern)
  end -- patfind

  local TNull = tables.Null

function TColFilter:MakeFilter ()
  local self = self
  local Items = self.Items
  if not Items or #Items == 0 then return end

  local Pattern = self.Pattern
  local FilterCol = self.FilterCol

  local RM = self.Props.RectMenu or TNull
  local Fixed = RM.Fixed or TNull
  local ColCount = RM.Cols or 1
  --logShow(Items, Pattern, 2)
  
  local j = 0
  local i = (Fixed.HeadRows or 0) * ColCount --+ FilterCol
  local e = #Items - (Fixed.FootRows or 0) * ColCount
  --logShow({ j, i, e, ColCount, FilterCol, i + FilterCol, Fixed, }, Pattern, 2)
  while i + FilterCol <= e do
    local v = Items[i + FilterCol]
    --if v == nil then logShow(i + FilterCol) end
    local s = v.conv
    if not s then
      s = v.text:lower()
      v.conv = s
    end

    local dummy
    if Pattern and Pattern ~= "" then
      local fpos, fend = patfind(s, Pattern)
      if fpos then
        dummy = false --nil
        v.RectMenu = v.RectMenu or {}
        v.RectMenu.TextMark = { fpos, fend }
      else
        j = j + 1
        dummy = true
        v.RectMenu = v.RectMenu or {}
        v.RectMenu.TextMark = nil
      end
    else
      dummy = nil
      v.RectMenu = v.RectMenu or {}
      v.RectMenu.TextMark = nil
    end

    for k = i + 1, i + ColCount do
      local v = Items[k]
      if v then v.dummy = dummy end
    end

    i = i + ColCount
  end -- while
  --logShow(Items, Pattern, 2)
  
  self.Filtered = j
end ---- MakeFilter

function TColFilter:ApplyFilter ()
  local self = self
  local Props = self.Props

  self:MakeFilter()

  Props.Title  = Props.FmtTitle:format(self.Pattern)
  Props.Bottom = Props.FmtBottom:format(self.Filtered, self.Count)
end ---- ApplyFilter

  local slen, sconv = string.len, string.lower

  --local CloseFlag  = { isClose = true }
  local CancelFlag = { isCancel = true }
  --local CompleteFlags = { isRedraw = false, isRedrawAll = true }
  local DoChange = { isUpdate = true }
  local NoChange = { isUpdate = false }

function TColFilter:AssignEvents () --> (bool | nil)
  local self = self

  local Table = { self.Props, self.Items, self.Keys }

  -- Обработчик нажатия клавиш.
  local function KeyPress (Input, ItemPos)
    local SKey = Input.Name --or InputRecordToName(Input)
    if SKey == "Esc" then return nil, CancelFlag end
    --if SKey == "Enter" then return end
    --logShow(Input, SKey)
    local State = Input.StateName
    if State ~= "" and State ~= "Shift" then return end

    local Data = self.Items[ItemPos]
    if not Data then return end

    SKey = Input.KeyName
    if SKey == "BS" then
      self.Pattern = self.Pattern:sub(1, -2)
    else
      if SKey == "Space" then SKey = " " end
      if slen(SKey) == 1 then
        self.Pattern = self.Pattern..sconv(SKey)
      else
        return
      end
    end -- SKey

    self:ApplyFilter()
    --logShow({ self.Filtered, self.Count, self.Pattern }, "KeyPress")
    if self.Filtered == self.Count then
      self.Pattern = self.Pattern:sub(1, -2)
      self:ApplyFilter()
    end

    return Table, DoChange
  end -- KeyPress

  -- Назначение обработчиков:
  local RM = self.Props.RectMenu
  RM.OnKeyPress = KeyPress
end -- AssignEvents

end -- do
---------------------------------------- ---- Nomens
do
  local TNomens = TMain.Nomens
  
function TNomens:MakeProps () --| (Nomens_Props)
  local self = self
  if self.Props then return end

  -- Свойства меню названий символов:
  local Props = {}
  self.Props = Props

  local Main = self.Main
  Props.Id = Props.Id or self.Guid
  Props.HelpTopic = Main.Custom.help.tlink
  Props.FarArea = Main.FarArea

  local L = Main.LocData
  Props.DefTitle  = L.NomensCaption
  Props.DefBottom = self.BasePattern or ""

  -- Свойства RectMenu:
  local RM = {
    ReuseItems = true,

    Order = "H",
    Cols = 1,

    Fixed = {
      --HeadRows = 1,
      --FootRows = 0,
      --HeadCols = 0,
      --FootCols = 0,
    },

    --MenuEdge = 2,
    MenuAlign = "CM",

    LineMax = 1,
    --TextMax = {
    --  [1] = RangeLen,
    --}, --

    --MaxHeight = Main.Props.RectMenu.MaxHeight,

    --Colors = self.Colors,

    --IsStatusBar = true,
  } -- RM
  Props.RectMenu = RM

  return true
end ---- MakeProps

  local uCP = CharsList.uCP
  local NomenFmt = "%s | %s | %s"
  local uCodeName = CharsList.uCodeName
  
  --local NamesCount = CharsData.NamesCount
  local NamesStart = CharsData.NamesStart
  local NamesLimit = CharsData.NamesLimit

function TNomens:MakeItems () --| (Nomens_Items)
  local self = self
  local Main = self.Main

  local L = Main.LocData

  local t = {
    { text = L.NomensColBlockName,
      Label = true,
      --RectMenu = self.RectItem,
    },
  } ---

  local pattern = self.BasePattern
  local U = unicode.utf8.char

  local k = 0
  local Count = self.NomensCount
  for i = NamesStart, NamesLimit do
    local c = CharsNames[i]
    if c then
      local s = c.name
      if s and s:lower():match(pattern) then
        k = k + 1

        t[k] = {
        --t[k + 0] = {
          --text = s,
          text = NomenFmt:format(c.code or uCP(i), U(i), s),
          Char = i,
        }
      end
    end

    if k >= Count then break end
  end -- for

  self.Count = k
  self.Items = t

  return true
end ---- MakeItems

function TNomens:ShowMenu () --> (item, pos)
  local self = self
  self:AssignEvents()

  return usercall(nil, unit.RunMenu,
                  self.Props, self.Items, self.Keys)
end ---- ShowMenu

end -- do
---------------------------------------- ---- Blocks
do
  local TBlocks = TMain.Blocks

  --local max = math.max
  
function TBlocks:MakeProps () --| (Blocks_Props)
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
  Props.DefTitle  = L.BlocksCaption
  Props.DefBottom = ""

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
    }, --

    --MaxHeight = Main.Props.RectMenu.MaxHeight,

    --Colors = self.Colors,

    --IsStatusBar = true,
  } -- RM
  Props.RectMenu = RM

  --self.RectItem = {
    --TextMark = true,
    --TextAlign = "CM",
  --} --

  return true
end ---- MakeProps

  local uCP = CharsList.uCP
  local BlockRangeFmt = "%s..%s"

function TBlocks:MakeItems () --| (Blocks_Items)
  local self = self
  if self.Items then return end

  local Main = self.Main

  local L = Main.LocData
  
  local t = {
    { text = L.BlocksColBlockRange,
      Label = true,
      --RectMenu = self.RectItem,
    },
    { text = L.BlocksColBlockName,
      Label = true,
      --RectMenu = self.RectItem,
    },
  } ---
  
  self.Count = CharsData.BlocksCount

  for i = 1, self.Count do
    local b = CharsBlocks[i]
    t[#t + 1] = {
      text = BlockRangeFmt:format(uCP(b.first, true),
                                  uCP(b.last, true)),
      Label = true,
      --RectMenu = self.RectItem,
    }
    t[#t + 1] = {
      text = b.name,
      Char = b.first,
    }
  end

  self.Items = t

  return true
end ---- MakeItems

function TBlocks:ShowMenu () --> (item, pos)
  local self = self
  self:AssignEvents()

  return usercall(nil, unit.RunMenu,
                  self.Props, self.Items, self.Keys)
end ---- ShowMenu

end -- do
---------------------------------------- ---- Choose
do

-- Choose character.
-- Выбор символа.
function TMain:ChooseChar (Data)

  local Nomens = self.Nomens
  Nomens.FilterCol = 1
  Nomens.NomensCount = self.InputCount
  Nomens.BasePattern = self.IsCharInput and self.Input

  Nomens:MakeProps()
  Nomens:MakeItems()
  Nomens:InitFilter()

  --local Char = Data and Data.Char or 0
  --Nomens.Props.SelectIndex = (uCodeBlock(Nomens) or 1) * 2 + 2
  --logShow(Nomens.Props, uCP(Char), 1)
  
  Nomens.ActItem, Nomens.ItemPos = Nomens:ShowMenu()
  farUt.RedrawAll() -- Exclude Nomens menu

  return Nomens.ActItem and Nomens.ActItem.Char
end ---- ChooseChar

  local uCodeBlock = CharsList.uCodeBlock

-- Choose character block.
-- Выбор блока символов.
function TMain:ChooseBlock (Data)
  --local self = self
  local Blocks = self.Blocks
  Blocks.FilterCol = 2
  
  Blocks:MakeProps()
  Blocks:MakeItems()
  Blocks:InitFilter()

  local Char = Data and Data.Char or 0
  Blocks.Props.SelectIndex = (uCodeBlock(Char) or 1) * 2 + 2
  --logShow(Blocks.Props, uCP(Char), 1)
  
  Blocks.ActItem, Blocks.ItemPos = Blocks:ShowMenu()
  farUt.RedrawAll() -- Exclude Blocks menu

  return Blocks.ActItem and Blocks.ActItem.Char
end ---- ChooseBlock

end -- do
---------------------------------------- ---- Input
do
  local tonumber = tonumber

function TMain:FindCodeInput ()
  --local self = self

  local Input = self.Input or ""
  if Input == "" then return end

  return tonumber(Input, 16)
end ---- FindCodeInput

function TMain:StartCodeInput (Data)
  local self = self
  local L = self.LocData

  self.Input = ""
  self.Props.Bottom = L.InputCodePoint
  self.IsCodeInput = true
end ---- StartCodeInput

function TMain:StopCodeInput (Data)
  local self = self

  self.IsCodeInput = false
  self.Props.Bottom = ""
  self.Char = self:FindCodeInput() or Data.Char
end ---- StopCodeInput

function TMain:EditCodeInput (SKey)
  local self = self

  local Input = self.Input
  if SKey == "BS" then
    if Input ~= "" then
      Input = Input:sub(1, -2)
    end

  elseif SKey == "CtrlV" then
    local s = far.PasteFromClipboard()
    --logShow(s, SKey)
    if type(s) == 'string' then
      s = (s.."0000"):match("^(%x%x%x%x)")
      --logShow(s, SKey)
      if s then Input = s:upper() end
    end
  else
    if Input:len() < 4 then
      Input = Input..SKey
    end
  end

  self.Input = Input
  if Input ~= "" then
    self.InputText = Input
  else
    local L = self.LocData
    self.InputText = L.InputCodePoint
  end

  self.Props.Bottom = self.InputText
end ---- EditCodeInput

end -- do
do
  --local u8byte = strings.u8byte -- TEMP
  local uFindCode = CharsList.uFindCode

function TMain:FindCharInput ()
  --local self = self
  
  local Input = self.Input or ""
  if Input == "" then return end

  if Input:sub(1, 1) ~= "^" then
    Input = ".*"..Input
  end
  --if Input:sub(-1, -1) ~= "$" then
  --  Input = Input..".*"
  --end

  --logShow(self, Input)
  --return u8byte(Input:sub(1, 1)) -- TEMP
  return uFindCode(Input, self.Char + 1)
end ---- FindCharInput

  local uCodeCount = CharsList.uCodeCount

function TMain:CountChars ()
  --local self = self
  
  local Input = self.Input or ""
  if Input == "" then return end

  if Input:sub(1, 1) ~= "^" then
    Input = ".*"..Input
  end

  return uCodeCount(Input)
end ---- CountChars

function TMain:StartCharInput (Data)
  local self = self
  local L = self.LocData

  self.Input = ""
  self.Props.Bottom = L.InputCharName
  self.IsCharInput = true
end ---- StartCharInput

function TMain:StopCharInput (Data)
  local self = self

  self.IsCharInput = false
  self.Props.Bottom = ""
end ---- StopCharInput

function TMain:GotoCharInput (Data)
  local self = self

  self.Char = self:FindCharInput() or Data.Char

  return self:FillInputCount()
end ---- GotoCharInput

  local NamesCount = CharsData.NamesCount

function TMain:FillInputCount ()
  local self = self
  local Input = self.Input

  if Input:len() > 2 then
    if Input ~= self.PriorInput then
      self.PriorInput = Input
      self.InputCount = self:CountChars()
    end
    self.Props.Bottom = self.InputText..
                        (" (%d / %d)"):format(self.InputCount, NamesCount)
  else
    self.PriorInput = Input
    self.InputCount = false
  end

  --return self.InputCount
end ---- FillInputCount

function TMain:EditCharInput (SKey)
  local self = self

  local Input = self.Input
  if SKey == "BS" then
    if Input ~= "" then
      Input = Input:sub(1, -2)
    end

  elseif SKey == "CtrlV" then
    local s = far.PasteFromClipboard()
    if type(s) == 'string' then
      Input = s
    end
  else
    --if Input:len() < 4 then
      if SKey == "Space" then SKey = " " end
      Input = Input..SKey
    --end
  end

  self.Input = Input
  if Input ~= "" then
    self.InputText = Input
  else
    local L = self.LocData
    self.InputText = L.InputCharName
  end

  self.Props.Bottom = self.InputText
end ---- EditCharInput

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

  local CodeInputActions = {
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
    ["CtrlV"] = true,
  } --- CodeInputActions

  local CharInputActions = {
    ["BS"] = true,
    ["CtrlV"] = true,
    ["Space"] = true,
  } --- CharInputActions

  local UniCharInputActions = {
    ["^"] = true,
    ["$"] = true,
    ["("] = true,
    [")"] = true,
    ["%"] = true,
    ["."] = true,
    ["["] = true,
    ["]"] = true,
    ["*"] = true,
    ["+"] = true,
    ["-"] = true,
    ["?"] = true,

    --["!"] = true,
    --[","] = true,
    --["'"] = true,
    --[":"] = true,
    --[";"] = true,
  } --- UniCharInputActions

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

  local NamesCount = CharsData.NamesCount

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
  local function KeyPress (Input, ItemPos)
    local SKey = Input.Name --or InputRecordToName(Input)
    if SKey == "Esc" then return nil, CancelFlag end
    --if SKey == "Enter" then return end
    --logShow(Input, SKey)

    local Data = self.Items[ItemPos].Data
    if not Data then return end

    -- TODO: Поддержка перехода на символ:
    -- - при нажатии комбинации клавиш, соответствующих символу
    --   (см. макросы для вставки символов в редактор) - через config!

    local isUpdate = true
    if SKey == "CtrlB" then
      if not CharsBlocks then return end
      local Char = self:ChooseBlock(Data)
      if type(Char) == 'number' then
        self.Char = Char
      else
        isUpdate = false
      end
      
    elseif SKey == "CtrlC" and self.IsCharInput then

      local PriorCount = self.InputCount
      self:FillInputCount()
      local InputCount = self.InputCount

      --logShow(Count, SKey)
      --if InputCount and InputCount > 0 and InputCount < 1000 then
      if InputCount and InputCount > 0 and InputCount < NamesCount / 2 then
        local Char = self:ChooseChar(Data)
        if type(Char) == 'number' then
          self.Char = Char
        else
          isUpdate = (InputCount ~= PriorCount)
        end
      else
        isUpdate = (InputCount ~= PriorCount)
      end
      
    elseif SKey == "Divide" then
      if self.IsCodeInput then
        self:StopCodeInput(Data)
      elseif not self.IsCharInput then
        self:StartCodeInput(Data)
      else
        isUpdate = false
      end

    elseif SKey == "ShiftDivide" then
      if self.IsCharInput then
        self:StopCharInput(Data)
      elseif not self.IsCodeInput then
        self:StartCharInput(Data)
      else
        isUpdate = false
      end

    elseif self.IsCodeInput then
      if CodeInputActions[SKey] then
        self:EditCodeInput(SKey)
      else
        isUpdate = false
      end

    elseif self.IsCharInput then
      --logShow(Input, SKey)
      local KeyChar = Input.KeyName
      local UniChar = Input.UnicodeChar
      if UniCharInputActions[UniChar or ""] then
        KeyChar = UniChar
      elseif KeyChar:len() == 1 then
        if (Input.StateName == "" or
            Input.StateName == "Shift") then
          KeyChar = KeyChar:lower()
        --if Input.StateName == "" then
        --  KeyChar = KeyChar:lower()
        --elseif Input.StateName == "Shift" then
        --  -- Nothing to do
        --  KeyChar = KeyChar:lower()
        else
          KeyChar = false
        end
      else
        KeyChar = false
      end

      if KeyChar or CharInputActions[SKey] then
        self:EditCharInput(KeyChar or SKey)
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

    elseif AlterActions[SKey] then
      self.Char = tonumber(Input.UnicodeChar.."000", 16)
      --logShow(self.Char, SKey)

    else
      local Char = u8byte(Input.UnicodeChar or 0x0000)
      if Char ~= 0x0000 and
         (Input.StateName == "" or
          Input.StateName == "Shift") then
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
    --if self.IsCodeInput then return end
    
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

  -- Обработчик нажатия мыши на отступе.
  local function EdgeClick (Kind, Input, ItemPos)
    --logShow(Input, Kind)

    local Data = self.Items[ItemPos].Data
    --if not Data then return end

    local isUpdate = true

    if Kind == "B" and Input.r == 3 then
      --logShow(Input, Kind)
      local Char = self:ChooseBlock(Data)
      if type(Char) == 'number' then
        self.Char = Char
      else
        isUpdate = false
      end
    else
      isUpdate = false
    end

    if isUpdate then
      self:LimitChar()
      return MakeUpdate()
    end

    return
  end -- EdgeClick

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

    if Kind == "Enter" then

      local isUpdate = true
      if     self.IsCodeInput then
        self:StopCodeInput(Data)
      elseif self.IsCharInput then
        self:GotoCharInput(Data)
      else
        isUpdate = false
      end

      if isUpdate then
        self:LimitChar()
        return MakeUpdate()
      end
    end

    self:SaveData(Data)

    return nil, CloseFlag
  end -- ChooseItem

  -- Назначение обработчиков:
  local RM = self.Props.RectMenu
  RM.DoMouseEvent   = true
  RM.OnKeyPress     = KeyPress
  RM.OnNavKeyPress  = NavKeyPress
  RM.OnEdgeClick    = CharsBlocks and EdgeClick
  --RM.OnSelectItem   = SelectItem
  RM.OnChooseItem   = ChooseItem
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
