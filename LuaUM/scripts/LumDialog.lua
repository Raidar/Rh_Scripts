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

----------------------------------------
local logShow = context.ShowInfo

----------------------------------------
local LumDlg = (require "Rh_Scripts.LuaUM.LumCfg").ConfigDlg

---------------------------------------- main
function LUM_Dlger (Args, Cfg)

  --logShow(Args, "Args")
  local Kind = Args[1]
  LumDlg(Cfg.Config, Kind)

end
--------------------------------------------------------------------------------
