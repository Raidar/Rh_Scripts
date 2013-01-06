--[[ Subtitles: English ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Separator",

  ----------------------------------------
  Subtitles         = "&Q - Subtitles",

    hot_SubtitleType    = "Y",
    cap_SubtitleType    = "Subtitle filetype",
      SubtitleUnknownType    = "Unknown subtitle filetype",
    hot_CurClauseData   = "L",
    cap_CurClauseData   = "Current line data",

  CurrentClause     = "&C - Current clause",
    hot_CurClauseLen    = "D",
    cap_CurClauseLen    = "Clause duration",
    hot_CurClauseGap    = "W",
    cap_CurClauseGap    = "Wait for clause",
                            -- 00:00:00:00,000
      TimeLenAssaFmt        = " %1d:%02d:%02d.%02d",
      TimeLenDataFmt        = "%02d:%02d:%02d,%03d",
      TimeLenMsecFmt        = " %s milliseconds",
      TimeLenTextFmt        = "%d h %d min %d,%03d sec",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
