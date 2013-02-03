--[[ Editor utils ]]--

----------------------------------------
--[[ description:
  -- Processing text in editor.
  -- Обработка текста в редакторе.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

local tconcat = table.concat

----------------------------------------
local far = far
local F = far.Flags

local editor = editor

----------------------------------------
--local context = context

--local utils = require 'context.utils.useUtils'
--local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'

--local isFlag = utils.isFlag

--local b2n, max2 = numbers.b2n, numbers.max2

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"
--local chrUt = require "Rh_Scripts.Utils.Character"

local BlockTypes = farUt.BlockTypes

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {
-- Default fields:
  GetInfo   = editor.GetInfo,
  GetLine   = editor.GetString,
  SetLine   = editor.SetString,
  GetPos    = editor.GetInfo, -- !!
  SetPos    = editor.SetPosition,
  InsText   = editor.InsertText,
  InsLine   = editor.InsertString,
  Del       = editor.DeleteChar,
  UndoRedo  = editor.UndoRedo,
  Redraw    = editor.Redraw,

-- Custom fields:
  -- Action
  Execute   = false,
  -- Editor
  GetLength = false,
  SetLength = false,
  -- Move
  Goto      = false,
  LineHome  = false,
  LineEnd   = false,
  CharLeft  = false,
  CharRight = false,
  -- Delete
  DelPos    = false,
  BackPos   = false,
  DelChar   = false,
  BackChar  = false,

  -- Text only
  Text      = false,
  -- Block
  Block     = false,
  -- Selection
  Selection = false,
} ---

---------------------------------------- Action
do
  local UndoRedo = unit.UndoRedo
  local Begin_UndoRedo = F.EUR_BEGIN
  local End_UndoRedo   = F.EUR_END
  local Undo_UndoRedo  = F.EUR_UNDO

-- Execute an action as single action.
-- Выполнение действия как одиночного действия.
function unit.Execute (action, ...)
  local Info = unit.GetInfo()
  local id = Info.EditorID

  if not UndoRedo(id, Begin_UndoRedo) then
    return nil, "Begin UndoRedo"
  end

  local isOk, SError = action(...)

  if isOk then
    if not UndoRedo(id, End_UndoRedo) then
      return nil, "End UndoRedo"
    end
  else
    if not UndoRedo(id, Undo_UndoRedo) then
      return nil, "Undo UndoRedo"
    end
    return nil, SError
  end

  unit.Redraw()

  return true
end ---- Execute

end -- do
---------------------------------------- Editor
-- Get length of line.
-- Получение длины линии.
function unit.GetLength (id, line)
  return (unit.GetLine(id, line, 2) or ""):len()
end ----

-- Set length of line.
-- Установка длины линии.
function unit.SetLength (id, line, len, fill)
  if type(len) ~= 'number' or len < 0 then return end

  local s = unit.GetLine(id, line, 2) or ""
  local l = s:len()
  if l == len then return true end

  if l < len then
    s = s..(fill or " "):rep(len - l)
  else
    s = s:sub(1, len)
  end

  return unit.SetLine(id, line, s)
end ---- SetLength

---------------------------------------- ---- Move
-- Go to position by Info.
-- Переход на позицию из Info.
function unit.Goto (Info)
  if type(Info) ~= 'table' then return end
  if Info.CurPos > 0 then Info.CurTabPos = -1 end
  return unit.SetPos(Info.EditorID, Info)
end -- Goto

-- Set position to home of line.
-- Установка позиции в начало линии.
function unit.LineHome (id, line)
  if line and line >= 0 then
    if not unit.SetPos(id, line) then return end
  end
  return unit.SetPos(id, -1, 0)
end -- LineHome

-- Set position to end of line.
-- Установка позиции в конец линии.
function unit.LineEnd (id, line)
  if line and line >= 0 then
    if not unit.SetPos(id, line) then return end
  end
  return unit.SetPos(id, -1, unit.GetLength(id, -1))
end -- LineEnd

-- Set position to left of current one within file.
-- Установка позиции слева от текущей внутри файла.
function unit.CharLeft (Info)
  local Info = Info or unit.GetInfo()
  local id = Info.EditorID

  if Info.CurPos > 0 then
    return unit.SetPos(id, -1, Info.CurPos - 1)
  elseif Info.CurLine > 0 then
    return unit.LineEnd(id, Info.CurLine - 1)
  end
end -- CharLeft

-- Set position to right of current one within file.
-- Установка позиции справа от текущей внутри файла.
function unit.CharRight (Info)
  local Info = Info or unit.GetInfo()
  local id = Info.EditorID

  if Info.CurPos < unit.GetLength(id, -1) then
    return unit.SetPos(id, -1, Info.CurPos + 1)
  elseif Info.CurLine < Info.TotalLines - 1 then
    return unit.LineHome(Info.EditorID, Info.CurLine + 1)
  end
end -- CharRight

---------------------------------------- ---- Delete
-- Delete character rightward.
-- Удаление символа справа.
function unit.DelPos (Info)
  local Info = Info or unit.GetInfo()
  local id = Info.EditorID

  if Info.CurPos >= unit.GetLength(id, -1) then return true end

  return unit.Del(id)
end -- DelPos

-- Delete character leftward.
-- Удаление символа слева.
function unit.BackPos (Info)
  local Info = Info or unit.GetInfo()
  local id = Info.EditorID

  if Info.CurPos == 0 then return true end

  if not unit.SetPos(id, -1, Info.CurPos - 1) then
    return
  end

  return unit.Del(id)
end -- BackPos

-- Delete character rightward within file.
-- Удаление символа справа внутри файла.
function unit.DelChar (Info)
  local Info = Info or unit.GetInfo()

  return unit.Del(Info.EditorID)
end -- DelChar

-- Delete character leftward within file.
-- Удаление символа слева внутри файла.
function unit.BackChar (Info)
  local Info = Info or unit.GetInfo()

  if not unit.CharLeft(Info) then return end

  return unit.Del(Info.EditorID)
end -- BackChar

---------------------------------------- Internal

-- Define parameters to enquote.
-- Определение параметров для закавычивания.
local function DefineEnquote (left, right) --> (string, string)
  return left or '"', right or '"'
end -- DefineEnquote

-- Define parameters to dequote.
-- Определение параметров для раскавычивания.
local function DefineDequote (left, right) --> (string, number, string, number)
  local tp

  tp = type(left)
  local left, l_len = left or '"'
  if tp == 'string' then
    l_len = left:len()
  elseif tp == 'number' then
    left, l_len = false, left
  end

  tp = type(right)
  local right, r_len = right or '"'
  if tp == 'string' then
    r_len = right:len()
  elseif tp == 'number' then
    right, r_len = false, right
  end

  return left, l_len, right, r_len
end -- DefineDequote

---------------------------------------- Text
local Text = {
  -- Quote
  Enquote = false,
  Dequote = false,
} ---
unit.Text = Text

---------------------------------------- ---- Quote
-- Enquote in current position.
-- Закавычивание в текущей позиции.
--[[
  -- @params: see Block.Enquote:
  Info (nil|t) - info about editor state.
  -- @return:
  isOk  (bool) - operation success flag.
--]]
function Text.Enquote (Info, left, right) --> (bool)
  local Info = Info or unit.GetInfo()
  local id = Info.EditorID

  local left, right = DefineEnquote(left, right)

  if not unit.InsText(id, left) then return end
  Info = unit.GetInfo()
  if not unit.InsText(id, right) then return end

  return unit.Goto(Info)
end -- Enquote

-- Dequote in current position.
-- Раскавычивание в текущей позиции.
--[[
  -- @params: see Block.Dequote:
  Info (nil|t) - info about editor state.
  -- @return:
  isOk  (bool) - operation success flag.
--]]
function Text.Dequote (Info, left, right) --> (bool)
  local Info = Info or unit.GetInfo()

  local left, l_len, right, r_len = DefineDequote(left, right)

  local id, Pos = Info.EditorID, Info.CurPos
  local s = unit.GetLine(id, -1, 2) or ""
  if Pos >= l_len then
    if not left or s:sub(Pos - l_len + 1, Pos) == left then
      s = (s:sub(1, Pos - l_len) or "")..(s:sub(Pos + 1, -1) or "")
      Pos = Pos - l_len
    end
  end
  local len = s:len()
  if Pos + r_len <= len then
    if not right or s:sub(Pos + 1, Pos + r_len) == right then
      s = (s:sub(1, Pos) or "")..(s:sub(Pos + r_len + 1, -1) or "")
    end
  end
  if not unit.SetLine(id, -1, s) then return end

  return unit.SetPos(id, -1, Pos)
end -- Dequote

---------------------------------------- Block
local Block = {
  -- Basic
  Params    = false,
  Concat    = false,
  Split     = false,
  -- Quote
  Enquote   = false,
  Dequote   = false,
  -- Substitute
  SubText   = false,
  SubLines  = false,
  SubBlock  = false,
  DelLines  = false,
} ---
unit.Block = Block

---------------------------------------- ---- Basic
do
  --local floor = math.floor
  --local tables = require 'context.utils.useTables'
  --local hpairs = tables.hpairs

-- Fill table with block params.
-- Заполнение таблицы параметрами блока.
--[[
  -- @params:
  block (table) - line or block of lines.
  t (nil|table) - table for block parameters.
  -- @return:
  t (nil|table) - filled table as empty block.
--]]
function Block.Params (block, t) --> (block)
  local t = t or {}
  if type(block) ~= 'table' then return t end

  for k, v in pairs(block) do
    if type(k) ~= 'number' --[[or
       k ~= floor(k) or
       k > (block.Count or #block)]] then
      t[k] = v
    end
  end
  --for k, v in hpairs(block) do t[k] = v end

  t.Count = #t
  return t
end ---- Params

end -- do

-- Concatenate block lines into one string.
-- Объединение линий блока в одну строку.
--[[
  -- @params:
  block (s|t|nil) - line or block of lines.
  sep    (string) - separator to concat.
  -- @return:
  s  (nil|string) - concatenated string.
--]]
function Block.Concat (block, sep) --> (string)
  if not block then return end

  if type(block) == 'string' then return block end

  return tconcat(block, sep or "\n")
end ---- Concat

-- Split string to block lines.
-- Разбиение строки на линии блока.
--[[
  -- @params:
  s (nil|string) - splited string.
  pat   (string) - pattern to match.
  sep   (string) - separator to split.
  -- @return:
  block (s|t|nil) - block of lines or line.
--]]
function Block.Split (s, pat, sep) --> (block)
  if not s then return end
  local pat = pat or "([^\n]-)"
  local sep = sep or "\n"

  --logShow(s, pattern)
  local t = {}
  for line in s:gmatch(pat..sep) do
    t[#t+1] = line -- all but last
  end

  local line = s:match(sep..pat.."$") -- last
  if line then
    t[#t+1] = line
  end

  if #t == 0 then return s end
  if #t == 1 then return t[1] end
  t.Count = #t

  return t
end ---- Split

---------------------------------------- ---- Quote
-- Enquote block lines.
-- Закавычивание линий блока.
--[[
  -- @params:
  block (s|t|nil) - line or block of lines.
  left  (s|n|nil) - left "quote": @default = '"'.
  right (s|n|nil) - right "quote": @default = '"'.
  -- @return:
  block (s|t|nil) - processed line or block of lines.
--]]
function Block.Enquote (block, left, right) --> (block)
  if not block then return end
  local SelType = block.Type

  local left, right = DefineEnquote(left, right)

  if type(block) == 'string' then
    block = left..block..right

  elseif SelType == "stream" then
    local k = #block
    local s = block[k]
    if block.FromStart and
       s == "" and not block.BeyondEnd then
      left = left.."\r"
    end

    block[1] = left..block[1]

    if s == "" and block.BeyondEnd then
      k = k - 1
      s = block[k]
    end
    block[k] = s..right

  elseif SelType == "column" then
    for k = 1, #block do
      block[k] = left..block[k]..right
    end

  end -- if

  return block
end ---- Enquote

-- Dequote block lines.
-- Раскавычивание линий блока.
--[[
  -- @params:
  block (s|t|nil) - line or block of lines.
  left  (s|n|nil) - left "quote" or its length: @default = '"'.
  right (s|n|nil) - right "quote" or its length: @default = '"'.
  -- @return:
  block (s|t|nil) - processed line or block of lines.
--]]
function Block.Dequote (block, left, right) --> (block)
  if not block then return end
  local SelType = block.Type

  local left, l_len, right, r_len = DefineDequote(left, right)

  --logShow({ left, right, block }, SelType)

  if type(block) == 'string' then
    local s = block
    local len = s:len()

    if len <= l_len + r_len then
      if left and s:sub(1, l_len) == left then
        s = s:sub(l_len + 1, -1)
      end
      if right and s:sub(-r_len, -1) == right then
        s = s:sub(1, -r_len - 1)
      end
      if not (left or right) then
        s = ""
      end

    else
      if not (left or right) or
         (left  and s:sub(1, l_len) == left and
          right and s:sub(-r_len, -1) == right) then
        s = s:sub(l_len + 1, -r_len - 1)
      end
    end

    block = s

  elseif SelType == "stream" then
    local s = block[1]
    if not left or s:sub(1, l_len) == left then
      block[1] = s:sub(l_len + 1, -1)
    end

    local k = #block
    s = block[k]
    if s == "" then
      k = k - 1
      s = block[k]
    end
    if not right or s:sub(-r_len, -1) == right then
      block[k] = s:sub(1, -r_len - 1)
    end

  elseif SelType == "column" then
    for k = 1, #block do
      local s = block[k]
      if not (left or right) or
         (left  and s:sub(1, l_len) == left and
          right and s:sub(-r_len, -1) == right) then
        block[k] = s:sub(l_len + 1, -r_len - 1)
      end
    end

  end -- if

  return block
end ---- Dequote

---------------------------------------- ---- Substitute

-- Substitute another text for initial one in block text.
-- Подставить другой текст вместо исходного в тексте блока.
--[[
  -- @params:
  block  (s|t|nil) - line or block of lines.
  pattern (string) - string to find: @see string.gsub.
  replace  (s|t|f) - string/table/function to replace: @see string.gsub.
  -- @return:
  block (s|t|nil) - processed line or block of lines.
--]]
function Block.SubText (block, pattern, replace) --> (block)
  if not block then return end

  if type(block) == 'string' then
    return block:gsub(pattern, replace)
  end

  local s = Block.Concat(block)
  s = s:gsub(pattern, replace)
  --logShow(s, pattern)

  local t = Block.Split(s)
  if not t then return end

  if type(t) == 'string' then
    t = { t, "", Count = 2 }
  end

  return Block.Params(block, t)
end ---- SubText

-- Substitute another text for initial one in block lines.
-- Подставить другой текст вместо исходного в линиях блока.
--[[
  -- @params:
  block  (s|t|nil) - line or block of lines.
  pattern (string) - string to find: @see string.gsub.
  replace  (s|t|f) - string/table/function to replace: @see string.gsub.
  -- @return:
  block (s|t|nil) - processed line or block of lines.
--]]
function Block.SubLines (block, pattern, replace) --> (block)
  if not block then return end

  if type(block) == 'string' then
    return block:gsub(pattern, replace)
  end

  for k = 1, block.Count or #block do
    block[k] = block[k]:gsub(pattern, replace)
  end

  return block
end ---- SubLines

-- Substitute another text for initial one in block.
-- Подставить другой текст вместо исходного в блоке.
--[[
  -- @params:
  block  (s|t|nil) - line or block of lines.
  start   (string) - string to find an start of text.
  stop    (string) - string to find an end of text.
  pattern (string) - string to find in found block: @see string.gsub.
  replace  (s|t|f) - string/table/function to replace: @see string.gsub.
  -- @return:
  block (s|t|nil) - processed line or block of lines.
--]]
function Block.SubBlock (block, pattern, replace) --> (block)
  if not block then return end

  --[[
  -- TODO: Реализовать!!!
  if type(block) == 'string' then
    return block:gsub(pattern, replace)
  end

  for k = 1, block.Count or #block do
    block[k] = block[k]:gsub(pattern, replace)
  end
  --]]

  return block
end ---- SubBlock

-- Delete block lines that is (not) matched a pattern.
-- Удалить линии блока, (не) соответствующие шаблону.
--[[
  -- @params:
  block  (s|t|nil) - line or block of lines.
  pattern (string) - string to find: @see string.gsub.
  include   (bool) - include pattern: @default = false.
  -- @return:
  block (s|t|nil) - processed line or block of lines.
--]]
function Block.DelLines (block, pattern, include) --> (block)
  if not block then return end
  local f = include and true or false

  if type(block) == 'string' then
    local is = block:find(pattern) and true or false
    return (f == is) and block or nil
  end

  local t = { Count = 0 }
  for k = 1, block.Count or #block do
    local s = block[k]
    local is = s:find(pattern) and true or false
    if f == is then
      t[#t+1] = s
    end
  end

  return Block.Params(block, t)
end ---- DelLines

---------------------------------------- Selection
local Selection = {
  Types = BlockTypes,

  -- Action
  Process = false,
  Execute = false,

  -- Basic
  Get = editor.GetSelection,
  Set = false,
  Del = editor.DeleteBlock,

  GetType = farUt.EditorSelType,

  CopyStream = false,
  CopyColumn = false,
  Copy = false,

  Delete = false,
  Cut = false,

  PasteStream = false,
  PasteColumn = false,
  Paste = false,

  -- Quote
  Enquote = false,
  Dequote = false,

  -- Iterator
  next = false,
  pairs = false,
} ---
unit.Selection = Selection

---------------------------------------- ---- Action
-- Process selected block.
-- Обработка выделенного блока.
--[[
  -- @params:
  force  (bool) - call action even if there is no selection.
  action (func) - function to process selected block (or nil).
  -- @return:
  isOk   (bool) - operation success flag.
--]]
function Selection.Process (force, action, ...) --> (bool)
  local Info = unit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]

  if force and SelType == "none" then -- Нет блока:
    return action(nil, ...)
  end

  local SelInfo = Selection.Get()
  if SelInfo == nil then return end -- Нет блока?

  local block = Selection.Cut(unit.GetInfo(), SelType)
  if not block then return end

  --logShow({ left, right, block }, SelType)

  block = action(block, ...)
  if not block then return end

  return Selection.Paste(unit.GetInfo(), block, SelType)
end -- Process

-- Execute for selected block.
-- Выполнение для выделенного блока.
function Selection.Execute (...)
  return unit.Execute(Selection.Process, ...)
end ----

---------------------------------------- ---- Basic
do

-- Select block in editor.
-- Выделение блока в редакторе.
function Selection.Set (id, Info) --> (boolean)
  local Info = Info
  local SelInfo = {
    BlockType = Info.BlockType,
    BlockStartLine = Info.StartLine,
    BlockStartPos  = Info.StartPos,
    BlockHeight = Info.EndLine - Info.StartLine + 1,
    BlockWidth  = Info.EndPos  - Info.StartPos  + 1,
  } ---

  -- TODO: Учесть Info.EndPos < 0 - нужно учесть и выделить следующую строку.
  if Info.EndPos < 0 then
    SelInfo.BlockHeight = SelInfo.BlockHeight + 1
    SelInfo.BlockWidth  = -Info.StartPos
  end

  --[[if Info.StartPos == Info.EndPos then
    SelInfo.BlockStartPos = SelInfo.BlockStartPos +
                            (Info.EndLine > Info.StartLine and 1 or -1)
  end]]--

  return editor.Select(id, SelInfo)
end ---- Set

  local spaces = strings.spaces -- to add spaces after end

-- Copy selected stream block.
-- Копирование выделенного строкового блока.
--[[
  -- @params: @see Selection.Copy (without Type).
  -- @return: @see Selection.Copy.
--]]
function Selection.CopyStream (Info, ToPos) --> (nil|string|table)
  local Info = Info or unit.GetInfo()
  if Info.BlockType == BlockTypes.None then return end

  local id = Info.EditorID
  local SelInfo = Selection.Get(id) -- Нет блока:
  if SelInfo == nil then return end

  --logShow(SelInfo, "SelInfo")

  local first, last = SelInfo.StartLine, SelInfo.EndLine
  if first == last then
    -- Одна выделенная cтрока
    local LineInfo = unit.GetLine(id, first, 0)
    if LineInfo == nil then return end -- Нет строки
    --logShow(LineInfo, "LineInfo")
    local s = LineInfo.StringText
    if s == nil then return end
    local len = s:len()
    local go, pos = LineInfo.SelStart, LineInfo.SelEnd

    if pos > 0 and pos <= len then
      return s:sub(go + 1, pos)
    end

    return {
      Type = "stream",
      Count = 2,
      FromStart = (go == 0),
      BeyondEnd = (pos > 0),

      s:sub(go + 1, -1)..spaces[pos - len], -- line
      "" -- with last EOL
    } ----
  end

  -- Несколько выделенных cтрок
  local s = unit.GetLine(id, first, 2) or ""
  local go = SelInfo.StartPos
  local t = {
    Type = "stream",
    Count = last - first + 1,
    FromStart = (go == 0),
    BeyondEnd = false,

    s:sub(go + 1, -1), -- first
  } ---

  for line = first + 1, last - 1 do
    t[#t+1] = unit.GetLine(id, line, 2) or "" -- inners
  end

  local LineInfo = unit.GetLine(id, last, 1)
  s = LineInfo.StringText
  if s ~= nil then
    local len = s:len()
    local pos = LineInfo.SelEnd

    if pos > 0 and pos <= len then
      t[#t+1] = s:sub(1, pos) -- last
    else
      t[#t+1] = s..spaces[pos - len] -- last
      t[#t+1] = "" -- with last EOL
      t.BeyondEnd = (pos > 0)
      t.Count = t.Count + 1
    end
  end

  if ToPos or ToPos == nil then unit.Goto(Info) end

  --logShow(tconcat(t, "\r"), "Selection.CopyStream")

  return t
end ---- CopyStream

-- TODO: Проверить, возможен ли EndPos == -1 при вертикальном выделении!!!

-- Copy selected column block.
-- Копирование выделенного вертикального блока.
--[[
  -- @params: @see Selection.Copy (without Type).
  -- @return: @see Selection.Copy.
--]]
function Selection.CopyColumn (Info, ToPos) --> (nil|string|table)
  local Info = Info or unit.GetInfo()
  if Info.BlockType == BlockTypes.None then return end

  local id = Info.EditorID
  local SelInfo = Selection.Get(id) -- Нет блока:
  if SelInfo == nil then return end

  --logShow(SelInfo, "SelInfo")

  local first, last = SelInfo.StartLine, SelInfo.EndLine
  if first == last then
    -- Одна выделенная cтрока
    local LineInfo = unit.GetLine(id, first, 0)
    if LineInfo == nil then return end -- Нет строки
    --logShow(LineInfo, "LineInfo")
    local s = LineInfo.StringText
    if s == nil then return end
    local pos = LineInfo.SelEnd
    --[[
    if pos < 0 then
      return s:sub(LineInfo.SelStart + 1, -1)
    end
    --]]

    return s:sub(LineInfo.SelStart + 1, pos)..spaces[pos - s:len()]
  end

  -- Несколько выделенных cтрок
  local go, pos = SelInfo.StartPos, SelInfo.EndPos
  local t = {
    Type = "column",
    Count = last - first + 1,
    FromStart = (go == 0),
    --BeyondEnd = nil, -- don't use
  } ---
  for line = first, last do
    local s = unit.GetLine(id, line, 2) or ""
    t[#t+1] = s:sub(go + 1, pos)..spaces[pos - s:len()]
  end

  if ToPos or ToPos == nil then unit.Goto(Info) end

  --logShow(tconcat(t, "\r"), "Selection.CopyColumn")

  return t
end ---- CopyColumn

-- Copy selected block.
-- Копирование выделенного блока.
--[[
  -- @params:
  Info  (nil|table) - info about editor state.
  Type (nil|string) - block type for action:
                      @default = nil - as in Info,
                      "stream" - as stream block,
                      "column" - as column block.
  ToPos  (nil|bool) - flag to restore position after action.
  -- @return:
  @1:
         (nil) - no selection block or error.
    s (string) - one line only in selection block, may be with "\r".
    t  (table) - table with lines in selection block, last line may be empty.
      Type    (string) - type of selected block.
      Count   (number) - count of lines in selected block including EOL-line.
      FromStart (bool) - selection start is at start of first selected line.
      BeyondEnd (bool) - selection end is over end of last selected line.
--]]
function Selection.Copy (Info, Type, ToPos) --> (nil|string|table)
  local Info = Info or unit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]
  if SelType == "none" then return end

  local Type = Type or SelType

  if     Type == "stream" then
    return Selection.CopyStream(Info, ToPos)
  elseif Type == "column" then
    return Selection.CopyColumn(Info, ToPos)
  end
end ---- Copy

-- Delete selected block.
-- Удаление выделенного блока.
--[[
  -- @params: @see Selection.Copy.
--]]
function Selection.Delete (Info, Type, ToPos) --> (bool)
  local Info = Info or unit.GetInfo()
  if Info.BlockType == BlockTypes.None then return end

  local id = Info.EditorID
  local SelInfo = Selection.Get(id) -- Нет блока:
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

    if not Selection.Set(id, SelInfo) then return end
  end

  if not Selection.Del(id) then return end

  if ToPos or ToPos == nil then
    return unit.SetPos(id, SelInfo.StartLine, SelInfo.StartPos)
  end

  return true
end ---- DeleteSelection

-- Cut selected block.
-- Вырезание выделенного блока.
--[[
  -- @params: @see Selection.Copy.
  -- @return: @see Selection.Copy.
--]]
function Selection.Cut (Info, Type) --> (nil|string|table)
  local Info = Info or unit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]
  if SelType == "none" then return end

  local Type = Type or SelType

  local s = Selection.Copy(Info, Type, false)

  Selection.Delete(Info, Type, true)

  return s
end ---- Cut

-- Paste stream block.
-- Вставка строкового блока.
--[[
  -- @params: @see Selection.Paste (without Type).
  -- @return: @see Selection.Paste.
--]]
function Selection.PasteStream (Info, block) --> (bool)

  if (block or "") == "" then return end

  local Info = Info or unit.GetInfo()

  if type(block) == 'table' then
    block = tconcat(block, "\r")
  end

  --logShow(block, "Selection.PasteColumn")
  return unit.InsText(Info.EditorID, block)
end ---- PasteStream

-- Paste column block.
-- Вставка вертикального блока.
--[[
  -- @params:
  -- @params: @see Selection.Paste (without Type).
  -- @return: @see Selection.Paste.
--]]
function Selection.PasteColumn (Info, block) --> (bool)

  if (block or "") == "" then return end

  local Info = Info or unit.GetInfo()
  local id = Info.EditorID

  if type(block) == 'string' then
    if not unit.InsText(id, block) then return end
    return unit.Goto(Info)
  end

  local CurLine, CurPos = Info.CurLine, Info.CurPos
  for k = 1, block.Count or #block do
    if not unit.InsText(id, block[k]) then return end
    --logShow({ block[k], Info }, "Selection.PasteColumn")
    CurLine = CurLine + 1
    if not unit.SetPos(id, CurLine, CurPos) then return end
  end

  --logShow(block, "Selection.PasteColumn")
  return unit.Goto(Info)
end ---- PasteColumn

-- Paste block.
-- Вставка блока.
--[[
  -- @params:
  Info (nil|t) - @see Selection.Copy.
  block  (s|t) - string block to insert.
  Type (nil|s) - @see Selection.Copy.
  -- @return:
  isOk  (bool) - operation success flag.
--]]
function Selection.Paste (Info, block, Type) --> (bool)

  if (block or "") == "" then return end

  local Info = Info or unit.GetInfo()

  --logShow({ block, Type, Info }, "PasteSelection")

  local Type = Type or type(block) == 'table' and block.Type

  if     Type == "stream" then
    return Selection.PasteStream(Info, block)
  elseif Type == "column" then
    return Selection.PasteColumn(Info, block)
  end
end ---- Paste

end -- do
---------------------------------------- ---- Quote
-- Enquote selected text lines.
-- Закавычивание выделенных линий текста.
--[[
  -- @params: see Block.Enquote:
  force (bool) - enquote even if there is no selection.
  -- @return:
  isOk  (bool) - operation success flag.
--]]
function Selection.Enquote (left, right, force) --> (bool)
  local Info = unit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]

  if force and SelType == "none" then -- Нет блока:
    return Text.Enquote(Info, left, right)
  end

  local SelInfo = Selection.Get()
  if SelInfo == nil then return end -- Нет блока?

  local block = Selection.Cut(Info, SelType)
  if not block then return end

  block = Block.Enquote(block, left, right)
  if not block then return end

  return Selection.Paste(unit.GetInfo(), block, SelType)
end -- Enquote

-- Dequote selected text lines.
-- Раскавычивание выделенных линий текста.
--[[
  -- @params: see Block.Dequote:
  force (bool) - dequote even if there is no selection.
  -- @return:
  isOk  (bool) - operation success flag.
--]]
function Selection.Dequote (left, right, force) --> (bool)
  local Info = unit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]

  if force and SelType == "none" then -- Нет блока:
    return Text.Dequote(Info, left, right)
  end

  local SelInfo = Selection.Get()
  if SelInfo == nil then return end -- Нет блока?

  local block = Selection.Cut(unit.GetInfo(), SelType)
  if not block then return end

  --logShow({ left, right, block }, SelType)

  block = Block.Dequote(block, left, right)
  if not block then return end

  return Selection.Paste(unit.GetInfo(), block, SelType)
end -- Dequote

---------------------------------------- ---- Iterator
do
  local EditorGetInfo = unit.GetInfo
  local EditorGetLine = unit.GetLine

-- Iterator of lines for selected block in editor.
-- Итератор строк выделенного блока в редакторе.
-- (maxfl's implementation: block_iterator.lua.)
--[[
  -- @params:
  count (number) - count of viewed lines.
  line  (number) - number of current used line.
--]]
function Selection.next (count, line) --> (number, table)
  if not count then return nil, nil end

  if count >= 0 then
    local line = (line or -1) + 1
    if line < count then
      local s = EditorGetLine(nil, line, 1)
      if s.SelEnd ~= 0 then return line, s end
    end

  elseif line >= 0 then
    return -1, EditorGetLine(nil, line, 1)
  end
end ---- nextEditorSelect

  local next = Selection.next

function Selection.pairs (line) --> (iterator, count, line)
  local Info = EditorGetInfo()

  if line then
    return next, -1, line == -1 and Info.CurLine
  end
  if Info.BlockType ~= BlockTypes.None then
    return next, Info.TotalLines, Info.BlockStartLine - 1
  end

  return next, nil, nil
end ---- pairsEditorSelect

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
