--[[ Debugging and logging of scripts ]]--
--[[ Отладка и протоколирование скриптов ]]--

--[[ uses:
  [LuaFAR].
  -- group: Utils.
--]]
--------------------------------------------------------------------------------
local _G = _G

local type = type
local pairs, ipairs = pairs, ipairs
local tonumber, tostring = tonumber, tostring
local setmetatable = setmetatable

local io_open = io.open

----------------------------------------
local far_Message, far_Show = far.Message, far.Show

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
local ExcludeChar = nil
--local ExcludeChar = '-'

local Types = {
  ["table"]     = 't',
  ["string"]    = 's',
  ["number"]    = 'n',
  ["boolean"]   = 'b',
  ["function"]  = 'f',
  ["userdata"]  = 'u',
} --- Types

local Names = {
  -- standard modules
  ["string"] = true,
  ["package"] = true,
  ["os"] = true,
  ["io"] = true,
  ["math"] = true,
  ["debug"] = true,
  ["table"] = true,
  ["coroutine"] = true,
  -- additional modules
  ["_io"] = true,
  ["uio"] = true,
  ["bit"] = true,
  ["bit64"] = true,
  ["export"] = true,
  ["far"] = true,
  ["far2"] = true,
  ["win"] = true,
  ["_G"] = true,
  ["_M"] = true,
  ["__index"] = true,
  -- special functions
  ["assert"] = true,
  ["error"] = true,
  ["print"] = true,
  ["collectgarbage"] = true,
  -- typing functions
  ["type"] = true,
  ["tostring"] = true,
  ["tonumber"] = true,
  -- module functions
  ["module"] = true,
  ["require"] = true,
  ["import"] = true,
  -- fenv functions
  ["getfenv"] = true,
  ["setfenv"] = true,
  -- iteration functions
  ["pairs"] = true,
  ["ipairs"] = true,
  ["next"] = true,
  -- global functions
  ["select"] = true,
  ["unpack"] = true,
  ["rawget"] = true,
  ["rawset"] = true,
  ["rawequal"] = true,
  ["getmetatable"] = true,
  ["setmetatable"] = true,
  -- load/call functions
  ["dofile"] = true,
  ["load"] = true,
  ["loadfile"] = true,
  ["loadstring"] = true,
  ["pcall"] = true,
  ["xpcall"] = true,

  -- other variables
  _VERSION = true,
  Flags = true,
  flags = true,
  -- RectMenu
  LMap = true,
} --- Names

local Metas = {
  -- LuaFAR context
  _meta_ = true,
} --- Metas

---------------------------------------- Work
-- Plain find of string.
local function sfind (s, pat) --> (bool)
  return s:find(pat, 1, true)
end --

local format = string.format

-- Convert to hexadecimal presentation.
-- Преобразование в 16-ричную форму.
local function hex (n, w) --> (string)
  return format(format("%%#0%dx", tonumber(w) or 10), n or 0)
end --

-- Convert to string checking quotes.
-- Преобразование в строку с учётом кавычек.
local function str (s, filter)
  return sfind(filter, "'") and format("'%s'", s or "") or
         sfind(filter, 'q') and s or ("%q"):format(s)
end --

local floor = math.floor

-- Проверка ключа на индекс части-массива таблицы.
local function isArrayKey (k, t) --> (bool)
  return k > 0 and k <= #t and floor(k) == k
end --

-- Check type of value to include.
local function isFitType (v, filter)
  return not sfind(filter, Types[type(v)] or '?')
end -- isFitType

-- Check name of value to include.
local function isNameChar (n, filter)
  return not (sfind(filter, '_') and Names[n] or
              sfind(filter, '/') and sfind(n, '/') or
              sfind(filter, '.') and sfind(n, '.') or
              sfind(filter, 'm') and (Metas[n] or n:find("^__"))
             )
end -- isNameChar

---------------------------------------- To string
-- Представление содержимого таблицы в виде строки.
--[[
  -- @params:
  t -- преобразуемая таблица.
  Indent -- отступ для подтаблиц.
  Depth -- уровень вложенности (nil/boolean -- любая вложенность).
--]]
local function TabToStr (t, Indent, Depth, Filter, Props) --> (string)
  if type(Depth) == 'string' then Filter, Depth = Depth, nil end
  Filter = Filter or ""
  -- Ограничение на вложенность вызовов
  if Depth and type(Depth) == 'number' then
    Depth = Depth - 1
    if Depth < 0 then return "[table]\n" end
  end -- if

  Indent = Indent or ""
  local Str = ""
  local tpairs = Props and Props.pairs or pairs
  -- Формирование сообщения:
  for k, v in tpairs(t) do
    local tk = type(k) -- Имя ключа:
    local w = Filter:match("hk(%d*)") or Filter:match("h(%d+)")
    local ParName  = (tk == 'number' and w) and hex(k, w) or
                  --[[tp == "string" and "'"..k.."'" or]] tostring(k)
    local tp = type(v) -- Значение ключа:
    w = Filter:match("hv(%d*)") or Filter:match("h(%d+)")
    local ParValue = (tp == 'number' and w) and hex(v, w) or
                      tp == 'string'   and str(v, Filter) or
                      tp == 'table'    and "[table]" or
                      tp == 'function' and "[func]" or tostring(v)

    -- Анализ исключений
    if isNameChar(tostring(k), Filter) and
       tp == "table" and (not Depth or Depth > -1) then
      ParName = '('..ParName..')'
      if Str:sub(-1) == ExcludeChar then Str = Str..'\n' end
      Str = ("%s%s%s:\n%s"):format(Str, Indent, ParName,
                                   TabToStr(v, Indent..":", Depth, Filter, Props))
    else
      if isNameChar(tostring(k), Filter) and isFitType(v, Filter) then
        if Str:sub(-1) == ExcludeChar then Str = Str..'\n' end
        if tk == "number" and isArrayKey(k, t) and sfind(Filter, '#') then
          if not sfind(Filter, 'i') then
            Str = ("%s%s%s\n"):format(Str, Indent, ParValue)
          end
        else
          Str = ("%s%s%s=%s\n"):format(Str, Indent, ParName, ParValue)
        end
      elseif ExcludeChar then
        Str = Str..ExcludeChar
      end
    end -- if
  end -- for

  -- Вывод сообщения
  return Str ~= "" and Str.."\n"..Indent.."():\n" or Str
end ---- TabToStr
unit.TabToStr = TabToStr

local DefStrSep = " | "
local DefLineSep = "\n"

-- Разделение строки-таблицы на таблицу строк.
local function StrAsTab (String, Indent, LineCount, CharCount) --> (table)
  if type(LineCount) == 'table' then
    CharCount = LineCount.CharCount
    LineCount = LineCount.LineCount
  end
  --LineCount = LineCount or 23
  --CharCount = CharCount or 76
  LineCount = LineCount or 27
  CharCount = CharCount or 88
  local t, len = {}
  local Sep, lSep = DefStrSep, DefLineSep
  local lenSep = Sep:len()

  local function ClearStr (Str)
    return Str:sub(1, -lenSep):gsub("(%)%:)"..Sep, "%1\n")
  end --
  local function ClearLine (Line)
    return Line:gsub("("..Indent.."%:+)%(%)%:", "%1")--:gsub("^\n", "")
  end --

  local Str, c = "", 0
  local Line, k = "", 0
  String = String:gsub("%z", " ")
  for s in String:gmatch("([^\n]+)") do -- Цикл по строкам
    len = s:len()
    c = c + len + lenSep
    --far.Message(Str, s)
    if c < CharCount and s:sub(1, 1) ~= '(' then
      Str = Str..s..Sep
    else
      Str = ClearStr(Str)
      _, c = Str:gsub("\n", "\n")
      k = k + c
      if k < LineCount then
        if Str ~= "" then Line, k = Line..Str..lSep, k + 1 end
      else
        t[#t+1], Line, k = ClearLine(Line), Str..lSep, 1 + c + 1
        --far.Message({ #t, c, t[#t] }, #t)
      end
      Str, c = s..Sep, len + lenSep
    end -- if
  end -- for s
  t[#t+1] = ClearLine(Line..ClearStr(Str)) -- ..lSep
  return t
end ---- StrAsTab
unit.StrAsTab = StrAsTab

---------------------------------------- Message
-- Вывод сообщения с учётом таблиц.
--[[
  -- @params:
  Value -- содержимое сообщения.
  Title -- заголовок сообщения.
  Depth -- уровень вложенности (nil -- любая вложенность).
  ...
--]]

local function farMsg (Msg, Title, Props)
  return far_Message(Msg, Title, Props.Buttons, Props.Flags, Props.HelpTopic)
end --

local function farShow (Msg, Title, Props)
  return far_Show(Title, Msg)
end --

local function Message (Msg, Title, Depth, Filter, Props, Show)
  if type(Depth) == 'string' then
    Show, Props, Filter, Depth = Props, Filter, Depth, nil
  end
  Props = Props or {}
  if not Props.Flags or not sfind(Props.Flags, 'l') then
    Props.Flags = (Props.Flags or "")..'l'
  end

  Show = Show or farMsg
  --Show = Show or farShow
  if not Msg or type(Msg) ~= 'table' then return Show(Msg, Title, Props) end

  -- Here is: type(Msg) == 'table'
  local Indent = Props.Indent or ""
  local t = TabToStr(Msg, Indent, Depth or 5, Filter, Props)
  t = StrAsTab(t, Indent, Props.LineCount, Props.CharCount)
  for k, v in ipairs(t) do
    if Show(v, Title, Props) == -1 then return -1 end
  end -- for

  return 0
end ---- Message
unit.Message = Message

function unit.lineMessage (Msg, Title, Depth, Filter, Props, Show)
  if type(Depth) == 'string' then
    Show, Props, Filter, Depth = Props, Filter, Depth, nil
  end

  Props = Props or {}
  Props.CharCount = Props.CharCount or 1

  return Message(Msg, Title, Depth, Filter, Props, Show)
end ----

---------------------------------------- Logging
local logging = {}
local meta = { __index = logging }

function logging:log (...)
  self.file:write(...)
end ----

function logging:logln (...)
  self:log(...)
  self:log('\n')
end ----

function logging:Message (Msg, Title, Depth, Filter, Props)
  if Title and Title ~= "" then self:log(Title..'\n') end
  local function logMsg (Msg, Title, Props)
    self:log(Msg)
    return 0
  end --
  lineMessage(Msg, Title, Depth, Filter, Props, logMsg)
end ----

function logging:close (s) --< (file table)
  self:log(s or "\nEnd logging\n")
  local f = self.file
  f:flush()
  f:close()
  --return true
end ----

function unit.open (filename, mode, s) --> (file table)
   local self = {
     name = filename,
     file = io_open(filename, mode or "w+"),
   } ---
   if self.file == nil then return end

   setmetatable(self, meta)
   self:log(s or "Start logging\n")

   return self
end ---- open

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
