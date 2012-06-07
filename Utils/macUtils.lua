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
  "left", "right", "up", "down",
  "home", "end",
  "return", "indret",
  "enter", "indenter",
  -- bsln must be before bs!
  "del", "bsln", "bs",
  "here", "back",
  "stop", "resume",
  "nop",
} ---
local MacroKeyNames = { -- Названия действий:
  ["return"] = "enter",
  indret = "indenter",
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
  SetPos   = editor.SetPosition,
  GetStr   = editor.GetString,
  InsText  = editor.InsertText,
  InsStr   = editor.InsertString,
  DelChar  = editor.DeleteChar,
  UndoRedo = editor.UndoRedo,
  Redraw   = editor.Redraw,
} ---

-- Получение длины текущей строки.
function farEdit.GetCurStrLen ()
  return (farEdit.GetStr(nil, -1, 2) or ""):len()
end ----

---------------------------------------- Plain actions

local function BackChar (Info) -- Удаление символа слева
  if Info.CurPos == 0 then return true end
  if not farEdit.SetPos(nil, { CurPos = Info.CurPos - 1 }) then return end

  return farEdit.DelChar()
end --

local EditorPlainActions = { -- Функции выполнения простых действий:
  text = function (Info, text) return farEdit.InsText(nil, text) end,
  line = function (Info, indent) return farEdit.InsStr(nil, indent) end,

  left  = function (Info)
    return farEdit.SetPos(nil, { CurPos = max2(Info.CurPos - 1, 0) })
  end, --- left
  right = function (Info)
    return farEdit.SetPos(nil, { CurPos = Info.CurPos + 1 })
  end, --- right
  up    = function (Info)
    return farEdit.SetPos(nil, { CurLine = max2(Info.CurLine - 1, 0) })
  end, --- up
  down  = function (Info)
    return farEdit.SetPos(nil, { CurLine = Info.CurLine + 1 })
  end, --- down

  home    = function (Info)
    return farEdit.SetPos(nil, { CurPos = 0 })
  end, --- home
  ["end"] = function (Info)
    return farEdit.SetPos(nil, { CurPos = farEdit.GetCurStrLen() })
  end, --- end

  del  = function (Info) return farEdit.DelChar() end, -- del
  bs   = BackChar, -- bs
  bsln = function (Info)
    if Info.CurPos > 0 then
      if not farEdit.SetPos(nil, { CurPos = Info.CurPos - 1 }) then return end
    else
      if not farEdit.SetPos(nil, { CurLine = Info.CurLine - 1 }) then return end
      if not farEdit.SetPos(nil, { CurPos = farEdit.GetCurStrLen() }) then return end
    end
    return farEdit.DelChar()
  end, --- bsln

  enter    = function (Info) return farEdit.InsStr(nil, false) end, -- simple enter
  indenter = function (Info) return farEdit.InsStr(nil, true)  end, -- indent enter
} --- EditorPlainActions
MacroActions.editor.plain = EditorPlainActions

---------------------------------------- Cycle actions

local function InsText (Info, Count, text) -- Вставка текста
  if Count > 1 then text = text:rep(Count) end
  return farEdit.InsText(nil, text)
end --

local function NewLine (Info, Count, indent) -- Новая строка
  for _ = 1, Count do
    if not farEdit.InsStr(nil, indent) then return end
  end
  return true
end --

local function DelText (Info, Count) -- Удаление текста
  for _ = 1, Count do
    if not farEdit.DelChar() then return end
  end
  return true
end --

local function BackText (Info, Count) -- Удаление текста слева
  local Info = Info or farEdit.GetInfo()
  local Count = min2(Count, Info.CurPos)
  if not farEdit.SetPos(nil, { CurPos = Info.CurPos - Count }) then return end
  return DelText(Info, Count)
end --

local function BackLine (Info, Count) -- Удаление текста слева
  local Info = Info or farEdit.GetInfo() -- с учётом перехода строку выше
  for _ = 1, Count do
    if Info.CurPos > 0 then
      if not farEdit.SetPos(nil, { CurPos = Info.CurPos - 1 }) then return end
    else
      if not farEdit.SetPos(nil, { CurLine = Info.CurLine - 1 }) then return end
      if not farEdit.SetPos(nil, { CurPos = farEdit.GetCurStrLen() }) then return end
    end

    Info = farEdit.GetInfo()
  end -- for
  return DelText(Info, Count)
end --

local EditorCycleActions = {
  text = InsText, -- text
  line = NewLine, -- line

  left  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(nil, { CurPos = max2(Info.CurPos - Count, 0) })
  end,
  right = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(nil, { CurPos = Info.CurPos + Count })
  end,
  up    = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(nil, { CurLine = max2(Info.CurLine - Count, 0) })
  end,
  down  = function (Info, Count)
    local Info = Info or farEdit.GetInfo()
    return farEdit.SetPos(nil, { CurLine = Info.CurLine + Count })
  end,

  home    = EditorPlainActions.home,
  ["end"] = EditorPlainActions["end"],

  del  = DelText,  -- del
  bs   = BackText, -- bs
  bsln = BackLine, -- bsln

  enter    = function (Info, Count) return NewLine(Info, Count, false) end,
  indenter = function (Info, Count) return NewLine(Info, Count, true)  end,
} --- EditorCycleActions
MacroActions.editor.cycle = EditorCycleActions

---------------------------------------- Macro actions
local CEditorMacroActions = {

  text = function (self, Info, Count, text) -- Вставка текста
    if not InsText(Info, Count, text) then return end
    if self.MoveStop then
      return farEdit.SetPos(nil, {
             CurLine = Info.CurLine, CurPos = Info.CurPos,
             TopScreenLine = Info.TopScreenLine, LeftPos = Info.LeftPos })
    end
    return true
  end, --- text
  line = function (self, Info, Count, indent) -- Вставка строки
    if not NewLine(Info, Count, indent) then return end
    if self.MoveStop then
      return farEdit.SetPos(nil, {
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
      return farEdit.SetPos(nil, {
             CurLine = Info.CurLine, CurPos = Info.CurPos })
    end
    return true
  end, --- bs
  bsln = function (self, Info, Count)
    if not BackLine(Info, Count) then return end
    if self.MoveStop then
      return farEdit.SetPos(nil, {
             CurLine = Info.CurLine, CurPos = Info.CurPos })
    end
    return true
  end, --- bsln

  here = function (self, Info, Count)
    self.Save = farEdit.GetInfo()
    return self.Save ~= nil
  end,
  back = function (self, Info, Count)
    if not self.Save then return end
    local Here = self.Save; self.Save = nil
    return farEdit.SetPos(nil, {
           CurLine  = Here.CurLine,  CurPos = Here.CurPos,
           OverType = Here.OverType, --CurTabPos = Here.CurTabPos,
           TopScreenLine = Here.TopScreenLine, LeftPos = Here.LeftPos })
  end,

  stop   = function (self, Info, Count) self.MoveStop = true;  return true end,
  resume = function (self, Info, Count) self.MoveStop = false; return true end,

  enter    = function (self, Info, Count)
    return self:line(Info, Count, false)
  end, --- enter
  indenter = function (self, Info, Count)
    return self:line(Info, Count, true)
  end, --- indenter
  nop = function (self, Info, Count) return true end,
} ---
local MEditorMacroActions = { __index = CEditorMacroActions }

local function EditorMacroActions (Data) --> (table)
  local Data = Data or Null -- No change!

  local self = {
    Data = Data,
    Save = Data.Save, --or nil -- Информация о редакторе для Here и Back
    MoveStop = Data.MoveStop or false, -- Двигаемость курсора для Stop и Resume

    Selections = {}, -- Список блоков текста
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
local function MakeTemplate (Text, MacroKeyChar) --> (table)
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
        if MacroKeyNames[key] then
          t[#t].Action = MacroKeyNames[key]
        end
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
end -- MakeTemplate

-- Выполнение действий макроса-шаблона.
local function Exec (Macro) --> (bool | nil, Action)
  local Actions = EditorMacroActions() -- Действия
  local InsText = Actions.text -- Вставка текста

  -- Цикл по действиям
  for _, v in ipairs(Macro) do
    local Info, isOk = farEdit.GetInfo()
    local Action, Value = v.Action, v.Value or 1
    --farEdit.Redraw(); logShow(v, _..": # = "..Value)

    -- Выполнение действия макроса:
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
end -- Exec

-- Выполнение разобранного макроса-шаблона.
local function ExecTemplate (Macro) --> (bool | nil, Action)

  if not farEdit.UndoRedo(nil, F.EUR_BEGIN) then
    return nil, "Begin UndoRedo"
  end

  local isOk, Action = Exec(Macro)

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
end -- ExecTemplate

-- Выполнение макроса (с разбором)
function unit.RunMacro (Macro) --> (bool)
  local t = MakeTemplate(Macro)
  --logShow(t, Item.Macro)

  return ExecTemplate(t)
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

  Make      = MakeTemplate,
  Exec      = Exec,
  Execute   = ExecTemplate,
  Macro     = unit.RunMacro,
} ---

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
