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

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {
  GetInfo   = editor.GetInfo,
  GetLine   = editor.GetString,
  SetPos    = editor.SetPosition,
  InsText   = editor.InsertText,
  InsLine   = editor.InsertString,
  DelChar   = editor.DeleteChar,

  UndoRedo  = editor.UndoRedo,
  Redraw    = editor.Redraw,

  GetLength = false,
  SetEnd    = false,
  SetLeft   = false,

  Selection = false,
} ---

---------------------------------------- Editor
-- Get length of line.
-- Получение длины линии.
function unit.GetLength (id, line)
  return (unit.GetLine(id, line, 2) or ""):len()
end ----

-- Set position to end of line.
-- Установка позиции в конец линии.
function unit.SetEnd (id, line)
  if line and line >= 0 then
    if not unit.SetPos(id, line) then return end
  end
  if not unit.SetPos(id, -1, unit.GetLength(id, - 1)) then return end

  return true
end -- SetEnd

-- Set position to left of current one within file.
-- Установка позиции слева от текущей внутри файла.
function unit.SetLeft (Info)
  local Info = Info or unit.GetInfo()
  if Info.CurPos > 0 then
    if not unit.SetPos(Info.EditorID, -1, Info.CurPos - 1) then return end
  elseif Info.CurLine > 0 then
    if not unit.SetEnd(Info.EditorID, Info.CurLine - 1) then return end
  else
    return
  end

  return true
end -- SetLeft

---------------------------------------- Selection
local BlockTypes = farUt.BlockTypes

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

  -- Iterator
  next = false,
  pairs = false,
} ---
unit.Selection = Selection

---------------------------------------- -- Process
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
      s:sub(LineInfo.SelStart + 1, -1), -- line
      "" -- with last EOL
    } ----
  end

  -- Несколько выделенных cтрок
  local s = unit.GetLine(id, first, 2) or ""
  local t = {
    s:sub(SelInfo.StartPos + 1, -1), -- first
  } ---

  for line = first + 1, last - 1 do
    t[#t+1] = unit.GetLine(id, line, 2) or "" -- inners
  end

  local LineInfo = unit.GetLine(id, last, 1)
  local s = LineInfo.StringText
  if s ~= nil then
    if LineInfo.SelEnd < 0 then
      t[#t+1] = s:sub(1, -1) -- last
      t[#t+1] = "" -- with last EOL
    else
      t[#t+1] = s:sub(1, SelInfo.EndPos) -- last
    end
  end

  if ToPos or ToPos == nil then unit.SetPos(id, Info) end

  --logShow(tconcat(t, "\r"), "Selection.CopyStream")

  return t
end ---- CopyStream

  local spaces = strings.spaces -- to add spaces after end

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
           spaces[LineInfo.SelEnd - s:len() + 1]
  end

  -- Несколько выделенных cтрок
  local s = unit.GetLine(id, first, 2) or ""
  local t = {}
  for line = first, last do
    local s = unit.GetLine(id, line, 2) or ""
    t[#t+1] = s:sub(SelInfo.StartPos + 1, SelInfo.EndPos)..
              spaces[SelInfo.EndPos - s:len() + 1]
  end

  if ToPos or ToPos == nil then unit.SetPos(id, Info) end

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
    return unit.SetPos(id, Info)
  end

  local CurLine, CurPos = Info.CurLine, Info.CurPos
  for k = 1, #block do
    if not unit.InsText(id, block[k]) then return end
    --logShow({ block[k], Info }, "Selection.PasteColumn")
    CurLine = CurLine + 1
    if not unit.SetPos(id, CurLine, CurPos) then return end
  end

  --logShow(block, "Selection.PasteColumn")
  return unit.SetPos(id, Info)
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

  if     Type == "stream" then
    return Selection.PasteStream(Info, block)
  elseif Type == "column" then
    return Selection.PasteColumn(Info, block)
  end
end ---- Paste

end -- do
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
