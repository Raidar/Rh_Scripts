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
local useprofiler = false
--local useprofiler = true

if useprofiler then
  require "profiler" -- Lua Profiler
  profiler.start("Calendar.log")
end

----------------------------------------
--local win, far = win, far

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local divf = numbers.divf

local Null = tables.Null
local addNewData = tables.extend

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

local datim = require "Rh_Scripts.Utils.DateTime"

----------------------------------------
local keyUt = require "Rh_Scripts.Utils.Keys"

local IsModCtrl, IsModAlt = keyUt.IsModCtrl, keyUt.IsModAlt
local IsModCtrlAlt = keyUt.IsModCtrlAlt

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.FileName   = "DateTime"
--unit.FilePath   = "scripts\\Rh_Scripts\\Common\\"
unit.ScriptName = "Calendar"
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
    file = unit.FileName,
    --path = unit.FilePath,
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

    FeteData  = false,    -- Данные о праздниках
    Fetes     = false,    -- Даты праздников

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
-- Инициализация календаря.
function TMain:InitData ()
  local self = self
  local CfgData = self.CfgData

  local dt = CfgData.dt or os.date("*t")
  self.Date = CfgData.Date or datim.newDate(dt.year, dt.month, dt.day)
  self.Time = CfgData.Time or datim.newTime(dt.hour, dt.min, dt.sec)
  self.YearMin = CfgData.YearMin or 1
  self.YearMax = CfgData.YearMax or 9999

  local DT_cfg = self.Date.config
  self.DT_cfg = DT_cfg

  self.World    = DT_cfg.World
  self.Type     = DT_cfg.Type
  self.WeekMax  = DT_cfg.MonthDays.WeekMax

  return true
end ---- InitData

function TMain:InitFetes ()
  local self = self
  local Custom = self.Custom

  local h = addNewData({}, Custom.history)
  --logShow(h, "Fete history", "w d2")
  h.field = "Fetes"
  h.dir   = "Fetes\\"
  h.ext   = '.lua'
  h.name  = self.World
  h.file  = h.name..h.ext
  --h.path  = h.path
  h.work  = h.f_fpath:format(Custom.profile, h.path, h.dir)
  h.full  = h.work..h.file
  --logShow(h, "Fete history", "w d2")

  local t = {
    history = h,
    History = datas.newHistory(h.full),
    Fetes = false,
  } ---
  --logShow(t.History, "Fete History", "w d2")
  t.Fetes = t.History:field(h.field)
  --logShow(t.Fetes, "Fetes", "w d2")

  self.FeteData = t
  --logShow(t, "Fete Data", "w d3")

  return true
end ---- InitFetes

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

function TMain:MakeFetes ()
  local self = self
  --local Custom = self.Custom

end ---- MakeFetes

  local max = math.max

function TMain:MakeProps ()
  local self = self

  -- Свойства меню:
  local Props = self.Menu.Props or {}
  self.Props = Props

  Props.Id = Props.Id or self.Guid
  Props.HelpTopic = self.Custom.help.tlink

  local L = self.LocData
  Props.Title  = L.Calendar

  local wL = L[self.World]
  local DT_cfg = self.DT_cfg

  self.TextMax = max(DT_cfg.Formats.DateLen,-- Date length
                     DT_cfg.Formats.TimeLen,-- Time length
                     wL.Name:len() + 2,     -- World name
                     wL.WeekDay[0].MaxLen,  -- WeekDay max
                     wL.YearMonth[0].MaxLen -- YearMonth max
                    )

  self.RowCount = 1 + DT_cfg.DayPerWeek + 1
  self.ColCount = 3 + self.WeekMax + 1

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

  self:InitData()
  --self:InitFetes()

  self:Localize()
  self:MakeLocLen()

  --self:MakeFetes()

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

    local sp = spaces[divf(Max - Len, 2)]

    return sp..Text
  end -- CenterText

-- Заполнение меню.
function TMain:FillMenu () --> (table)
  local self = self
  local t = self.Items

  local Date = self.Date
  local Time = self.Time
  local World = self.World
  local DT_cfg = self.DT_cfg

  local WeekDay = Date:getWeekDay()
  local DayPerWeek = DT_cfg.DayPerWeek
  local WeekMax = self.WeekMax

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

    --FirstDay      = RowCount * 3 + 1,
    --FirstWeekDay  = RowCount * (3 + WeekMax) + 1,

  } -- ItemNames

  local Formats = DT_cfg.Formats
  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local wL = L[World]
  local WeekDayNames   = (wL or Null).WeekDay or Null
  local YearMonthNames = (wL or Null).YearMonth or Null

  local ItemDatas = {
    --World     = Formats.World:format(wL.World),
    World     = World ~= "Terra" and Formats.World:format(wL.World) or "",
    Year      = Formats.Year:format(Date.y),
    Month     = (YearMonthNames[0] or Null)[Date.m],
    Date      = Formats.Date:format(Date.y, Date.m, Date.d),
    Time      = Time and Formats.Time:format(Time.h, Time.n, Time.s) or "",
    WeekDay   = (WeekDayNames[0] or Null)[WeekDay],

    YearDay   = Formats.YearDay:format(Date:getYearDay()),
    YearWeek  = Formats.YearWeek:format(Date:getYearWeek()),

    --[[
    PrevYear  = "<==",
    NextYear  = "==>",
    PrevMonth = "<--",
    NextMonth = "-->",
    --]]
  } --- ItemDatas

  --[[
  local ItemHints = {
    World     = Formats.Type:format(wL[self.Type]),
  } --- ItemHints
  --]]

  -- Текущая информация:
  local TextMax = self.TextMax
  for k, v in pairs(ItemDatas) do
    local pos = ItemNames[k]
    if pos then
      if pos < RowCount or pos > RowCount * 2 then
        t[pos].text = v
      else
        t[pos].text = CenterText(v, TextMax)
      end

      --[[
      local hint = ItemHints[k]
      if hint then t[pos].Hint = hint end
      --]]
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
  local WeekMax = self.WeekMax

  local RowCount = self.RowCount

  local Formats = DT_cfg.Formats
  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local wL = L[World]
  local WeekDayNames   = (wL or Null).WeekDay or Null
  local YearMonthNames = (wL or Null).YearMonth or Null

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
  local Start = Date:copy()
  Start.d = 1
  --logShow(Start, CurrentDay, "w d2")
  local MonthDays = Start:getMonthDays()
  --logShow(Start, MonthDays, "w d2")
  local StartYearWeek = Start:getYearWeek()

  local StartWeekDay, StartWeekShift = Start:getWeekDay(), 0
  if StartWeekDay == 0 then
    StartWeekDay = DayPerWeek
  elseif StartWeekDay < divf(DayPerWeek, 2) then
    StartWeekShift = 1
    StartWeekDay = StartWeekDay + DayPerWeek
  end
  --t[RowCount * 3 - 1].text = ("%1d"):format(StartWeekDay) -- DEBUG

  local Prev = Start:copy()
  Prev:shd(-StartWeekDay)
  --logShow({ Prev, Start }, StartWeekDay, "w d2")
  local Next = Start:copy()
  Next:shd(MonthDays)

  -- Дни месяца:
  local d = 0       -- День текущего месяца
  local p = Prev.d  -- День предыдущего месяца
  local q = 0       -- День следующего месяца
  local SelIndex    -- Индекс пункта с текущей датой
  for i = 1, WeekMax do

    -- Номер недели месяца:
    t[#t+1] = {
      text = Formats.MonthWeek:format(i - StartWeekShift),
      Label = true,
    } --

    -- Дни недели:
    for j = 1, DayPerWeek do
      local State = 0
      if i < 3 then
        if (i - 1) * DayPerWeek + j < StartWeekDay then
          if p > 0 then p = p + 1 end
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
        Text = DayToStr(p and p <= 0 and 0 or p or q)
      end

      t[#t+1] = {
        text = Text,
        Label = true,

        grayed = (State ~= 0),

        RectMenu = {
          TextMark = DT_cfg.RestWeekDays[j % DayPerWeek],
        }, --

        Data = {
          r = j,
          c = i,
          State = State,
          [-1] = Prev,
          [ 0] = Date,
          [ 1] = Next,
          Start = Start,
          d = (State == 0 and d or
               p and p <= 0 and 0 or p or q),
        }, --
      } --
    end

    -- Номер недели года:
    t[#t+1] = {
      text = Formats.YearWeek:format(StartYearWeek + i - 1 - StartWeekShift),
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

  self.Items = false -- Сброс меню (!)

  return self:MakeMenu()
end -- MakeCalendar

end -- do
---------------------------------------- ---- Utils
-- Limit date.
-- Ограничение даты.
function TMain:LimitDate (Date)
  if Date.y < self.YearMin then
    Date.y = self.YearMin
    Date.m = 1
    Date.d = 1
  
  elseif Date.y > self.YearMax then
    Date.y = self.YearMax
    Date.m = Date:getYearMonths()
    Date.d = Date:getMonthDays()
  end

  return Date
end ---- LimitDate
---------------------------------------- ---- Input
do
  local tonumber = tonumber
  local InputFmtY   = "^(%d+)"
  local InputFmtYM  = "^(%d+)%-(%d+)"
  local InputFmtYMD = "^(%d+)%-(%d+)%-(%d+)"

function TMain:ParseInput ()
  local self = self
  local Date = self.Date:copy()

  local Input = self.Input or ""
  local _, Count = Input:gsub("-", "")

  if Count == 0 then
    local y = Input:match(InputFmtY)
    y = tonumber(y) or 1
    Date.y, Date.m, Date.d = y, 1, 1
  elseif Count == 1 then
    local y, m = Input:match(InputFmtYM)
    y, m = tonumber(y) or 1, tonumber(m) or 1
    Date.y, Date.m, Date.d = y, m, 1
  else
    local y, m, d = Input:match(InputFmtYMD)
    y, m, d = tonumber(y) or 1, tonumber(m) or 1, tonumber(d) or 1
    --logShow({ Count, y, m, d }, Input)
    Date.y, Date.m, Date.d = y, m, d
  end

  return Date:fixMonth():fixDay()
end ---- ParseInput

function TMain:StartInput (Date)
  local self = self
  local L = self.LocData

  self.Input = ""
  self.Props.Bottom = L.Date
  self.IsInput = true
end ---- StartInput

function TMain:StopInput (Date)
  local self = self

  self.IsInput = false
  self.Props.Bottom = ""
  self.Date = self:ParseInput() or Date
end ---- StopInput

function TMain:EditInput (SKey)
  local self = self

  local Input = self.Input
  if SKey == "BS" then
    if Input ~= "" then Input = Input:sub(1, -2) end
  else
    if SKey == "Subtract" then SKey = "-" end

    Input = Input..SKey
  end

  self.Input = Input
  self.Props.Bottom = Input
end ---- EditInput

end -- do
---------------------------------------- ---- Events
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
    ["-"] = true,
    ["BS"] = true,
    ["Subtract"] = true,
  } --- InputActions

function TMain:AssignEvents () --> (bool | nil)
  local self = self

  local function MakeUpdate () -- Обновление!
    farUt.RedrawAll()
    self:MakeCalendar()
    --logShow(self.Items, "MakeUpdate")
    if not self.Items then return nil, CloseFlag end
    --logShow(ItemPos, hex(FKey))
    return { self.Props, self.Items, self.Keys }, CompleteFlags
  end -- MakeUpdate

  -- Обработчик нажатия клавиш.
  local function KeyPress (VirKey, ItemPos)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end
    --logShow(SKey, "SKey")

    --local DT_cfg = self.DT_cfg
    local Data = self.Items[ItemPos].Data
    if not Data then return end

    local Date = Data[Data.State]
    if Data.d <= 0 then return end
    Date.d = Data.d

    local isUpdate = true
    local Action = DateActions[SKey]
    if Action then
      Date[Action](Date)

    elseif SKey == "Divide" then
      if self.IsInput then
        self:StopInput(Date)
        return MakeUpdate()
      else
        self:StartInput(Date)
      end

    elseif self.IsInput and InputActions[SKey] then
      self:EditInput(SKey)

    else
      isUpdate = false
    end

    self.Time = false

    if isUpdate then
      --self.Date = Date
      self.Date = self:LimitDate(Date)
      return MakeUpdate()
    end

    return
  end -- KeyPress

  -- Обработчик нажатия клавиш навигации.
  local function NavKeyPress (AKey, VMod, ItemPos)
    local AKey, VMod = AKey, VMod

    local DT_cfg = self.DT_cfg
    local Data = self.Items[ItemPos].Data
    if not Data then return end

    local State = Data.State
    local Date = Data[State]
    if Data.d <= 0 then return end
    Date.d = Data.d
    --logShow({ AKey, VMod, Data }, ItemPos, "w d2")

    local isUpdate = true
    if VMod == 0 then
      --logShow({ AKey, VMod, Date }, ItemPos, "w d2")
      if AKey == "Clear" or AKey == "Multiply" then
        self:InitData()
        return MakeUpdate()
      elseif AKey == "Left"  and Data.c == 1 then
        if State == 0 then Date:shd(-DT_cfg.DayPerWeek) end
      elseif AKey == "Right" and Data.c == self.WeekMax then
        if State == 0 then Date:shd(DT_cfg.DayPerWeek) end
      elseif AKey == "Up"    and Data.r == 1 then
         Date:dec_d()
      elseif AKey == "Down"  and Data.r == DT_cfg.DayPerWeek then
        --logShow({ Date, Date:inc_d() }, AKey)
         --logShow(Date:inc_d(), AKey)
         Date:inc_d()
      else
        isUpdate = false
      end

    elseif IsModCtrl(VMod) then
      if AKey == "Clear" or AKey == "Multiply" then
        self:InitData()
        return MakeUpdate()
      elseif AKey == "PgUp" then
        Date.y = (divf(Date.y, 10) - 1) * 10 + 1
        Date.m = 1
        Date.d = 1
      elseif AKey == "PgDn" then
        Date.y = (divf(Date.y, 10) + 1) * 10
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      elseif AKey == "Home" then
        Date.y = (divf(Date.y, 100) - 1) * 100 + 1
        Date.m = 1
        Date.d = 1
      elseif AKey == "End" then
        Date.y = (divf(Date.y, 100) + 1) * 100
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      else
        isUpdate = false
      end

    elseif IsModAlt(VMod) then
      if AKey == "Clear" or AKey == "Multiply" then
        self:InitData()
        return MakeUpdate()
      elseif AKey == "PgUp" then
        Date.d = 1
      elseif AKey == "PgDn" then
        Date.d = Date:getMonthDays()
      elseif AKey == "Home" then
        if Date.m == 1 and Date.d == 1 then
          Date.y = Date.y - 1
        end
        Date.m = 1
        Date.d = 1
      elseif AKey == "End" then
        if Date.m == Date:getYearMonths() and
           Date.d == Date:getMonthDays() then
          Date.y = Date.y + 1
        end
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      else
        isUpdate = false
      end

    elseif IsModCtrlAlt(VMod) then
      if AKey == "Clear" or AKey == "Multiply" then
        self:InitData()
        return MakeUpdate()
      elseif AKey == "PgUp" then
        Date.y = (divf(Date.y, 1000) - 1) * 1000 + 1
        Date.m = 1
        Date.d = 1
      elseif AKey == "PgDn" then
        Date.y = (divf(Date.y, 1000) + 1) * 1000
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      elseif AKey == "Home" then
        Date.y = 1
        Date.m = 1
        Date.d = 1
      elseif AKey == "End" then
        Date.y = 9999
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      else
        isUpdate = false
      end

    else
      isUpdate = false
    end

    self.Time = false

    if isUpdate then
      self.Date = self:LimitDate(Date)
      return MakeUpdate()
    end

    return
  end -- NavKeyPress

  -- Обработчик выделения пункта.
  local function SelectItem (Kind, ItemPos)
    local Data = self.Items[ItemPos].Data
    --logShow(Data, ItemPos, "w d2")
    if not Data then return end

    self.Date = Data[Data.State]
    if Data.d <= 0 then return end
    self.Date.d = Data.d

    return self:FillMenu()
  end -- SelectItem

  -- Обработчик выбора пункта.
  local function ChooseItem (Kind, ItemPos)
    local Data = self.Items[ItemPos].Data
    if not Data then return end

    if self.IsInput and Kind == "Enter" then
      local Date = Data[Data.State]
      self:StopInput(Date)

      return MakeUpdate()
    end

    return nil, CloseFlag
  end -- ChooseItem

  -- Назначение обработчиков:
  local RM_Props = self.Props.RectMenu
  RM_Props.OnKeyPress = KeyPress
  RM_Props.OnNavKeyPress = NavKeyPress
  RM_Props.OnSelectItem = SelectItem
  RM_Props.OnChooseItem = ChooseItem
end -- AssignEvents

end --

---------------------------------------- ---- Show
-- Показ меню заданного вида.
function TMain:ShowMenu () --> (item, pos)
  return usercall(nil, unit.RunMenu, self.Props, self.Items, self.Keys)
end ---- ShowMenu

-- Вывод календаря.
function TMain:Show () --> (bool | nil)

  --local Cfg = self.CfgData

  self:MakeCalendar()
  if self.Error then return nil, self.Error end

  if useprofiler then profiler.stop() end

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
return unit
--return unit.Execute()
--------------------------------------------------------------------------------
