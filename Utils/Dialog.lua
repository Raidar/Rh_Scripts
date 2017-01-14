--[[ Dialog utils ]]--

----------------------------------------
--[[ description:
  -- Handling dialogs.
  -- Управление диалогами.
--]]
----------------------------------------
--[[ uses:
  LuaFAR, far2.dialog,
  Rh Utils.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

local type = type
local pairs, ipairs = pairs, ipairs
local tonumber, tostring = tonumber, tostring

----------------------------------------
--local bit = bit64
--local band, bor = bit.band, bit.bor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local win, far = win, far
local F = far.Flags

----------------------------------------
local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'

local newFlags = utils.newFlags

local Null = tables.Null
local tfind = tables.find

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
local SendDlgMessage = far.SendDlgMessage
local GetDlgItem = far.GetDlgItem

---------------------------------------- Dialog
-- Названия полей элементов диалога и их номера. -- from far2.dialog
local DlgItem = {

  Type = 1, X1 = 2, Y1 = 3, X2 = 4, Y2 = 5,
  Selected = 6, ListItems = 6,
  VBuf = 6,
  History = 7, Mask = 8,
  Flags = 9,
  Data = 10, --Ptr = 10,
  MaxLen = 11,
  UserData = 12,

} -- DlgItem
unit.DlgItem = DlgItem

local diSelected  = DlgItem.Selected
local diListItems = DlgItem.ListItems
local diData      = DlgItem.Data

-- Типы элементов диалога:
unit.DlgItemType = {

  DBox      = "DI_DOUBLEBOX",   -- двойная рамка
  SBox      = "DI_SINGLEBOX",   -- одиночная рамка

  Text      = "DI_TEXT",        -- надпись
  VText     = "DI_VTEXT",       -- вертикальная надпись

  Edit      = "DI_EDIT",        -- поле ввода
  Fixed     = "DI_FIXEDIT",     -- поле ввода фикс. размера
  Pass      = "DI_PSWEDIT",     -- поле ввода пароля

  List      = "DI_LIST",        -- список выбора
  Combo     = "DI_COMBOBOX",    -- поле со списком

  Check     = "DI_CHECKBOX",    -- переключатель
  Radio     = "DI_RADIOBUTTON", -- кнопка выбора

  Button    = "DI_BUTTON",      -- кнопка

  User      = "DI_USERCONTROL", -- пользовательский элемент

} -- DlgItemType

-- Флаги элементов диалога:
unit.DlgItemFlag = {

  -- Common:
  Focus         = F.DIF_FOCUS,              -- Элемент с фокусом (по умолчанию)
                                            -- -- FAR3 - вместо поля Focus
  Disable       = F.DIF_DISABLE,            -- Недоступный элемент
  Hidden        = F.DIF_HIDDEN,             -- Скрытый элемент
  ReadOnly      = F.DIF_READONLY,           -- Только для чтения
  NoFocus       = F.DIF_NOFOCUS,            -- Нет фокуса с клавиатуры

  BoxColor      = F.DIF_BOXCOLOR,           -- Цвет рамок
  CenterGroup   = F.DIF_CENTERGROUP,        -- Группа по центру
  Ampersand     = F.DIF_SHOWAMPERSAND,      -- Показ символа '&'

  -- Special:
  NoAutoComplete= F.DIF_NOAUTOCOMPLETE,     -- Без автодополнения
  SelectOnEntry = F.DIF_SELECTONENTRY,      -- Выделение при получении фокуса

  -- DBox / SBox:
  BoxTextLeft   = F.DIF_LEFTTEXT,           -- Заголовок по левому краю

  -- Text / VText:
  SingleSep     = F.DIF_SEPARATOR,          -- Одиночная линия
  DoubleSep     = F.DIF_SEPARATOR2,         -- Двойная линия
  CenterText    = F.DIF_CENTERTEXT,         -- Центрирование текста

  -- Edit / Fixed:
  Editor        = F.DIF_EDITOR,             -- Ряд элементов как редактор
  EditPath      = F.DIF_EDITPATH,           -- Ввод имён файловых объектов
  ExpandVars    = F.DIF_EDITEXPAND,         -- Разворачивание переменных среды
  MaskEdit      = F.DIF_MASKEDIT,           -- Использование маски

  History       = F.DIF_HISTORY,            -- Ведение истории
  HistoryAdd    = F.DIF_MANUALADDHISTORY,   -- Ручное добавление в историю
  HistoryLast   = F.DIF_USELASTHISTORY,     -- Начальное значение из истории

  -- List / Combo:
  AutoHighlight = F.DIF_LISTAUTOHIGHLIGHT,  -- Автоназначение горячих букв
  ShowHighlight = F.DIF_LISTNOAMPERSAND,    -- Показ горячих букв
  ListNoBox     = F.DIF_LISTNOBOX,          -- Список без рамки
  ListNoClose   = F.DIF_LISTNOCLOSE,        -- Без закрытия диалога
  ListWrapMode  = F.DIF_LISTWRAPMODE,       -- Циклический проход по списку
  DropDownList  = F.DIF_DROPDOWNLIST,       -- Только выбор из списка
  --TrackMouse        = F.DIF_LISTTRACKMOUSE,           -- FAR3 - ?
  --TrackFocusMouse   = F.DIF_LISTTRACKMOUSEINFOCUS,    -- FAR3 - ?

  -- Check:
  MultiState    = F.DIF_3STATE,             -- Три состояния

  -- Radio:
  RadioGroup    = F.DIF_GROUP,              -- Группа из последовательных элементов
  MoveSelect    = F.DIF_MOVESELECT,         -- Выделение с помощью фокуса

  -- Button:
  BtnDefault    = F.DIF_DEFAULTBUTTON,      -- Кнопка по умолчанию -- FAR3 - вместо поля DefaultButton
  BtnNoClose    = F.DIF_BTNNOCLOSE,         -- Без закрытия диалога
  NoBrackets    = F.DIF_NOBRACKETS,         -- Текст без скобок
  Privileged    = F.DIF_SETSHIELD,          -- Необходимость прав администратора

  -- Комбинации:
  SeparLine     = newFlags(F.DIF_BOXCOLOR, F.DIF_SEPARATOR, F.DIF_CENTERTEXT),
  ComboList     = newFlags(F.DIF_DROPDOWNLIST, F.DIF_LISTWRAPMODE),
  DlgButton     = newFlags(F.DIF_CENTERGROUP, F.DIF_NOBRACKETS),
  DefButton     = newFlags(F.DIF_CENTERGROUP, F.DIF_NOBRACKETS, F.DIF_DEFAULTBUTTON),

} -- DlgItemFlag

---------------------------------------- Datas

-- Формирование списка элементов из списка значений.
function unit.ListItems (Config, Kind, L) --> (table)

  L = L or Config.Custom.Locale

  local List = Config.DlgTypes[Kind]
  local Prefix = List.Prefix

  local t = {}
  for k = 1, #List do
    t[#t + 1] = { Text = L:config(Prefix..List[k]) }

  end
  --logShow(t, "ListItems")

  return t

end ---- ListItems

-- Загрузка данных в элемент диалога.
local function LoadDlgItem (Info, Data, Dlg) --| Item

  local Type = Info.Type or "edt"
  local k, List = Info.Field --, nil

  if type(Type) == 'table' then
    List, Type = Type, Type.Type

  end

  local Name = Type..(Info.Name or k)
  local u = Dlg[Name] -- Dialog item
  --logShow(Dlg, "LoadDlgItem Dlg", 2)
  --logShow({ k, Type, Name, u }, "LoadDlgItem", 2)
  if not u then return end

  if not List then
    if Type == "edt" then
      u[diData] = Data[k]

    elseif Type == "chk" then
      u[diSelected] = Data[k] and 1 or 0

    end
  else
    if Type == "edt" then
      if List.Format == "number" then u[diData] = tostring(Data[k]) end

    else -- "lbx" or "cbx"
      u[diListItems].SelectIndex = tfind(List, Data[k], ipairs)

    end
  end
end ---- LoadDlgItem
unit.LoadDlgItem = LoadDlgItem

local torange = numbers.torange -- Приведение к диапазону

-- Сохранение данных из элемента диалога.
local function SaveDlgItem (Info, Data, Dlg) --| Item

  local Type = Info.Type or "edt"
  local k, List = Info.Field --, nil

  if type(Type) == 'table' then
    List, Type = Type, Type.Type

  end

  local Name = Type..(Info.Name or k)
  local u = Dlg[Name] -- Dialog item
  --logShow(Dlg, "SaveDlgItem Dlg", 2)
  --logShow({ k, Type, Name, List, u }, "SaveDlgItem", 2)
  if not u then return end

  local d -- Данные
  if not List then
    if Type == "edt" then
      d = u[diData]

    elseif Type == "chk" then
      d = u[diSelected] ~= 0

    end
  else
    if Type == "edt" then
      u = u[diData]
      if List.Format == "number" then
        d = tonumber(u) or List.Default or Data[k]
        u = List.Range
        if u then d = torange(d, u.min, u.max) end

      end
    else -- "lbx" | "cbx"
      u = u[diListItems]
      --logShow(Value, "diListItems")
      d = u and List[u.SelectIndex] or ""

    end
  end
  --logShow({ k, Type, Name, d, v }, "SaveDlgItem", 2)
  --logShow({ k, Info.Default, d, Data }, "SaveDlgItem", 2)
  --if Info.SpaceAsNil then logShow({ Info, Name, d, v }, "SaveDlgItem", 2) end

  --[[
  if d == ' ' and Info.SpaceAsNil then
    Data[k] = nil
  elseif d ~= "" and
         d ~= Info.Default then
    Data[k] = d
  else
    Data[k] = nil
  end
  --]]

  if d ~= "" and d ~= Info.Default then
    Data[k] = d

  else
    Data[k] = nil

  end

  --logShow({ k, Info.Default, d, Data }, "SaveDlgItem", 2)

end ----
unit.SaveDlgItem = SaveDlgItem

-- Загрузка данных в элементы диалога.
function unit.LoadDlgData (Data, ArgData, Dlg, Types) --| Data

  local t = { Field = 0, Type = 0 }
  for k, _ in pairs(ArgData) do
    t.Field, t.Type = k, Types[k]
    LoadDlgItem(t, Data, Dlg)

  end
end ---- LoadDlgData

-- Сохранение данных из элементов диалога.
function unit.SaveDlgData (Data, ArgData, Dlg, Types) --| Data

  local t = { Field = 0, Default = 0, Type = 0 }
  for k, v in pairs(ArgData) do
    t.Field, t.Default, t.Type = k, v, Types[k]
    SaveDlgItem(t, Data, Dlg)

  end
end ---- SaveDlgData

---------------------------------------- Functions
-- Make item+box draw color.
-- Формирование цвета отрисовки элемента+рамки.
--[[
  Lo_Lo (number) - цвет текста.
  Lo_Hi (number) - цвет выделенного текста.
  Hi_Lo (number) - цвет рамки.
  Hi_Hi (number) - зарезервирован.
--]]
function unit.ItemColor (Lo_Lo, Lo_Hi, Hi_Lo, Hi_Hi) --> (table)

  --logShow({ Lo_Lo, Lo_Hi, Hi_Lo, Hi_Hi, }, "ItemColor", "d3 x2")

  return { Lo_Lo, Lo_Hi, Hi_Lo, Hi_Hi, }

end ---- ItemColor

-- Change item+box draw color.
-- Изменение цвета отрисовки элемента+рамки.
function unit.ChangeColor (Color, Lo_Lo, Lo_Hi, Hi_Lo, Hi_Hi) --> (table)

  return { Lo_Lo or Color[1], Lo_Hi or Color[2],
           Hi_Lo or Color[3], Hi_Hi or Color[4], }

end ---- ChangeColor

-- Get draw color for item text.
-- Получение цвета отрисовки для текста элемента.
function unit.GetTextColor (Color) --> (table)

  return Color[1]

end ---- GetTextColor

-- Получение "прямоугольника" окна.
function unit.DialogRect (hDlg) --> (table)

  local DlgRect = SendDlgMessage(hDlg, F.DM_GETDLGRECT, 0)

  return {
    x = DlgRect.Left,
    y = DlgRect.Top,
    w = DlgRect.Right - DlgRect.Left + 1,
    h = DlgRect.Bottom - DlgRect.Top + 1,
    xw = DlgRect.Right,
    yh = DlgRect.Bottom,
  } ----

end ---- DialogRect

---------------------------------------- from service.c
-- Обновление элементов диалога.
function unit.UpdateItems (hDlg, Items) --| (Items)

  for k, u in ipairs(Items) do
    local w = GetDlgItem(hDlg, k)
    if type(u[diListItems]) == 'table' then
      local Pos = far.SendDlgMessage(hDlg, F.DM_LISTGETCURPOS, k, 0)
      u[diListItems].SelectIndex = (Pos or Null).SelectPos

    else
      u[diListItems] = w[diListItems]

    end

    u[diData] = w[diData]

  end
end ---- UpdateItems

-- Стандартный диалог с возможным обновлением элементов после выполнения.
function unit.Dialog (Guid, X1, Y1, X2, Y2,
                      HelpTopic, Items, Flags, DlgProc, view)

  Guid = Guid or win.Uuid()

  local hDlg = far.DialogInit(Guid, X1, Y1, X2, Y2,
                              HelpTopic, Items, Flags, DlgProc)
  if hDlg == nil then return nil end

  local iDlg = far.DialogRun(hDlg)
  if not view then unit.UpdateItems(hDlg, Items) end
  far.DialogFree(hDlg)

  return iDlg

end ---- Dialog

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
