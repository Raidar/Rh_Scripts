--[[ Binding ]]--

----------------------------------------
--[[ description:
  -- Working with binds.
  -- Работа с привязками.
--]]
----------------------------------------
--[[ uses:
  LF context,
  Rh Utils.
  -- used in: LUM.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------
--local _G = _G

local require, pcall = require, pcall

----------------------------------------
local detect = context.detect
local logShow = context.ShowInfo

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- File type
local PathNamePattern = "^(.-)([^\\/]+)$"
local curFileType, getFileType = detect.area.current, detect.FileType

-- Get file type by its name and firstline.
-- Получение типа файла по его имени и первой строке.
function unit.BindFileType (Scope) --> (string | string, error)

  local FileName = Scope.FileName

  local Result, SError
  if not FileName or FileName == "" then
    Result, SError = curFileType()

  else
    local Path, Name = FileName:match(PathNamePattern)
    Result, SError = getFileType({ filename = Name, path = Path,
                                   firstline = Scope.FirstLine })
  end

  if not Result then return 'none', SError end

  return Result

end ---- BindFileType

---------------------------------------- Layout
do
  local LayoutPath = "Rh_Scripts.Utils.layouts."

-- Get a character layout data from file.
-- Получение из файла данных о раскладке символов.
local function RequireLayout (LayoutName) --> (string, string | nil)

  local isOk, Data = pcall(require, LayoutPath..LayoutName)
  if not isOk then return end
  --logShow(Data, Language)

  return Data.Name, Data.Layout

end ----

  local DefLayoutName = "Default" -- Default layout name

-- Get character layout only.
-- Получение только раскладки символов.
function unit.BindLayout (LayoutName) --> (string | nil, error)

  local _, Layout = RequireLayout(LayoutName or DefLayoutName)

  return Layout

end ----

end -- do

-- Convert character from one layout to other.
-- Преобразует символ из одной раскладки в другую.
local function ConvertLayoutChar (c, From, To) --> (char | nil)

  local pos = From:cfind(c, 1, true)
  if pos then return To:sub(pos, pos) end

end ----
unit.ConvertLayoutChar = ConvertLayoutChar

-- Convert string from one layout to other.
-- Преобразует строку из одной раскладки в другую.
function unit.ConvertLayout (s, From, To, LetterOnly) --> (string | nil)

  local function ConvertSubChar (c)

    return ConvertLayoutChar(c, From, To)

  end --

  return s:gsub(LetterOnly and '%w' or '.', ConvertSubChar)

end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
