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
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

---------------------------------------- main
function LUM_Dlger (Args, Cfg)
  --logShow(Args, "Args")
  local Kind = Args[1]
  LumDlg(Cfg.Config, Kind)
end
--------------------------------------------------------------------------------
