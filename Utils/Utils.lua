--[[ Lua and LuaFAR utils ]]--

----------------------------------------
--[[ description:
  -- Lua and LuaFAR functions.
  -- Lua‑ и LuaFAR‑функции.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

local type = type
local pairs = pairs

--local format = string.format

----------------------------------------
--local bit = bit64
--local band, bor = bit.band, bit.bor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local far = far
local F = far.Flags

local farAdvControl = far.AdvControl
local EditorGetInfo = editor.GetInfo
local ViewerGetInfo = viewer.GetInfo
local PanelsGetInfo = panel.GetPanelInfo

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
--local strings = require 'context.utils.useStrings'

local isFlag = utils.isFlag

local b2n, max2 = numbers.b2n, numbers.max2

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
--[[
  The most part of functions haven't value & type checking for arguments.
  Большинство функций не выполняют проверки значений и типов для параметров.
--]]
---------------------------------------- String

---------------------------------------- Table
local function _isEqual (t, u) --> (bool)

  if t == nil and u == nil then return true end
  if t == nil or u == nil then return false end

  local typeT, typeU = type(t), type(u)
  if typeT ~= 'table' or typeU ~= 'table' then
    return typeT == typeU and t == u

  end

  for k, v in pairs(t) do
    if u[k] == nil then return false end

    local equal = _isEqual(v, u[k])
    if not equal then return false end

  end

  for k, _ in pairs(u) do
    if t[k] == nil then return nil end

  end

  return true

end -- _isEqual
unit.isEqual = _isEqual

-- Выполнение gsub для значений ключей таблицы строк.
function unit.t_gsub (t, name, pattern, replace) --> (table)

  for k, v in pairs(t) do
    if not name or (name and k:find(name)) then
      t[k] = v:gsub(pattern, replace)

    end
  end

  return t

end ---- t_gsub

-- Maximum of field values for table array-part.
-- Максимум значений полей для части-массива таблицы.
function unit.t_imax (t, count) --> (number)

  local m, i = 0, 0

  -- Find first value.
  for k = 1, count or #t do
    local v = t[k]
    if v then
      m, i = v, k

      break
    end
  end
  if i == 0 then return end

  -- Check next values.
  for k = i + 1, count or #t do
    local v = t[k]
    if v and v > m then m = v end

  end

  return m

end ---- t_imax

-- Sum of field values for table array-part.
-- Сумма значений полей для части-массива таблицы.
function unit.t_isum (t, first, last, step) --> (number)

  local s = 0

  for k = first or 1, last or #t, step or 1 do
    s = s + (t[k] or 0)

  end

  return s

end ---- t_isum

-- Преобразование значения в таблицу с полем [0].
function unit.valtotab (v, key, default) --> (table)

  if type(v) == 'table' then return v end

  if key == nil then key = 0 end

  if v == nil then
    if default == nil then return end
    v = default

  end

  return { [key] = v }

end ---- valtotab

---------------------------------------- Package
do
  local getevar = function (env, name) return env[name] end

-- Get value of variable 'name' from env.
-- Получение значения переменной name из env.
function unit.getvalue (env, name) --> (value)

  local isOk, var = pcall(getevar, env, name)
  if isOk then return var end

end ----

-- Get a global variable (with possible creation)
-- when using a "strict" work mode (strict.lua).
-- Получение (с возможным созданием) глобальной переменной
-- при использовании "строгого" режима работы (strict.lua).
function unit.getglobal (varname, default) --> (var)

  default = default == nil and {} or default
  if getevar(_G, varname) == nil then
    _G[varname] = default

  end

  return _G[varname]

end ---- getglobal

  local require = require
  local pkg_loaded = package.loaded

-- Variant of require with mandatory reloading of a chunk.
-- Вариант require с обязательной перезагрузкой chunk'а.
local function newrequire (modname, dorequire)

  if pkg_loaded[modname] then
    pkg_loaded[modname] = nil

  end

  return (dorequire or require)(modname)

end ----
unit.newrequire = newrequire

  local pcall = pcall

-- Variant of require with protected mode call.
-- Вариант require с вызовом в защищённом режиме.
local function prequire (modname)

  local isOk, res = pcall(require, modname)
  --far.Message(Result, tostring(isOk))
  return isOk and res

end ----
unit.prequire = prequire

-- Variant of require with mandatory reloading and protected mode call.
-- Вариант require с обязательной перезагрузкой в защищённом режиме.
function unit.newprequire (modname)

  return newrequire(modname, prequire)

end --

end -- do

---------------------------------------- Function
-- Call function.
-- Вызов функции.
function unit.fcall (f, ...)

  return f(...)

end ----

-- Check pcall function result.
-- Проверка результата функции pcall.
function unit.pcheck (isOk, ...)

  if isOk then return ... end

end ----

do
  local pcall = pcall

-- Protected call function.
-- Защищённый вызов функции.
function unit.pfcall (f, ...)

  return unit.pcheck(pcall(f, ...))

end ----

end -- do
do
  local getvalue = unit.getvalue
  local sFieldNotFoundError = "No field %s\n of %s"

-- Find function with compound name in environment env (and _G).
-- Поиск функции с составным именем name в окружении env (и _G).
function unit.ffind (env, name) --> (function | nil, error)

  local f = getvalue(env, name)
  if f then return f end

  -- Проверка первой компоненты имени.
  f = name:match("^[^.]+")
  --logShow(env, f, 1)
  --logShow(_G, f, "d3 _ns")
  --logShow(rawget(_G, name), f, "d2 _ns")
  --logShow(package.loaded[f], f, "d2 _ns")
  if getvalue(env, f) then
    f = env

  elseif getvalue(_G, f) then
    f = _G

  else
    return nil, sFieldNotFoundError:format(f, name) -- Ошибка

  end

  -- Разбор всех компонент имени.
  for s in name:gmatch("([^.]+)") do
    --logShow(s, Name)
    if not getvalue(f, s) then
      return nil, sFieldNotFoundError:format(s, name) -- Ошибка

    end
    f = f[s]
    --logShow(f, s)

  end
  --logShow(f, name)

  return f

end ---- ffind

end -- do

---------------------------------------- System

---------------------------------------- -- Path
-- Приведение пути к формату Windows.
function unit.FileWPath (path) --> (string)

  return path:gsub("/", "\\")

end ----
-- Приведение пути к формату Unix.
function unit.FileUPath (path) --> (string)

  return path:gsub("\\", "/")

end ----

-- Adding a trailing slash to path.
-- Добавление завершающего слэша к пути.
function unit.ChangeSlash (path, slash) --> (string)

  slash = slash or '\\' -- Windows
  --slash = slash or '/' -- Unix like

  path = (path or ""):gsub("\\", slash)
  if path:find("[/\\]", -1) then
    return path

  else
    return path..slash

  end
end ---- ChangeSlash

-- Разбор произвольного пути файла.
function unit.ParseFileName (filepath) --> (path, fullname, name, ext)

   -- Разделение полного пути на собственно путь и полное имя.
  local path, fullname = filepath:match("^(.*[/\\])([^/\\]*)$")
  if not path then fullname = filepath end -- Нет пути к файлу

  -- Разделение полного имени на собственно имя и расширение.
  if fullname == "" then fullname = nil end -- Нет полного имени
  if not fullname then return path, nil, nil, nil end -- Только путь
  local name, ext = fullname:match("^(.*)%.([^%.]*)$")
  if not name and not ext then name = fullname end -- Только имя
  if ext == "" then ext = nil end -- Нет расширения файла

  -- Путь к файлу, Имя с расширением, Имя файла, Расширение файла.
  return path, fullname, name, ext

end ---- ParseFileName

-- Разбор полного пути файла: с наличием пути и файла с расширением.
function unit.ParseFullName (fullpath) --> (path, fullname, name, ext)

  -- Путь к файлу, Имя с расширением, Имя файла, Расширение файла.
  return fullpath:match("^(.-[/\\])(([^/\\]*)%.([^/\\%.]*))$")

end ---- ParseFullName

-- Adding a path of modules to EnvPath.
-- Добавление пути к модулям в EnvPath.
function unit.AddEnvPath (BasePath, ModulePath, ModuleName, EnvPath) --> (string)

  for CurPath in ModulePath:gmatch("([^;]+)") do
    local Path = unit.ChangeSlash(BasePath..CurPath)..ModuleName -- Полный путь.
    -- Настройка путей для поиска модулей.
    if not EnvPath:find(Path, 1, true) then EnvPath = Path..';'..EnvPath end

  end

  return EnvPath

end ---- AddEnvPath

local package = package

-- Adding a path of used lua-modules.
-- Добавление пути к используемым lua-модулям.
function unit.AddLuaPath (BasePath, ModulePath) --> (bool)

  package.path = unit.AddEnvPath(BasePath, ModulePath, "?.lua", package.path)

end

-- Adding a path of used dll-modules.
-- Добавление пути к используемым dll-модулям.
function unit.AddLibPath (BasePath, ModulePath) --> (bool)

  package.cpath = unit.AddEnvPath(BasePath, ModulePath, "?.dll", package.cpath)

end

---------------------------------------- -- File
do
  local ssub = string.sub -- Byte cut! for check CP

-- Проверка строки файла на признаки Unicode.
function unit.CheckLineCP (s) --> (string)

  if #s < 2 then return "OEM" end

  local sBOM = ssub(s, 1, 3)
  if sBOM == '\239\187\191' then return "UTF-8" end -- EF BB BF
  sBOM = ssub(s, 1, 2)

  return sBOM == '\255\254' and "UTF-16 BE" or -- FF FE
         sBOM == '\254\255' and "UTF-16 LE" or -- FE FF
         "OEM" -- by default

end ---- CheckLineCP

end -- do

do
  local io_open = io.open

-- Проверка файла на признаки Unicode.
function unit.CheckFileCP (filename) --> (string)

  local f = io_open(filename, 'r')
  if not f then return nil end
  local s = f:read('*l')
  f:close()

  return unit.CheckLineCP(s)

end ---- CheckFileCP

end -- do

---------------------------------------- Common
do
  local type = type

-- Value length.
-- Длина значения.
function unit.length (v) --> (number)

  local tp = type(v)
  if tp == 'string' then return v:len() end
  if tp == 'table' then return #v end

  return v ~= nil and 1 or 0

end ---- length

end -- do

---------------------------------------- FAR API
-- Version of FAR.
-- Версия of FAR.
local function Version (kind) --> (string | vary)

  return far.AdvControl(F.ACTL_GETFARVERSION, kind)

end --

unit.FarVersion = { -- Version info:

  FAR       = { Version(true) },            -- Table with version as numbers
  VerFAR    = Version():match("^%d+%.%d+"), -- String with version without build

} --- FarVersion

-- Значение цвета по его индексу Index.
function unit.IndexColor (Index) --> (table)

  return farAdvControl(F.ACTL_GETCOLOR, Index)

end ----

-- Position & size of FAR window.
-- Позиция и размер окна FAR.
function unit.GetFarRect () --> (table)

  local R = farAdvControl(F.ACTL_GETFARRECT)
  if R then
    R.Width  = R.Right - R.Left + 1
    R.Height = R.Bottom - R.Top + 1

  end

  return R

end ---- GetFarRect

do
  local DefHelpTopicFlags = { FHELP_USECONTENTS = 1, FHELP_NOSHOWERROR = 1, }

-- Show specified help topic.
-- Показ заданной темы помощи.
function unit.ShowHelpTopic (HelpTopic, Flags) --> (bool)

  if not HelpTopic then return nil end

  Flags = Flags or DefHelpTopicFlags

  local File, Topic = HelpTopic:match("%<([^%>]*)%>(.*)$")
  if not File then
    File, Topic = utils.PluginWorkPath, HelpTopic

  end

  --far.Message(File, Topic)
  return far.ShowHelp(File, Topic, Flags)

end ---- ShowHelpTopic

end
---------------------------------------- Redraw
-- Redraw all.
-- Перерисовка всего.
function unit.RedrawAll ()

  return farAdvControl(F.ACTL_REDRAWALL)

end --

-- Run function with followed redrawing.
-- Выполнение функции с последующей перерисовкой.
function unit.RunWithRedraw (f, ...)

  f(...)
  return farAdvControl(F.ACTL_REDRAWALL)

end ----

---------------------------------------- Window
-- Get information about window.
-- Получение информации об окне.
function unit.GetWindowInfo (pos) --> (table)

  return farAdvControl(F.ACTL_GETWINDOWINFO, pos or 0)

end ----

-- Switch to specified FAR window.
-- Переключение на конкретное окно FAR.
function unit.SetCurrentWindow (pos) --> (bool)

  local isOk = farAdvControl(F.ACTL_SETCURRENTWINDOW, pos or 1)
  if isOk then return farAdvControl(F.ACTL_COMMIT) end

end ----

-- Switch to FAR panels window.
-- Переключение на окно панелей FAR.
function unit.SwitchToPanels (CmdLine) --> (bool | nil, error)

  if not panel.CheckPanelsExist() then
    return nil, "No panels window"

  end

  local Info = farAdvControl(F.ACTL_GETWINDOWINFO, 0)
  if not Info then return nil, "No window info" end

  if Info.Type ~= F.WTYPE_PANELS then
    if not unit.SetCurrentWindow() then
      return nil, "No switch to panels window"

    end
  end

  return true

end ---- SwitchToPanels

---------------------------------------- Plugin API
-- Call function in "user" mode.
function unit.usercall (newcfg, f, ...)

  return f(...)

end

if rawget(_G, 'lf4ed') then

  local pcall = pcall
  local lfed_cfg = lf4ed.config

  function unit.usercall (newcfg, f, ...) --> (result, error)

    newcfg = newcfg or -- Новый конфиг
             { RequireWithReload = false, ReturnToMainMenu = false, }
    local isOk, oldcfg = pcall(lfed_cfg, newcfg)
    oldcfg = isOk and oldcfg or nil

    local sError
    isOk, sError = f(...)
    if oldcfg then lfed_cfg(oldcfg) end -- Старый конфиг

    return isOk, sError

  end --

end -- if

do
  local require = require

-- Require module in "user" mode.
--unit.urequire = require
-- [[
function unit.urequire (modname)

  return unit.usercall(nil, require, modname)

end
--]]

end -- do

---------------------------------------- FAR area
-- Type of FAR area.
-- Тип области/окна FAR.
unit.FarAreaTypes = {

  [F.WTYPE_PANELS] = "panels",
  [F.WTYPE_VIEWER] = "viewer",
  [F.WTYPE_EDITOR] = "editor",
  [F.WTYPE_DIALOG] = "dialog",
  [F.WTYPE_VMENU]  = "vmenu",
  [F.WTYPE_HELP]   = "help",

} --- AreaTypes

-- Type of specified/current area.
-- Тип заданной/текущей области.
--[[
  -- @params:
  pos (n|nil) - area number (@default = (nil | 0) - current area).
--]]
function unit.GetAreaType (pos) --> (string)

  return unit.FarAreaTypes[unit.GetWindowInfo(pos).Type]

end

-- Check to basic FAR area.
-- Проверка на базисную область.
unit.FarIsBasicAreaType = {

  panels = true,
  editor = true,
  viewer = true,

} --

-- Type of basic (for specified/current) area.
-- Тип основной (для заданной/текущей) области.
function unit.GetBasicAreaType (pos) --> (string)

  local Result = unit.GetAreaType(pos)
  if unit.FarIsBasicAreaType[Result] then
    return Result

  else
    return unit.GetAreaType(0)

  end
end ---- GetBasicAreaType

-- Get size of specified FAR area.
-- Получение размера заданной области.
unit.FarGetAreaSize = {

  panels = function () -- Панели:

    local APInfo = PanelsGetInfo(nil, 1).PanelRect -- Активная панель
    local PPInfo = PanelsGetInfo(nil, 0).PanelRect -- Пассивная панель
    if APInfo and PPInfo then
      return { Width  = APInfo.right - APInfo.left + 1 +
                        PPInfo.right - PPInfo.left + 1,
               Height = max2(APInfo.bottom - APInfo.top + 1,
                             PPInfo.bottom - PPInfo.top + 1), }
    end
  end, -- panels

  editor = function () -- Редактор:

    local Info = EditorGetInfo(nil)
    if Info then
      return { Width  = Info.WindowSizeX,
               Height = Info.WindowSizeY, }
    end
  end, -- editor

  viewer = function () -- Просмотр:

    local Info = ViewerGetInfo(nil)
    if Info then
      return { Width  = Info.WindowSizeX,
               Height = Info.WindowSizeY, }
    end
  end, -- viewer

  dialog = false,

} --- FarGetAreaSize

function unit.FarGetAreaSize.dialog () -- Просмотр:

  return unit.FarGetAreaSize.panels() or
         unit.FarGetAreaSize.editor() or
         unit.FarGetAreaSize.viewer()

end -- dialog

-- Size of current FAR area.
-- Размер текущей области FAR.
function unit.GetAreaSize (Type, pos) --> (table | nil)

  Type = Type or unit.GetAreaType(pos) or ""
  if unit.FarGetAreaSize[Type] then
    return unit.FarGetAreaSize[Type]()

  end
end ---- GetAreaSize

---------------------------------------- FAR item
unit.FarGetAreaItemName = {

  panels = function () -- Панели:

    local Item = panel.GetCurrentPanelItem(nil, 1)
    local Name = Item and Item.FileName or ".."
    if utils.isPluginPanel() then return "" end

    local Dir = panel.GetPanelDirectory(nil, 1).Name
    --logShow({ Name, Dir, Item }, "AreaItem Name")
    if Name == ".." then
      return Dir

    else
      return Dir:sub(-1, -1) == "\\" and (Dir..Name) or (Dir.."\\"..Name)

    end
  end, -- panels

  editor = function () -- Редактор:

    return EditorGetInfo(nil).FileName

  end, -- editor

  viewer = function () -- Просмотр:

    return ViewerGetInfo(nil).FileName

  end, -- viewer

} --- FarGetAreaItemName

-- Name of current item in FAR area.
-- Имя текущего элемента в области FAR.
function unit.GetAreaItemName (Type, pos) --> (string | nil)

  Type = Type or unit.GetAreaType(pos) or ""
  if unit.FarGetAreaItemName[Type] then
    return unit.FarGetAreaItemName[Type]()

  end
end ----

---------------------------------------- Selection
-- Count of selected items on panels.
-- Число выделенных элементов на панелях.
function unit.PanelsSelCount (handle, kind)

  local Result = PanelsGetInfo(handle, kind).SelectedItemsNumber
  if Result ~= 1 then return Result end

  Result = panel.GetSelectedPanelItem(handle, kind, 1)
  if Result then
    return b2n(isFlag(Result.Flags, F.PPIF_SELECTED))

  end

  return 0

end ---- PanelsSelCount

-- Type of selected block.
-- Тип выделенного блока.
local BlockTypes = {

  -- flags
  None    = F.BTYPE_NONE,
  Stream  = F.BTYPE_STREAM,
  Column  = F.BTYPE_COLUMN,

  -- names
  [F.BTYPE_NONE]   = "none",
  [F.BTYPE_STREAM] = "stream",
  [F.BTYPE_COLUMN] = "column",

} --- BlockTypes
unit.BlockTypes = BlockTypes

-- Type of selected block in editor.
-- Тип выделенного блока в редакторе.
function unit.EditorSelType (id) --> (string)

  return BlockTypes[EditorGetInfo(id).BlockType]

end ----

-- Check selection presence.
-- Проверка наличия выделения.
local FarIsSelection = {

  panels = function () return unit.PanelsSelCount(nil, 1) > 0 end,
  editor = function () return unit.EditorSelType() ~= "none" end,
  -- TODO: Add function for dialog area

} --- FarIsSelection
unit.FarIsSelection = FarIsSelection

-- Check selection in specified FAR area.
-- Проверка выделения в заданной области.
function unit.IsSelection (Area) --> (bool)

  if FarIsSelection[Area] then
    return FarIsSelection[Area]()

  end
end ----

---------------------------------------- Text
-- TODO: Попробовать на основе regex.
-- Parse text string with hot character.
-- Разбор строки текста с "горячей" буквой.
function unit.ParseHotStr (Str, Hot, isPos) --> (Left, Char, Right)

  Str, Hot = Str or "", Hot or '&'
  if Str == Hot then return Str, nil, "" end

  local HotPos = Str:cfind(Hot, 1, true)
  if not HotPos then return nil, nil, Str end

  local Pos
  local Len, Hots = #Str + 1, 1
  -- Учёт цепочек символов Hot.
  for k = HotPos + 1, Len do
    if Str:sub(k, k) ~= Hot then
      -- При нечётном 1-й Hot -- ссылка на букву.
      if Hots % 2 ~= 0 then Pos = k - Hots + 1 end

      break -- При чётном -- нет ссылки на букву.
    else
      Hots = Hots + 1 -- Подсчёт количества Hot

    end
  end

  -- Разбор строки с учётом цепочки.
  if Pos and Pos < Len then
    -- Поправка на следующий символ Hot:
    Len = b2n( Str:sub(Pos + 1, Pos + 1) == Hot )
    if isPos then return 1, Pos, Pos + 1 + Len end
    return Str:sub(1, Pos - 2), Str:sub(Pos, Pos),
           Str:sub(Pos + 1 + Len):gsub(Hot..Hot, Hot)
  else
    if isPos then return 0, 0, 1 end
    return nil, nil, Str:gsub(Hot..Hot, Hot)

  end
end ---- ParseHotStr

do
  local ParseHotStr = unit.ParseHotStr

-- Get string without hot character.
-- Получение строки без "горячей" буквы.
function unit.ClearHotStr (Str, Hot) --> (string)

  local Left, Char, Right = ParseHotStr(Str, Hot)
  return (Left or "")..(Char or '')..(Right or "")

end ---- ClearHotStr

end -- do
do
  local tables = require 'context.utils.useTables'

  local ClearHotStr = unit.ClearHotStr

-- Get text without hot character.
-- Получение текста без "горячей" буквы.
function unit.ClearHotText (Str, Hot)

  local tp = type(Str)
  if Str == nil or tp == 'string' then
    return ClearHotStr(Str, Hot)

  end
  if tp ~= 'table' then
    return Str

  end

  local t = tables.clone(Str, true, nil)
  for k = 1, #Str do
    local v = t[k]
    local s = ClearHotStr(v, Hot)
    if v ~= s then
      t[k] = s

      break
    end
  end

  return t

end ---- ClearHotText

end -- do
---------------------------------------- I/O
do
  local far_Text = far.Text

--[[
-- Horizontal output of text.
-- Вывод текста горизонтально.
function unit.HText (X, Y, Color, Str)
  return far_Text(X, Y, Color, Str)

end ----
--]]

unit.HText = far_Text

-- Vertical output of text.
-- Вывод текста вертикально.
function unit.VText (X, Y, Color, Str)

  for k = 1, #Str do
    far_Text(X, Y, Color, Str:sub(k, k))
    Y = Y + 1

  end
end ---- VText

-- Vertical output of text with "reversed" coordinates.
-- Вывод текста вертикально с "обратными" координатами.
function unit.YText (Y, X, Color, Str)

  return unit.VText(X, Y, Color, Str)

end

end -- do
---------------------------------------- Insert
do
  local DlgEditItems = {

    [F.DI_EDIT]     = true,
    [F.DI_FIXEDIT]  = true,
    [F.DI_COMBOBOX] = true,

  } ---
  local SendDlgMessage = far.SendDlgMessage

-- Insert text to active item of dialog.
-- Вставка текста в активный элемент диалога.
local function DialogInsertText (hDlg, s)

  if not hDlg then
    local Info = farAdvControl(F.ACTL_GETWINDOWINFO, 0)
    if Info.Type ~= F.WTYPE_DIALOG then return false end

    hDlg = Info.Id

  end

  local id = SendDlgMessage(hDlg, F.DM_GETFOCUS)
  if not DlgEditItems[ far.GetDlgItem(hDlg, id)[1] or "" ] then
    return -- Not supported type

  end

  local PosInfo
  local text = SendDlgMessage(hDlg, F.DM_GETTEXT, id)
  -- Обработка имеющегося текста
  if text and text:len() > 0 then
    -- Обработка позиции в тексте
    PosInfo = SendDlgMessage(hDlg, F.DM_GETEDITPOSITION, id)
    -- Обработка выделения текста
    local SelInfo = SendDlgMessage(hDlg, F.DM_GETSELECTION, id)
    local pos = SelInfo and SelInfo.BlockStartPos or 0
    if pos == 0 then pos = PosInfo and PosInfo.CurPos or 0 end
    local sel = SelInfo and SelInfo.BlockWidth or 0
    --logShow({ text:len(), pos, sel, PosInfo, SelInfo }, "DialogInsertText:Pos")

    if pos > 0 then
      text = text:sub(1, pos - 1)..
             s..
             text:sub(pos + sel, -1)

      PosInfo.CurPos = pos + s:len()
      PosInfo.CurTabPos = -1

    else
      text = text..s
      PosInfo = nil

    end

  else
    text = s

  end -- if

  --logShow({ text, PosInfo, }, s)
  local isOk = SendDlgMessage(hDlg, F.DM_SETTEXT, id, text) and true or false
  if not isOk then return end

  if PosInfo then
    isOk = SendDlgMessage(hDlg, F.DM_SETEDITPOSITION, id, PosInfo)

  end

  return isOk

end ---- DialogInsertText
unit.DialogInsertText = DialogInsertText

-- Insert text.
-- Вставка текста.
unit.FarInsertText = {

  panels = function (s) return panel.InsertCmdLine(nil, s) end,
  editor = function (s) return editor.InsertText(nil, s) end,
  viewer = function (s) return true end,
  dialog = function (s) return DialogInsertText(nil, s) end,

} --- FarInsertText

-- Insert text in specified FAR area.
-- Вставка текста в заданной области.
function unit.InsertText (Area, Text) --> (bool | number)

  local Insert = unit.FarInsertText[Area or unit.GetAreaType()] or
                 function () end -- заглушка

  return Insert(Text)

end ---- InsertText

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
