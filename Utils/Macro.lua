--[[ Macro utils ]]--

----------------------------------------
--[[ description:
  -- Working with macro‑templates.
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
--local F = far.Flags

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local tables = require 'context.utils.useTables'
--local numbers = require 'context.utils.useNumbers'

local Null = tables.Null

----------------------------------------
local farEdit = require "Rh_Scripts.Utils.Editor"

--------------------------------------------------------------------------------
local unit = {
  Actions = false,

  Use = false,
  Run = false,

  Execute = false,
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

  --use = false, -- Локальные функции
  --run = false, -- Основные функции
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
    return farEdit.SetPos(Info.EditorID, 0, max(Info.CurPos - 1, 1))
  end, --- left
  right = function (Info)
    return farEdit.SetPos(Info.EditorID, 0, Info.CurPos + 1)
  end, --- right
  up    = function (Info)
    return farEdit.SetPos(Info.EditorID, max(Info.CurLine - 1, 1))
  end, --- up
  down  = function (Info)
    return farEdit.SetPos(Info.EditorID, Info.CurLine + 1)
  end, --- down

  home    = function (Info)
    return farEdit.LineHome(Info.EditorID, 0)
  end, --- home
  ["end"] = function (Info)
    return farEdit.LineEnd(Info.EditorID, 0)
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
local Use = {
  InsText = false,
  NewLine = false,

  DelLineText = false,
  DelCharText = false,
  BackLineText = false,
  BackCharText = false,
} ---
unit.Use = Use

----------------------------------------

-- Вставка текста.
function Use.InsText (Info, Count, text)
  local Info = Info or farEdit.GetInfo()
  if Count > 1 then
    text = text:rep(Count)
  end

  return farEdit.InsText(Info.EditorID, text)
end ---- InsText

-- Вставка новой строки (построчно).
function Use.NewLine (Info, Count, indent)
  local Info = Info or farEdit.GetInfo()
  for _ = 1, Count do
    if not farEdit.InsLine(Info.EditorID, indent) then
      return
    end
  end

  return true
end ---- NewLine

-- Удаление текста справа до конца строки (посимвольно).
function Use.DelLineText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local id = Info.EditorID
  local Len = farEdit.GetLength(id, 0)

  for _ = 1, min(Count, Len - Info.CurPos + 1) do
    if not farEdit.Del(id) then return end
  end

  return true
end ---- DelLineText

-- Удаление текста справа с учётом включения строки ниже (посимвольно).
function Use.DelCharText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local id = Info.EditorID

  for _ = 1, Count do
    if not farEdit.Del(id) then return end
  end

  return true
end ---- DelCharText

-- Удаление текста слева (до начала строки).
function Use.BackLineText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local id = Info.EditorID
  local Len = farEdit.GetLength(id, 0)
  local Count = min(Count, Len, Info.CurPos - 1)
  if not farEdit.SetPos(id, 0, Info.CurPos - Count) then
    return
  end

  return Use.DelCharText(Info, Count)
end ---- BackLineText

-- Удаление текста слева с учётом перехода на строку выше.
function Use.BackCharText (Info, Count)
  local Info = Info or farEdit.GetInfo()
  local k = Count
  while k > 0 do
    local CurPos = Info.CurPos
    if CurPos > 1 then
      local NewPos = CurPos - k
      if NewPos >= 1 then
        if not farEdit.SetPos(Info.EditorID, 0, NewPos) then
          return
        end
        k = 0
      else
        if not farEdit.LineEnd(Info.EditorID, Info.CurLine - 1) then
          return
        end
        k = k - CurPos
        Info = farEdit.GetInfo()
      end

    else--if Info.CurLine > 1 then
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

  return Use.DelCharText(Info, Count)
end ---- BackCharText

local EditorCycleActions = {
  text = Use.InsText,
  line = Use.NewLine,

  left  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, 0, max(Info.CurPos - Count, 1))
  end,
  right = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, 0, Info.CurPos + Count)
  end,
  up    = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, max(Info.CurLine - Count, 1))
  end,
  down  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(Info.EditorID, Info.CurLine + Count)
  end,

  home    = EditorPlainActions.home,
  ["end"] = EditorPlainActions["end"],

  del  = Use.DelLineText,
  deln = Use.DelCharText,
  bs   = Use.BackLineText,
  bsln = Use.BackCharText,

  enter    = function (Info, Count)
    return Use.NewLine(Info, Count, false)
  end,
  indenter = function (Info, Count)
    return Use.NewLine(Info, Count, true)
  end,
  nop = function (Info, Count) return true end,
} --- EditorCycleActions
MacroActions.editor.cycle = EditorCycleActions

---------------------------------------- Macro actions
local TEditorMacroActions = {

  text = function (self, Info, Count, text) -- Вставка текста
    if not Use.InsText(Info, Count, text) then
      return
    end
    if self.MoveStop then
      return farEdit.Goto(Info)
    end
    return true
  end, --- text
  line = function (self, Info, Count, indent) -- Вставка строки
    if not Use.NewLine(Info, Count, indent) then return end
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
    if not Use.BackLineText(Info, Count) then return end
    if self.MoveStop then
      return farEdit.SetPos(Info.EditorID, Info.CurLine, Info.CurPos)
    end
    return true
  end, --- bs
  bsln = function (self, Info, Count)
    if not Use.BackCharText(Info, Count) then return end
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
local Run = {
  CheckPos  = false,
  CheckRep  = false,

  Make      = false,
  Play      = false,
  Exec      = false,
  Macro     = false,
} ---
unit.Run = Run

----------------------------------------
-- Check to macro-key in specified position.
-- Проверка на макро-ключ в заданной позиции.
function Run.CheckMacroPos (Text, Pos) --> (string | nil)
  --assert(Text and Pos)
  local s = Text:sub(Pos, -1):lower()
  for _, v in ipairs(MacroKeys) do
    if (s:find(v, 1, true) or 0) == 1 then return v end
  end
end ---- CheckMacroPos

-- Check to repeat of macro-key in specified position.
-- Проверка на повторение макро-ключа в заданной позиции.
function Run.CheckMacroRep (Text, Pos) --> (string | nil)
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
end ---- CheckMacroRep

-- Parse macro-template.
-- Разбор макроса-шаблона.
function Run.Make (Text, MacroKeyChar) --> (table)
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
      local key = Run.CheckMacroPos(Text, k)
      if s ~= "" then
        t[#t+1], s = { Action = "text", Text = s, }, ""
      end

      if key then
        t[#t+1] = { Action = key }
        k = k + key:len() - 1

      else -- Action value:
        local value = Run.CheckMacroRep(Text, k)
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
    t[#t+1] = { Action = "text", Text = s, }
  end
  --logShow(t, Text)

  return t
end ---- Make

-- Execute actions of macro-template.
-- Выполнение действий макроса-шаблона.
function Run.Play (Macro) --> (bool | nil, Action)
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
      --logShow(v, "InsText")
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
end ---- Play

-- Execute parsed macro-template.
-- Выполнение разобранного макроса-шаблона.
function Run.Exec (Macro) --> (bool | nil, Action)
  return farEdit.Execute(Run.Play, Macro)
end ---- Exec

-- Execute Macro (with parsing).
-- Выполнение макроса (с разбором).
function Run.Macro (Macro) --> (bool)
  local t = Run.Make(Macro)
  --logShow(t, Item.Macro)

  return Run.Exec(t)
end ----

unit.Execute = Run.Macro

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
