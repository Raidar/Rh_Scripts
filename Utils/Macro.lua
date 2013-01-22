--[[ Macro utils ]]--

----------------------------------------
--[[ description:
  -- Working with macro‑templates.
  -- Работа с макросами‑шаблонами.
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

local math = math
local min, max = math.min, math.max

----------------------------------------
local far, editor = far, editor
local F = far.Flags

----------------------------------------
--local context = context

local tables = require 'context.utils.useTables'
--local numbers = require 'context.utils.useNumbers'

local Null = tables.Null

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"
local farEdit = require "Rh_Scripts.Utils.Editor"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {
  Actions = false,
  Execute = false,

  Use = false,
  Run = false,
} --- unit

---------------------------------------- Macro-keys
local DefMacroKeyChar = '@' -- Masyamba

--local MacroKeyLen = 12
local MacroKeys = { -- Макро-ключи:
                        -- перемещение курсора
  "left", "right", "up", "down", "home", "end",
  --"return", "indret",
  "enter", "indenter",  -- новая строка
  -- bsln/deln must be before bs/del!
  "bsln", "bs",         -- удаление текста слева
  "deln", "del",        -- удаление текста справа
  "here", "back",       -- управление закладками
  "stop", "resume",     -- управление перемещением
  "cut", "paste",       -- работа с выделенным блоком
  "nop",                -- нет операции
  --"|",                  -- разделитель параметров
} ---
--local MacroValues = "1234567890" -- Цифры повторения макро-ключей

local MacroActions = {
  editor = {}, -- Редактор
  panels = {}, -- Панели

  use = false, -- Локальные функции
  run = false, -- Основные функции
} ---
unit.Actions = MacroActions

---------------------------------------- Macro actions in editor
local farSelect = farEdit.Selection

---------------------------------------- Plain actions

local EditorPlainActions = { -- Функции выполнения простых действий:
  text = function (Info, text)
    return farEdit.InsText(Info.EditorID, text)
  end,
  line = function (Info, indent)
    return farEdit.InsLine(Info.EditorID, indent)
  end,

  left  = function (Info)
    return farEdit.SetPos(Info.EditorID, -1, max(Info.CurPos - 1, 0))
  end, --- left
  right = function (Info)
    return farEdit.SetPos(Info.EditorID, -1, Info.CurPos + 1)
  end, --- right
  up    = function (Info)
    return farEdit.SetPos(Info.EditorID, max(Info.CurLine - 1, 0))
  end, --- up
  down  = function (Info)
    return farEdit.SetPos(Info.EditorID, Info.CurLine + 1)
  end, --- down

  home    = function (Info)
    return farEdit.LineHome(Info.EditorID, -1)
  end, --- home
  ["end"] = function (Info)
    return farEdit.LineEnd(Info.EditorID, -1)
  end, --- end

  del  = farEdit.DelPos,
  deln = farEdit.DelChar,
  bs   = farEdit.BackPos,
  bsln = farEdit.BackChar,

  enter    = function (Info)
    return farEdit.InsLine(Info.EditorID, false) -- simple enter
  end,
  indenter = function (Info)
    return farEdit.InsLine(Info.EditorID, true) -- indent enter
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
    if not farEdit.InsLine(Info.EditorID, indent) then
      return
    end
  end

  return true
end -- NewLine

-- Удаление текста справа до конца строки (посимвольно).
local function DelLineText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local id = Info.EditorID
  local Len = farEdit.GetLength(id, -1)

  for _ = 1, min(Count, Len - Info.CurPos) do
    if not farEdit.Del(id) then return end
  end

  return true
end -- DelLineText

-- Удаление текста справа с учётом включения строки ниже (посимвольно).
local function DelCharText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local id = Info.EditorID

  for _ = 1, Count do
    if not farEdit.Del(id) then return end
  end

  return true
end -- DelCharText

-- Удаление текста слева (до начала строки).
local function BackLineText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local id = Info.EditorID
  local Len = farEdit.GetLength(id, -1)
  local Count = min(Count, Len, Info.CurPos)
  if not farEdit.SetPos(id, -1, Info.CurPos - Count) then
    return
  end

  return DelCharText(Info, Count)
end -- BackLineText

-- Удаление текста слева с учётом перехода на строку выше.
local function BackCharText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local k = Count
  while k > 0 do
    local CurPos = Info.CurPos
    if CurPos > 0 then
      local NewPos = CurPos - k
      if NewPos >= 0 then
        if not farEdit.SetPos(Info.EditorID, -1, NewPos) then
          return
        end
        k = 0
      else
        if not farEdit.LineEnd(Info.EditorID, Info.CurLine - 1) then
          return
        end
        k = k - CurPos - 1
        Info = farEdit.GetInfo()
      end

    else--if Info.CurLine > 0 then
      if not farEdit.CharLeft(Info) then
        return
      end
      k = k - 1
      Info = farEdit.GetInfo()

    --else
    --  return
    end
  end
  --[[
  for _ = 1, Count do
    if not farEdit.CharLeft(Info) then
      return
    end

    Info = farEdit.GetInfo()
  end -- for
  --]]

  return DelCharText(Info, Count)
end -- BackCharText

local EditorCycleActions = {
  text = InsText, -- text
  line = NewLine, -- line

  left  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, -1, max(Info.CurPos - Count, 0))
  end,
  right = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, -1, Info.CurPos + Count)
  end,
  up    = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, max(Info.CurLine - Count, 0))
  end,
  down  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, Info.CurLine + Count)
  end,

  home    = EditorPlainActions.home,
  ["end"] = EditorPlainActions["end"],

  del  = DelLineText,
  deln = DelCharText,
  bs   = BackLineText,
  bsln = BackCharText,

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
local TEditorMacroActions = {

  text = function (self, Info, Count, text) -- Вставка текста
    if not InsText(Info, Count, text) then
      return
    end
    if self.MoveStop then
      return farEdit.Goto(Info)
    end
    return true
  end, --- text
  line = function (self, Info, Count, indent) -- Вставка строки
    if not NewLine(Info, Count, indent) then return end
    if self.MoveStop then
      return farEdit.Goto(Info)
    end
    return true
  end, --- line

  left  = function (self, ...) return EditorCycleActions.left(...)  end,
  right = function (self, ...) return EditorCycleActions.right(...) end,
  up    = function (self, ...) return EditorCycleActions.up(...)    end,
  down  = function (self, ...) return EditorCycleActions.down(...)  end,

  home    = function (self, ...) return EditorPlainActions.home(...) end,
  ["end"] = function (self, ...) return EditorPlainActions["end"](...) end,

  del  = function (self, ...) return EditorCycleActions.del(...) end,
  deln = function (self, ...) return EditorCycleActions.deln(...) end,
  bs   = function (self, Info, Count)
    if not BackLineText(Info, Count) then return end
    if self.MoveStop then
      return farEdit.SetPos(Info.EditorID, Info.CurLine, Info.CurPos)
    end
    return true
  end, --- bs
  bsln = function (self, Info, Count)
    if not BackCharText(Info, Count) then return end
    if self.MoveStop then
      return farEdit.SetPos(Info.EditorID, Info.CurLine, Info.CurPos)
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
    return farEdit.Goto(Here)
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
    self.Clip[Index] = farSelect.Cut(Info, "stream") or ""
    return true
  end, --- copy
  paste = function (self, Info, Index)
    farSelect.Paste(Info, self.Clip[Index] or "", "stream")
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

-- Check to macro-key in specified position.
-- Проверка на макро-ключ в заданной позиции.
local function CheckMacroPos (Text, Pos) --> (string | nil)
  --assert(Text and Pos)
  local s = Text:sub(Pos, -1):lower()
  for _, v in ipairs(MacroKeys) do
    if (s:find(v, 1, true) or 0) == 1 then return v end
  end
end -- CheckMacroPos

-- Check to repeat of macro-key in specified position.
-- Проверка на повторение макро-ключа в заданной позиции.
local function CheckMacroRep (Text, Pos) --> (string | nil)
  --assert(Text and Pos)
  return Text:sub(Pos, -1):match("^(%d+)")
  --[[
  local k, s = 1, Text:sub(Pos, -1)
  while k <= s:len() do
    local c = s:sub(k, k)
    if not MacroValues:find(c, 1, true) then break end
    k = k + 1
  end
  if k > 1 then return s:sub(1, k - 1) end
  --]]
end -- CheckMacroRep

-- Parse macro-template.
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

-- Execute actions of macro-template.
-- Выполнение действий макроса-шаблона.
local function Play (Macro) --> (bool | nil, Action)
  local Actions = EditorMacroActions() -- Действия
  local InsText = Actions.text -- Вставка текста

  -- Цикл по действиям
  local k, Count = 1, #Macro
  while k <= Count do
    local Info, v = farEdit.GetInfo(), Macro[k]
    local Action, Value = v.Action, v.Value or 1
    --farEdit.Redraw(); logShow(v, _..": # = "..Value)

    -- Выполнение действия макроса:
    local isOk
    if Action == "text" then
      isOk = InsText(Actions, Info, Value, v.Text)
    --[[
    elseif Action == "pair" then
      local p
      --isOk, p = MakePair(Actions, Info, Value, Macro, k)
      if p then k = k + p end
    --]]
    elseif Actions[Action] then
      --farEdit.Redraw(); logShow(Info, Action..": # = "..Value)
      isOk = Actions[Action](Actions, Info, Value)
      --logShow(Info, Action)
    end
    if not isOk then return nil, Action end

    k = k + 1
  end

  return true
end -- Play

-- Execute parsed macro-template.
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

-- Execute Macro (with parsing).
-- Выполнение макроса (с разбором).
function unit.Execute (Macro) --> (bool)
  local t = Make(Macro)
  --logShow(t, Item.Macro)

  return Exec(t)
end ----

unit.Use = {
  InsText = InsText,
  NewLine = NewLine,

  DelLineText = DelLineText,
  DelCharText = DelCharText,
  BackLineText = BackLineText,
  BackCharText = BackCharText,
} ---

unit.Run = {
  CheckPos  = CheckMacroPos,
  CheckRep  = CheckMacroRep,

  Make      = Make,
  Play      = Play,
  Exec      = Exec,
  Macro     = unit.Execute,
} ---

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
