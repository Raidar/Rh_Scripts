--[[ Date+Time: English ]]--

--------------------------------------------------------------------------------
local Data = {
  -- Dialog items texts.
  btn_Ok     = "Ok",
  btn_Close  = "Close",
  btn_Cancel = "Cancel",

  ----------------------------------------
  Calendar = "Calendar",

  --
  Date              = "Date",
  Time              = "Time",

  ----------------------------------------
  ["Gregorean Calendar"] = "Gregorean Calendar",

  ----------------------------------------
  WeekDay = {
    [0] = {
      [0] = "Sunday",
      "Monday",     "Tuesday",  "Wednesday",
      "Thursday",   "Friday",   "Saturday",
    },
    --[[
    [1] = {
      [0] = "0",
      "1", "2", "3",
      "4", "5", "6",
    },
    --]]
    [2] = {
      [0] = "Su",
      "Mo", "Tu", "We",
      "Th", "Fr", "Sa",
    },
    [3] = {
      [0] = "Sun",
      "Mon", "Tue", "Wed",
      "Thu", "Fri", "Sat",
    },
  }, -- WeekDay

  ----------------------------------------
  YearMonth = {
    [0] = {
      "January",    "February",     "March",
      "April",      "May",          "June",
      "July",       "August",       "September",
      "October",    "November",     "December",
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
      "Ja", "Fe", "Ma",
      "Ap", "My", "Jn",
      "Jy", "Au", "Se",
      "Oc", "Nv", "De",
    },
    [3] = {
      "Jan", "Feb", "Mar",
      "Apr", "May", "Jun",
      "Jul", "Aug", "Sep",
      "Oct", "Nov", "Dec",
    },
  }, -- YearMonth

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
