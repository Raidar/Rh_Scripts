--[[ Word Completion: English ]]--

--------------------------------------------------------------------------------
local Data = {

  -- Dialog items texts.
  btn_Ok     = "Ok",
  btn_Close  = "Close",
  btn_Cancel = "Cancel",

  ----------------------------------------

  -- Settings dialogs titles.
  cap_Dialog  = "Word Completion: Settings",
  cap_DlgAuto = "Auto Completion: Settings",

  -- Settings dialogs separators.
  sep_TypedWord = "Typed word", 
  sep_WordsFind = "Words find",
  sep_WordsSort = "Words sort",
  sep_WordsList = "Words list",
  sep_TypedCmpl = "Completion",

  -- Settings dialogs texts.
  cfg_Enabled = "Enable script&!",

     -- Typed word properties:
  cfg_CharEnum = "&Valid word characters",      -- v --
  cfg_CharsMin = " Minimal c&hars count",       -- h -
  cfg_UseMagic = "Use ma&gic chars-modifiers",  -- g --
  cfg_UsePoint = "Use dot &qua magic char",     -- q --
  cfg_UseInside  = "Use &inside of words",      -- i --
  cfg_UseOutside = "Use &outside of words",     -- o --

     -- Words' search properties:
  cfg_FindKind = "Find &kind",                  -- k --
      cfg_FK_customary = "Customary",
      cfg_FK_unlimited = "Unlimited",
      cfg_FK_alternate = "Alternate",
      cfg_FK_trimmable = "Trimmable",
  cfg_FindsMax  = " Maximum words &for search", -- f -
  cfg_MinLength = " Minimal word &length",      -- l -
  cfg_PartFind  = "Search inside &words",       -- w -
  cfg_MatchCase = "Case &sensitive search",     -- s --
  cfg_LinesView = "Analy&zed lines count:",     -- z --
  cfg_LinesUp   = "- up the current line",
  cfg_LinesDown = "- down the current line",

     -- Words' sort properties:
  cfg_SortKind = "Sor&t kind",                  -- t -
      cfg_SK_searching = "Search order",
      cfg_SK_character = "Alphanumeric",
      cfg_SK_closeness = "By closeness",
      cfg_SK_frequency = "By frequency",
  cfg_SortsMin = " Minimum words fo&r sort",    -- r -

     -- Words' list properties:
  cfg_ListsMax = " Ma&ximum words in list",     -- x -
  cfg_SlabMark = "&Mark typed characters",      -- m --
  cfg_HotChars  = "Choose wor&d with Alt",      -- d -
  cfg_ActionAlt = "Alt for actions &per text",  -- p -
  cfg_EmptyList  = "Allow &empty list",         -- e --
  cfg_EmptyStart = "Allow empt&y start list",   -- y --

     -- Completion properties:
  cfg_Trailers = "&Completion characters",      -- c --
  cfg_UndueOut = "Cancel on &undue keys",       -- u --
  cfg_LoneAuto = "&Autocompletion on one word", -- a --
  cfg_TailOnly = "Add only u&ntyped chars",     -- n -

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
