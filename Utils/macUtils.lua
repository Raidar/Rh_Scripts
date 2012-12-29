--[[ Macro-templates ]]--

----------------------------------------
--[[ description:
  -- Working with macro-templates.
  -- Работа с макросами-шаблонами.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- used in: Rh Editor.
  -- group: Macros, Utils.
--]]
----------------------------------------
--[[ based on:
  truemac plugin.
  (true macro processor.)
  (c) 2000, raVen.
  Home: http://raven.elk.ru/
--]]
--------------------------------------------------------------------------------

--local type, assert = type, assert
local ipairs = ipairs
local tonumber = tonumber
local setmetatable = setmetatable

----------------------------------------
local far, editor = far, editor
local F = far.Flags

----------------------------------------
--local context = context

local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'

local Null = tables.Null

local min2, max2 = numbers.min2, numbers.max2

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.luaUtils"
local farUt = require "Rh_Scripts.Utils.farUtils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Macro-keys
local DefMacroKeyChar = '@' -- Masyamba

--local MacroKeyLen = 12
local MacroKeys = { -- Макро-ключи:
                        -- перемещение курсора
  "left", "right", "up", "down", "home", "end",
  --"return", "indret",
  "enter", "indenter",  -- новая строка
  -- bsln must be before bs!
  "del", "bsln", "bs",  -- удаление текста
  "here", "back",       -- управление закладками
  "stop", "resume",     -- управление перемещением
  "cut", "paste",       -- работа с выделенным блоком
  "nop",                -- нет операции
} ---
local MacroValues = "1234567890" -- Цифры повторения макро-ключей

local MacroActions = {
  editor = {}, -- Редактор
  panels = {}, -- Панели
  use = false, -- Локальные функции
  run = false, -- Основные функции
} ---
unit.MacroActions = MacroActions

---------------------------------------- Macro actions in editor
local farEdit = {
  GetInfo  = editor.GetInfo,
  GetStr   = editor.GetString,
  SetPos   = editor.SetPosition,
  GetSel   = editor.GetSelection,
  SetSel   = farUt.EditorSetSelection,
  DelSel   = editor.DeleteBlock,
  InsText  = editor.InsertText,
  InsStr   = editor.InsertString,
  DelChar  = editor.DeleteChar,
  UndoRedo = editor.UndoRedo,
  Redraw   = editor.Redraw,
} ---

-- Получение длины текущей строки.
function farEdit.GetCurStrLen (Info)
  return (farEdit.GetStr(Info.EditorID, -1, 2) or ""):len()
end ----

---------------------------------------- Plain actions

-- Удаление символа слева.
local function BackChar (Info)
  if Info.CurPos == 0 then
    return true
  end
  if not farEdit.SetPos(Info.EditorID, { CurPos = Info.CurPos - 1 }) then
    return
  end

  return farEdit.DelChar(Info.EditorID)
end -- BackChar

local EditorPlainActions = { -- Функции выполнения простых действий:
  text = function (Info, text)
    return farEdit.InsText(Info.EditorID, text)
  end,
  line = function (Info, indent)
    return farEdit.InsStr(Info.EditorID, indent)
  end,

  left  = function (Info)
    return farEdit.SetPos(Info.EditorID,
                          { CurPos = max2(Info.CurPos - 1, 0) })
  end, --- left
  right = function (Info)
    return farEdit.SetPos(Info.EditorID,
                          { CurPos = Info.CurPos + 1 })
  end, --- right
  up    = function (Info)
    return farEdit.SetPos(Info.EditorID,
                          { CurLine = max2(Info.CurLine - 1, 0) })
  end, --- up
  down  = function (Info)
    return farEdit.SetPos(Info.EditorID,
                          { CurLine = Info.CurLine + 1 })
  end, --- down

  home    = function (Info)
    return farEdit.SetPos(Info.EditorID,
                          { CurPos = 0 })
  end, --- home
  ["end"] = function (Info)
    return farEdit.SetPos(Info.EditorID,
                          { CurPos = farEdit.GetCurStrLen() })
  end, --- end

  del  = function (Info)
    return farEdit.DelChar(Info.EditorID)
  end, -- del
  bs   = BackChar, -- bs
  bsln = function (Info)
    if Info.CurPos > 0 then
      if not farEdit.SetPos(Info.EditorID,
                            { CurPos = Info.CurPos - 1 }) then
        return
      end
    else
      if not farEdit.SetPos(Info.EditorID,
                            { CurLine = Info.CurLine - 1 }) then
        return
      end
      if not farEdit.SetPos(Info.EditorID,
                            { CurPos = farEdit.GetCurStrLen(Info) }) then
        return
      end
    end

    return farEdit.DelChar(Info.EditorID)
  end, --- bsln

  enter    = function (Info)
    return farEdit.InsStr(Info.EditorID, false) -- simple enter
  end,
  indenter = function (Info)
    return farEdit.InsStr(Info.EditorID, true) -- indent enter
  end,
  nop = function (Info) return true end,

  --[[
  cut = function (self, Info, Index)
    return true
  end, --- copy
  paste = function (self, Info, Index)
    return true
  end, --- paste
  ]]--
} --- EditorPlainActions
MacroActions.editor.plain = EditorPlainActions

---------------------------------------- Cycle actions

-- Вставка текста.
local function InsText (Info, Count, text)
  local Info = Info or farEdit.GetInfo()
  if Count > 1 then
    text = text:rep(Count)
  end

  return farEdit.InsText(Info.EditorID, text)
end -- InsText

-- Вставка новой строки (построчно).
local function NewLine (Info, Count, indent)
  local Info = Info or farEdit.GetInfo()
  for _ = 1, Count do
    if not farEdit.InsStr(Info.EditorID, indent) then return end
  end

  return true
end -- NewLine

-- Удаление текста справа (посимвольно).
local function DelText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  for _ = 1, Count do
    if not farEdit.DelChar(Info.EditorID) then
      return
    end
  end

  return true
end -- DelText

-- Удаление текста слева (до начала строки).
local function BackText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local Count = min2(Count, Info.CurPos)
  if not farEdit.SetPos(Info.EditorID,
                        { CurPos = Info.CurPos - Count }) then
    return
  end

  return DelText(Info, Count)
end -- BackText

-- Удаление текста слева с учётом перехода строку выше.
local function BackLine (Info, Count)
  local Info = Info or farEdit.GetInfo()
  for _ = 1, Count do
    if Info.CurPos > 0 then
      if not farEdit.SetPos(Info.EditorID,
                            { CurPos = Info.CurPos - 1 }) then
        return
      end
    else
      if not farEdit.SetPos(Info.EditorID,
                            { CurLine = Info.CurLine - 1 }) then
        return
      end
      if not farEdit.SetPos(Info.EditorID,
                            { CurPos = farEdit.GetCurStrLen(Info) }) then
        return
      end
    end

    Info = farEdit.GetInfo()
  end -- for

  return DelText(Info, Count)
end -- BackLine

local EditorCycleActions = {
  text = InsText, -- text
  line = NewLine, -- line

  left  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID,
                          { CurPos = max2(Info.CurPos - Count, 0) })
  end,
  right = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID,
                          { CurPos = Info.CurPos + Count })
  end,
  up    = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID,
                          { CurLine = max2(Info.CurLine - Count, 0) })
  end,
  down  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID,
                          { CurLine = Info.CurLine + Count })
  end,

  home    = EditorPlainActions.home,
  ["end"] = EditorPlainActions["end"],

  del  = DelText,  -- del
  bs   = BackText, -- bs
  bsln = BackLine, -- bsln

  enter    = function (Info, Count)
    return NewLine(Info, Count, false)
  end,
  indenter = function (Info, Count)
    return NewLine(Info, Count, true)
  end,
  nop = function (Info, Count) return true end,
} --- EditorCycleActions
MacroActions.editor.cycle = EditorCycleActions

---------------------------------------- Macro actions
  local tconcat = table.concat

-- Копирование выделенного текста в строку (от начала блока до конца блока).
local function CopySelText (Info) --> (string)
  local Info = Info or farEdit.GetInfo()
  local SelInfo = farEdit.GetSel(Info.EditorID) -- Нет блока:
  if SelInfo == nil or SelInfo.BlockType == F.BTYPE_NONE then return end

  --logShow(SelInfo, "SelInfo")

  local first, last = SelInfo.StartLine, SelInfo.EndLine
  if first == last then
    -- Одна выделенная
    local LineInfo = farEdit.GetStr(Info.EditorID, first, 0)
    if LineInfo == nil then return end -- Нет строки
    --logShow(LineInfo, "LineInfo")
    local s = LineInfo.StringText
    if s == nil then return end
    if LineInfo.SelEnd < 0 then
      return s:sub(LineInfo.SelStart + 1, -1).."\r"
    end

    return s:sub(LineInfo.SelStart + 1, LineInfo.SelEnd)
  end

  local s = farEdit.GetStr(Info.EditorID, first, 2) or ""
  local t = {
    s:sub(SelInfo.StartPos + 1, -1), -- first
  } ---

  for line = first + 1, last - 1 do
    t[#t+1] = farEdit.GetStr(Info.EditorID, line, 2) or "" -- block
  end

  local LineInfo = farEdit.GetStr(Info.EditorID, last, 1)
  local s = LineInfo.StringText
  if s ~= nil then
    if LineInfo.SelEnd < 0 then
      t[#t+1] = s:sub(1, -1) -- last
      t[#t+1] = "" -- with last EOL
    else
      t[#t+1] = s:sub(1, SelInfo.EndPos) -- last
    end
  end

  farEdit.SetPos(Info.EditorID, Info)

  --logShow(tconcat(t, "\r"), "CopySelText")

  return tconcat(t, "\r")
end -- CopySelText

-- Вырезание выделенного текста в строку (от начала блока до конца блока).
local function CutSelText (Info) --> (string)
  local Info = Info or farEdit.GetInfo()
  local SelInfo = farEdit.GetSel(Info.EditorID) -- Нет блока:
  if SelInfo == nil or SelInfo.BlockType == F.BTYPE_NONE then return end

  local s = CopySelText(Info)

  if SelInfo.BlockType == F.BTYPE_COLUMN then
    SelInfo.BlockType = F.BTYPE_STREAM
    farEdit.SetSel(Info.EditorID, SelInfo)
  end
  farEdit.DelSel(Info.EditorID)

  return s
end -- CutSelText

-- Вставка строки в текст.
local function PasteSelText (Info, text) --> (string)
  local Info = Info or farEdit.GetInfo()

  --logShow(text, "PasteSelText")
  -- TODO: Добавить выделение блока вставленного текста!
  return farEdit.InsText(Info.EditorID, text)
end -- PasteSelText

local TEditorMacroActions = {

  text = function (self, Info, Count, text) -- Вставка текста
    if not InsText(Info, Count, text) then
      return
    end
    if self.MoveStop then
      return farEdit.SetPos(Info.EditorID, {
             CurLine = Info.CurLine, CurPos = Info.CurPos,
             TopScreenLine = Info.TopScreenLine, LeftPos = Info.LeftPos })
    end
    return true
  end, --- text
  line = function (self, Info, Count, indent) -- Вставка строки
    if not NewLine(Info, Count, indent) then return end
    if self.MoveStop then
      return farEdit.SetPos(Info.EditorID, {
             CurLine = Info.CurLine, CurPos = Info.CurPos,
             TopScreenLine = Info.TopScreenLine, LeftPos = Info.LeftPos })
    end
    return true
  end, --- line

  left  = function (self, ...) return EditorCycleActions.left(...)  end,
  right = function (self, ...) return EditorCycleActions.right(...) end,
  up    = function (self, ...) return EditorCycleActions.up(...)    end,
  down  = function (self, ...) return EditorCycleActions.down(...)  end,

  home    = function (self, ...) return EditorPlainActions.home(...) end,
  ["end"] = function (self, ...) return EditorPlainActions["end"](...) end,

  del  = function (self, ...) return EditorCycleActions.del(...) end, -- del
  bs   = function (self, Info, Count)
    if not BackText(Info, Count) then return end
    if self.MoveStop then
      return farEdit.SetPos(Info.EditorID, {
             CurLine = Info.CurLine, CurPos = Info.CurPos })
    end
    return true
  end, --- bs
  bsln = function (self, Info, Count)
    if not BackLine(Info, Count) then return end
    if self.MoveStop then
      return farEdit.SetPos(Info.EditorID, {
             CurLine = Info.CurLine, CurPos = Info.CurPos })
    end
    return true
  end, --- bsln

  here = function (self, Info, Index)
    self.Save[Index] = farEdit.GetInfo()
    return self.Save[Index] ~= nil
  end,
  back = function (self, Info, Index)
    if not self.Save[Index] then return end
    local Here = self.Save[Index]; self.Save[Index] = nil
    return farEdit.SetPos(Info.EditorID, {
           CurLine  = Here.CurLine,  CurPos = Here.CurPos,
           Overtype = Here.Overtype, --CurTabPos = Here.CurTabPos,
           TopScreenLine = Here.TopScreenLine, LeftPos = Here.LeftPos })
  end,

  stop   = function (self, Info, Count)
    self.MoveStop = true
    return true
  end, --- stop
  resume = function (self, Info, Count)
    self.MoveStop = false
    return true
  end, --- resume

  enter    = function (self, Info, Count)
    return self:line(Info, Count, false)
  end, --- enter
  indenter = function (self, Info, Count)
    return self:line(Info, Count, true)
  end, --- indenter
  nop = function (self, Info, Count) return true end,

  cut = function (self, Info, Index)
    self.Clip[Index] = CutSelText(Info) or ""
    return true
  end, --- copy
  paste = function (self, Info, Index)
    PasteSelText(Info, self.Clip[Index] or "")
    return true
  end, --- paste
} ---
local MEditorMacroActions = { __index = TEditorMacroActions }

local function EditorMacroActions (Data) --> (table)
  local Data = Data or Null -- No change!

  local self = {
    Data = Data,
    Save = { -- Информация о редакторе для Here и Back
      Data.Save, -- 1 --
    }, --
    MoveStop = Data.MoveStop or false, -- Передвигаемость курсора для Stop и Resume

    Clip = { -- Внутренний буфер обмена
      Data.Clip or false, -- 1 --
    }, --
  } --- self

  return setmetatable(self, MEditorMacroActions)
end -- EditorMacroActions
MacroActions.editor.macro = EditorMacroActions

---------------------------------------- Run

-- Проверка на макро-ключ в заданной позиции.
local function CheckMacroPos (Text, Pos) --> (string | nil)
  --assert(Text and Pos)
  local s = Text:sub(Pos, -1):lower()
  for _, v in ipairs(MacroKeys) do
    if (s:find(v, 1, true) or 0) == 1 then return v end
  end
end -- CheckMacroPos

-- Проверка на повторение макро-ключа в заданной позиции.
local function CheckMacroRep (Text, Pos) --> (string | nil)
  --assert(Text and Pos)
  local k, s = 1, Text:sub(Pos)
  while k <= s:len() do
    local c = s:sub(k, k)
    if not MacroValues:find(c, 1, true) then break end
    k = k + 1
  end
  if k > 1 then return s:sub(1, k - 1) end
end -- CheckMacroRep

-- Разбор макроса-шаблона.
local function Make (Text, MacroKeyChar) --> (table)
  --assert(Text)
  local MacroKeyChar = MacroKeyChar or DefMacroKeyChar

  local t = {}
  local k, Len = 1, Text:len()
  local s = "" -- Обычный текст

  while k <= Len do -- Цикл по макросу-шаблону
    local p = Text:cfind(MacroKeyChar, k, true)
    s = Text:sub(k, (p or 0) - 1) -- Plain text
    if not p or p == Len then break end
    --logShow(Text..'\n'..s, ("%d from %d"):format(k, Len))

    k = p + 1
    if Text:sub(k, k) == MacroKeyChar then
      s = s..MacroKeyChar -- MacroKeyChar as simple char

    else -- Action key:
      local key = CheckMacroPos(Text, k)
      if s ~= "" then
        t[#t+1], s = { Action = "text", Text = s }, ""
      end

      if key then
        t[#t+1] = { Action = key }
        k = k + key:len() - 1

      else -- Action value:
        local value = CheckMacroRep(Text, k)
        if value then
          t[#t].Value = tonumber(value)
          k = k + value:len() - 1
        else
          k = k - 1
        end
      end
    end -- if
    k = k + 1
  end -- while

  if s ~= "" then -- Unsaved rest of text:
    t[#t+1] = { Action = "text", Text = s }
  end
  --logShow(t, Text)

  return t
end -- Make

-- Выполнение действий макроса-шаблона.
local function Play (Macro) --> (bool | nil, Action)
  local Actions = EditorMacroActions() -- Действия
  local InsText = Actions.text -- Вставка текста

  -- Цикл по действиям
  for _, v in ipairs(Macro) do
    local Info = farEdit.GetInfo()
    local Action, Value = v.Action, v.Value or 1
    --farEdit.Redraw(); logShow(v, _..": # = "..Value)

    -- Выполнение действия макроса:
    local isOk
    if Action == "text" then
      isOk = InsText(Actions, Info, Value, v.Text)
    elseif Actions[Action] then
      --farEdit.Redraw(); logShow(Info, Action..": # = "..Value)
      isOk = Actions[Action](Actions, Info, Value)
      --logShow(Info, Action)
    end
    if not isOk then return nil, Action end
  end

  return true
end -- Play

-- Выполнение разобранного макроса-шаблона.
local function Exec (Macro) --> (bool | nil, Action)

  if not farEdit.UndoRedo(nil, F.EUR_BEGIN) then
    return nil, "Begin UndoRedo"
  end

  local isOk, Action = Play(Macro)

  if not farEdit.UndoRedo(nil, F.EUR_END) then
    return nil, "End UndoRedo"
  end

  if not isOk then
    if not farEdit.UndoRedo(nil, F.EUR_UNDO) then
      return nil, "Undo UndoRedo"
    end
    return nil, Action
  end

  farEdit.Redraw()

  return true
end -- Exec

-- Выполнение макроса (с разбором)
function unit.Execute (Macro) --> (bool)
  local t = Make(Macro)
  --logShow(t, Item.Macro)

  return Exec(t)
end ----

MacroActions.use = {
  BackChar = BackChar,

  InsText = InsText,
  NewLine = NewLine,
  DelText = DelText,

  BackText = BackText,
  BackLine = BackLine,
} ---

MacroActions.run = {
  CheckMacroPos = CheckMacroPos,
  CheckMacroRep = CheckMacroRep,

  Make      = Make,
  Play      = Play,
  Exec      = Exec,
  Macro     = unit.Execute,
} ---

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
