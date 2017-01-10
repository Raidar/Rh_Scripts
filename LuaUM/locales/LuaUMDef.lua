--[[ LUM: English ]]--

--------------------------------------------------------------------------------
local Data = {

  -- Message titles.
  Error = "Error",
  Warning = "Warning",

  -- Information messages.
  UMenuName  = "Lua UM",
  UMenuMenu  = "%s menu",
  UMenuItem  = "%s menu item",
  HKeysHelp  = "Enter,BS,Esc,S+F1,^+F1",
  --HKeysHelp  = "\027\217,\027,Esc,S+F1,^+F1",
  Msgs_File  = "LuaUserMenu messages",
  StrucBind  = "Common bind of structures",
  BindsFile  = "Binds to LUM-menu files",
  UMenuFile  = "LuaUserMenu user menu",

  -- Error messages.
  FileNotFound   = "File not found:\n%s",
  FileDataError  = "Error getting data from file of kind:\n%s. Error description:\n%s",
  IniSecNotFound = "[%s] section not found\nin file %s",
  IniKeyNotFound = "\"%s\" key not found\nin [%s] section\nof file %s",
  MnuSecNotFound = "Menu section not found:\n%s",
  MnuWrongItem   = "Menu item type is wrong:\n'%s' for %s[%d]",
  UnknownCfgGroup = "Unknown group of LUM config:\n%s from %s.\n%s: %s",
  UnknownCfgField = "Unknown field of LUM config:\n%s from %s.\n%s: %s",

  -- Item action error messages.
  LuaMacro_Error  = "Error of running lua-macro.\n%s: %s",
  PlainText_Error = "Error of plain text insert.\n%s: %s",
  MacroText_Error = "Error of macro-template insert.\n%s: %s",
  LuaScript_Error = "Error of lua script execution.\n%s: %s\nError text:\n%s",
  Function_Error  = "Error of lua function execution.\n%s: %s\nError text:\n%s",
  Command_Error   = "Error of OS command execution.\n%s: %s\nError code of command:%d",
  Program_Error   = "Error of program execution.\n%s: %s",
  CmdLine_Error   = "Error of command line execution.\n%s: %s\nError text:\n%s",
  UAction_Error   = "Error: Unknown item action.\n%s: %s",

  -- Dialog items texts.
  btn_Ok     = "Ok",        -- o
  btn_Close  = "Close",     -- c
  btn_Cancel = "Cancel",    -- c
  sep_Default = "Default values",

  -- Settings dialogs titles.
  cap_Basic = "Basic parameters",
  cap_Files = "Files and pathes",
  cap_UMenu = "User menu display",
  btn_Basic = "Basic",
  btn_Files = "Files",
  btn_UMenu = "UMenu",

  -- Settings dialogs texts.

     -- LUM_BasicDlg:
  cfg_LuaUMPath = "&Path to utility...",    -- p
  cfg_LuaUMName = "and &filename base",     -- f
  cfg_LuaUMHint = " + <lng>",
  cfg_DefUMPath = "Base &script path",      -- s
  cfg_UMenuFile = "&Menu file name",        -- m
  cfg_BindsFile = "&Binds file name",       -- b

     -- LUM_FilesDlg:
  cfg_MenusFile = "Menu b&inds file",       -- i
  cfg_FilesPath = "&Base files path",       -- b
  cfg_MenusPath = "&Menu files path",       -- m
  cfg_LuaScPath = "Lua &scripts path",      -- s

     -- LUM_UMenuDlg:
  sep_MenuCaptions  = "Captions in menu",
  sep_MenuItemText  = "Text of menu items",
  sep_MenuAddition  = "Additional options",
  cfg_MenuTitleBind = "Bind name in &MainMenu title",       -- m
  cfg_CompoundTitle = "&Compound caption in menu title",    -- c
  cfg_BottomHotKeys = "Basic hotkeys in menu &bottom",      -- b
  cfg_CaptAlignText = "Text align on &long captions",       -- l
  cfg_TextNamedKeys = "&Key combo in menu item text",       -- k
  cfg_FullNamedKeys = "Key combo &full names in text",      -- f
  cfg_KeysAlignText = "Key combo name right &alignment",    -- a
  cfg_ShowErrorMsgs = "Show windows with &error message",   -- e
  cfg_ReturnToUMenu = "&Return to menu after action run",   -- r

} --- Data

return Data
--------------------------------------------------------------------------------
