--[[ Action utils ]]--

----------------------------------------
--[[ description:
  -- Running actions.
  -- Выполнение действий.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local far = far
local F = far.Flags

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {
  Run = false,
  Lua = false,
} ---

---------------------------------------- Run
local Run = {
  Process   = false,
  LuaMacro  = false,
  Command   = false,
  CmdLine   = false,
} ---
unit.Run = Run

do
  local popen = io.popen

-- Execute program and return its output.
-- Выполнение программы и возвращение его вывода.
function Run.Process (program) --> (string)
  local h = popen(program)
  if not h then return end
  local out = h:read("*a")
  h:close()

  return out -- console output
end ----

end -- do

do
  local MacroPost = far.MacroPost

-- Run lua-macro.
-- Запуск lua-макроса.
function Run.LuaMacro (Macro, Flags, AKey) --> (bool)
  return MacroPost(Macro, Flags, AKey)
end ----

end -- do

do
  local execute = os.execute

-- Run command from OS shell.
-- Запуск команды из оболочки ОС.
function Run.Command (Command) --> (ErrorLevel)
  return execute(Command)
end ----

end -- do

do
  local CmdFlags = F.KMFLAGS_DISABLEOUTPUT
  --far.Message(CmdFlags, "CmdFlags")

-- Run command from FAR command line.
-- Запуск команды из командной строки FAR.
function Run.CmdLine (Command) --> (integer)
  if panel.SetCmdLine(-1, Command) then
    if context.use.LFVer >= 3 then -- FAR23
    return Run.LuaMacro("if Area.Menu then Keys'Esc' end\nKeys'Enter'", CmdFlags)
    else
    return Run.LuaMacro("$If(Menu) Esc $End Enter", CmdFlags)
    end
  end
end ----

end -- do

---------------------------------------- Lua
local Lua = {
  Split     = false,
  GetArgs   = false,
} ---
unit.Lua = Lua

-- Split to name and arguments.
-- Разбиение на имя и аргументы.
--[[
  -- @params:
  Name    (string) - имя и (возможно) аргументы в скобках.
  DefArgs (string) - аргументы, используемые по умолчанию.
  -- @notes: Пример значения Name:
  "TableName.FunctionName(Arg1, 'Arg2', { Arg3_1, Arg3_2 })"
--]]
function Lua.Split (Name, DefArgs) --> (string, string, boolean)
  if type(Name) == 'string' and
     Name:find("(", 1, true) and Name:sub(-1) == ")" then
    return Name:match("^([^%(]+)%((.+)%)$")
    --return Name:match("([^%(]+)"), Name:match("^[^%(]+%((.+)%)$"), false
  end

  return Name, DefArgs, true
end ---- Split

do
  local loadstring = loadstring
  local format = string.format
  local ArgsFmt = "return { %s }" -- ascii string only

-- Getting arguments.
-- Получение аргументов.
function Lua.GetArgs (Args) --> (table | Args)
  if type(Args) ~= 'string' then return Args end

  -- Загрузка строки как порции.
  local Args, SError = loadstring(format(ArgsFmt, Args))
  if not Args then return nil, SError end

  Args = Args() -- Получение таблицы
  --logShow(Args, "User Args")
  if not Args then return nil, SError end

  return Args
end ---- GetArgs

end -- do

---------------------------------------- Actions:

---------------------------------------- ---- Text/Macro
-- Execute: label action.
-- Выполнение: действие-метка.
function unit.Label () --> (true)
  return true -- Nothing to do
end ----

-- Execute: lua-macro.
-- Выполнение: lua-макрос.
function unit.LuaMacro (Value, Flags) --> (true | nil, error)
  -- WARN: Use Result for future run changes.
  local Result = Run.LuaMacro(Value, Flags)
  if Result == 0 then return nil, "" end
  return true
end ----

-- Execute: insert plain text.
-- Выполнение: вставка обычного текста.
function unit.Plain (Value, Insert, ...) --> (true | nil, error)
  local Result = Insert(Value, ...)
  if Result == nil then return nil, "" end
  return true
end ----

do
  local macUt = require "Rh_Scripts.Utils.Macro"

-- Execute: macro-template.
-- Выполнение: макро-шаблон.
function unit.Macro (Value) --> (true | nil, error)
  local Result, SError = macUt.Execute(Value)
  if Result == nil then return nil, SError end

  return true
end ----

end -- do

---------------------------------------- ---- Command
-- Execute: program as process.
-- Выполнение: программа как процесс.
function unit.Program (Value) --> (string | nil, error)
  local Result = Run.Process(Value)
  if Result == nil then return nil, "" end

  return Result
end ----

-- Execute: command from OS shell.
-- Выполнение: команда из оболочки ОС.
function unit.Command (Value, Format) --> (true | nil, error)
  local Result = Run.Command(Value)
  if Result ~= 0 then return nil, Format:format(Result) end

  return true
end ----

-- Execute: command from command line.
-- Выполнение: команда из командной строки.
function unit.CmdLine (Value, Error) --> (integer | nil, error)
  local Result = Run.CmdLine(Value)
  if Result == nil then return nil, Error end

  return Result
end ----

---------------------------------------- ---- Lua script
do
  local farUt = require "Rh_Scripts.Utils.Utils"

-- Execute: lua function.
-- Выполнение: lua-функция.
function unit.Function (Value, Args, ...) --> (res [, error])
  if type(Value) ~= 'function' then return end

  return farUt.fcall(Value, Args, ...) -- MAYBE: pfcall
end ---- Function

-- Execute: lua script (chunk/function).
-- Выполнение: lua-скрипт (порция/функция).
function unit.Script (Chunk, Function, ChunkArgs, Args, ...) --> (res [, error])
  --logShow({ Function, ChunkArgs, FuncArgs, ... }, Chunk)

  if Chunk == nil then -- Выполнение функции.
    return unit.Function(Function, Args, ...)
  end

  -- Загрузка порции скрипта.
  local f, SError = loadfile(Chunk)
  if not f then return nil, SError end

  local Env, Result = { __index = _G }; setmetatable(Env, Env)
  --logShow(Chunk, Function)
  ChunkArgs = ChunkArgs or Function
  --logShow(ChunkArgs, Chunk)

  -- Выполнение порции скрипта.
  Result, SError = setfenv(f, Env)(ChunkArgs, ...)
  --logShow(ChunkArgs, f)
  if not Function or (Result or SError) then
    return Result, Result == nil and SError
  end

  -- Получение функции скрипта.
  f, SError = farUt.ffind(Env, Function)
  --logShow(Function, f)
  if not f then return nil, SError end

  -- Выполнение функции скрипта.
  return unit.Function(f, Args, ...)
end ---- Script

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
