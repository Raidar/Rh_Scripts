--[[ flsLUM settings ]]--

----------------------------------------
--[[ description:
  -- flsLUM settings.
  -- Настройка flsLUM.
--]]
--------------------------------------------------------------------------------
local LUM_Path = "scripts\\Rh_Scripts\\flsLUM\\"

local ArgData = {
  Basic = {
    LuaUMName = "flsLUM",
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
  }, --
} --- ArgData

return require("Rh_Scripts.LuaUM.LumCfg").Configure(ArgData)
--------------------------------------------------------------------------------
