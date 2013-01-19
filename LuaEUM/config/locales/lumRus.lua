--[[ LuaEUM menus: Russian ]]--
--[[ LuaEUM--меню: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Разделитель",

  MainMenu          = "LUM для Редактора",

  ----------------------------------------
  -- Template Insert
  TemplateInsert    = "Вставка шаблона",
  TplInsItem        = "&J - Вставка шаблона",

  ----------------------------------------
  -- Lua scripts
  LuaScripts        = "&S - Lua-скрипты",
  LuaScripting      = "Примеры Lua-скриптов",

  LuaTruncateVoid   = "&T - Усечение пустоты",
    LuaTruncCurLine     = "&C - Текущая строка",
    LuaTruncAllLines    = "&A - Все строки текста",
    LuaTruncEndLines    = "&E - Пустой конец файла",
    LuaTruncFileText    = "&T - Текст и конец файла",

  LuaQuoteText      = "&Q - Кавычки/скобки",
    LuaEnquote          = "&Q - Закавычивание",
      LuaEnquoteQuotes      = "Кавычки",
      LuaEnquoteBrackets    = "Скобки",
      LuaEnquoteOthers      = "Другие",
      LuaEnquoteComments    = "Комментарии",
      LuaEnquoteMarkers     = "Маркеры",
      LuaEnquoteSpecials    = "Специальные",
        LuaQuoteReplace     = " (замена)",
    LuaDequote          = "&D - Раскавычивание",
      LuaDequoteSingle      = "&S - Любое одинарное",
      LuaDequoteDouble      = "&D - Любое двойное",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
