--[[ LuaEUM menus: English ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Separator",

  ----------------------------------------
  Subtitles         = "&Q - Subtitles",

  hot_SubtitleType  = "Y",
  cap_SubtitleType  = "Subtitle filetype",
    SubtitleUnknownType = "Unknown subtitle filetype",

  TimeCalcer        = "&Q - Time Calculator",
    hot_CurLineTimeLen  = "D",
    cap_CurLineTimeLen  = "Clause duration",
    hot_CurLineTimeGap  = "G",
    cap_CurLineTimeGap  = "Gap before clause",
                            -- 00:00:00:00,000
      TimeLenAssaFmt        = "%01d:%02d:%02d.%02d",
      TimeLenDataFmt        = "%02d:%02d:%02d,%03d",
      TimeLenMsecFmt        = "%03d milliseconds",
      TimeLenTextFmt        = "%d h %d min %d,%03d sec",

    hot_CurrentLineData = "Y",
    cap_CurrentLineData = "Current line data",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
