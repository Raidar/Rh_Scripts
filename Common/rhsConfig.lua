--[[ Rh_Scripts config ]]--

----------------------------------------
--[[ description:
  -- Rh_Scripts pack configurator.
  -- Конфигуратор Rh_Scripts pack.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  far2,
  Rh Utils.
  -- group: Config.
  -- areas: config.
--]]
--------------------------------------------------------------------------------

local pcall = pcall
local ipairs = ipairs
local setmetatable = setmetatable

----------------------------------------
--local bit = bit64
--local bshr = bit.rshift
--local band, bor = bit.band, bit.bor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local win, far = win, far
local F = far.Flags
local farMsg = far.Message

----------------------------------------
local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local isFlag = utils.isFlag
local addNewData = tables.extend

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "rhsConfig"
unit.WorkerPath = utils.PluginWorkPath
unit.ScriptPath = "scripts\\Rh_Scripts\\Common\\"
--local umFilePath = "scripts\\Rh_Scripts\\"

---------------------------------------- ---- Custom
local DefCustom = {
  name = unit.ScriptName,
  path = unit.ScriptPath,

  locale = { kind = 'load', },

} --- DefCustom

---------------------------------------- ---- Config
local CfgDataOrder = {
  -- AddToMenu function lines:
  "sLUMs", -- Меню LUM:
  "mLuaEUM",
  "mLuaEUM_Insert",
  "mLuaEUM_ChsKit",
  "mLuaVUM",
  "mLuaPUM",
  "mLuaDUM",
  "mLumFLS",
  "sScripts", -- Скрипты:
  "mVoidTruncate",
  "mWordComplete", "mAutoComplete",
  "mTextTemplate", "mAutoTemplate",
  "mTT_Update",
  "sSamples", -- Примеры:
  "mKeysInfo",
  "Separator", -- Separator --
  -- MakeResident function lines:
  "rAutoActions", "rTruncAction",

} --- CfgDataOrder
local CfgDataSepPos = tables.find(CfgDataOrder, "Separator", ipairs)

--[[
local AreaNames = {
  e = "editor",
  v = "viewer",
  p = "panels",
  c = "config",
} --- AreaNames
--]]

local DefCfgData = {
  um = {
    FilePath = "scripts\\Rh_Scripts\\",
    FileName = "_usermenu.lua",
    --FileName = "usermenu.lua",
  },
  ----------------------------------------
  -- Обычные пункты меню:
  sLUMs = { -- Меню LUM:
    Area = "evpc",
    enabled = true,
    Name = "UserMenus",
    Title = "User Menus",
    separator = true,
  },
  mLuaEUM = {
    Area = "ec",
    enabled = true,
    Name = "LuaEUM",
    Title = "LU&M for Editor",
    HotKey = "Alt+Shift+F2",
    --Command = "luaeum",
    BasePath = "ScriptsPath",
    FilePath = [[LuaEUM\\LuaEUM]],
    config = {
      enabled = true,
      Title = "LUM for &Editor",
      Param1 = "Config",
    },
    Comment = "-- LUM for Editor.",
  },
  mLuaEUM_Insert = {
    Area = "e",
    enabled = true,
    Name = "LuaEUM_Insert",
    HotKey = "Ctrl+J",
    BasePath = "ScriptsPath",
    FilePath = [[LuaEUM\\LuaEUM]],
    Param1 = "Insert",
    Comment = "  -- Template insert assigned to key.",
  },
  mLuaEUM_ChsKit = {
    Area = "e",
    enabled = true,
    Name = "LuaEUM_ChsKit",
    HotKey = "Ctrl+Shift+H",
    BasePath = "ScriptsPath",
    FilePath = [[LuaEUM\\LuaEUM]],
    Param1 = "Characters",
    Comment = "  -- Characters kit assigned to key.",
  },
  --[==[
  mLuaEUM_Paired = {
    Area = "e",
    enabled = true,
    Name = "LuaEUM_Paired",
    --HotKey = "Ctrl+P",
    BasePath = "ScriptsPath",
    FilePath = [[LuaEUM\\LuaEUM]],
    Param1 = "Paired",
    Comment = "  -- Paired structures handling menu.",
  },
  --]==]
  mLuaVUM = {
    Area = "vc",
    enabled = true,
    Name = "LuaVUM",
    Title = "LU&M for Viewer",
    --HotKey = "Alt+Shift+F2",
    --Command = "luavum",
    BasePath = "ScriptsPath",
    FilePath = [[LuaVUM\\LuaVUM]],
    config = {
      enabled = true,
      Title = "LUM for &Viewer",
      Param1 = "Config",
    },
    Comment = "-- LUM for Viewer.",
  },
  mLuaPUM = {
    Area = "pc",
    enabled = true,
    Name = "LuaPUM",
    Title = "LU&M for Panels",
    --HotKey = "Alt+Shift+F2",
    Command = "luapum",
    BasePath = "ScriptsPath",
    FilePath = [[LuaPUM\\LuaPUM]],
    config = {
      enabled = true,
      Title = "LUM for &Panels",
      Param1 = "Config",
    },
    Comment = "-- LUM for Panels.",
  },
  mLuaDUM = {
    Area = "dc",
    enabled = true,
    Name = "LuaDUM",
    Title = "LU&M for Dialog",
    --HotKey = "Alt+Shift+F2",
    --Command = "luadum",
    BasePath = "ScriptsPath",
    FilePath = [[LuaDUM\\LuaDUM]],
    config = {
      enabled = true,
      Title = "LUM for &Dialog",
      Param1 = "Config",
    },
    Comment = "-- LUM for Dialog.",
  },
  mLumFLS = {
    Area = "evpdc",
    enabled = true,
    Name = "LumFLS",
    Title = "&fl scripts LUM",
    --HotKey = "Alt+Shift+F2",
    Command = "lumfls",
    BasePath = "ScriptsPath",
    FilePath = [[LumFLS\\LumFLS]],
    config = {
      enabled = true,
      Title = "&fl scripts LUM",
      Param1 = "Config",
    },
    Comment = "-- LUM for farlua scripts.",
  },
  ----------------------------------------
  sScripts = { -- Скрипты:
    Area = "evpc",
    enabled = true,
    Name = "Scripts",
    Title = "User Scripts",
    separator = true,
  },
  mVoidTruncate = {
    Area = "e",
    enabled = false,
    Name = "VoidTruncate",
    --Title = "",
    HotKey = "Ctrl+T",
    BasePath = "EditorPath",
    FilePath = "VoidTruncate",
    Param1 = "TruncateFileText",
    Comment = "  -- Void Truncater.",
  },
  mWordComplete = {
    Area = "ec",
    enabled = true,
    Name = "WordComplete",
    Title = "&Word Completion",
    HotKey = "Ctrl+Space",
    --BasePath = "EditorPath",
    --FilePath = "HandActions",
    BasePath = "EditorHandActions",
    Param1 = "WC:Execute",
    config = {
      enabled = true,
      Title = "&Word Completion",
      Param1 = "WC:Config",
    },
    Comment = "  -- Word Completion.",
  },
  mAutoComplete = {
    Area = "c",
    Name = "AutoComplete",
    --HotKey = nil,
    --BasePath = "EditorPath",
    --FilePath = "HandActions",
    BasePath = "EditorHandActions",
    config = {
      enabled = true,
      Title = "&Auto Completion",
      Param1 = "WC:AutoCfg",
    },
  },
  mTextTemplate = {
    Area = "ec",
    Name = "TextTemplate",
    Title = "&Text Templates",
    HotKey = "Shift+Space",
    --BasePath = "EditorPath",
    --FilePath = "HandActions",
    BasePath = "EditorHandActions",
    Param1 = "TT:Execute",
    config = {
      enabled = true,
      Title = "&Text Templates",
      Param1 = "TT:Config",
    },
    Comment = "  -- Text Templates.",
  },
  mAutoTemplate = {
    Area = "c",
    Name = "AutoTemplate",
    --HotKey = nil,
    --BasePath = "EditorPath",
    --FilePath = "HandActions",
    BasePath = "EditorHandActions",
    config = {
      enabled = true,
      Title = "A&uto Templates",
      Param1 = "TT:AutoCfg",
    },
  },
  mTT_Update = {
    Area = "c",
    Name = "TT_Update",
    --Title = "Update Templates",
    --HotKey = nil,
    --BasePath = "EditorPath",
    --FilePath = "HandActions",
    BasePath = "EditorHandActions",
    --Param1 = "WC:Update",
    config = {
      enabled = true,
      Title = "Update Te&mplates",
      Param1 = "TT:Update",
    },
  },
  ----------------------------------------
  sSamples = { -- Примеры:
    Area = "evpc",
    enabled = false,
    Name = "Samples",
    Title = "Samples",
    separator = true,
  },
  mKeysInfo = {
    Area = "evp",
    enabled = true,
    Name = "KeysInfo",
    Title = "&Keys information",
    BasePath = "SamplesPath",
    FilePath = "KeysInfo",
    Comment = "  -- Keys information.",
  },
  ----------------------------------------
  -- Резидентные модули:
  rAutoActions = {
    Area = "e",
    enabled = false,
    Name = "AutoActions",
    BasePath = "EditorPath",
    FilePath = "AutoActions",
    EndComment = " -- Auto Actions",
  },
  rTruncAction = {
    Area = "e",
    enabled = false,
    Name = "TruncAction",
    BasePath = "EditorPath",
    FilePath = "TruncAction",
    EndComment = " -- Truncate Action",
  },

} --- DefCfgData

---------------------------------------- ---- Types
-- Fill DlgTypes table.
local function MakeDlgTypes (cData, aData)

  local DlgTypes = {}
  local t, n, v, w, wc, Area
  --logShow(aData, "aData")
  DlgTypes.umFileName = { Field = "FileName", Type = "edt",
                          Name = "umFileName", Default = aData.um.FileName }

  -- Опции для AddToMenu.
  for k = 1, CfgDataSepPos - 1 do
    n = CfgDataOrder[k]
    v, w = cData[n], aData[n]
    Area = v.Area
    t = { config = {} }; DlgTypes[n] = t
    if Area ~= "c" and not w.separator then
      t.HotKey  = { Field = "HotKey", Type = "edt",
                    Name = "k"..n, Default = w.HotKey }
    end
    if Area ~= "c" then
      t.enabled = { Field = "enabled", Type = "chk",
                    Name = "i"..n, Default = w.enabled }
      t.Title   = { Field = "Title",   Type = "edt",
                    Name = "i"..n, Default = w.Title }
                    --Name = "i"..n, Default = w.Title, SpaceAsNil = true }
    end
    wc = w.config
    --logShow({ n, Area, v, w }, "DlgTypes", 2)
    if Area:find("c") and wc then
      t = t.config
      t.enabled = { Field = "enabled", Type = "chk",
                    Name = "c"..n, Default = wc.enabled }
      t.Title   = { Field = "Title",   Type = "edt",
                    Name = "c"..n, Default = wc.Title or w.Title }
    end
  end

  -- Опции для MakeResident.
  for k = CfgDataSepPos + 1, #CfgDataOrder do
    n = CfgDataOrder[k]
    w = aData[n]
    t = {}; DlgTypes[n] = t
    t.enabled = { Field = "enabled", Type = "chk",
                  Name = "r"..n, Default = w.enabled }
  end

  return DlgTypes

end -- MakeDlgTypes

---------------------------------------- Configure

-- Обработка конфигурации.
local function Configure (ArgData)

  ArgData = addNewData(ArgData or {}, DefCfgData)
  --logShow(ArgData, "ArgData")
  local Custom = datas.customize(ArgData.Custom, DefCustom)

  local History = datas.newHistory(Custom.history.full)
  local CfgData = {}
  --local CfgData = History:field(Custom.Field)

  CfgData.um = History:field("um")
  for k, v in pairs(ArgData) do
    CfgData[k] = History:field(k) -- Чтение текущих значений
    if v.config then
      CfgData[k].config = CfgData[k].config or {}
      setmetatable(CfgData[k].config, { __index = v.config })
      --logShow({ CfgData[k].config, v.config }, "config")

    end
    setmetatable(CfgData[k], { __index = v })

  end -- for
  --logShow(CfgData, "CfgData", 2)

  -- Конфигурация:
  local Config = {
    Custom = Custom,
    History = History,
    --DlgTypes = DlgTypes,
    CfgData = CfgData,
    ArgData = ArgData,
    --DefCfgData = DefCfgData,

  } ---

  locale.customize(Config.Custom)
  --logShow(Config.Custom, "Custom")

  return Config

end -- Configure

---------------------------------------- Locale
local LocData -- Данные локализации
local L -- Класс сообщений локализации

---------------------------------------- Dialog
local dialog = require "far2.dialog"
local dlgUt = require "Rh_Scripts.Utils.Dialog"

local DI = dlgUt.DlgItemType
local DIF = dlgUt.DlgItemFlag
local LoadDlgItem, SaveDlgItem = dlgUt.LoadDlgItem, dlgUt.SaveDlgItem

local function ConfigForm (Config) --> (dialog)

  local DBox = Config.DBox
  local isSmall = DBox.Flags and isFlag(DBox.Flags, F.FDLG_SMALLDIALOG)
  local I, J = isSmall and 0 or 3, isSmall and 0 or 1
  local H = DBox.Height - (isSmall and 1 or 2)
  local W = DBox.Width  - (isSmall and 0 or 2)
  --local M = bshr(W, 1) -- Medium -- Width/2
  --local Q = bshr(M, 1) -- Quarta -- Width/4
  W = W - 2 - (isSmall and 0 or 2)
  local A = I + 1
  --local A, B = I + 1, M + 2
  -- Some controls' sizes:
  --local SE = 5  -- Small field
  local HK = DBox.edtHKey       -- HotKey field
  local DE = DBox.lblDesc + 1   -- Desc field
  local CK = DBox.chkItem       -- Check field
  local TX = DBox.edtName       -- Text field
  local I0 =  A +  1; local IH = I0 + HK
  --local I0 =  A + SE; local IH = I0 + HK
  local I1 = IH + DE; local IL = I1 + CK
  local I2 = IL + TX; local IC = I2 + CK
  local I3 = IC + TX; --local IA = I3 + CK

  local Data = Config.CfgData

  local Caption = L:caption"Dialog"
  local D = dialog.NewDialog() -- Форма окна:
                    -- 1          2     3     4   5  6  7  8  9  10
                    -- Type      X1    Y1    X2  Y2  L  H  M  F  Data
  --D._             = {DI.DBox,     I,    J,  W+2,  H; Data = Caption}
  D._             = {DI.DBox,     I,    J,  W+2,  H, 0, 0, 0, 0, Caption}

  J = J + 1 -- Descriptions
    --D.sep         = {DI.Text,     A,    J, I0-1,  0, 0, 0, 0, 0, L:label"Area"}
    --[[
    D.sep         = {DI.Text,    I0,    J, IH-1,  0; Data = L:label"HotKey"}
    D.sep         = {DI.Text,    IH,    J, I1-1,  0; Data = L:label"ItemDesc"}
    D.sep         = {DI.Text,    I1,    J, I2-1,  0; Data = L:label"ItemName"}
    D.sep         = {DI.Text,    I2,    J, I3-1,  0; Data = L:label"ItemCfgName"}
    --]]
    -- [[
    D.sep         = {DI.Text,    I0,    J, IH-1,  0, 0, 0, 0, 0, L:label"HotKey"}
    D.sep         = {DI.Text,    IH,    J, I1-1,  0, 0, 0, 0, 0, L:label"ItemDesc"}
    D.sep         = {DI.Text,    I1,    J, I2-1,  0, 0, 0, 0, 0, L:label"ItemName"}
    D.sep         = {DI.Text,    I2,    J, I3-1,  0, 0, 0, 0, 0, L:label"ItemCfgName"}
    --]]
  -- Свойства конфигурации:
  J = J + 1 -- MenuItems for AddToMenu
  D.sep           = {DI.Text,     0,    J,    0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"MenuItems"}
  for k = 1, CfgDataSepPos - 1 do
    J = J + 1
    local n = CfgDataOrder[k]
    local v = Data[n]
    local Area = v.Area

    --D["txta"..n]  = {DI.Text,     A,    J, I0-1,  0, 0, 0, 0, 0, Area}
    if v.separator then
      D["txts"..n]  = {DI.Text,    I0,    J, IH-2,  0, 0, 0, 0, 0, L:label"Separator"}

    elseif Area ~= "c" then
      D["edtk"..n]  = {DI.Edit,    I0,    J, IH-2,  0, 0, 0, 0, 0, ""}

    end

    do
      D["txti"..n]  = {DI.Text,    IH,    J, I1-1,  0, 0, 0, 0, 0, L:config(v.Name)}
    end

    if Area ~= "c" then
      D["chki"..n]  = {DI.Check,   I1,    J, IL-1,  0, 0, 0, 0, 0, ""}
      D["edti"..n]  = {DI.Edit,    IL,    J, I2-1,  0, 0, 0, 0, 0, ""}

    end

    if Area:find("c") and v.config then
      D["chkc"..n]  = {DI.Check,   I2,    J, IC-1,  0, 0, 0, 0, 0, ""}
      D["edtc"..n]  = {DI.Edit,    IC,    J, I3-1,  0, 0, 0, 0, 0, ""}

    end
  end -- for

  J = J + 1 -- Empty line
  J = J + 1 -- Residents for MakeResident
  D.sep           = {DI.Text,     0,    J,   0,  0, 0, 0, 0, DIF.SeparLine, L:fmtsep"Residents"}
  for k = CfgDataSepPos + 1, #CfgDataOrder do
    J = J + 1
    local n = CfgDataOrder[k]
    local v = Data[n]
    --local Area = v.Area

    --D["txta"..n]  = {DI.Text,     A,    J, I0-2,  0, 0, 0, 0, 0, Area}
    D["txtrk"..n] = {DI.Text,    I0,    J, IH-2,  0, 0, 0, 0, 0, L:config("Res_Keys_"..v.Name)}
    D["txtr"..n]  = {DI.Text,    IH,    J, I1-1,  0, 0, 0, 0, 0, L:config("Res_"..v.Name)}
    D["chkr"..n]  = {DI.Check,   I1,    J, IL-1,  0, 0, 0, 0, 0, ""}
    D["txtrd"..n] = {DI.Text,  IL+1,    J, I3-1,  0, 0, 0, 0, 0, L:config("Res_Desc_"..v.Name)}

  end -- for

  -- Кнопки управления:
  D.sep           = {DI.Text,     0,  H-2,    0,  0, 0, 0, 0, DIF.SeparLine, ""}
  D.btnOk         = {DI.Button,   0,  H-1,    0,  0, 0, 0, 0, DIF.DefButton, L:defbtn"Apply"}
  D.btnCancel     = {DI.Button,   0,  H-1,    0,  0, 0, 0, 0, DIF.DlgButton, L:fmtbtn"Cancel"}
  --D.edtumFileName = {DI.Edit,    IC,  H-1, I3-1,  0, 0, 0, 0, 0, ""}

  return D

end -- ConfigForm

-- Загрузка данных в элементы диалога.
local function LoadDlgData (cData, aData, D, DlgTypes)

  --logShow(aData, "dData")
  --logShow(cData, "cData", 2)

  LoadDlgItem(DlgTypes.umFileName, cData.um, D)

  for k = 1, CfgDataSepPos - 1 do
    local n = CfgDataOrder[k]
    local v, t = cData[n], DlgTypes[n]
    local Area = v.Area

    if Area ~= "c" then
      if not v.separator then
        LoadDlgItem(t.HotKey,  v, D)

      end

      LoadDlgItem(t.enabled, v, D)
      LoadDlgItem(t.Title,   v, D)

    end

    v = v.config
    if Area:find("c") and v then
      t = t.config

      LoadDlgItem(t.enabled, v, D)
      LoadDlgItem(t.Title,   v, D)

    end
  end

  for k = CfgDataSepPos + 1, #CfgDataOrder do
    local n = CfgDataOrder[k]
    local v, t = cData[n], DlgTypes[n]

    LoadDlgItem(t.enabled, v, D)

  end
end -- LoadDlgData

-- Сохранение данных из элементов диалога.
local function SaveDlgData (cData, aData, D, DlgTypes)

  --logShow(aData, "aData")

  SaveDlgItem(DlgTypes.umFileName, cData.um, D)

  for k = 1, CfgDataSepPos - 1 do
    local n = CfgDataOrder[k]
    local v, t = cData[n], DlgTypes[n]
    local Area = v.Area

    if Area ~= "c" then
      if not v.separator then
        SaveDlgItem(t.HotKey,  v, D)

      end

      SaveDlgItem(t.enabled, v, D)
      SaveDlgItem(t.Title,   v, D)

    end

    v = v.config
    if Area:find("c") and v then
      t = t.config

      SaveDlgItem(t.enabled, v, D)
      SaveDlgItem(t.Title,   v, D)

    end
  end

  for k = CfgDataSepPos + 1, #CfgDataOrder do
    local n = CfgDataOrder[k]
    local v, t = cData[n], DlgTypes[n]

    SaveDlgItem(t.enabled, v, D)

  end
end -- SaveDlgData

local ConfigGuid = win.Uuid("140a8bd3-546d-469b-867b-e0e61f9b41af")

local numbers = require 'context.utils.useNumbers'

-- Настройка конфигурации.
function unit.ConfigDlg (Data)

  -- Конфигурация:
  local Config = Configure(Data)
  local HelpTopic = Config.Custom.HelpTopic

  -- Локализация:
  LocData = locale.getData(Config.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not LocData then return end
  L = locale.make(Config.Custom, LocData)

  -- Конфигурация:
  local isSmall = Config.Custom.isSmall
  if isSmall == nil then isSmall = true end

  -- Подготовка:
  Config.DBox = {
    Flags = isSmall and F.FDLG_SMALLDIALOG or nil,
    Width  = 0, FixWidth  = 0,
    Height = 0, FixHeight = 0,
    edtHKey = 16,   -- x1
    lblDesc = 20,   -- x1
    chkItem = 3,    -- x2
    edtName = 16,   -- x2

  } --
  local DBox = Config.DBox

  DBox.FixWidth  = 2 +                  -- Edge
                   2 +                  -- + 2 margins
                   --5 +                -- + 1 column: txt
                   DBox.edtHKey + 1 +   -- + 1 column: edt
                   DBox.lblDesc +       -- + 1 column: txt
                   (DBox.chkItem +
                    DBox.edtName) * 2   -- + 2 columns: chk + edt

  DBox.FixHeight = 2 +                  -- Edge
                   (1 + 1) +            -- + (button separator + buttons)
                   1 +                  -- + group separators
                   2 * 2 +              -- + group empty lines
                   #CfgDataOrder - 1    -- + group item lines

  local FarBox = farUt.GetFarRect()
  local dWidth = FarBox.Width - DBox.FixWidth - 4
  if dWidth > 0 then
    local dExtra = numbers.divf(dWidth, 4)

    local dName = dExtra
    if dName > 0 then
      if dName > 4 then dName = 4 end
      DBox.edtHKey = DBox.edtHKey + dName
      DBox.edtName = DBox.edtName + dName

    end
    local dDesc = (dWidth - dExtra * 4)
    if dDesc > 2 then dDesc = 2 end
    DBox.lblDesc = DBox.lblDesc + dDesc

    --logShow({ dWidth, dName, dDesc, DBox })

  end

  --DBox.Width = DBox.FixWidth
  DBox.Width  = 2 +
                2 +
                --5 +
                DBox.edtHKey + 1 +
                DBox.lblDesc +
                (DBox.chkItem + DBox.edtName) * 2

  DBox.Height = DBox.FixHeight
  --DBox.Height = 2 +
  --              (1 + 1) +
  --              1 +
  --              2*2 +
  --              #CfgDataOrder - 1

  if not isSmall then
    DBox.Width, DBox.Height = DBox.Width + 4*2, DBox.Height + 1*2

  end
  --logShow(DBox, "DBox", 1)

  -- Настройка:
  local D = ConfigForm(Config)
  local cData, aData = Config.CfgData, Config.ArgData
  local DlgTypes = MakeDlgTypes(cData, aData)
  --logShow(DlgTypes, "DlgTypes", 2)

  LoadDlgData(cData, aData, D, DlgTypes)
  local iDlg = dlgUt.Dialog(ConfigGuid, -1, -1,
                            DBox.Width, DBox.Height, HelpTopic, D, DBox.Flags)

  if D.btnOk and iDlg == D.btnOk.id then
    SaveDlgData(cData, aData, D, DlgTypes)
    --logShow(Config.CfgData, "CfgData", 2)
    --logShow(Config.History.Data.rhsConfig, "History")
    Config.History:save()
    local isOk, Result = unit.CreateFile(cData) -- Создание _usermenu.lua
    --logShow({ isOk, Result }, "isOk", 1)

    local MsgTitle = L:t"FileCreate"
    if isOk then
      farMsg(Result.."\n"..L:t"RequireReloadFAR", MsgTitle)

    elseif isOk == false then
      farMsg(Result, MsgTitle, nil, 'w')

    else
      farMsg(Result, MsgTitle)

    end -- if

    return true

  end

end ---- ConfigDlg

---------------------------------------- _usermenu.lua
local _UM = {}
_UM.Start = [==[
--[[ Rh_Scripts ]]--
-- This file is auto-generated. Please, don't edit it.

----------------------------------------
--[[ description:
  -- User menu.
  -- Пользовательское меню.
--]]
---------------------------------------- Check
local CErrorTitle = "Error: Rh_Scripts pack"
local SInstallError = "Package is not properly installed:\n%s"
local farError = function (Msg) return far.Message(Msg, CErrorTitle, nil, 'e') end

if rawget(_G, 'context') == nil then
  farError(SInstallError:format"LuaFAR context is required!")

  return false

end

----------------------------------------
rawset(_G, 'Rh_Scripts', {})

Rh_Scripts.guid = win.Uuid("f0aa2f42-5352-4d11-b8c7-baff33ea3dca")

]==]--_UM.Start
----------------------------------------
_UM.End = [==[

--------------------------------------------------------------------------------
]==]--_UM.End
----------------------------------------
_UM.MenuItems = [==[
---------------------------------------- Items
local ScriptsPath = "scripts\\Rh_Scripts\\"
local EditorPath  = ScriptsPath.."Editor\\"
local SamplesPath = ScriptsPath.."Samples\\"
local EditorHandActions = EditorPath.."HandActions"

]==]--_UM.MenuItems
----------------------------------------
_UM.Commands = [==[

---------------------------------------- Commands

]==]--_UM.Commands
----------------------------------------
--MakeResident("Rh_Scripts.Common.Resident")
_UM.Residents = [==[

---------------------------------------- Residents

]==]--_UM.Residents
----------------------------------------
_UM.AddSepItem  = 'AddToMenu("%s", ":sep:%s")\n'
_UM.AddMenuItem = 'AddToMenu("%s", %s, %s, %s..%s, %s, %s)'
_UM.AddCmdItem  = 'AddCommand("%s", %s..%s, %s)'
_UM.MakeResItem = 'MakeResident(%s..%s)'
_UM.rhsConfig = [==[
-- Rh_Scripts pack configurator.
AddToMenu("c", "&Rh_Scripts package", nil, ScriptsPath.."Common\\rhsConfig")
]==]--_UM.rhsConfig

---------------------------------------- Main make
-- Quote string.
local function q (s) --> (string)

  return (s and s ~= " ") and ('%q'):format(s) or "nil"

end --

-- Name parameter.
local function p (s) --> (string)

  return (s and s ~= " ") and ('"%s"'):format(s) or ''

end --

-- Fix wrong fields args.
-- Exclude trailing nil args.
local function FixLine (s) --> (string)

  local n
  s = s:gsub('%.%.,', ',')
  --s = s:gsub('%.%.\"\",', ',')
  repeat
    s, n = s:gsub("%, nil%)$", "%)", 1)

  until n == 0

  return s

end -- FixLine

local function GenerateFile (f, Data)

  f:write(_UM.Start)
  --logShow(Data, "Data")

  f:write(_UM.MenuItems) -- Menu items:
  f:write(_UM.rhsConfig)
  for k = 1, CfgDataSepPos - 1 do
    local n = CfgDataOrder[k]
    local v = Data[n]
    local Area = v.Area

    if v.separator then f:write("\n") end
    if v.separator and v.enabled then
      f:write(_UM.AddSepItem:format(Area, v.Title or ""))

    else
      local w = v.config

      if v.Comment and (v.enabled or
                        (Area:find("c") and w and w.enabled)) then
        f:write(v.Comment, '\n')

      end

      if Area ~= "c" and v.enabled then
        local s = _UM.AddMenuItem:format(Area:gsub("c", "", 1),
                                         q(v.Title), q(v.HotKey),
                                         v.BasePath, p(v.FilePath),
                                         q(v.Param1), q(v.Param2) )
        f:write(FixLine(s), '\n')

      end

      --logShow({ Area, w, w and w.enabled }, n, 2)
      --logShow({ Area, w, w and getmetatable(w) }, n, 2)
      if Area:find("c") and w and w.enabled then
        local s = _UM.AddMenuItem:format("c",
                                         q(w.Title or v.Title), q(w.HotKey),
                                         w.BasePath or v.BasePath,
                                         p(w.FilePath or v.FilePath),
                                         q(w.Param1), q(w.Param2) )
        f:write(FixLine(s), '\n')

      end
    end
  end -- for

  f:write(_UM.Commands) -- Commands:
  for k = 1, CfgDataSepPos - 1 do
    local n = CfgDataOrder[k]
    local v = Data[n]

    if v.Command and v.enabled then
      local s = _UM.AddCmdItem:format(v.Command,
                                      v.BasePath, p(v.FilePath),
                                      q(v.CmdParam) )
      f:write(FixLine(s), '\n')

    end
  end -- for

  f:write(_UM.Residents) -- Residents:
  for k = CfgDataSepPos + 1, #CfgDataOrder do
    local n = CfgDataOrder[k]
    local v = Data[n]

    if v.enabled then
      f:write(_UM.MakeResItem:format(v.BasePath, p(v.FilePath)))
      if v.EndComment then f:write(v.EndComment) end
      f:write('\n')

    end
  end

  f:write(_UM.End)

end ---- GenerateFile

-- Создание файла в соответствии с пользовательскими настройками.
function unit.CreateFile (Data)

  local um = Data.um
  local umFullName = unit.WorkerPath..um.FilePath..um.FileName

  local f = io.open(umFullName, 'r')
  if f then
    f:close()
    if farMsg(L:t"FileExistsOverwrite",
              L:t"FileCreate", ";OkCancel") ~= 1 then
      return nil, L:t"FileCreatingCancel"

    end
  end

  f = io.open(umFullName, 'w+')
  if not f then return false, L:t"FileNotOpenCreated" end

  --local isOk = true, GenerateFile(f, Data)
  local isOk = pcall(GenerateFile, f, Data)
  f:close()

  return isOk, L:t(isOk and "FileCreatingSuccess" or "FileNewContentError")

end ---- CreateFile

--------------------------------------------------------------------------------
return unit.ConfigDlg()
--------------------------------------------------------------------------------
