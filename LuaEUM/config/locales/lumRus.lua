--[[ LuaEUM menus: Russian ]]--
--[[ LuaEUM--меню: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Разделитель",

  MainMenu          = "LUM для Редактора",

  ----------------------------------------
  -- Template Insert:
  TemplateInsert    = "Вставка шаблона",
  TplInsItem        = "&J - Вставка шаблона",

  ----------------------------------------
  -- Quotes and brackets:
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
      LuaDequoteXmlComment  = "&X - Комментарий XML",
      LuaDequoteLuaComment  = "&L - Комментарий Lua",

  ----------------------------------------
  -- Lua scripts:
  LuaScripts        = "&S - Lua-скрипты",
  LuaScripting      = "Примеры Lua-скриптов",

  LuaClearText      = "&C - Чистка текста",
      LuaClearDeleteAllSpaces       = "&L - Удалить все пробелы",
      LuaClearSqueezeSpaceChars     = "&Q - Сжать пробел-символы",
      LuaClearDeleteAllEmptys       = "&E - Удалить все пустые",
      LuaClearSqueezeEmptyLines     = "&Z - Сжать пустые строки",

  LuaTruncateVoid   = "&T - Усечение пустоты",
    LuaTruncCurLine     = "&C - Текущая строка",
    LuaTruncAllLines    = "&A - Все строки текста",
    LuaTruncEndLines    = "&E - Пустой конец файла",
    LuaTruncFileText    = "&T - Текст и конец файла",

  LuaChangeChar     = "&Q - Изменение символов",
      LuaChangeCharTyper    = "&Q - Типографика",
      LuaChangeCharMaths    = "&M - Математика",
      LuaChangeCharSuper    = "&= - Верхний индекс",
      LuaChangeCharSuber    = "&- - Нижний индекс",
      LuaChangeCharRefer    = "&0 - Ссылка-сноска",

  LuaTranscript     = "&X - Транскрибирование",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
