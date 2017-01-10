--[[ LumFLS settings ]]--

----------------------------------------
--[[ description:
  -- LumFLS settings.
  -- Настройка LumFLS.
--]]
--------------------------------------------------------------------------------
local LUM_Path = "scripts\\Rh_Scripts\\LumFLS\\"

local ArgData = {

  Basic = {
    LuaUMName = "LumFLS",
    LuaUMPath = LUM_Path,

  }, -- Basic

  Files = {
    FilesPath = LUM_Path.."config\\",
    MenusFile = "LumBinds.lua",
    MenusPath = LUM_Path.."config\\",
    LuaScPath = 'scripts\\fl_scripts\\',

  }, -- Files

  UMenu = {
    MenuTitleBind = false,
    CompoundTitle = false,
    BottomHotKeys = false,
    CaptAlignText = false,
    TextNamedKeys = false,
    FullNamedKeys = false,
    KeysAlignText = false,
    ShowErrorMsgs = true,
    ReturnToUMenu = false,

  }, -- UMenu

} --- ArgData

return require("Rh_Scripts.LuaUM.LumCfg").Configure(ArgData)
--------------------------------------------------------------------------------
