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

  LuaTruncateVoid   = "&Truncate void",
    LuaTruncCurLine     = "&Current line",
    LuaTruncAllLines    = "&All text lines",
    LuaTruncEndLines    = "&Empty lines at end",
    LuaTruncFileText    = "File end and &text",

  LuaPairItems      = "&P - Paired items",
    LuaPairUnpair       = "&U - Unpair the block",
      LuaPairUnSingle       = "&S - Unpair single",
      LuaPairUnDouble       = "&D - Unpair double",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
