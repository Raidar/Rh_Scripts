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
unit.RunMenu = usercall(nil, require, "Rh_Scripts.RMenu.RectMenu")

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
} --- DefCustom

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
  --Guid       = win.Uuid("64b26458-1e8b-4844-9585-becfb1ce8de3"),
  --ConfigGuid = win.Uuid("642eb0fd-d297-4855-bd87-dcecfc55bcc4"),
}
local MMain = { __index = TMain }

-- Создание объекта основного класса.
local function CreateMain (ArgData)

  local self = {
    ArgData = addNewData(ArgData, unit.DefCfgData),

    Custom    = false,
    Options   = false,
    History   = false,
    CfgData   = false,
    --DlgTypes  = unit.DlgTypes,

    -- Текущее состояние:
    Date      = false,    -- Дата
    Time      = false,    -- Время

    --Error    = false,   -- Текст ошибки
    --Menu      = false,    -- CfgData.Menu or {}

    --Words     = false,    -- Список слов
    Items     = false,    -- Список пунктов меню
    Props     = false,    -- Свойства меню

    ActItem   = false,    -- Выбранный пункт меню
    ItemPos   = false,    -- Позиция выбранного пункта меню
    --Action    = false,    -- Выбранное действие
    --Effect    = false,    -- Выбранный эффект
  } ---

  self.ArgData.Custom = self.ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(self.ArgData, "ArgData")
  self.Custom = datas.customize(self.ArgData.Custom, unit.DefCustom)
  self.Options = addNewData(self.ArgData.Options, unit.DefOptions)

  -- 2. Заполнение конфигурации.
  self.History = datas.newHistory(self.Custom.history.full)
  self.CfgData = self.History:field(self.Custom.history.field)

  local CfgData = self.CfgData
  self.Menu = CfgData.Menu or {}
  --self.Menu.CompleteKeys = self.Menu.CompleteKeys or unit.CompleteKeys
  --self.Menu.LocalUseKeys = self.Menu.LocalUseKeys or unit.LocalUseKeys

  local dt = CfgData.dt or os.date("*t")
  self.Date = CfgData.Date or datim.newDate(dt.year, dt.month, dt.day)
  self.Time = CfgData.Time or datim.newTime(dt.hour, dt.min, dt.sec)

  -- 3. Дополнение конфигурации.
  setmetatable(self.CfgData, { __index = self.ArgData })
  --logShow(self.CfgData, "CfgData")

  locale.customize(self.Custom) -- Инфо локализации
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

  --local function WeekDayToStr (d)
  --  return ("%02d"):format(d)
  --end --

-- Заполнение меню.
function TMain:MakeMenu () --> (table)
  --local Cfg = self.CfgData

  --[[
  local Rows = 8
  local ItemNames = {
    Year    = Rows + 1,
    Month   = Rows + 2,
    Date    = Rows + 4,
    Time    = Rows + 5,
    Week    = Rows + 7,
    YearWeek  = Rows + 0,
    WeekDay   = Rows * 3 + 0,

    FirstDay      = Rows * 3 + 1,
    FirstWeekDay  = Rows * (3 + 5) + 1,
  } --
  --]]

  local Date = self.Date
  local Time = self.Time
  local WeekDay = Date:getWeekDay()

  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local WeekDayNames   = L.WeekDay or Null
  local YearMonthNames = L.YearMonth or Null

  local ItemDatas = {
    Year        = ("%04d"):format(Date.y),
    Date        = ("%04d-%02d-%02d"):format(Date.y, Date.m, Date.d),
    Time        = ("%02d:%02d:%02d"):format(Time.h, Time.n, Time.s),

    YearDay     = ("%03d"):format(Date:getYearDay()),
    YearWeek    = ("%02d"):format(Date:getYearWeek()),

    WeekDayName0    = (WeekDayNames[0] or Null)[WeekDay],
    YearMonthName0  = (YearMonthNames[0] or Null)[Date.m],
  } --- ItemDatas

  -- Текущие данные:
  local t = {
    -- 1 --
    { -- Разделитель
      --text = "",
      separator = true,
    },
    { -- Год
      text = "<==",
      Label = true,
    },
    { -- Месяц
      text = "<--",
      Label = true,
    },
    { -- Разделитель
      --text = "",
      separator = true,
    },
    { -- Дата
      text = "",
      Label = true,
    },
    { -- Неделя
      text = ItemDatas.YearDay,
      Label = true,
    },
    { -- Время
      text = "",
      Label = true,
    },
    { -- Разделитель
      --text = "",
      separator = true,
    },
    -- 2 --
    { -- Разделитель
      --text = "",
      separator = true,
    },
    { -- Год
      text = ItemDatas.Year,
      Label = true,
    },
    { -- Месяц
      text = ItemDatas.YearMonthName0,
      Label = true,
    },
    { -- Разделитель
      --text = "",
      separator = true,
    },
    { -- Дата
      text = ItemDatas.Date,
      Label = true,
    },
    { -- Неделя
      text = ItemDatas.WeekDayName0,
      Label = true,
    },
    { -- Время
      text = ItemDatas.Time,
      Label = true,
    },
    { -- Разделитель
      --text = "",
      separator = true,
    },
    -- 3 --
    { -- Разделитель
      --text = "",
      separator = true,
    },
    { -- Год
      text = "==>",
      Label = true,
    },
    { -- Месяц
      text = "-->",
      Label = true,
    },
    { -- Разделитель
      --text = "",
      separator = true,
    },
    { -- Дата
      text = "",
      Label = true,
    },
    { -- Неделя
      text = ItemDatas.YearWeek,
      Label = true,
    },
    { -- Время
      text = "",
      Label = true,
    },
    { -- Разделитель
      --text = "",
      separator = true,
    },
  } ---

  local MonthCurrentDay = Date.d
  local MonthStart = datim.newDate(Date.y, Date.m, 01)
  local MonthDays = MonthStart:getMonthDays()
  local MonthStartWeekDay = MonthStart:getWeekDay()
  MonthStartWeekDay = MonthStartWeekDay == 0 and
                      MonthStartWeekDay.config.DayPerWeek or MonthStartWeekDay
  --t[8 * 3 - 1].text = ("%1d"):format(MonthStartWeekDay) -- DEBUG
  local MonthStartYearWeek = MonthStart:getYearWeek()

  local SelIndex -- Индекс пункта с текущей датой
  -- Дни месяца:
  local k = 0
  for i = 1, 5 do

    t[#t+1] = {
      text = ("%02d"):format(MonthStartYearWeek + i - 1),
      Label = true,
    } --

    for j = 1, 7 do
      local State = 0
      if i == 1 and j < MonthStartWeekDay then
        State = -1
      elseif k > MonthDays then
        State = 1
      end

      local Text = ""
      if State == 0 then
        k = k + 1
        Text = DayToStr(k)

        if k == MonthCurrentDay then SelIndex = #t + 1 end
      end

      t[#t+1] = {
        text = Text,
        Label = true,
      } --
    end

  end

  self.Props.SelectIndex = SelIndex

  -- Дни недели:
  local WeekDayNames2 = WeekDayNames[2] or Null
  t[#t+1] = {
    text = "",
    separator = true,
  } --
  for k = 1, 7 do
    t[#t+1] = {
      text = WeekDayNames2[k % 7], --or WeekDayToStr(k),
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
