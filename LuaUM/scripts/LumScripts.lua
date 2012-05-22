--[[ LuaUM ]]--

----------------------------------------
--[[ description:
  -- Examples of simple finctions.
  -- Примеры реализации простых функций.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: LUM.
--]]
--------------------------------------------------------------------------------
local _G = _G

local farUt = require "Rh_Scripts.Utils.farUtils"

----------------------------------------
local F = far.Flags

----------------------------------------
local context = context

----------------------------------------
local logUt = require "Rh_Scripts.Utils.Logging"
local logMsg, linMsg = logUt.Message, logUt.lineMessage

--------------------------------------------------------------------------------

---------------------------------------- Quick information
local far2u = require "far2.utils"

function LuaFarVersion ()
  local Ver = { '\n',
    "FAR Manager: ", far.AdvControl(F.ACTL_GETFARVERSION), '\n\n',
    "LuaFAR: ", tostring(far.LuafarVersion()), '\n',
    "LuaFAR for Editor: ",
    tostring(far2u and far2u.GetPluginVersion and
             far2u.GetPluginVersion() or -- FAR 3+
             lf4ed and lf4ed.version and lf4ed.version() or -- FAR 2
             "unknown"), '\n\n',
    "Lua dll version: ", tostring(_G._VERSION), '\n\n',
    "Plugin Path:\n",
    far.PluginStartupInfo().ModuleName:match("(.*[/\\])"), '\n',
  } --- Ver
  far.Message(table.concat(Ver), "LuaFAR Version", nil, "l")
end ---- LuaFarVersion

-- Глобальное окружение --
function GlobalVarsData ()
  linMsg(_G, "Non-standard global variables", 1, "_")
end ---- GlobalVarsData

---------------------------------------- Hello, World!

-- Окно с сообщением --
function HelloWorldMsg (Args, Cfg)
  local Scope = Cfg.Config.Scope
  far.Message("Hello, world!", "Message ("..Scope.Area..")")
end ---- HelloWorldMsg

-- Текст в редактор --
function HelloWorldText (Args, Cfg)
  local Scope = Cfg.Config.Scope
  if Scope.Area == "editor" then
    editor.InsertText(nil, "Hello, world!")
  else
    panel.InsertCmdLine(nil, "Hello, world!")
  end
end ---- HelloWorldText

---------------------------------------- Functions

-- Глобальное окружение --
function GlobalEnvironment ()
  logMsg(_G, "Global Environment", 0, "_/")
  logMsg(_G._Plugin, "_Plugin data", 0, "_f")
  --logMsg(_G, "Global Environment", 1, "fts")
end ---- GlobalEnvironment

-- Окружение функции --
function FunctionEnvironment ()
  logMsg(getfenv(), "Function Environment", 1, "_/")
end ---- FunctionEnvironment

-- Локальная функция --
local function LocalFunction ()
  return "Some Local Function"
end ---- LocalFunction

local
  CArgs   = "Arguments: %s"
  CDefCfg = "Default Config: %s"

-- Аргументы функции --
function DefaultArguments (Args, Cfg)
  -- [[
  -- 1. Конфигурация среды
  logMsg(Cfg.Item,   CArgs:format"Item",   2)
  --logMsg(Cfg.Config, CArgs:format("Config"), 2)
  for k, v in pairs(Cfg.Config) do
    logMsg(v, CArgs:format("Config: "..k), 1)
  end
  --]]
  -- 2. Проверка __index
  --local DefCfg = getmetatable(Cfg).__index
  --logMsg(DefArg, "Default Config", 2)
  --[[
  -- -- Отдельные значения
  for k, v in pairs(DefCfg) do
    if type(v) ~= 'table' then
      logMsg(v, CDefCfg:format(tostring(k)), 1)
    end
  end
  --]]
  -- -- Отдельные подзначения:
  --logMsg(DefCfg.Config.CfgData, CDefCfg:format"CfgData", 2)
  --logMsg(DefCfg.Config.ArgData, CDefCfg:format"ArgData", 2)
end ---- DefaultArguments

-- Аргументы функции --
function FunctionArguments (Args, Cfg)
  local tp = type(Args)
  -- Число аргументов
  local ArgCount = tp == 'table'  and #Args or
                   tp == 'string' and Args:len() or 0
  logMsg(Args, CArgs:format("count = "..tostring(ArgCount)), 1)
  --[[
  -- 1. Список аргументов.
  for k = 1, ArgCount do -- Аргументы функции:
    logMsg(Args[k], CArgs:format(tostring(k)), 1)
  end
  --]]
  if tp ~= 'table' or ArgCount > 1 then return end
  -- [[
  -- 2. Параметр скрипта.
  local Arg = Args[1]
  if Arg then
    --Arg = Arg()
    logMsg(Arg, "Function argument")
  end
  --]]
end ---- FunctionArguments

-- Функция таблицы --
Var = {}
function Var.SubFunction (Args, Cfg)
  local Scope = Cfg.Config.Scope
  far.Message("Table Function", "Message: "..Scope.Area)
end

--logMsg({ ... }, "LumScripts", 2)

-- Функция модуля --
module ("LumScripts", package.seeall)

function ModFunction (Args, Cfg)
  local Scope = Cfg.Config.Scope
  far.Message("Module Function", "Message: "..Scope.Area)
end

--------------------------------------------------------------------------------
