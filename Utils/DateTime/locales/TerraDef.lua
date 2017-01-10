--[[ Calendar - Terra: English ]]--

--------------------------------------------------------------------------------
local Data = {
  ----------------------------------------
  Name = "Earth",
  ["Type.Terra"]        = "Calendar",
  ["Type.Gregorean"]    = "Gregorean calendar",
  ["Type.Hexadecimal"]  = "Hexadecimal calendar",
  ["Type.Minimum"]      = "Minimum project of calendar",

  ----------------------------------------
  WeekDay = {
    n = 3,

    [0] = {
      [0] = "Sunday",
      "Monday",     "Tuesday",  "Wednesday",
      "Thursday",   "Friday",   "Saturday",
      [-1] = "Extra.1",
      [-2] = "Extra.2",
    },

    --[[
    [1] = {
      [0] = "7",
      "1", "2", "3",
      "4", "5", "6",
      [-1] = "-1",
      [-2] = "-2",
    },
    --]]

    [2] = {
      [0] = "Su",
      "Mo", "Tu", "We",
      "Th", "Fr", "Sa",
      [-1] = "X1",
      [-2] = "X2",
    },

    [3] = {
      [0] = "Sun",
      "Mon", "Tue", "Wed",
      "Thu", "Fri", "Sat",
      [-1] = "X.1",
      [-2] = "X.2",
    },
  }, -- WeekDay

  ----------------------------------------
  YearMonth = {
    n = 3,

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
