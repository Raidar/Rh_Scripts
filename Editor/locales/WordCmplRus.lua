--[[ Word Completion: Russian ]]--
--[[ Завершение слов: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  -- Dialog items texts.
  btn_Ok     = "Ок",
  btn_Close  = "Закрыть",
  btn_Cancel = "Отмена",

  -- Settings dialogs titles.
  cap_Dialog  = "Завершение слов: Параметры",
  cap_DlgAuto = "АвтоЗавершение: Параметры",

  -- Settings dialogs separators.
  sep_TypedWord = "Набранное слово",
  sep_WordsFind = "Поиск слов",
  sep_WordsSort = "Сортировка слов",
  sep_WordsList = "Список слов",
  sep_TypedCmpl = "Завершение слова",

  -- Settings dialogs texts.
  cfg_Enabled = "Включить скрипт&!",

     -- Typed word properties:
  cfg_CharEnum = "Символ&ы слова",                  -- ы --
  cfg_CharsMin = " Минимал&ьное число символов",    -- ь -
  cfg_UseMagic = '"Ма&гические" модификаторы',      -- г --
  cfg_UsePoint = "То&чка как магический символ",    -- ч --
  cfg_UseInside  = "Применять вн&утри слов",        -- у --
  cfg_UseOutside = "Применять вн&е слов",           -- е --

     -- Words' search properties:
  cfg_FindKind = "Вид &поиска",                     -- п --
      cfg_FK_customary = "Обычный",
      cfg_FK_unlimited = "Неограниченный",
      cfg_FK_alternate = "Чередующийся",
      cfg_FK_trimmable = "Балансируемый",
  cfg_FindsMax  = " Максимум слов д&ля поиска",     -- л -
  cfg_MinLength = " Минимальная &длина слова",      -- д -
  cfg_PartFind  = "&Искать внутри слов",            -- и -
  cfg_MatchCase = "Учёт &регистра символов",        -- р --
  cfg_LinesView = "Число анализируемы&х строк:",    -- x -
  cfg_LinesUp   = "- вверх от текущей строки",
  cfg_LinesDown = "- вниз от текущей строки",

     -- Words' sort properties:
  cfg_SortKind = "Вид &сортировки",                 -- с -
      cfg_SK_searching = "По нахождению",
      cfg_SK_character = "По алфавиту",
      cfg_SK_closeness = "По близости",
      cfg_SK_frequency = "По встречаемости",
  cfg_SortsMin = " Минимум дл&я сортировки",        -- я -

     -- Words' list properties:
  cfg_ListsMax = " Ма&ксимум слов в списке",        -- к -
  cfg_SlabMark = "&Маркировать набранные символы",  -- м --
  cfg_HotChars  = "Выбор слова с помо&щью Alt",     -- щ -
  cfg_ActionAlt = "Alt для де&йствий по тексту",    -- й -
  cfg_EmptyList  = "Разрешить пуст&ой список",      -- о --
  cfg_EmptyStart = "Пус&той начальный список",      -- т --

     -- Completion properties:
  cfg_Trailers = "Символы-&завершители",            -- з --
  cfg_UndueOut = "Отмена при неверных клави&шах",   -- ш -
  cfg_LoneAuto = "&Автозавершение при одном слове", -- а --
  cfg_TailOnly = "Добавлять только нена&бранное",   -- б -
} --- Data

return Data
--------------------------------------------------------------------------------
