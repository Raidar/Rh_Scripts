--[[ LuaEUM menus: English ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Separator",

  MainMenu          = "LUM for Editor",

  ----------------------------------------
  -- Template Insert
  TemplateInsert    = "Template insert",
  TplInsItem        = "&J - Template insert",

  ----------------------------------------
  -- Lua scripts
  LuaScripts        = "&S - Lua scripts",
  LuaScripting      = "Lua-scripts samples",

  LuaTruncateVoid   = "&Truncate void",
    LuaTruncCurLine     = "&Current line",
    LuaTruncAllLines    = "&All text lines",
    LuaTruncEndLines    = "&Empty lines at end",
    LuaTruncFileText    = "File end and &text",

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
      LuaDequoteSingle      = "Dequote any &single",
      LuaDequoteDouble      = "Dequote any &double",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
