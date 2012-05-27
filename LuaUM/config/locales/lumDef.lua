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
  -- FAR macros
  FarMacros         = "&` - FAR macros",
    FarMacros_Load      = "&Load from DB",
    FarMacros_Save      = "&Save  to  DB",

  ----------------------------------------
  -- Character kits
  CharacterKits     = "Character kits",
  ChsKitItem        = "&H - Character kits",

  ChsChars          = "Characters",
    ChsCharsGreekEx     = "Greek characters",
    ChsCharsCyrSlav     = "Cyrillic slavic",
  ChsMaths          = "Mathematics",
    ChsMathsScripts     = "Sub-/superscripts",
    ChsMathsIndexes     = "Other used indexes",
  ChsPunct          = "Punctuation",
    ChsPunctSymbols     = "Symbols",
    ChsPunctSpaHyps     = "Space & hyphen",
  ChsTechs          = "Technology",
    ChsTechs_Arrows     = "Arrows",
  ChsDraws          = "Drawings",
    ChsDraws_Boxing     = "Boxing",

  ----------------------------------------
  -- Command samples
  CommandSamples    = "&M - Commands samples",

  CmdShowFarDesc    = "Show FAR description",
    CmdFarDescExec      = "— by OS exec",
    CmdFarDescProg      = "— as subprocess",
    CmdFarDescLine      = "— from command line",

  ----------------------------------------
  -- Other scripts
  OtherScripts      = "&O - Other scripts",

  OthQuickInfo      = "Common &information",
    OthQInfoVers        = "&Versions",
    OthQInfoGlobal      = "&Global data",

  OthLFcontext      = "Using LF conte&xt",
    OthLFcDetectType    = "Detect t&ype",
    OthLFcOpenFiles     = "Open &files list",
    OthLFcSepInfo       = "LuaFAR context",
    OthLFcBriefInfo     = "&Brief info",
    OthLFcDetailedInfo  = "&Detailed info",
    OthLFcTypesTable    = "types &config",
    OthLFcTypesInfo     = "types &info",
    OthLFcTestDetType   = "&Test type detect",

  OthHelloWorld     = "&Hello, world!",
    OthHelloWorldMsg    = "Show &message",
    OthHelloWorldText   = "&Insert text",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
