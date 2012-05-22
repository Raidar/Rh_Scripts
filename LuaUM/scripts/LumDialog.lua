--[[ LuaUM ]]--

----------------------------------------
--[[ description:
  -- LUM settings: Calling dialogs.
  -- Настройка LUM: Вызов диалогов.
--]]
----------------------------------------
--[[ uses:
  nil.
  -- group: LUM.
--]]
--------------------------------------------------------------------------------
local LumDlg = (require "Rh_Scripts.LuaUM.LumCfg").ConfigDlg

----------------------------------------
--local logMsg = (require "Rh_Scripts.Utils.Logging").Message

---------------------------------------- main
function LUM_Dlger (Args, Cfg)
  --logMsg(Args, "Args")
  local Kind = Args[1]
  LumDlg(Cfg.Config, Kind)
end
--------------------------------------------------------------------------------
