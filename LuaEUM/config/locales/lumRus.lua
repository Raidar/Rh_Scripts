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

  LuaTruncateVoid   = "&T - Усечение пустоты",
    LuaTruncCurLine     = "&C - Текущая строка",
    LuaTruncAllLines    = "&A - Все строки текста",
    LuaTruncEndLines    = "&E - Пустой конец файла",
    LuaTruncFileText    = "&T - Текст и конец файла",

  LuaPairItems      = "&P - Парные элементы",
    LuaPairUnpair       = "&U - Снятие пары с блока",
      LuaPairUnSingle       = "&S - Обычная пара",
      LuaPairUnDouble       = "&D - Двойная пара",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
