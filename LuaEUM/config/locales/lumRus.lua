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

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
