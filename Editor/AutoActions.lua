--[[ Auto Actions ]]--

----------------------------------------
--[[ description:
  -- Auto Actions.
  -- Авто-действия.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context,
  Text Templates,
  Word Completion.
  -- areas: editor.
--]]
--------------------------------------------------------------------------------
local _G = _G

----------------------------------------
local editors = ctxdata.editors

----------------------------------------
-- [[
local rhlog = require "Rh_Scripts.Utils.Logging"
local logMsg = rhlog.Message
--]]

--------------------------------------------------------------------------------
-- AutoTemplates -- АвтоШаблоны:
local TT = require "Rh_Scripts.Editor.TextTemplate"
local TT_Execute = TT.Execute
local TT_CfgData = TT.AutoCfgData

-- AutoCompletion -- АвтоЗавершение:
local WC = require "Rh_Scripts.Editor.WordComplete"
local WC_Execute = WC.Execute
local WC_CfgData = WC.AutoCfgData

-- Using AutoTemplates on Word Completion.
-- Использование АвтоШаблонов при Завершении слов.
local function TT_CharPress (FarKey, Char)
  return TT_Execute(TT_CfgData)
end --function TT_CharPress
WC_CfgData.OnCharPress = TT_CharPress

---------------------------------------- Configure

---------------------------------------- Process
local F = far.Flags
local KEY_EVENT = F.KEY_EVENT

local k = 0x00

--far.Message(tostring(KEY_EVENT), "AutoActions")
--local log = rhlog.open("AC_test.log", "a", "")

function ProcessEditorInput (rec) --> (bool)
  if rec.EventType == KEY_EVENT then
    far.RepairInput(rec)
    --log:Message(rec, "rec", nil, "#hv4")
    if rec.KeyDown then
      --k = rec.VirtualKeyCode
      k = (rec.UnicodeChar or " "):byte() or 0x00
      --log:Message('"'..c..'"', "c1", nil, "#hv4")
    elseif k > 0x20 and k ~= 0x7F then
      --log:Message('"'..c..'"', "c2", nil, "#hv4")
      k = 0x00
      --logMsg(rec, "rec", nil, "#hv4")
      --log:Message(rec, "rec", nil, "#hv4")
      TT_CfgData.FileType = editors.current.type
      --logMsg(TT_CfgData, "TT_CfgData", 1, "#")
      --TextTemplate(TT_CfgData)
      if not TT_Execute(TT_CfgData) then
        WC_Execute(WC_CfgData)
      end
    end
  end -- if

  return false
end ----
--------------------------------------------------------------------------------
