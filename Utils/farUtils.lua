--[[ LuaFAR utils ]]--

----------------------------------------
--[[ description:
  -- Additional LuaFAR functions.
  -- Дополнительные LuaFAR-функции.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local far = far
local F = far.Flags

local farAdvControl = far.AdvControl
local EditorGetInfo = editor.GetInfo
local ViewerGetInfo = viewer.GetInfo
local PanelsGetInfo = panel.GetPanelInfo

----------------------------------------
--local context = context

local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'

local isFlag = utils.isFlag

local b2n, max2 = numbers.b2n, numbers.max2

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.luaUtils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- FAR API
-- Version of FAR.
-- Версия of FAR.
local function Version (kind) --> (string | vary)
  return far.AdvControl(F.ACTL_GETFARVERSION, kind)
end --

unit.FarVersion = { -- Version info:
  FAR = { Version(true) },                -- Table of version as numbers
  VerFAR = Version():match("^%d+%.%d+"),  -- String of version without build
  LuaFAR = { far.LuafarVersion(true) },   -- Table of version as numbers
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
end ----

-- Show specified help topic.
-- Показ заданной темы помощи.
function unit.ShowHelpTopic (HelpTopic, Flags) --> (bool)
  if not HelpTopic then return nil end
  Flags = Flags or { FHELP_USECONTENTS = 1, FHELP_NOSHOWERROR = 1 }
  local File, Topic = HelpTopic:match("%<([^%>]*)%>(.*)$")
  if not File then
    File, Topic = utils.PluginPath, HelpTopic
  end
  --far.Message(File, Topic)
  return far.ShowHelp(File, Topic, Flags)
end ---- ShowHelpTopic

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
  return farAdvControl(F.ACTL_GETWINDOWINFO, pos or -1)
end ----

-- Switch to specified FAR window.
-- Переключение на конкретное окно FAR.
function unit.SetCurrentWindow (pos) --> (bool)
  local isOk = farAdvControl(F.ACTL_SETCURRENTWINDOW, pos or 0)
  if isOk then return farAdvControl(F.ACTL_COMMIT) end
end ----

-- Switch to FAR panels window.
-- Переключение на окно панелей FAR.
function unit.SwitchToPanels (CmdLine) --> (bool | nil, error)
  if not panel.CheckPanelsExist() then
    return nil, "No panels window"
  end

  local Info = farAdvControl(F.ACTL_GETWINDOWINFO, -1)
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
function unit.urequire (modname)
  return unit.usercall(nil, require, modname)
end

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
  pos (n|nil) - area number: @default = (nil | -1) - current area.
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
function unit.GetBasicAreaType (pos)
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
    return { Width  = APInfo.right - APInfo.left + 1 +
                      PPInfo.right - PPInfo.left + 1,
             Height = max2(APInfo.bottom - APInfo.top + 1,
                           PPInfo.bottom - PPInfo.top + 1) }
  end, -- panels
  editor = function () -- Редактор:
    local Info = EditorGetInfo(nil)
    return { Width = Info.WindowSizeX, Height = Info.WindowSizeY }
  end, -- editor
  viewer = function () -- Просмотр:
    local Info = ViewerGetInfo(nil)
    return { Width = Info.WindowSizeX, Height = Info.WindowSizeY }
  end, -- viewer
} ---

-- Size of current FAR area.
-- Размер текущей области FAR.
function unit.GetAreaSize (Type, pos) --> (table | nil)
  local Type = Type or unit.GetAreaType(pos) or ""
  if unit.FarGetAreaSize[Type] then
    return unit.FarGetAreaSize[Type]()
  end
end ----

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
} ---

-- Name of current item in FAR area.
-- Имя текущего элемента в области FAR.
function unit.GetAreaItemName (Type, pos) --> (string | nil)
  local Type = Type or unit.GetAreaType(pos) or ""
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
  --TODO: Add function for dialog area
} --- FarIsSelection
unit.FarIsSelection = FarIsSelection

-- Check selection in specified FAR area.
-- Проверка выделения в заданной области.
function unit.IsSelection (Area) --> (bool)
  if FarIsSelection[Area] then
    return FarIsSelection[Area]()
  end
end ----

---------------------------------------- Editor
local farEditor = {
  GetSelection = editor.GetSelection,
  SetSelection = false,
  DelSelection = editor.DeleteBlock,

  GetSelectionType = unit.EditorSelType,

  CopyStreamSelection = false,
  CopyColumnSelection = false,
  CopySelection = false,

  DeleteSelection = false,
  CutSelection = false,

  PasteStreamSelection = false,
  PasteColumnSelection = false,
  PasteSelection = false,
} ---
unit.editor = farEditor

---------------------------------------- -- Selection
-- Select block in editor.
-- Выделение блока в редакторе.
function farEditor.SetSelection (id, Info) --> (boolean)
  local Info = Info
  local SelInfo = {
    BlockType = Info.BlockType,
    BlockStartLine = Info.StartLine,
    BlockStartPos  = Info.StartPos,
    BlockHeight = Info.EndLine - Info.StartLine + 1,
    -- TODO: Учесть Info.EndPos < 0 - нужно учесть и выделить следующую строку.
    BlockWidth  = Info.EndPos  - Info.StartPos  + 1,
  } ---

  if Info.EndPos < 0 then
    SelInfo.BlockHeight = SelInfo.BlockHeight + 1
    SelInfo.BlockWidth  = -Info.StartPos
  end

  --[[if Info.StartPos == Info.EndPos then
    SelInfo.BlockStartPos = SelInfo.BlockStartPos +
                            (Info.EndLine > Info.StartLine and 1 or -1)
  end]]--

  return editor.Select(id, SelInfo)
end -- SetSelection

do
  local tconcat = table.concat

  local farEdit = {
    GetInfo  = editor.GetInfo,
    GetStr   = editor.GetString,
    SetPos   = editor.SetPosition,
    InsText  = editor.InsertText,
  } ---

-- Copy selected stream block.
-- Копирование выделенного строкового блока.
--[[
  -- @params:
  Info (nil|table) - info about editor state.
--]]
function farEditor.CopyStreamSelection (Info) --> (nil|string|table)
  local Info = Info or farEdit.GetInfo()
  if Info.BlockType == BlockTypes.None then return end

  local id = Info.EditorID
  local SelInfo = farEditor.GetSelection(id) -- Нет блока:
  if SelInfo == nil then return end

  --logShow(SelInfo, "SelInfo")

  local first, last = SelInfo.StartLine, SelInfo.EndLine
  if first == last then
    -- Одна выделенная cтрока
    local LineInfo = farEdit.GetStr(id, first, 0)
    if LineInfo == nil then return end -- Нет строки
    --logShow(LineInfo, "LineInfo")
    local s = LineInfo.StringText
    if s == nil then return end
    if LineInfo.SelEnd < 0 then
      return s:sub(LineInfo.SelStart + 1, -1).."\r"
    end

    return s:sub(LineInfo.SelStart + 1, LineInfo.SelEnd)
  end

  -- Несколько выделенных cтрок
  local s = farEdit.GetStr(id, first, 2) or ""
  local t = {
    s:sub(SelInfo.StartPos + 1, -1), -- first
  } ---

  for line = first + 1, last - 1 do
    t[#t+1] = farEdit.GetStr(id, line, 2) or "" -- inners
  end

  local LineInfo = farEdit.GetStr(id, last, 1)
  local s = LineInfo.StringText
  if s ~= nil then
    if LineInfo.SelEnd < 0 then
      t[#t+1] = s:sub(1, -1) -- last
      t[#t+1] = "" -- with last EOL
    else
      t[#t+1] = s:sub(1, SelInfo.EndPos) -- last
    end
  end

  farEdit.SetPos(id, Info)

  --logShow(tconcat(t, "\r"), "CopySelection")

  return t
end ---- CopyStreamSelection

  local spaces = strings.spaces -- to add spaces after end

-- TODO: Проверить, возможен ли EndPos == -1 при вертикальном выделении!!!

-- Copy selected column block.
-- Копирование выделенного вертикального блока.
--[[
  -- @params:
  Info (nil|table) - info about editor state.
--]]
function farEditor.CopyColumnSelection (Info) --> (nil|string|table)
  local Info = Info or farEdit.GetInfo()
  if Info.BlockType == BlockTypes.None then return end

  local id = Info.EditorID
  local SelInfo = farEditor.GetSelection(id) -- Нет блока:
  if SelInfo == nil then return end

  --logShow(SelInfo, "SelInfo")

  local first, last = SelInfo.StartLine, SelInfo.EndLine
  if first == last then
    -- Одна выделенная cтрока
    local LineInfo = farEdit.GetStr(id, first, 0)
    if LineInfo == nil then return end -- Нет строки
    --logShow(LineInfo, "LineInfo")
    local s = LineInfo.StringText
    if s == nil then return end
    --[[
    if LineInfo.SelEnd < 0 then
      return s:sub(LineInfo.SelStart + 1, -1)
    end
    --]]

    return s:sub(LineInfo.SelStart + 1, LineInfo.SelEnd)..
           spaces[LineInfo.SelEnd - s:len() + 1]
  end

  -- Несколько выделенных cтрок
  local s = farEdit.GetStr(id, first, 2) or ""
  local t = {}
  for line = first, last do
    local s = farEdit.GetStr(id, line, 2) or ""
    t[#t+1] = s:sub(SelInfo.StartPos + 1, SelInfo.EndPos)..
              spaces[SelInfo.EndPos - s:len() + 1]
  end

  farEdit.SetPos(id, Info)

  --logShow(tconcat(t, "\r"), "CopySelection")

  return t
end ---- CopyColumnSelection

-- Copy selected block.
-- Копирование выделенного блока.
--[[
  -- @params:
  Info  (nil|table) - info about editor state.
  Type (nil|string) - block type for action:
                      @default = nil - as in Info,
                      "stream" - as stream block,
                      "column" - as column block.
--]]
function farEditor.CopySelection (Info, Type) --> (nil|string|table, flag)
  local Info = Info or farEdit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]
  if SelType == "none" then return end

  local Type = Type or SelType

  if     Type == "stream" then
    return farEditor.CopyStreamSelection(Info)
  elseif Type == "column" then
    return farEditor.CopyColumnSelection(Info)
  end
end ---- CopySelection

-- Delete selected block.
-- Удаление выделенного блока.
--[[
  -- @params: @see farEditor.CopySelection.
--]]
function farEditor.DeleteSelection (Info, Type) --> (bool)
  local Info = Info or farEdit.GetInfo()
  if Info.BlockType == BlockTypes.None then return end

  local id = Info.EditorID
  local SelInfo = farEditor.GetSelection(id) -- Нет блока:
  if SelInfo == nil then return end

  local SelType = BlockTypes[SelInfo.BlockType]
  local Type = Type or SelType

  if Type ~= SelType then
    if     Type == "stream" then
      -- Convert block to stream type
      SelInfo.BlockType = BlockTypes.Stream
    elseif Type == "column" then
      -- Convert block to column type
      SelInfo.BlockType = BlockTypes.Column
    end

    farEditor.SetSelection(id, SelInfo)
  end

  return farEditor.DelSelection(id)
end ---- DeleteSelection

-- Cut selected block.
-- Вырезание выделенного блока.
--[[
  -- @params: @see farEditor.CopySelection.
--]]
function farEditor.CutSelection (Info, Type) --> (nil|string|table)
  local Info = Info or farEdit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]
  if SelType == "none" then return end

  local Type = Type or SelType

  local s = farEditor.CopySelection(Info, Type)

  farEditor.DeleteSelection(Info, Type)

  return s
end ---- CutSelection

-- Paste stream block.
-- Вставка строкового блока.
--[[
  -- @params:
  Info     (nil|table) - info about editor state.
  block (string|table) - string block to insert.
--]]
function farEditor.PasteStreamSelection (Info, block) --> (bool)

  if (block or "") == "" then return end

  local Info = Info or farEdit.GetInfo()

  if type(block) == 'table' then block = tconcat(block, "\r") end

  --logShow(text, "PasteSelection")
  return farEdit.InsText(Info.EditorID, block)
end ---- PasteStreamSelection

-- Paste column block.
-- Вставка вертикального блока.
--[[
  -- @params:
  Info     (nil|table) - info about editor state.
  block (string|table) - string block to insert.
--]]
function farEditor.PasteColumnSelection (Info, block) --> (bool)

  if (block or "") == "" then return end

  local Info = Info or farEdit.GetInfo()
  local id = Info.EditorID

  if type(block) == 'string' then
    if not farEdit.InsText(id, block) then return end
    return farEdit.SetPos(id, Info)
  end

  local Pos = {
    CurPos  = Info.CurPos,
    CurLine = Info.CurLine
  } ---
  for k = 1, #block do
    if not farEdit.InsText(id, block[k]) then return end
    Pos.CurLine = Pos.CurLine + 1
    if not farEdit.SetPos(id, Pos) then return end
  end

  --logShow(text, "PasteSelection")
  return farEdit.SetPos(id, Info)
end ---- PasteColumnSelection

-- Paste block.
-- Вставка блока.
--[[
  -- @params:
  Info     (nil|table) - @see farEditor.CopySelection.
  block (string|table) - string block to insert.
  Type    (nil|string) - @see farEditor.CopySelection.
--]]
function farEditor.PasteSelection (Info, block, Type) --> (bool)

  if (block or "") == "" then return end

  local Info = Info or farEdit.GetInfo()

  --logShow(text, "PasteSelection")

  if     Type == "stream" then
    return farEditor.PasteStreamSelection(Info, block)
  elseif Type == "column" then
    return farEditor.PasteColumnSelection(Info, block)
  end
end ---- PasteSelection

end -- do
do
  local EditorGetStr = editor.GetString

-- Iterator of lines for selected block in editor.
-- Итератор строк выделенного блока в редакторе.
-- (maxfl's implementation: block_iterator.lua.)
--[[
  -- @params:
  count (number) - count of viewed lines.
  line  (number) - number of current used line.
--]]
function unit.nextEditorSelect (count, line) --> (number, table)
  if not count then return nil, nil end

  if count >= 0 then
    local line = (line or -1) + 1
    if line < count then
      local s = EditorGetStr(nil, line, 1)
      if s.SelEnd ~= 0 then return line, s end
    end

  elseif line >= 0 then
    return -1, EditorGetStr(nil, line, 1)
  end
end ---- nextEditorSelect

  local nextEditorSelect = unit.nextEditorSelect

function unit.pairsEditorSelect (line) --> (iterator, count, line)
  local Info = EditorGetInfo()

  if line then
    return nextEditorSelect, -1, line == -1 and Info.CurLine
  end
  if Info.BlockType ~= BlockTypes.None then
    return nextEditorSelect, Info.TotalLines, Info.BlockStartLine - 1
  end

  return nextEditorSelect, nil, nil
end ---- pairsEditorSelect

end -- do

---------------------------------------- Text
-- TODO: Попробовать на основе regex.
-- Parse text string with hot character.
-- Разбор строки текста с "горячей" буквой.
function unit.ParseHotText (Str, Hot, isPos) --> (Left, Char, Right)
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
    Len = b2n( Str:sub(Pos+1, Pos+1) == Hot )
    if isPos then return 1, Pos, Pos+1+Len end
    return Str:sub(1, Pos-2), Str:sub(Pos, Pos),
           Str:sub(Pos+1+Len):gsub(Hot..Hot, Hot)
  else
    if isPos then return 0, 0, 1 end
    return nil, nil, Str:gsub(Hot..Hot, Hot)
  end
end ---- ParseHotText

-- Get text without hot character.
-- Получение текста без "горячей" буквы.
function unit.ClearHotText (Str, Hot) --> (string)
  local Left, Char, Right = unit.ParseHotText(Str, Hot)
  return (Left or "")..(Char or '')..(Right or "")
end ---- ClearHotText

---------------------------------------- I/O
do
  local far_Text = far.Text

-- Horizontal output of text.
-- Вывод текста горизонтально.
function unit.HText (X, Y, Color, Str)
  return far_Text(X, Y, Color, Str)
end ----

-- Vertical output of text.
-- Вывод текста вертикально.
function unit.VText (X, Y, Color, Str)
  local Y = Y
  for k = 1, #Str do
    far_Text(X, Y, Color, Str:sub(k, k))
    Y = Y + 1
  end
end ----

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
function unit.DialogInsertText (hDlg, s)
  local id = SendDlgMessage(hDlg, F.DM_GETFOCUS)
  if DlgEditItems( far.GetDlgItem(hDlg, id)[1] ) then -- DlgItem.Type!
    return SendDlgMessage(hDlg, F.DM_SETTEXT, id, s) -- TODO: Check for boolean!
  end
end ----

-- Insert text.
-- Вставка текста.
unit.FarInsertText = {
  panels = function (s, args) return panel.InsertCmdLine(nil, s) end,
  editor = function (s, args) return editor.InsertText(nil, s) end,
  dialog = function (s, args) return unit.DialogInsertText(args.hDlg, s) end,
} --- FarInsertText

-- Insert text in specified FAR area.
-- Вставка текста в заданной области.
function unit.InsertText (Area, ...) --> (bool | number)
  if unit.FarInsertText[Area] then
    return unit.FarInsertText[Area](...)
  end
end ----

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
