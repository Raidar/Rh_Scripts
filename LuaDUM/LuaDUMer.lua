--[[ LuaVUM settings ]]--

----------------------------------------
--[[ description:
  -- LuaVUM settings.
  -- Настройка LuaVUM.
--]]
--------------------------------------------------------------------------------
local LUM_Path = "scripts\\Rh_Scripts\\LuaVUM\\"

local ArgData = {
  Basic = {
    LuaUMName = "LuaVUM",
    LuaUMPath = LUM_Path,
  }, -- Basic
  Files = {
    FilesPath = LUM_Path.."config\\",
    MenusFile = "LumBinds.lua",
    MenusPath = LUM_Path.."config\\",
    LuaScPath = LUM_Path.."scripts\\",
  }, -- Files
  UMenu = {
    MenuTitleBind = false,
    CompoundTitle = false,
    BottomHotKeys = true,
    CaptAlignText = true,
    TextNamedKeys = true,
    FullNamedKeys = false,
    KeysAlignText = false,
    ShowErrorMsgs = true,
    ReturnToUMenu = false,
  }, -- UMenu
} --- ArgData

return require("Rh_Scripts.LuaUM.LumCfg").Configure(ArgData)
--------------------------------------------------------------------------------
