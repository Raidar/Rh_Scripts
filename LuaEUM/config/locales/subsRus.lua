--[[ LuaEUM menus: Russian ]]--
--[[ LuaEUM--меню: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Separator",

  ----------------------------------------
  Subtitles         = "&Q - Субтитры",

  hot_SubtitleType  = "Y",
  cap_SubtitleType  = "Тип файла субтитров",
    SubtitleUnknownType = "Неизвестный тип файла субтитров",

  TimeCalcer        = "&Q - Калькулятор времени",
    hot_CurLineTimeLen  = "D",
    cap_CurLineTimeLen  = "Длительность фразы",
    hot_CurLineTimeGap  = "G",
    cap_CurLineTimeGap  = "Пауза перед фразой",
                            -- 00:00:00:00,000
      --TimeLenAssaFmt        = "%01d:%02d:%02d.%02d",
      --TimeLenDataFmt        = "%02d:%02d:%02d,%03d",
      TimeLenMsecFmt        = "%03d миллисекунд",
      TimeLenTextFmt        = "%d ч %d мин %d,%03d сек",

    hot_CurrentLineData = "Y",
    cap_CurrentLineData = "Данные по текущей строке",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
