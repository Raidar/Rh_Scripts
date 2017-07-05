--[[ LUM menus: Russian ]]--
--[[ LUM--меню: русский ]]--

--------------------------------------------------------------------------------
local Data = {

  -- basic
  Separator         = "Разделитель",

  MainMenu          = "Меню LUM",

  ----------------------------------------
  -- Bottom
  EscToQuit         = "Для выхода из меню нажмите Esc",

  ----------------------------------------
  -- No menu
  UserMenu          = "Пользовательское меню",
  NoUserMenu            = "Нет пользовательского меню",

  ----------------------------------------
  -- Config
  ConfigMenu        = "Конфигурация",

  ConfigItem        = "&C - Конфигурация",
    ConfigSep           = "Настройка",
    ConfigBasic         = "&B - Основные параметры",
    ConfigFiles         = "&F - Имена файлов и пути",
    ConfigUMenu         = "&U - Пользовательское меню",

  ----------------------------------------
  -- LuaFAR macros
  LuaFarMacros      = "&` - Макросы LuaFAR",
    LuaFarMacros_Load   = "&` - Загрузить макросы",
    LuaFarMacros_Save   = "&S - Сохранить макросы",

  ----------------------------------------
  -- Character kits
  CharacterKits     = "Наборы символов",
  ChsKitItem        = "&H - Наборы символов",
  
  ChsCharacterMap   = "Все символы",

  ChsChars          = "Буквы",
    ChsChars_Greek      = "Греческие",
    ChsChars_Hebrew     = "Иврит",
  ChsKeybd          = "Клавиатуры",
    ChsKeybd_Cyrillic   = "Кириллица",
  ChsMaths          = "Математика",
    ChsMaths_Symbols    = "Символы и знаки",
    ChsMaths_Scripts    = "Различные индексы",
  ChsPunct          = "Пунктуация",
    ChsPunct_Symbols    = "Символы",
    ChsPunct_Spaces     = "Пробел и черта",
  ChsTechs          = "Технология",
    ChsTechs_Arrows     = "Стрелки",
  ChsDraws          = "Рисование",
    ChsDraws_Boxing     = "Рамки",

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
      LuaEnquoteReplace     = " Замена ",
      LuaEnquoteReadMe      = "ReadMe",
    LuaDequote          = "&D - Раскавычивание",
      LuaDequoteSingle      = "&S - Любое одинарное",
      LuaDequoteDouble      = "&D - Любое двойное",
      LuaDequoteXmlComment  = "&X - Комментарий XML",
      LuaDequoteLuaComment  = "&L - Комментарий Lua",

  ----------------------------------------
  -- Addon scripts
  AddonScripts      = "&A - Дополнения",

  AdnCharactersMap  = "&H - Символы",

  AdnCalendars      = "&K - Календари",
    AdnCalendarTerra    = "&C - Календарь",
    AdnCalendarGrego    = "&G - Григорианский календарь",
    AdnCalendarMillo    = "&M - Календарь тысячелетий",
    AdnCalendarHekso    = "&H - 16-ричный календарь",
    AdnCalendarMinimum  = "&I - Проект-минимум календаря",
    AdnCalendarPern     = "&P - Пернский календарь",

  ----------------------------------------
  -- Other scripts
  OtherScripts      = "&O - Разные скрипты",

  OthQuickInfo      = "&I - Общая информация",
    OthQInfoVersions    = "&V - Используемые версии",
    OthQInfoGlobalVars  = "&G - Глобальные данные",
    OthQInfoPackageUnit = "&P - Содержимое package",
    OthQInfoEnvironVars = "&E - Переменные окружения",

  OthLFcontext      = "&X - Применение LF context",
    OthLFcDetectType    = "&Y - Определение типа",
    OthLFcOpenFiles     = "&F - Список открытых файлов",
    OthLFcSepInfo       = "LF context Data",
    OthLFcBriefInfo     = "&B - Краткая информация",
    OthLFcDetailedInfo  = "&D - Подробная информация",
    OthLFcTypesTable    = "&C - Конфигурация типов",
    OthLFcTypesInfo     = "&I - Информация о типах",
    OthLFcTestDetType   = "&T - Тест определения типов",

  OthHelloWorld     = "&H - Пример Hello, world!",
    OthHelloWorldMsg    = "&M - Показ сообщения",
    OthHelloWorldText   = "&I - Вставка текста",

  ----------------------------------------
  -- Command samples
  CommandSamples    = "&M - Примеры команд",

  CmdShowFarDesc    = "Показать FAR description",
    CmdFarDescExec      = "— по команде ОС",
    CmdFarDescProg      = "— как подпроцесс",
    CmdFarDescLine      = "— из командной строки",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
