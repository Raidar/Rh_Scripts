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
  
  ChsCharacterMap   = "All characters",

  ChsChars          = "Characters",
    ChsChars_Greek      = "Greek",
    ChsChars_Hebrew     = "Hebrew",
  ChsKeybd          = "Клавиатуры",
    ChsKeybd_Cyrillic   = "Cyrillics",
  ChsMaths          = "Mathematics",
    ChsMaths_Symbols    = "Symbols & signs",
    ChsMaths_Scripts    = "Various indexes",
  ChsPunct          = "Punctuation",
    ChsPunct_Symbols    = "Symbols",
    ChsPunct_Spaces     = "Space & hyphen",
  ChsTechs          = "Technology",
    ChsTechs_Arrows     = "Arrows",
  ChsDraws          = "Drawings",
    ChsDraws_Boxing     = "Boxing",

  ----------------------------------------
  -- Quotes and brackets:
  LuaQuoteText      = "&Quotes/brackets",
    LuaEnquote          = "&Quote text",
      LuaEnquoteQuotes      = "Quotes",
      LuaEnquoteBrackets    = "Brackets",
      LuaEnquoteOthers      = "Others",
      LuaEnquoteComments    = "Comments",
      LuaEnquoteMarkers     = "Markers",
      LuaEnquoteSpecials    = "Specials",
        LuaQuoteReplace     = " (replacing)",
    LuaDequote          = "&Dequote text",
      LuaDequoteSingle      = "Any &single",
      LuaDequoteDouble      = "Any &double",
      LuaDequoteXmlComment  = "&Xml comment",
      LuaDequoteLuaComment  = "&Lua comment",

  ----------------------------------------
  -- Addon scripts
  AddonScripts      = "&A - Additions",
  
  AdnCharactersMap  = "&H - Characters",

  AdnCalendars      = "&K - Calendars",
    AdnCalendarTerra    = "&C - Calendar",
    AdnCalendarGrego    = "&G - Gregorean calendar",
    AdnCalendarMillo    = "&M - Milleniums' calendar",
    AdnCalendarHekso    = "&H - Hexadecimal calendar",
    AdnCalendarMinimum  = "&I - Min-project of calendar",
    AdnCalendarPern     = "&P - Pernese calendar",

  ----------------------------------------
  -- Other scripts
  OtherScripts      = "&O - Other scripts",

  OthQuickInfo      = "Common &information",
    OthQInfoVersions    = "&Versions used",
    OthQInfoGlobalVars  = "&Global data",
    OthQInfoPackageUnit = "&package content",
    OthQInfoEnvironVars = "&Environment values",

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
