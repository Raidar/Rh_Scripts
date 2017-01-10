--[[ LuaPUM settings ]]--

----------------------------------------
--[[ description:
  -- LuaPUM settings.
  -- Настройка LuaPUM.
--]]
--------------------------------------------------------------------------------
local LUM_Path = "scripts\\Rh_Scripts\\LuaPUM\\"

local ArgData = {

  Basic = {
    LuaUMName = "LuaPUM",
    LuaUMPath = LUM_Path,

  }, -- Basic

  Files = {
    FilesPath = LUM_Path.."config\\",
    MenusFile = "LumBinds.lua",
    MenusPath = LUM_Path.."config\\",
    LuaScPath = LUM_Path.."scripts\\",

  }, -- Files

  UMenu = {
    MenuTitleBind = true,
    CompoundTitle = false,
    BottomHotKeys = true,
    CaptAlignText = true,
    TextNamedKeys = true,
    FullNamedKeys = true,
    KeysAlignText = true,
    ShowErrorMsgs = true,
    ReturnToUMenu = false,

  }, -- UMenu

} --- ArgData

return require("Rh_Scripts.LuaUM.LumCfg").Configure(ArgData)
--------------------------------------------------------------------------------
