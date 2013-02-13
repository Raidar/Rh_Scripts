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

--local type, assert = type, assert
--local pairs, ipairs = pairs, ipairs
--local setmetatable = setmetatable

----------------------------------------
--local win, far = win, far

----------------------------------------
--local context = context

--local utils = require 'context.utils.useUtils'
--local strings = require 'context.utils.useStrings'
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
--[[
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
  self.LocData = locale.getData(self.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not self.LocData then return end

  self.L = locale.make(self.Custom, self.LocData)

  return self.L
end ---- Localize

  local menUt = require "Rh_Scripts.Utils.Menu"
  local colors = require 'context.utils.useColors'
  local basics = colors.BaseColors

  local Colors = menUt.MenuColors()
  local MainColors = UsualColors
  MainColors = menUt.ChangeColors(MainColors,
                                  --nil,
                                  colors.getFG(Colors.COL_MENUTEXT),
                                  colors.getBG(Colors.COL_MENUTEXT),
                                  --basics.blue,
                                  basics.black,
                                  basics.silver)
  MainColors = menUt.ChangeColors(MainColors,
                                  nil,
                                  --colors.getFG(Colors.COL_MENUSELECTEDTEXT),
                                  colors.getBG(Colors.COL_MENUSELECTEDTEXT),
                                  nil,
                                  --basics.green,
                                  basics.white)

function TMain:MakeProps ()

  --local Cfg = self.CfgData

  -- Свойства меню:
  local Props = self.Menu.Props or {}
  self.Props = Props

  Props.Id = self.Guid

  local L = self.LocData
  Props.Title = L.Calendar

  -- Свойства RectMenu:
  local RM_Props = {
    Order = "V",
    Rows = 8,
    --Cols = 3 + 5 + 1,
    Fixed = {
      HeadRows = 1,
      HeadCols = 3,
      FootCols = 1,
    },

    --MenuEdge = 2,
    MenuAlign = "CM",

    Colors = MainColors,
    --[[
    Colors = {
    }, --

    FixedColors = {
    }, --
    --]]

  } --- RM_Props
  Props.RectMenu = RM_Props

  return true
end ---- MakeProps

-- Подготовка.
-- Preparing.
function TMain:Prepare ()

  self:Localize() -- Локализация.

  return self:MakeProps()
end ---- Prepare

end -- do
---------------------------------------- ---- Menu
do
  local function DayToStr (d)
    return ("%02d"):format(d)
  end --

  local function WeekDayToStr (d)
    return ("<%1d>"):format(d)
  end --

-- Формирование меню.
function TMain:MakeMenu () --> (table)
  --local Cfg = self.CfgData

  local Date = self.Date
  local Time = self.Time
  local DT_cfg = Date.config
  local DT_name = DT_cfg.Name

  local WeekDay = Date:getWeekDay()
  local DayPerWeek = DT_cfg.DayPerWeek

  local RowCount = DayPerWeek + 1 -- Количество строк календаря
  local ItemNames = {
    World     = RowCount + 1,
    Year      = RowCount + 3,
    Month     = RowCount + 4,
    Date      = RowCount + 6,
    Time      = RowCount + 8,
    WeekDay   = RowCount + 7,

    YearDay   = RowCount * 0 + 7,
    YearWeek  = RowCount * 2 + 7,

    PrevYear  =                3,
    NextYear  = RowCount * 2 + 3,
    PrevMonth =                4,
    NextMonth = RowCount * 2 + 4,

    Separators = {
                     2,                5, -- 1
      RowCount     + 2, RowCount     + 5, -- 2
      RowCount * 2 + 2, RowCount * 2 + 5, -- 3
    }, --

    FirstDay      = RowCount * 3 + 1,
    FirstWeekDay  = RowCount * (3 + DT_cfg.MonthDays.WeekMax) + 1,

  } -- ItemNames

  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local Loc = L[DT_name]
  local WeekDayNames   = (Loc or Null).WeekDay or Null
  local YearMonthNames = (Loc or Null).YearMonth or Null

  local ItemDatas = {
    World     = (" %s "):format(Loc.Name),
    Year      = ("%04d"):format(Date.y),
    Month     = (YearMonthNames[0] or Null)[Date.m],
    Date      = ("%04d-%02d-%02d"):format(Date.y, Date.m, Date.d),
    Time      = ("%02d:%02d:%02d"):format(Time.h, Time.n, Time.s),
    WeekDay   = (WeekDayNames[0] or Null)[WeekDay],

    YearDay   = ("%03d"):format(Date:getYearDay()),
    YearWeek  = ("%02d"):format(Date:getYearWeek()),

    PrevYear  = "<==",
    NextYear  = "==>",
    PrevMonth = "<--",
    NextMonth = "-->",
  } --- ItemDatas

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

  for k, v in pairs(ItemDatas) do
    local n = ItemNames[k]
    if n then
      t[n].text = v
    end
  end --

  local Separators = ItemNames.Separators
  for k = 1, #Separators do
    local v = Separators[k]
    t[v].separator = true
  end

  local CurrentDay = Date.d
  local Start = datim.newDate(Date.y, Date.m, 01)
  local MonthDays = Start:getMonthDays()
  local StartWeekDay = Start:getWeekDay()
  StartWeekDay = StartWeekDay == 0 and DayPerWeek or StartWeekDay
  --t[RowCount * 3 - 1].text = ("%1d"):format(StartWeekDay) -- DEBUG
  local StartYearWeek = Start:getYearWeek()

  -- Дни месяца:
  local d = 0    -- День месяца
  local SelIndex -- Индекс пункта с текущей датой
  for i = 1, DT_cfg.MonthDays.WeekMax do

    -- Номер недели:
    t[#t+1] = {
      text = ("%02d"):format(StartYearWeek + i - 1),
      Label = true,
    } --

    -- Дни недели:
    for j = 1, DayPerWeek do
      local State = 0
      if i == 1 and j < StartWeekDay then
        State = -1
      elseif d > MonthDays then
        State = 1
      end

      local Text = ""
      if State == 0 then
        d = d + 1
        Text = DayToStr(d)

        if d == CurrentDay then SelIndex = #t + 1 end
      end

      t[#t+1] = {
        text = Text,
        Label = true,
      } --
    end

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
    } --
  end

  self.Items = t

  return true
end -- MakeMenu

-- Формирование календаря.
function TMain:MakeCalendar () --> (table)

  --local Cfg = self.CfgData

  local dt = self.Value or os.date("*t")
  self.Date = datim.newDate(dt.year, dt.month, dt.day)
  self.Time = datim.newTime(dt.hour, dt.min, dt.sec)

  self.Items = false -- Сброс меню (!)

  return self:MakeMenu()
end -- MakeCalendar

end -- do
---------------------------------------- ---- Show
-- Показ меню заданного вида.
function TMain:ShowMenu () --> (item, pos)
  return usercall(nil, unit.RunMenu,
                  self.Props, self.Items, self.Menu.CompleteKeys)
  --return unit.RunMenu(self.Props, self.Items, self.Menu.CompleteKeys)
end ----

do
  local CompleteFlags = { isRedraw = false, isRedrawAll = true }
  local CloseFlag  = { isClose = true }
  local CancelFlag = { isCancel = true }

function TMain:AssignKeyPress () --> (bool | nil)

  --local Cfg = self.CfgData
  local Menu = self.Menu
  --local Menu, Popup = self.Menu, self.Popup

  -- Обработчик нажатия клавиши.
  local function KeyPress (VirKey, ItemPos)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end

    local function MakeUpdate () -- Обновление!
      farUt.RedrawAll()
      self:MakeCalendar()
      --logShow(self.Items, "MakeUpdate")
      if not self.Items then return nil, CloseFlag end
      --logShow(ItemPos, hex(FKey))
      return { self.Props, self.Items, Menu.CompleteKeys }, CompleteFlags
    end -- MakeUpdate

    return MakeUpdate()
  end -- KeyPress

  -- Назначение обработчика:
  local RM_Props = self.Props.RectMenu
  RM_Props.OnKeyPress = KeyPress
end -- AssignKeyPress

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

  self:AssignKeyPress()

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
