--[[ Calendar ]]--

----------------------------------------
--[[ description:
  -- Menu based simple calendar.
  -- Простой календарь на основе меню.
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

local type, assert = type, assert
local pairs, ipairs = pairs, ipairs
local setmetatable = setmetatable

----------------------------------------
--local win, far = win, far

----------------------------------------
--local context = context

local utils = require 'context.utils.useUtils'
local strings = require 'context.utils.useStrings'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local Null = tables.Null
local addNewData = tables.extend

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"
local datim = require "Rh_Scripts.Utils.DateTime"

----------------------------------------
--local keyUt = require "Rh_Scripts.Utils.Keys"

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.FileName   = "DateTime"
unit.FilePath   = "scripts\\Rh_Scripts\\Common\\"
unit.ScriptName = "Calendar"
unit.ScriptPath = "scripts\\Rh_Scripts\\Testing\\"

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
    file = unit.FileName,
    path = unit.FilePath,
  }, --
} -- DefCustom

--[[
local L, e1, e2 = locale.localize(nil, unit.DefCustom)
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
  --Guid       = win.Uuid(""),
  --ConfigGuid = win.Uuid(""),
}
local MMain = { __index = TMain }

-- Создание объекта основного класса.
local function CreateMain (ArgData)

  local self = {
    ArgData   = addNewData(ArgData, unit.DefCfgData),

    Custom    = false,
    Options   = false,
    History   = false,
    CfgData   = false,
    --DlgTypes  = unit.DlgTypes,
    LocData   = false,
    L         = false,

    -- Текущее состояние:
    World     = false,    -- Мир
    Date      = false,    -- Дата
    Time      = false,    -- Время

    --Error     = false,    -- Текст ошибки
    --Menu      = false,    -- CfgData.Menu or {}

    Items     = false,    -- Список пунктов меню
    Props     = false,    -- Свойства меню

    ActItem   = false,    -- Выбранный пункт меню
    ItemPos   = false,    -- Позиция выбранного пункта меню
    --Action    = false,    -- Выбранное действие
    --Effect    = false,    -- Выбранный эффект
  } --- self

  self.ArgData.Custom = self.ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(self.ArgData, "ArgData")
  self.Custom = datas.customize(self.ArgData.Custom, unit.DefCustom)
  self.Options = addNewData(self.ArgData.Options, unit.DefOptions)

  self.History = datas.newHistory(self.Custom.history.full)
  self.CfgData = self.History:field(self.Custom.history.field)

  local CfgData = self.CfgData
  self.Menu = CfgData.Menu or {}
  --self.Menu.CompleteKeys = self.Menu.CompleteKeys or unit.CompleteKeys
  --self.Menu.LocalUseKeys = self.Menu.LocalUseKeys or unit.LocalUseKeys

  local dt = CfgData.dt or os.date("*t")
  self.Date = CfgData.Date or datim.newDate(dt.year, dt.month, dt.day)
  self.Time = CfgData.Time or datim.newTime(dt.hour, dt.min, dt.sec)
  self.World = self.Date.config.Name

  setmetatable(self.CfgData, { __index = self.ArgData })
  --logShow(self.CfgData, "CfgData")

  locale.customize(self.Custom)
  --logShow(self.Custom, "Custom")

  return setmetatable(self, MMain)
end -- CreateMain

---------------------------------------- Dialog

---------------------------------------- Main making

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

  local menUt = require "Rh_Scripts.Utils.Menu"
  local colors = require 'context.utils.useColors'
  local basics = colors.BaseColors
  local make = colors.make

  local Colors = menUt.MenuColors()
  local t = Colors
  -- Обычный день
  local v = Colors.COL_MENUTEXT
  t = menUt.ChangeColors(t,
                         colors.getFG(v),   colors.getBG(v),
                         basics.black,      basics.silver)
  -- Выделенный день
  v = Colors.COL_MENUSELECTEDTEXT
  t.COL_MENUSELECTEDTEXT = make(basics.blue, colors.getBG(v), type(v))
  -- Выходной день
  v = Colors.COL_MENUMARKTEXT
  t.COL_MENUMARKTEXT = make(basics.maroon, colors.getBG(v), type(v))
  v = Colors.COL_MENUSELECTEDMARKTEXT
  t.COL_MENUSELECTEDMARKTEXT = make(basics.maroon, colors.getBG(v), type(v))
  t = menUt.ChangeColors(t,
                         nil, colors.getBG(Colors.COL_MENUSELECTEDTEXT),
                         nil, basics.white)
  self.UsualColors = t

  local t = tables.copy(t, false, pairs, true)
  t = menUt.ChangeColors(t,
                         basics.black,      nil,
                         basics.white,      basics.gray)
  self.FixedColors = t

  return true
end ---- MakeColors

function TMain:MakeLocLen () --> (bool)
  local self = self

  local World = self.World
  local L = self.LocData[World]
  --logShow(L, World, "w d2")

  do -- Названия дней недели
    local WeekDay = L.WeekDay[0]

    local MaxLen = WeekDay[0]:len()
    for k = 1, #WeekDay do
      local Len = WeekDay[k]:len()
      if MaxLen < Len then MaxLen = Len end
    end

    WeekDay.MaxLen = MaxLen
  end

  do -- Названия месяцев года
    local YearMonth = L.YearMonth[0]

    local MaxLen = YearMonth[1]:len()
    for k = 2, #YearMonth do
      local Len = YearMonth[k]:len()
      if MaxLen < Len then MaxLen = Len end
    end

    YearMonth.MaxLen = MaxLen
  end

  return true
end ---- MakeLocLen

  local max = math.max

function TMain:MakeProps ()
  local self = self

  -- Свойства меню:
  local Props = self.Menu.Props or {}
  self.Props = Props

  Props.Id = self.Guid

  local L = self.LocData
  Props.Title  = L.Calendar
  Props.Bottom = "Alt+(←→↑↓)"

  local wL = L[self.World]
  self.TextMax = max(10,                    -- date / time
                     wL.Name:len() + 2,     -- World name
                     wL.WeekDay[0].MaxLen,  -- WeekDay max
                     wL.YearMonth[0].MaxLen -- YearMonth max
                    )

  local DT_cfg = self.Date.config
  self.RowCount = 1 + DT_cfg.DayPerWeek + 1
  self.ColCount = 3 + DT_cfg.MonthDays.WeekMax + 1

  -- Свойства RectMenu:
  local RM_Props = {
    Order = "V",
    Rows = self.RowCount,
    --Cols = self.ColCount,
    Fixed = {
      HeadRows = 1,
      FootRows = 1,
      HeadCols = 3,
      FootCols = 1,
    },

    --MenuEdge = 2,
    MenuAlign = "CM",

    textMax = {
      [2] = self.TextMax,
    }, -- textMax

    Colors = self.UsualColors,
    FixedColors = self.FixedColors,

  } --- RM_Props
  Props.RectMenu = RM_Props

  return true
end ---- MakeProps

-- Подготовка.
-- Preparing.
function TMain:Prepare ()

  self:Localize()
  self:MakeLocLen()

  self:MakeColors()

  return self:MakeProps()
end ---- Prepare

end -- do
---------------------------------------- ---- Menu
do
  local function DayToStr (d) --> (string)
    return ("%02d"):format(d)
  end --

  local function WeekDayToStr (d) --> (string)
    return ("<%1d>"):format(d)
  end --

  local spaces = strings.spaces

  local function CenterText (Text, Max) --> (string)
    local Text = Text or ""
    local Len = Text:len()
    if Len >= Max then return Text end

    local sp = spaces[(Max - Len - (Max - Len) % 2) / 2]

    return sp..Text
  end -- CenterText

-- Заполнение меню.
function TMain:FillMenu () --> (table)
  local self = self
  local t = self.Items

  local Date = self.Date
  local Time = self.Time
  local World = self.World
  local DT_cfg = Date.config

  local WeekDay = Date:getWeekDay()
  local DayPerWeek = DT_cfg.DayPerWeek
  local WeekMax = DT_cfg.MonthDays.WeekMax

  local RowCount = self.RowCount
  local ItemNames = {
    World     = RowCount + 1,
    Year      = RowCount + 3,
    Month     = RowCount + 4,
    Date      = RowCount + 6,
    Time      = RowCount + 9,
    WeekDay   = RowCount + 7,

    YearDay   = RowCount * 0 + 7,
    YearWeek  = RowCount * 2 + 7,

    PrevYear  =                3,
    NextYear  = RowCount * 2 + 3,
    PrevMonth =                4,
    NextMonth = RowCount * 2 + 4,

    Separators = {
                     2,                5,                8, -- 1
      RowCount     + 2, RowCount     + 5, RowCount     + 8, -- 2
      RowCount * 2 + 2, RowCount * 2 + 5, RowCount * 2 + 8, -- 3
                     1,                                  9, -- 1*
      RowCount * 2 + 1,                   RowCount * 2 + 9, -- 3*
    }, --

    FirstDay      = RowCount * 3 + 1,
    FirstWeekDay  = RowCount * (3 + WeekMax) + 1,

  } -- ItemNames

  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local Loc = L[World]
  local WeekDayNames   = (Loc or Null).WeekDay or Null
  local YearMonthNames = (Loc or Null).YearMonth or Null

  local ItemDatas = {
    --World     = (" %s "):format(Loc.Name),
    World     = World ~= "Terra" and (" %s "):format(Loc.Name) or "",
    Year      = ("%04d"):format(Date.y),
    Month     = (YearMonthNames[0] or Null)[Date.m],
    Date      = ("%04d-%02d-%02d"):format(Date.y, Date.m, Date.d),
    Time      = Time and ("%02d:%02d:%02d"):format(Time.h, Time.n, Time.s) or "",
    WeekDay   = (WeekDayNames[0] or Null)[WeekDay],

    YearDay   = ("%03d"):format(Date:getYearDay()),
    YearWeek  = ("%02d"):format(Date:getYearWeek()),

    --[[
    PrevYear  = "<==",
    NextYear  = "==>",
    PrevMonth = "<--",
    NextMonth = "-->",
    --]]
  } --- ItemDatas

  -- Текущая информация:
  local TextMax = self.TextMax
  for k, v in pairs(ItemDatas) do
    local n = ItemNames[k]
    if n then
      if n < RowCount or n > RowCount * 2 then
        t[n].text = v
      else
        t[n].text = CenterText(v, TextMax)
      end
    end
  end --

  local Separators = ItemNames.Separators
  for k = 1, #Separators do
    local v = Separators[k]
    t[v].separator = true
  end

  return true
end ---- FillMenu

-- Формирование меню.
function TMain:MakeMenu () --> (table)
  local self = self

  local Date = self.Date
  local Time = self.Time
  local World = self.World
  local DT_cfg = Date.config

  local WeekDay = Date:getWeekDay()
  local DayPerWeek = DT_cfg.DayPerWeek
  local WeekMax = DT_cfg.MonthDays.WeekMax

  local RowCount = self.RowCount

  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local Loc = L[World]
  local WeekDayNames   = (Loc or Null).WeekDay or Null
  local YearMonthNames = (Loc or Null).YearMonth or Null

  local t = {}

  -- Текущая информация:
  for i = 1, 3 do
    for j = 1, RowCount do
      t[#t+1] = {
        text = "",
        Label = true,
      } --
    end
  end --

  local CurrentDay = Date.d
  local Start = datim.newDate(Date.y, Date.m, 01)
  --logShow(Start, CurrentDay, "w d2")
  local MonthDays = Start:getMonthDays()
  local StartWeekDay, StartWeekShift = Start:getWeekDay(), 0
  if StartWeekDay == 0 then
    StartWeekDay = DayPerWeek
  elseif StartWeekDay == 1 then
    StartWeekShift = 1
    StartWeekDay = StartWeekDay + DayPerWeek
  end
  --StartWeekDay = StartWeekDay == 0 and DayPerWeek or StartWeekDay
                 --== 1 and StartWeekDay + DayPerWeek or StartWeekDay

  --t[RowCount * 3 - 1].text = ("%1d"):format(StartWeekDay) -- DEBUG
  local StartYearWeek = Start:getYearWeek()

  local Prev = Start:copy()
  --logShow(Prev, Prev:getEraDay(), "w d2")
  Prev:shd(-StartWeekDay)
  --logShow(Prev, StartWeekDay, "w d2")
  local Next = Start:copy()
  Next:shd(MonthDays)
  --logShow(Next, MonthDays, "w d2")

  -- Дни месяца:
  local d = 0       -- День текущего месяца
  local p = Prev.d  -- День предыдущего месяца
  local q = 0       -- День следующего месяца
  local SelIndex    -- Индекс пункта с текущей датой
  for i = 1, WeekMax do

    -- Номер недели месяца:
    t[#t+1] = {
      text = (" %1d"):format(i - StartWeekShift),
      Label = true,
    } --

    -- Дни недели:
    for j = 1, DayPerWeek do
      local State = 0
      if i < 2 then
        if j < StartWeekDay then
          p = p + 1
          State = -1
        end
      elseif d >= MonthDays then
        p = false
        q = q + 1
        State = 1
      end

      local Text = ""
      if State == 0 then
        d = d + 1
        Text = DayToStr(d)

        if d == CurrentDay then SelIndex = #t + 1 end
      else
        Text = DayToStr(p or q)
      end

      t[#t+1] = {
        text = Text,
        Label = true,

        grayed = (State ~= 0),

        RectMenu = {
          TextMark = DT_cfg.RestWeekDays[j % DayPerWeek],
        }, --

        Data = {
          [-1] = Prev,
          [ 0] = Date,
          [ 1] = Next,
          Start = Start,
          State = State,
          d = State == 0 and d or p or q,
        }, --
      } --
    end

    -- Номер недели года:
    t[#t+1] = {
      text = ("%02d"):format(StartYearWeek + i - 1 - StartWeekShift),
      Label = true,
    } --

  end -- for

  self.Props.SelectIndex = SelIndex

  -- Дни недели:
  local WeekDayShort = WeekDayNames[2] or WeekDayNames[3] or Null
  t[#t+1] = {
    text = "",
    separator = true,
  } --
  for w = 1, DayPerWeek do
    t[#t+1] = {
      text = WeekDayShort[w % DayPerWeek] or WeekDayToStr(w),
      Label = true,

      RectMenu = {
        TextMark = DT_cfg.RestWeekDays[w % DayPerWeek],
      }, --
    } --
  end
  t[#t+1] = {
    text = "",
    separator = true,
  } --

  self.Items = t

  return self:FillMenu()
end -- MakeMenu

-- Формирование календаря.
function TMain:MakeCalendar () --> (table)

  --local Cfg = self.CfgData

  --self.Date = datim.newDate(2012, 12, 31)
  --self.Date = datim.newDate(2013, 01, 01)
  --local dt = self.Value or os.date("*t")
  --self.Date = self.Date or datim.newDate(dt.year, dt.month, dt.day)
  --self.Time = self.Time or datim.newTime(dt.hour, dt.min, dt.sec)

  self.Items = false -- Сброс меню (!)

  return self:MakeMenu()
end -- MakeCalendar

end -- do
---------------------------------------- ---- Show
-- Показ меню заданного вида.
function TMain:ShowMenu () --> (item, pos)
  return usercall(nil, unit.RunMenu,
                  self.Props, self.Items, self.Keys)
  --return unit.RunMenu(self.Props, self.Items, self.Menu.CompleteKeys)
end ----

do
  local CloseFlag  = { isClose = true }
  local CancelFlag = { isCancel = true }
  local CompleteFlags = { isRedraw = false, isRedrawAll = true }

  local DateActions = {
    AltLeft     = "dec_m",
    AltRight    = "inc_m",
    AltUp       = "dec_y",
    AltDown     = "inc_y",
  } -- DateActions

function TMain:AssignEvents () --> (bool | nil)

  -- Обработчик нажатия клавиши.
  local function KeyPress (VirKey, ItemPos)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end

    --logShow(SKey, "SKey")
    local Action = DateActions[SKey]
    if Action then
      local date = self.Date
      date[Action](date)
      self.Time = false
    end

    local function MakeUpdate () -- Обновление!
      farUt.RedrawAll()
      self:MakeCalendar()
      --logShow(self.Items, "MakeUpdate")
      if not self.Items then return nil, CloseFlag end
      --logShow(ItemPos, hex(FKey))
      return { self.Props, self.Items, self.Keys }, CompleteFlags
    end -- MakeUpdate

    return MakeUpdate()
  end -- KeyPress

  -- Обработчик выделения пункта.
  local function SelectItem (Kind, ItemPos)
    local Data = self.Items[ItemPos].Data
    --logShow(Data, ItemPos, "w d2")
    if not Data then return end

    self.Date = Data[Data.State]
    self.Date.d = Data.d

    return self:FillMenu()
  end -- SelectItem

  -- Назначение обработчика:
  local RM_Props = self.Props.RectMenu
  RM_Props.OnKeyPress = KeyPress
  RM_Props.OnSelectItem = SelectItem
end -- AssignEvents

end --

-- Вывод календаря.
function TMain:Show () --> (bool | nil)

  --local Cfg = self.CfgData

  self:MakeCalendar()
  if self.Error then return nil, self.Error end

  self.ActItem, self.ItemPos = self:ShowMenu()

  return true
end -- Show

---------------------------------------- ---- Run
function TMain:Run () --> (bool | nil)

  self:AssignEvents()

  return self:Show()
end -- Run

---------------------------------------- main

function unit.Execute (Data) --> (bool | nil)

  local _Main = CreateMain(Data)
  if not _Main then return end

  --logShow(Data, "Data", 2)
  --logShow(_Main, "Config", "_d2")
  --logShow(_Main.CfgData, "CfgData", 2)
  --if not _Main.CfgData.Enabled then return end

  _Main:Prepare()
  if _Main.Error then return nil, _Main.Error end

  return _Main:Run()
end ---- Execute

--------------------------------------------------------------------------------
--return unit
return unit.Execute()
--------------------------------------------------------------------------------
