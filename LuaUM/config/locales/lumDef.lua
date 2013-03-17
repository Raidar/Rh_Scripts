--[[ LUM menus: English ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Separator",

  MainMenu          = "LUM menu",

  ----------------------------------------
  -- Bottom
  EscToQuit         = "Press Esc to exit",

  ----------------------------------------
  -- No menu
  UserMenu          = "User menu",
  NoUserMenu            = "No User menu",

  ----------------------------------------
  -- Config
  ConfigMenu        = "Configuration",

  ConfigItem        = "&C - Configuration",
    ConfigSep           = "Configure",
    ConfigBasic         = "&Basic parameters",
    ConfigFiles         = "&Files and pathes",
    ConfigUMenu         = "&User menu display",

  ----------------------------------------
  -- LuaFAR macros
  LuaFarMacros      = "&` - LuaFAR macros",
    LuaFarMacros_Load   = "&` - Load macros",
    LuaFarMacros_Save   = "&S - Save macros",

  ----------------------------------------
  -- Character kits
  CharacterKits     = "Character kits",
  ChsKitItem        = "&H - Character kits",
  
  ChsCharacterMap   = "Character map",

  ChsChars          = "Characters",
    ChsChars_Greeks     = "Greek characters",
    ChsChars_Cyrils     = "Cyrillic chars",
  ChsMaths          = "Mathematics",
    ChsMathsScripts     = "Sub-/superscripts",
    ChsMathsIndexes     = "Other used indexes",
  ChsPunct          = "Punctuation",
    ChsPunctSymbols     = "Symbols",
    ChsPunct_Spaces     = "Space & hyphen",
  ChsTechs          = "Technology",
    ChsTechs_Arrows     = "Arrows",
  ChsDraws          = "Drawings",
    ChsDraws_Boxing     = "Boxing",

  ----------------------------------------
  -- Addon scripts
  AddonScripts      = "&A - Additions",
    AddonTerraCalendar  = "&C - Calendar",
    AddonPernCalendar   = "&P - Pern Calendar",
    AddonMilloCalendar  = "&M - Milleniums' Calendar",

  ----------------------------------------
  -- Other scripts
  OtherScripts      = "&O - Other scripts",

  OthQuickInfo      = "Common &information",
    OthQInfoVers        = "&Versions",
    OthQInfoGlobal      = "&Global data",
    OthQInfoPackage     = "&package content",

  OthLFcontext      = "Using LF conte&xt",
    OthLFcDetectType    = "Detect t&ype",
    OthLFcOpenFiles     = "Open &files list",
    OthLFcSepInfo       = "LF context Data",
    OthLFcBriefInfo     = "&Brief info",
    OthLFcDetailedInfo  = "&Detailed info",
    OthLFcTypesTable    = "types &config",
    OthLFcTypesInfo     = "types &info",
    OthLFcTestDetType   = "&Test type detect",

  OthHelloWorld     = "&Hello, world!",
    OthHelloWorldMsg    = "Show &message",
    OthHelloWorldText   = "&Insert text",

  ----------------------------------------
  -- Command samples
  CommandSamples    = "&M - Commands samples",

  CmdShowFarDesc    = "Show FAR description",
    CmdFarDescExec      = "— by OS exec",
    CmdFarDescProg      = "— as subprocess",
    CmdFarDescLine      = "— from command line",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
