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
--local luaUt = require "Rh_Scripts.Utils.LuaUtils"
local farUt = require "Rh_Scripts.Utils.FarUtils"

local BlockTypes = farUt.BlockTypes

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {
  -- Editor
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

  -- Block
  Block     = false,
  -- Selection
  Selection = false,
} ---

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

---------------------------------------- -- Move
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

---------------------------------------- -- Delete
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

---------------------------------------- Block
local Block = {
  -- Quote
  Enquote = false,
  Dequote = false,
} ---
unit.Block = Block

---------------------------------------- -- Quote
-- Enquote block lines.
-- Закавычивание блока текста.
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

  -- Define params:
  local left  = left or '"'
  local right = right or '"'

  if type(block) == 'string' then
    block = left..block..right

  elseif SelType == "stream" then
    block[1] = left..block[1]
    local k = #block
    local s = block[k]
    if s == "" and not block.Last then
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
end -- Enquote

-- Dequote selected text lines.
-- Раскавычивание выделенных линий текста.
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

  -- Define params:
  local tp = type(left)
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
    local s = block[k]
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
end -- Dequote
---------------------------------------- Selection
local Selection = {
  Types = BlockTypes,

  -- Process
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

---------------------------------------- -- Basic
do
  local tconcat = table.concat

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

    if LineInfo.SelEnd > 0 then
      return s:sub(LineInfo.SelStart + 1, LineInfo.SelEnd)
    end

    return {
      Type = "stream",
      s:sub(LineInfo.SelStart + 1, -1), -- line
      "" -- with last EOL
    } ----
  end

  -- Несколько выделенных cтрок
  local s = unit.GetLine(id, first, 2) or ""
  local t = {
    Type = "stream",
    s:sub(SelInfo.StartPos + 1, -1), -- first
  } ---

  for line = first + 1, last - 1 do
    t[#t+1] = unit.GetLine(id, line, 2) or "" -- inners
  end

  local LineInfo = unit.GetLine(id, last, 1)
  local s = LineInfo.StringText
  if s ~= nil then
    local len = s:len()
    if LineInfo.SelEnd < 0 then
    --if LineInfo.SelEnd < 0 or LineInfo.SelEnd > s:len() then
      t[#t+1] = s--:sub(1, -1) -- last
      t[#t+1] = "" -- with last EOL
      t.Last = true
    elseif LineInfo.SelEnd > len then
      t[#t+1] = s..spaces[LineInfo.SelEnd - len] -- last
      t[#t+1] = "" -- with last EOL
    else
      t[#t+1] = s:sub(1, SelInfo.EndPos) -- last
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
function Selection.CopyColumn (Info) --> (nil|string|table)
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
    --[[
    if LineInfo.SelEnd < 0 then
      return s:sub(LineInfo.SelStart + 1, -1)
    end
    --]]

    return s:sub(LineInfo.SelStart + 1, LineInfo.SelEnd)..
           spaces[LineInfo.SelEnd - s:len()]
  end

  -- Несколько выделенных cтрок
  local s = unit.GetLine(id, first, 2) or ""
  local t = {
    Type = "column",
  } ---
  for line = first, last do
    local s = unit.GetLine(id, line, 2) or ""
    t[#t+1] = s:sub(SelInfo.StartPos + 1, SelInfo.EndPos)..
              spaces[SelInfo.EndPos - s:len()]
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
  @first:
         (nil) - no selection block or error.
    s (string) - one line only in selection block, may be with "\r".
    t  (table) - table with lines in selection block, last line may be empty.
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
  for k = 1, #block do
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
  Info     (nil|table) - @see Selection.Copy.
  block (string|table) - string block to insert.
  Type    (nil|string) - @see Selection.Copy.
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
---------------------------------------- -- Quote
-- Enquote selected text lines.
-- Закавычивание выделенных линий текста.
--[[
  -- @params: see Block.Enquote:
  force (bool) - enquote even if there is no selection.
--]]
function Selection.Enquote (left, right, force) --> (bool)
  -- Define params:
  --local left  = left or '"'
  --local right = right or '"'

  local Info = unit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]

  if force and SelType == "none" then -- Нет блока:
    if not unit.InsText(Info.EditorID, left) then return end
    local Info = unit.GetInfo()
    if not unit.InsText(Info.EditorID, right) then return end

    return unit.Goto(Info)
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
--]]
function Selection.Dequote (left, right, force) --> (bool)
  local Info = unit.GetInfo()
  local SelType = BlockTypes[Info.BlockType]

  if force and SelType == "none" then -- Нет блока:
    -- Define params:
    local tp = type(left)
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
---------------------------------------- -- Iterator
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
