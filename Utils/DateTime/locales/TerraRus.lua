--[[ Calendar - Terra: Russian ]]--
--[[ Календарь - Земля: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  ----------------------------------------
  Name = "Земля",
  ["Type.Gregorean"] = "Григорианский календарь",

  ----------------------------------------
  WeekDay = {
    n = 3,
    [0] = {
      [0] = "Воскресенье",
      "Понедельник", "Вторник", "Среда",
      "Четверг", "Пятница", "Суббота",
    },
    --[[
    [1] = {
      [0] = "7",
      "1", "2", "3",
      "4", "5", "6",
    },
    --]]
    [2] = {
      [0] = "ВС",
      "ПН", "ВТ", "СР",
      "ЧТ", "ПТ", "СБ",
    },
    [3] = {
      [0] = "Вск",
      "Пнд", "Втр", "Срд",
      "Чтв", "Птн", "Сбт",
    },
  }, -- WeekDay

  ----------------------------------------
  YearMonth = {
    n = 3,
    [0] = {
      "Январь",     "Февраль",      "Март",
      "Апрель",     "Май",          "Июнь",
      "Июль",       "Август",       "Сентябрь",
      "Октябрь",    "Ноябрь",       "Декабрь",
    },
    --[[
    [1] = {
      "1", "2", "3",
      "4", "5", "6",
      "7", "8", "9",
      "°", "¹", "²",
      --"@", "#", "§",
    },
    --]]
    [2] = {
      "Ян", "Фв", "Мр",
      "Ап", "Мй", "Ин",
      "Ил", "Ав", "Се",
      "Ок", "Нб", "Де",
    },
    [3] = {
      "Янв", "Фев", "Мар",
      "Апр", "Май", "Июн",
      "Июл", "Авг", "Сен",
      "Окт", "Ноя", "Дек",
    },
  }, -- YearMonth

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------