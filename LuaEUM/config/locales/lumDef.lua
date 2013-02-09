--[[ LuaEUM menus: English ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Separator",

  MainMenu          = "LUM for Editor",

  ----------------------------------------
  -- Template Insert:
  TemplateInsert    = "Template insert",
  TplInsItem        = "&J - Template insert",

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

  ----------------------------------------
  -- Lua scripts:
  LuaScripts        = "&S - Lua scripts",
  LuaScripting      = "Lua-scripts samples",

  LuaClearText      = "&Clear text",
      LuaClearDeleteAllSpaces       = "Delete a&ll spaces",
      LuaClearSqueezeSpaceChars     = "S&queeze space chars",
      LuaClearDeleteAllEmptys       = "Delete all &empties",
      LuaClearSqueezeEmptyLines     = "Squee&ze empty lines",

  LuaTruncateVoid   = "&Truncate void",
    LuaTruncCurLine     = "&Current line",
    LuaTruncAllLines    = "&All text lines",
    LuaTruncEndLines    = "&Empty lines at end",
    LuaTruncFileText    = "File end and &text",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
