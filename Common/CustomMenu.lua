--[[ Custom menu ]]--

----------------------------------------
--[[ description:
  -- Custom menu.
  -- Настраиваемое меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context,
  Rh Utils.
  -- group: Menus.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local assert = assert
local require = require
local setmetatable = setmetatable

----------------------------------------
local useprofiler = false
--local useprofiler = true

if useprofiler then
  require "profiler" -- Lua Profiler
  profiler.start("CustomMenu.log")

end

----------------------------------------
local F = far.Flags

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
--local datas = require 'context.utils.useDatas'

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"
local menUt = require "Rh_Scripts.Utils.Menu"

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Fields
-- Копирование полей t.
local function copyFields (t) --|> (t)

  return tables.clone(t, true, tables.allpairs, true)

end --

-- Обновление полей t значениями полей из u.
local function updateFields (t, u) --|> (t)

  if t == u or u == nil then return t end

  return tables.update(t, u, pairs, true)

end --

-- Установка полей u как метаиндексов полей из t.
local function dometaFields (t, u) --|> (t)

  if u == nil then return t end

  return tables.exmeta(t, u, pairs, true)

  --[[ -- Only one-step deep used!
  for k, v in pairs(u) do
    if type(v) == 'table' then
      t[k] = type(t[k]) == 'table' and t[k] or {}
      setmetatable(t[k], { __index = v })

    end
  end

  return t
  --]]

end -- dometaFields

-- Формирование таблицы по базовой и "индексной" таблицам.
--[[
  -- @params:
  t (table) - таблица с исходными значениями полей.
  u (table) - таблица с полями-таблицами в роли __index для полей.
--]]
local function makeFields (t, u) --> (table)

  t = copyFields(t) or {}   -- Заполнение

  return dometaFields(t, u) -- "Индексирование"

end -- makeFields

---------------------------------------- Menu class
local TMenu = {

  Guid = win.Uuid("3700abe9-c460-42b2-9f2e-1fe705b2942a"),

}
local MMenu = { __index = TMenu }

local function CreateMenu (Properties, Menus, Config) --> (object)

  assert(type(Menus) == 'table')

  --Properties = Properties or {}
  Config = Config or {}
  local Scope = Config.Scope or {}

  -- Object
  local self = {
    Props     = Properties or {},
    Menus     = Menus,
    Config    = Config,
    Scope     = Scope,

    -- TODO: Выделить из LUM в CustomMenu его сообщения!
    LocData   = Scope.LocData,
    L         = Scope.Locale,

    BaseName  = "Menu",   -- Имя базового меню
    BaseMenu  = false,    -- Ссылка на базовое меню в Menus

    -- Текущее состояние:
    Error     = false,    -- Текст ошибки
    SelPos    = 1,        -- Позиция пункта-меню в надменю
    isNova    = true,     -- Признак показа нового меню
    CurMenu   = false,    -- Текущее меню-таблица
    CurName   = "(none)", -- Имя этого текущего меню
    CurData   = false,    -- Таблица данных конфигурации меню
    CurProps  = false,    -- Таблица свойств (для вывода) меню

    RunMenu   = false,    -- Текущее запускаемое меню
    RunItem   = false,    -- Текущий пункт этого меню
    RunCount  = 0,        -- Число пунктов этого меню

    ActItem   = {         -- Выбранный пункт этого меню
      Menu      = false,    -- Ссылка на запускаемое меню
      isBack    = nil,      -- Признак возврата в это меню

    },

    ItemPos   = 1,        -- Позиция выбранного пункта меню

  } --- self

  return setmetatable(self, MMenu)

end -- CreateMenu

---------------------------------------- Menu making

---------------------------------------- ---- Common

-- Установка заголовка базового/главного меню.
function TMenu:SetBaseTitle (Menu) --|> (Menu)

  local DefMenu = self.Scope.DefMenu
  if not DefMenu then return end

  Menu = Menu or self.CurMenu

  --[[
  --logShow({ Menu = {
              Name = Menu.Name, Title = Menu.Title,
              Caption = Menu.Caption, text = Menu.text },
            DefMenu = {
              Name = DefMenu.Name, Title = DefMenu.Title,
              Caption = DefMenu.Caption, text = DefMenu.text },
          }, "Menu vs DefMenu")
  --]]

  local CheckMenu
  if Menu.Name == "Menu" then
    CheckMenu = tables.Null

  elseif Menu.Title or Menu.Caption or Menu.text then
    return

  else
    CheckMenu = Menu

  end

  if DefMenu.Title then
    Menu.Title = CheckMenu.Title or DefMenu.Title

  elseif DefMenu.Caption and not Menu.Title then
    Menu.Caption = CheckMenu.Caption or DefMenu.Caption
    Menu.Title   = nil

  elseif DefMenu.text then
    Menu.text  = CheckMenu.text or DefMenu.text
    Menu.Title = nil

  end
  --logShow(Menu.text, Menu.Title)

end ---- SetBaseTitle

-- Подготовка объекта класса меню (после создания).
function TMenu:Prepare () --> (bool | nil, error)

  -- Получение базового меню:
  --logShow(self.Scope.BaseName, self.BaseName)

  if (self.Scope.BaseName or "") ~= "" then
    self.BaseName = self.Scope.BaseName -- Подменю как базовое меню

  end
  if not self.BaseName then
    self.Error = "Menu not found"

    return
  end

  local tp = type(self.BaseName)
  if     tp == 'string' then
    self.BaseMenu = self.Menus[self.BaseName]

  elseif tp == 'function' then
    self.BaseMenu = self.BaseName
    self.BaseName = false

  end

  if type(self.BaseMenu) == 'function' then
    self.BaseMenu = self.BaseMenu()

  end

  if type(self.BaseMenu) ~= 'table' then
    if self.BaseName == false then self.BaseName = "?" end
    self.Error = "Menu not found:\n"..tostring(self.BaseName)

    return -- Нет главного меню
  end

  if self.BaseName == false then
    self.BaseName = self.BaseMenu.Name

  end
  --logShow(self.BaseMenu, "BaseName: "..self.BaseName, 1)

  -- Настройка базового меню:
  self.BaseMenu.Name = self.BaseName -- Имя
  self.BaseMenu.Back = { Menu = nil, } -- Нет надменю
  -- MAYBE: tables.extend?!
  self.BaseMenu.Props = self.BaseMenu.Props or self.Props or {}
  self:SetBaseTitle(self.BaseMenu)

  self.ActItem.Menu = self.BaseMenu

  -- Часто используемые тексты. -- TODO: Часть локализации!!
  self.L.MenuMenu = self.L:t2("UMenuMenu", "UMenuName") -- Меню
  self.L.MenuItem = self.L:t2("UMenuItem", "UMenuName") -- Пункт меню

  return true

end ---- Prepare

--[[
function TMenu:Finish ()
  --
end ---- Finish
--]]

---------------------------------------- ---- Properties

-- Заполнение свойств для меню/пункта.
function TMenu:FillProperties (Props, Table) --|> (Props)

  local TableProps = (Table or tables.Null).Props or tables.Null

  -- Common --
  updateFields(Props, TableProps)

  -- RectMenu --
  local RM = Props.RectMenu or {}
  Props.Id = Props.Id or self.Guid
  Props.RectMenu = RM
  updateFields(RM, TableProps.RectMenu)
  --Table.RectMenu = Table.RectMenu or {}

  -- FilterMenu --
  Props.Filter = Props.Filter or {}
  updateFields(Props.Filter, TableProps.Filter)

  return Props

end ---- FillProperties

local ChangeMenuProps = {

  SearchMenu = function (Props, Table) --| Props

    Props.Flags = menUt.HighlightOff(Props.Flags)

  end, --

} --- ChangeMenuProps

-- Изменение свойств для меню/пункта.
function TMenu:ChangeProperties (Props, Table) --|> Props

  self:FillProperties(Props, Table)
  --logShow({ Props, Table }, Props.MenuView, 2)
  local MakeChangeProps = ChangeMenuProps[Props.MenuView]
  --if MakeChangeProps then logShow(Table, Props.MenuView, 1) end
  if MakeChangeProps then MakeChangeProps(Props, Table) end

  return Props

end ---- ChangeProperties

---------------------------------------- ---- User Item
local ItemKinds = { -- Виды пунктов меню:

  Label     = "Label",    -- Метка
  Items     = "Menu",     -- Подменю
  separator = "Separator",-- Разделитель
  LuaMacro  = "LuaMacro", -- Lua-макрос
  Plain     = "Plain",    -- Обычный текст
  Macro     = "Macro",    -- Макрос-шаблон
  --Template  = "Template", -- Шаблон
  Command   = "Command",  -- Команда
  Program   = "Program",  -- Программа
  CmdLine   = "CmdLine",  -- Командная строка
  Script    = "Script",   -- Скрипт Lua
  Function  = "Script",   -- Функция Lua
  Error     = "Error",    -- Ошибочный пункт

} --- ItemKinds

-- Определение вида пункта меню.
function TMenu:DefineItemKind (Item) --| Item

  if not Item or Item.Kind then return end -- Вид известен

  -- Поиск вида пункта по соответствующему полю:
  for f, t in pairs(ItemKinds) do
    if Item[f] then
      Item.Kind = t

      return -- Вид найден
    end
  end

  Item.Kind = ItemKinds.Error -- Вид пункта по умолчанию

end ---- DefineItemKind

do
  local MakeItemKey = menUt.MakeItemKey

-- Задание клавиш быстрого доступа и прерывателя.
function TMenu:MakeItemKeys (Item) --| Item

  --local UMenu = self.CurData.UMenu

  -- Формирование AccelKey для пункта.
  if Item.AccelStr ~= "" then
    local FullNamedKeys = self.CurData.UMenu.FullNamedKeys
    MakeItemKey(Item, "AccelKey", "AccelStr", FullNamedKeys)

  end
end ---- MakeItemKeys

end -- do

-- Настройка пункта-lua-макроса.
function TMenu:DefineLuaMacro (Item) --| Item

  if not Item.LuaMacro then return end

  -- Флаги по умолчанию:
  if not Item.Flags then
    Item.Flags = F.KMFLAGS_DISABLEOUTPUT

  end

  return true

end ---- DefineLuaMacro

-- Определение полей пункта меню.
function TMenu:DefineMenuItem (Item) --| Item

  --local CurMenu = self.CurMenu
  --local CurData = self.CurData
  --logShow(CurData, "CurData", 1)

  self:DefineItemKind(Item) -- Определение вида пункта
  self:MakeItemKeys(Item) -- Задание клавиш для пункта

  -- Настройка пункта-разделителя.
  if Item.Kind == ItemKinds.separator then Item.separator = true end
  --logShow({ "'"..Item.Caption.."'", "'"..Item.text.."'" }, "Item")

  -- Настройка пункта-макроса FAR.
  self:DefineLuaMacro(Item)

  -- Настройка пункта -- макроса-шаблона.
  if Item.Macro then -- Флаги по умолчанию
    -- Преобразование в однострочный макрос.
    --Item.Macro = Item.Macro:gsub('\n', "")
    -- TODO: Ошибка при области ~= "editor" -- MAYBE!!
    -- Область пункта по умолчанию.
    if not Item.Area then
      Item.Area = "editor"

    elseif Item.Area == ";selected" then
      Item.Area = "editor"..Item.Area

    end

    -- TODO: Разделить Area и isSelection -- MAYBE!!

  end
end ---- DefineMenuItem

---------------------------------------- ---- User Menu

-- Проверка на Главное меню.
function TMenu:isMainMenu (Menu) --> (bool)

  return self.Menus.Menu == (Menu or self.CurMenu)

end ----

-- Проверка на Базовое меню.
function TMenu:isBaseMenu (Menu) --> (bool)
--[[
  if Menu then return Menu.Back.Menu == nil
          --else return self.BackMenu == nil end
          else return self.CurMenu.Back.Menu == nil end
--]]

  return (Menu or self.CurMenu).Back.Menu == nil

end ----

do
  local NoneName = "(none)"
  local CompNameFmt = "%s.%s"

-- Получение имени меню (полное).
function TMenu:GetNameMenu (BackName, Name) --> (string, table | nil)

  -- Имя меню (с учётом имени надменю):
  Name = Name and self.Menus[Name] and Name or
         CompNameFmt:format(BackName or NoneName, Name or NoneName)

  return Name, self.Menus[Name]

end --

-- Поиск меню в надменю (учёт вложенности пунктов).
local function _GetBackMenu (Menu, Name) --> (table | nil)

  --return Menu and (Menu[Name] or --Menu.Back and
  --                 _GetBackMenu(Menu.Back.Menu, Name))

  if not Menu then return end
  if Menu[Name] then return Menu[Name] end

  return _GetBackMenu(Menu.Back.Menu, Name)

end -- _GetBackMenu

--[[ -- MAYBE: Change _GetBackMenu to function of TMenu.
function TMenu:GetBackMenu (Name) --> (table | nil)
  return _GetBackMenu(self.CurMenu, Name)
end --
--]]

-- Получение имени пункта меню (краткое и полное).
function TMenu:GetNameItem (Name) --> (string, string, table | nil)

  local CurMenu = self.CurMenu
  --logShow(self, Name, 1)
  local Base = CurMenu[Name] or -- Краткое имя-результат...
               _GetBackMenu(CurMenu, Name) -- или же таблица/функция:
  local tp = type(Base)
  if tp == 'table' or tp == 'function' then
    return Name, Name, Base

  elseif tp ~= 'string' then
    return -- Ошибка

  end

  local Menu = _GetBackMenu(CurMenu, Base) -- Таблица/функция или нет?
  --return Name, Base, Menu

  -- [[
  -- TODO: Разобраться и вспомнить для чего это надо было!
  tp = type(Menu)
  if tp == 'table' or tp == 'function' then
    return Name, Base, Menu

  end

  Base = Base or Name -- Краткое имя (результат/оригинал)
  if type(Base) ~= 'string' then return Name, nil, false end

  --logShow(self, Base, 1)
  local FullName -- Полное имя (имя с учётом имени меню):
  FullName, Menu = self:GetNameMenu(self.CurName, Base)
  Menu = Menu or _GetBackMenu(CurMenu, FullName) -- Поиск таблицы/функции!
  --logShow(Menu, FullName, 1)
  return Base, FullName, Menu
  --]]

  --return Base, self:GetNameMenu(self.CurName, Base)

end ---- GetNameItem

end -- do

-- Получение заголовка пункта меню.
function TMenu:GetItemTitle (Item) --> (string)

  return Item and (Item.Title or Item.Caption) or "Menu"

end ----

do
  -- TODO: Change to use as options
  local BindNameFmt = "%s (%s)"
  local MenuMSign = "►" -- 0x25BA
  local CompTitleFmt = "%s %s %s"

-- Формирование заголовка меню.
function TMenu:GetMenuTitle () --> (string)

  local CurMenu = self.CurMenu
  local Title = self:GetItemTitle(CurMenu)

  local isBMenu = self:isBaseMenu(CurMenu)
  local UMenu = self.CurData.UMenu -- Вид меню
  if UMenu.MenuTitleBind and isBMenu then
    -- MAYBE: FileType как альтернатива / дополнение.
    local BindName = self.Scope.BindsType
    if BindName == 'none' then BindName = self.Scope.FileType.."*" end
    Title = BindNameFmt:format(Title, BindName)

  end

  --logShow({ CurMenu.Title, CurMenu.Caption, CurMenu.text }, Title)
  if UMenu.CompoundTitle and not isBMenu then -- Имя надменю
    Title = CompTitleFmt:format(
            self:GetItemTitle(CurMenu.Back.Menu), MenuMSign, Title)
    -- MAYBE: Список всех title'ов с урезанием (хотя и так уже лишнее).

  end

  return Title

end ---- GetMenuTitle

end -- do

---------------------------------------- ---- FAR Item
do
  local isSelection = farUt.IsSelection

-- Проверка пункта на область и выделение.
function TMenu:CheckAreaItem (Item) --> (bool)

  local ScopeArea = self.Scope.Area

  -- Проверка на область:
  if not Item.Area then return true end -- Нет области
  local CurArea = Item.Area:match("([^;]*)")
  if CurArea ~= ScopeArea then return false end
  if CurArea == Item.Area and -- только область
     CurArea == ScopeArea then return true end

  -- Проверка на выделение:
  local Selected = true
  if Item.Area:find(";selected", 1, true) then
    Selected = isSelection(ScopeArea)

  end
  if CurArea == "" or
     CurArea:find(ScopeArea, 1, true) then
    return Selected

  end

  --logShow({ CurArea, Checked }, Item.Area)
  return false

end ---- CheckAreaItem

-- Проверка пункта по вызову функции.
function TMenu:CheckCallItem (Item) --> (bool)

  if not Item.Check then return true end
  assert(type(Item.Check) == 'function')

  local DefCfg = { Config = self.Config, Item = Item }
  local Cfg = { __index = DefCfg }; setmetatable(Cfg, Cfg)

  -- Выполнение проверки пункта.
  return farUt.fcall(Item.Check, Cfg) -- MAYBE: pfcall

end ---- CheckCallItem

-- Проверка пункта на включение в меню.
function TMenu:CheckItem (Item) --> (bool)

  if self:CheckAreaItem(Item) then
    return self:CheckCallItem(Item)

  end

  return false

end ---- CheckItem

end -- do

---------------------------------------- ---- FAR Menu
-- Формирование конфигурации текущего меню-таблицы.
function TMenu:MakeMenuConfig () --> (table)

  --logShow(self.CurMenu.CfgData, "self.CurMenu.CfgData", 2)

  local CurData = makeFields(self.CurMenu.CfgData, self.Config.CfgData)
  self.CurData = CurData
  --logShow(self.CurData, "self.CurData", 2)

  -- Конфиг для меню настройки:
  if self.CurName == "Config" then
    CurData.UMenu.MenuTitleBind = false
    CurData.UMenu.CompoundTitle = false
    CurData.UMenu.BottomHotKeys = false
    --CurData.UMenu.CaptAlignText = false
    CurData.UMenu.ReturnToUMenu = false -- ?!

  end --

  return CurData

end ---- MakeMenuConfig

-- Формирование свойств текущего меню-таблицы.
function TMenu:MakeMenuProps () --> (table)

  local CurMenu = self.CurMenu
  local BackMenu = CurMenu.Back.Menu

  CurMenu.Inherit = (CurMenu.Inherit ~= false)

  -- Свойства меню (по умолчанию):
  local Props = --CurMenu.Props or
                copyFields(CurMenu.Props) or
                CurMenu.Inherit and BackMenu and
                copyFields(BackMenu.Props) or {}
  self.CurProps = Props
  --logShow(BackMenu and BackMenu.Props, "BackMenu.Props", 2)
  --logShow(Props, "self.Props", 2)
  --[[
  if BackMenu and BackMenu == self.Menus.Characters then
    --logShow(Props, "self.Props", 3, "", logProps)

  end
  --]]

  -- Параметры оригинала
  local HisData = CurMenu.HisData
  if     HisData == nil then
    HisData = CurMenu.CfgData

  elseif type(HisData) == 'string' then
    HisData = CurMenu[HisData]

  end

  Props.Origin = {
    Custom  = CurMenu.Custom,
    Options = CurMenu.Options,
    --History = CurMenu.History,
    HisData = HisData,
    CfgData = CurMenu.CfgData,

  } -- Props.Origin

  Props.Flags = Props.Flags or F.FMENU_WRAPMODE
  Props.SelectIndex = self.SelPos -- Выбранный пункт
  --logShow(self.Scope.HlpLink, Props.HelpTopic or "HlpLink")
  if self.Scope.HlpLink and not Props.HelpTopic then
    Props.HelpTopic = self.Scope.HlpLink -- Справка

  end

  -- Вид меню:
  Props.MenuView = CurMenu.MenuView or Props.MenuView or self.Scope.MenuView
  --self:ChangeProperties(Props, CurMenu) -- Свойства меню с учётом вида меню
  self:ChangeProperties(Props, nil) -- Свойства меню с учётом вида меню

  -- Задание заголовка меню:
  Props.Title = self:GetMenuTitle()
  -- Задание нижней надписи меню:
  if self.CurData.UMenu.BottomHotKeys then
    Props.Bottom = self.L:t"HKeysHelp"

  end

  return Props

end ---- MakeMenuProps

-- Формирование запускаемого пункта.
function TMenu:MakeRunItem () --> (table)

  local CurMenu = self.CurMenu
  local RunItem = self.RunItem

  -- Учёт пунктов только для текущей области.
  if not self:CheckItem(RunItem) then return end

  local RunPos = self.RunCount + 1
  self.RunCount = RunPos

  -- Выделение пункта для нового меню.
  if RunItem.Selected and self.isNova then
    CurMenu.Props.SelectIndex = RunPos

  end

  -- Управление переходом в меню.
  RunItem.Menu = RunItem -- Информация для прямого перехода и...
  RunItem.Back = { Menu = CurMenu, Pos = RunPos, } -- для обратного

  -- Определение полей пункта меню.
  --self:ChangeProperties({ MenuView = Props.MenuView }, RunItem)
  self:DefineMenuItem(RunItem)

  self.RunMenu[RunPos] = RunItem
  --logShow(RunItem, "RunItem #"..tostring(RunPos), 2)
  --self.RunItem = false

  return true

end ---- MakeRunItem

-- Формирование пункта-таблицы запускаемого меню.
function TMenu:MakeRunMenuItem (Item, Index) --> (true | nil, error)

  local CurName = self.CurName

  if type(Item) == 'function' then
    --logShow({ CurName, self.Menus }, "RunItem # "..tostring(Index), "w d2")
    Item = Item() -- TODO: Поставить pcall?!

  end

  if type(Item) == 'table' then

    local BaseName
    -- Получение реального пункта меню с его именем:
    BaseName, self.RunItem = tostring(Index), Item
    Item.Name = Item.Name or ("%s.%s"):format(CurName, BaseName)
    return self:MakeRunItem()

  elseif type(Item) == 'string' then

    -- Создание из списка имён пунктов.
    for s in Item:gmatch("([^;]+)") do
      --logShow({ self.Menus, CurName, s }, "RunItem # "..tostring(k), 1)
      -- Получение реального пункта меню с его именем:
      local BaseName, ItemName, RunItem = self:GetNameItem(s)
      if type(RunItem) == 'function' then
        RunItem = RunItem() -- TODO: Поставить pcall?!

      end

      if not RunItem then
        self.Error = self.L:et1("MnuSecNotFound", BaseName, ItemName or "(none)")

        return

      elseif type(RunItem) ~= 'table' then
        self.Error = self.L:et1("MnuWrongItem", type(RunItem), CurName, Index)

        return

      end

      RunItem.Name = ItemName
      self.RunItem = RunItem

      self:MakeRunItem()
      --return self:MakeRunItem()

    end --

  else

    self.Error = self.L:et1("MnuWrongItem", type(Item), CurName, Index)

    return

  end
end ---- MakeRunMenuItem

-- Make runnable menu from current menu-table.
-- Формирование запускаемого меню из текущего меню-таблицы.
function TMenu:MakeRunMenu () --> (table)

  local CurMenu = self.CurMenu
  --logShow(CurMenu, "CurMenu", "w d3")

  local Items = CurMenu.Items
  if type(Items) == 'function' then
    --logShow(CurMenu, "CurMenu", "w d2")
    Items = Items()

  end

  if type(Items) == 'table' then
    CurMenu.Items = Items
    --logShow(Items, "Items", "w d2")

  elseif Items == nil then
    --self.RunMenu, self.RunCount = {}, 0
    --self:MakeRunMenuItem(CurMenu, k)
    --if self.Error then return end
    self.ActItem = CurMenu
    self:DefineItemKind(self.ActItem)
    local isOk, SError = self:MakeAction()
    --logShow(CurMenu, "No Items", "w d2")
    --logShow({ isOk = isOk, error = SError }, self.ActItem.Kind)
    if isOk == nil then return nil, SError, self.ActItem end

    --logShow(CurMenu, "No Items", "w d2")
    return true

  else
    CurMenu.Items = { Items }

  end
  --logShow(CurMenu.Items, "CurMenu.Items", "w d2")

  -- Создание из списка пунктов-таблиц.
  self.RunMenu, self.RunCount = {}, 0
  for k = 1, #CurMenu.Items do
    self:MakeRunMenuItem(CurMenu.Items[k], k)
    if self.Error then return end

  end

  --logShow(self.RunMenu, "self.RunMenu")

end ---- MakeRunMenu

do
  local isItemUnused = menUt.isItem.Unused

-- Формирование таблицы BreakKeys. -- TEMP: for far.Menu only.
function TMenu:MakeBreakKeys (Menu, DefKeys) --> (table)

  local t = {}
  for k = 1, #DefKeys do t[k] = DefKeys[k] end -- Копия
  --logShow(DefKeys, "Default")
  --logShow(t, "Current")

  -- Объединение всех BreakKey
  for k = 1, #Menu do
    local v = Menu[k]
    if v.BreakKey and not isItemUnused(v) then
      -- Полная информация для быстрого поиска пункта:
      t[#t + 1] = { BreakKey = v.BreakKey, Item = v, Pos = k }

    end
  end

  return t

end ---- MakeBreakKeys

end -- do

---------------------------------------- Menu control

---------------------------------------- ---- Action
do
  local runUt = require "Rh_Scripts.Utils.Actions"

-- Определение полного имени скрипта.
function TMenu:DefineScriptName (Item) --> (string)

  local CfgData = self.Config.CfgData
  local Path = utils.PluginWorkPath

  local ScPath  = "scripts\\"
  local ScName  = Item.Script
  local RelPath = Item.Relative

  -- Определение каталога скрипта.
  if not RelPath then
    Path = Path..CfgData.Files.LuaScPath -- Каталог скриптов LUM

  else
    local Cfg_Basic = CfgData.Basic

    local ScriptPath = { -- Перечень специальных путей:

      Plugin    = "",       -- Каталог плагина
      scripts   = ScPath,   -- Каталог скриптов плагина

      LUM       = Cfg_Basic.LuaUMPath,          -- Каталог используемого LUM
      DefUM     = Cfg_Basic.DefUMPath,          -- Каталог LUM по умолчанию
      default   = Cfg_Basic.DefUMPath..ScPath,  -- Каталог скриптов DefUM

    } ---

    Path = Path..(ScriptPath[RelPath] or RelPath)
    if not utils.fexists(Path..ScName) then Path = Path..ScPath end

  end

  return Path..ScName

end ---- DefineScriptName

  local runLua = runUt.Lua

-- Выполнение порции / функции скрипта.
function TMenu:RunScript (Item)

  local Config = self.Config

  -- Исключение изменений в реальном пункте.
  Item = { __index = Item }
  setmetatable(Item, Item)

  local Args, ChunkArgs, SError

  -- Обработка имени скрипта.
  Item.Script, Item.ChunkArgs, ChunkArgs =
      runLua.Split(Item.Script, Item.ChunkArgs)
  --logShow(Item, tostring(Item.Script))

  -- Определение полного имени скрипта.
  local ChunkName
  if type(Item.Script) == 'string' then
    ChunkName = self:DefineScriptName(Item)

  end

  -- Формирование аргументов (порции) скрипта.
  if ChunkArgs then
    ChunkArgs, SError = Item.Script and Item.ChunkArgs, false

  else
    ChunkArgs, SError = runLua.GetArgs(Item.ChunkArgs)

  end
  if not ChunkArgs and SError then
    return nil, SError

  end

  -- Обработка имени функции скрипта.
  -- TODO: Убрать аргументы в названии скрипта!?
  Item.Function, Item.Arguments, Args =
      runLua.Split(Item.Function, Item.Arguments)
  --logShow(Item, tostring(Item.Function))
  -- Формирование аргументов функции скрипта.
  if Args then
    Args, SError = Item.Function and Item.Arguments, false

  else
    Args, SError = runLua.GetArgs(Item.Arguments)

  end

  if not Args and SError then
    return nil, SError

  end

  local DefCfg = { Config = Config, Item = Item, }
  local Cfg = { __index = DefCfg }; setmetatable(Cfg, Cfg)

  --logShow(Item, ChunkName)
  -- Запуск скрипта / функции скрипта с передачей ему аргументов.
  return runUt.Script(ChunkName, Item.Function, ChunkArgs, Args, Cfg)

end ---- RunScript

  local Errors = {

    PlainNoInsert = "Area has no text insert",
    MacroNoEditor = "Area is not editor",
    CommandELevel = "ErrorLevel is %d",
    CmdLineNoExec = "Command is not executed",
    UnknownAction = "Unknown action for item kind",

  } --- Errors

  -- Отмена возврата LF4Ed в главное меню.
  local function EscapeFromMainMenu ()

    local LF4Ed_Cfg = --rawget(_G, '_Plugin') and _G._Plugin.config() or
                      rawget(_G, 'lf4ed') and _G.lf4ed.config()
    --logShow(LF4Ed_Cfg, "LF4Ed_Cfg", 1)
    -- Учёт возврата LF4Ed в меню
    if LF4Ed_Cfg and LF4Ed_Cfg.ReturnToMainMenu then
      return runUt.LuaMacro("if Area.Menu then Keys'Esc' end")

    else
      return true

    end
  end -- EscapeFromMainMenu

-- Выполнение действия выбранного пункта.
function TMenu:MakeAction ()

  local Scope = self.Scope
  local ActItem = self.ActItem
  --logShow(Scope, "Scope", 1)
  --
  local Actions = { -- Функции выполнения действий:

    Label = runUt.Label, -- Пункт-метка

    LuaMacro = function () -- Выполнение макроса FAR'а

      local Macro = ActItem.LuaMacro
      EscapeFromMainMenu()

      return runUt.LuaMacro(Macro, ActItem.Flags)

    end, --

    Plain = function () -- Вывод обычного текста

      if not Scope.InsertText then
        return nil, Errors.PlainNoInsert

      end

      return runUt.Plain(ActItem.Plain, Scope.InsertText, Scope.args)

    end, --

    Macro = function () -- Вывод макроса-шаблона

      if Scope.Area ~= "editor" then
        return nil, Errors.MacroNoEditor

      end

      return runUt.Macro(ActItem.Macro)

    end, --

    Script = function () -- Запуск скрипта Lua

      local isOk, SError = self:RunScript(ActItem)
      --logShow({ isOk, SError }, ActItem.Name)
      if isOk ~= nil then return isOk end
      if SError then return nil, SError end

    end, --

    Program = function () -- Запуск процесса

      return runUt.Program(ActItem.Program)

    end, --

    Command = function () -- Запуск команды ОС

      return runUt.Command(ActItem.Command, Errors.CommandELevel)

    end, --

    CmdLine = function () -- Запуск из командной строки

      local isOk, SError = farUt.SwitchToPanels()
      if isOk == nil then return nil, SError end

      return runUt.CmdLine(ActItem.CmdLine, Errors.CmdLineNoExec)

    end, --

  } --- Actions

  -- Выполнение действия пункта меню.
  local Action = Actions[ActItem.Kind]
  if not Action then
    return nil, Errors.UnknownAction

  end
  --logShow(Item, Item.Kind)

  local isOk, SError = Action()
  ActItem.PressedKey = false -- Сброс

  if SError then return nil, SError end
  if isOk ~= nil then return isOk end

  return true

end ---- MakeAction

end -- do
---------------------------------------- ---- Show
do
  -- TODO: Для RectMenu делать замену клавиш на VK'шные!
  local DefBreakKeys = { --  BreakKeys по умолчанию:

    -- [[
    { BreakKey = "BS",      Action = "Back", },       -- Возврат в надменю
    { BreakKey = "ShiftF1", Action = "Item Info", },  -- Сведения о пункте меню
    { BreakKey = "CtrlF1",  Action = "Menu Info", },  -- Сведения о меню в целом
    --]]

    { BreakKey = "BACK",    Action = "Back", },       -- Возврат в надменю
    { BreakKey = "S+F1",    Action = "Item Info", },  -- Сведения о пункте меню
    { BreakKey = "C+F1",    Action = "Menu Info", },  -- Сведения о меню в целом

  } --- DefBreakKeys

  local Call = require "Rh_Scripts.Common.MenuCaller"

-- Показ меню заданного вида.
function TMenu:ShowMenu (Properties, Items) --> (item, pos)

  if not (Items and Items[1]) then return end
  --logShow(Items[1], "Items", "w d3")

  -- Объединение всех BreakKey.
  local BreakKeys = self:MakeBreakKeys(Items, DefBreakKeys)
  --logShow(BreakKeys, "BreakKeys")

  -- Отображение меню на экране.
  --logShow(Items[1], "Items")
  return Call(Properties, Items, BreakKeys)

end ---- ShowMenu

end -- do

local function ShowInfo (...)

  local debugs = require "context.utils.useDebugs"

  return debugs.Show(...)

end --

-- Обработка BreakKeys.
function TMenu:HandleBreakKeys ()

  -- Здесь self.ActItem -- BreakCode -- элемент таблицы BreakKeys.
  local Action = self.ActItem.Action -- Действие по BreakKey
  --logShow(Action, "Action of Break Key")

  -- Специальные действия:
  if Action and type(Action) == 'string' then
    -- Возврат в надменю.
    if Action == "Back" then
      local Back = self.CurMenu.Back
      self.ItemPos = Back.Pos
      self.ActItem = { Menu = Back.Menu, isBack = true }

      return

    end

    -- Показ информации:
    --logShow(Action, "Action of Info")
    if Action == "Item Info" then -- о пункте меню
      local Item = self.RunMenu[self.ItemPos]
      --logShow(Item, Action)
      -- TODO: Сделать нормальный вывод только нужной информации.
      ShowInfo(Item, self.L.MenuItem..": "..self:GetItemTitle(Item), 0)

    elseif Action == "Menu Info" then -- о меню в целом
      local Item = self.Menus[tables.Nameless] or self.BaseMenu
      -- TODO: Сделать нормальный вывод только нужной информации.
      --logShow(Item, Action)
      ShowInfo(Item, self.L.MenuMenu..": "..self:GetItemTitle(self.BaseMenu), 0)

    end --

    self.ActItem = { Menu = self.CurMenu, isBack = false }

    return

  end

  local ActItem = self.ActItem
  -- Поиск пункта с нажатым BreakKey.
  self.ItemPos = ActItem.Pos
  self.ActItem = ActItem.Item
  -- Нажатая клавиша - для дальнейшего анализа.
  self.ActItem.PressedKey = ActItem.BreakKey

end ---- HandleBreakKeys

do
  local sfind = string.find

  local MenuTexter = require "Rh_Scripts.Common.MenuTexter"

-- Цикл вывода меню до выбора.
function TMenu:ShowLoop ()

  --local CfgData = self.Config.CfgData

  repeat
    local ActItem = self.ActItem
    --logShow(self.ActItem, "self.ActItem", "w d2")
    if ActItem.isBack and not ActItem.Menu then
      self.ActItem, self.ItemPos = nil, nil

      return -- Выход из главного меню

    end

    self.isNova = (ActItem.isBack == nil) -- Учёт нового меню
    self.SelPos = not self.isNova and self.ItemPos or 1 -- Учёт возврата

    -- Получение реального меню с его именем:
    self.CurMenu = ActItem.Menu
    if self.CurMenu then
      self.CurName = self.CurMenu.Name

    else
      self.Error = self.L:et1("MnuSecNotFound", ActItem.Name or "(none)")

      return

    end
    --logShow(self.CurMenu, self.CurName, "w d2")

    self:MakeMenuConfig() -- Конфигурация меню
    local Props = self:MakeMenuProps()  -- Свойства меню
    self:MakeRunMenu()
    --logShow(self.RunMenu, "RunMenu", "w d2")
    if self.Error then return end

    -- Формирование текста пунктов меню.
    -- TODO: Add new params! Therefore copy is used.
    if self.CurData.UMenu.UseMenuTexter then
      Props.Texter = copyFields(self.CurData.UMenu)
      MenuTexter(Props, self.RunMenu, nil, false)
      --logShow(self.RunMenu, "self.RunMenu", 2)

      -- Исключение лишнего выравнивания в RectMenu
      Props.RectMenu.WidthAligned = Props.Texter.TextAligned

    end

    self.ActItem, self.ItemPos = self:ShowMenu(Props, self.RunMenu)

    if self.ActItem and not self.ActItem.Kind then
      self:HandleBreakKeys() -- Обработка нажатия BreakKey.

    end

    -- self:ShowMenu()

  until not self.ActItem or
        (self.ActItem.Kind and self.ActItem.Kind ~= "Menu")

end ---- ShowLoop

end -- do

---------------------------------------- ---- Run
do
  local NoReturnKinds = {

    --LuaMacro  = true,
    CmdLine   = true,

  } ---

-- Вывод меню и обработка выбранного пункта.
function TMenu:Run ()

  repeat
    self:ShowLoop()

    if self.Error then return nil, self.Error end

    if not self.ActItem then
      if not self.ItemPos then return false, "" end -- Отмена меню

      return nil, "ItemPos", self.ItemPos -- Ошибка при работе с меню

    end
    --logShow(self.ActItem, self.ActItem.Kind)

    local isOk, SError = self:MakeAction()
    --logShow({ isOk = isOk, error = SError }, self.ActItem.Kind)
    if isOk == nil then return nil, SError, self.ActItem end

    if NoReturnKinds[self.ActItem.Kind] or
       not self.CurData.UMenu.ReturnToUMenu then
       --not self.Config.CfgData.UMenu.ReturnToUMenu then
      return true

    end

    farUt.RedrawAll()

    self.ActItem = { Menu = self.CurMenu, isBack = false, }

  until false

  --return true

end ---- Run

end -- do

---------------------------------------- main

-- TODO: Объект/таблица локализации!!!
function unit.Menu (Properties, Menus, Config, ShowMenu)
                       --| (Menu) and/or --> (Menu|Items)

  if not Menus then return end

  local _Menu = CreateMenu(Properties, Menus, Config)
  if not _Menu then return end

  _Menu:Prepare()
  if _Menu.Error then return nil, _Menu.Error end

  if ShowMenu == 'self' then return _Menu end
  --logShow(_Menu, "_Menu")
  --logShow(Properties.Flags, "Flags")

  if useprofiler then profiler.stop() end

  return _Menu:Run()

end -- Menu

--------------------------------------------------------------------------------
return unit.Menu
--------------------------------------------------------------------------------
