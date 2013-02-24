--[[ Hand actions ]]--

----------------------------------------
--[[ description:
  -- Hand actions.
  -- Ручные действия.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Text Templates,
  Word Completion.
  -- areas: editor.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local logShow = context.ShowInfo

--------------------------------------------------------------------------------

---------------------------------------- Config
local Actions = {
  -- Run -- Выполнение:
  Execute = "Execute",
  -- Configuration -- Конфигурация:
  Config  = "ConfigDlg", -- Hand-mode -- Обычный ручной режим
  AutoCfg = "ConfigDlg", -- Auto-mode -- Автоматический режим
  -- Обновление
  --Update = "Update",
} --- Actions

local Packs = {
  -- TextTemplates -- Текстовые шаблоны:
  TT = require "Rh_Scripts.Editor.TextTemplate",
  -- WordCompletion -- Завершение слов:
  WC = require "Rh_Scripts.Editor.WordComplete",
} --- Packs

---------------------------------------- main
local args = (...)
if type(args) ~= 'table' then args = {} end

local Param1, Param2 = args[1], args[2]
--logShow({ Param1, Param2 }, "HA Params")
if not Param1 then return end

-- Package --
local SPack, SAction = Param1:match("^(%w+)%:?(%w-)$")
local Pack = Packs[SPack or ""]
if not Pack then return end

-- Action --
--logShow({ SPack, SAction }, Param1)
local Action = SAction and (Actions[SAction] or SAction) or Actions[SPack]
if SAction == "AutoCfg" then Param2 = Param2 or "AutoCfgData" end
--logShow({ SPack, SAction, Action }, Param1)

return Pack[Action](Param2)
--------------------------------------------------------------------------------
