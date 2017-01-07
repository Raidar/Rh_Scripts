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
  -- Lua scripts:
  LuaScripts        = "&S - Lua scripts",
  LuaScripting      = "Lua-scripts samples",

  LuaClearText      = "&C - Clear text",
      LuaClearDeleteAllSpaces       = "Delete a&ll spaces",
      LuaClearSqueezeSpaceChars     = "S&queeze space chars",
      LuaClearDeleteAllEmptys       = "Delete all &empties",
      LuaClearSqueezeEmptyLines     = "Squee&ze empty lines",

  LuaTruncateVoid   = "&T - Truncate void",
    LuaTruncCurLine     = "&Current line",
    LuaTruncAllLines    = "&All text lines",
    LuaTruncEndLines    = "&Empty lines at end",
    LuaTruncFileText    = "File end and &text",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
