--[[ LuaEUM menus: Russian ]]--
--[[ LuaEUM--меню: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Separator",

  ----------------------------------------
  Subtitles         = "&Q - Субтитры",

    --hot_SubtitleType    = "Y",
    cap_SubtitleType    = "Тип файла субтитров",
      SubtitleUnknownType   = "Неизвестный тип файла субтитров",
    --hot_CurClauseData   = "L",
    --cap_CurClauseData   = "Current line data",
    cap_CurClauseData   = "Данные по текущей строке",

  CurrentClause     = "&C - Текущая фраза",
    --hot_CurClauseLen    = "D",
    cap_CurClauseLen    = "Длительность фразы",
    --hot_CurClauseGap    = "G",
    cap_CurClauseGap    = "Пауза перед фразой",
                            -- 00:00:00:00,000
      --TimeLenAssaFmt        = "%01d:%02d:%02d.%02d",
      --TimeLenDataFmt        = "%02d:%02d:%02d,%03d",
      TimeLenMsecFmt        = " %s миллисекунд",
      TimeLenTextFmt        = "%d ч %d мин %d,%03d сек",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
