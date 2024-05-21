--[[ LuaUM ]]--

----------------------------------------
--[[ description:
  -- Transcript.
  -- Транскрибирование.
--]]
--------------------------------------------------------------------------------

local pairs = pairs
--local unpack = unpack

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--local utils = require 'context.utils.useUtils'
local strings = require 'context.utils.useStrings'
local locale = require 'context.utils.useLocale'

----------------------------------------
--local farUt = require "Rh_Scripts.Utils.Utils"
local farEdit = require "Rh_Scripts.Utils.Editor"

--local RedrawAll = farUt.RedrawAll

local farBlock = farEdit.Block
local farSelect = farEdit.Selection

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "Transcript"
--unit.WorkerPath = utils.PluginWorkPath
unit.ScriptPath = "scripts\\Rh_Scripts\\LuaUM\\scripts\\"

---------------------------------------- Locale
local Custom = {

  name = unit.ScriptName,
  path = unit.ScriptPath,
  locale = { kind = 'load', },

} --- Custom

local L, e1, e2 = locale.localize(Custom)
if L == nil then
  return locale.showError(e1, e2)

end

---------------------------------------- Configure

---------------------------------------- Data
local TekstChangeSets = require "Rh_Scripts.Utils.Transcript.TekstChangeSets"
unit.TekstChangeSets = TekstChangeSets

local FormoChangeSets = require "Rh_Scripts.Utils.Transcript.FormoChangeSets"
unit.FormoChangeSets = FormoChangeSets

local LiterChangeSets = require "Rh_Scripts.Utils.Transcript.LiterChangeSets"
unit.LiterChangeSets = LiterChangeSets

----------------------------------------
-- TODO: Refactor as above: Add AsIsChangeSets function and extract AsIsChangeSets
local CharChangeSets = {

  -- Tekst:
  SignFixer = true,
  SignTyper = true,
  SignMaths = true,
  --
  SignSuper = true,
  SignSuber = true,
  SignRefer = true,

  -- Liter\Char:
  CharLatinRus      = true,
  CharRusLatin      = true,

  CharLatinGreek    = true,
  CharGreekLatin    = true,

  CharExploroRus    = true,
  CharRusExploro    = true,

  -- Liter\Graf:
  GrafLatinRus      = true,
  GrafRusLatin      = true,

  -- -- --
  Formo = FormoChangeSets,
  Tekst = TekstChangeSets,
  Liter = LiterChangeSets,

} --- CharChangeSets
unit.CharChangeSets = CharChangeSets

---------------------------------------- Fill
do

-- Using as-is set for specifed kind.
-- Использование как-есть набора указанного вида.
local function makePlain (Base, Kind)

  CharChangeSets[Kind] = CharChangeSets[Base][Kind]

end

-- Widening set for specifed kind by character forms.
-- Расширение набора указанного вида с учётом формы символов.
local function makeWiden (Base, Kind)

  local t = {}
  CharChangeSets[Kind] = t
  local u = CharChangeSets[Base][Kind]

  for k, v in pairs(u) do
    t[k] = v
    local l = k:lower()
    if not t[l] then
      t[l] = v:lower()

    end
  end -- for

  CharChangeSets[Base][Kind] = t

end -- makeWiden
unit.makeWiden = makeWiden

  local makeplain = strings.makeplain

-- Grouping set for specifed kind by key length.
-- Группировка набора указанного вида по длине ключа.
local function makeGroup (Base, Kind)

  local t = {}
  CharChangeSets[Kind] = t
  local u = CharChangeSets[Base][Kind]

  local max = 0

  for k, v in pairs(u) do
    if v and v ~= '' then
      local len = k:len()
      if max < len then max = len end

      if t[len] == nil then t[len] = {} end

      t[len][makeplain(k)] = v

    end
  end -- for

  t[0] = max

end -- makeGroup
unit.makeGroup = makeGroup

-- Tekst:
makeGroup("Tekst", "SignFixer")
makeGroup("Tekst", "SignTyper")
makeGroup("Tekst", "SignMaths")

-- Formo:
makePlain("Formo", "SignSuper")
makePlain("Formo", "SignSuber")
makePlain("Formo", "SignRefer")

-- Liter: Char:
makeWiden("Liter", "CharLatinRus")
makeGroup("Liter", "CharLatinRus")
makeWiden("Liter", "CharRusLatin")
makeGroup("Liter", "CharRusLatin")

makeWiden("Liter", "CharLatinGreek")
makeGroup("Liter", "CharLatinGreek")
makeWiden("Liter", "CharGreekLatin")
makeGroup("Liter", "CharGreekLatin")

makeWiden("Liter", "CharExploroRus")
makeGroup("Liter", "CharExploroRus")
makeWiden("Liter", "CharRusExploro")
makeGroup("Liter", "CharRusExploro")

-- Liter: Graf:
makeGroup("Liter", "GrafLatinRus")
makeGroup("Liter", "GrafRusLatin")

end -- do

---------------------------------------- Action
local Actions = {

  default = function (Table) --> (function)

    return function (block) --> (block)

             return farBlock.SubLines(block, ".",
                                      function (s)

                                        return Table[s] or s

                                      end)
           end

  end, -- default

  -- Tekst:
  SignFixer     = false,
  SignTyper     = false,
  SignMaths     = false,

  -- Liter\Char:
  CharLatinRus      = false,
  CharRusLatin      = false,

  CharLatinGreek    = false,
  CharGreekLatin    = false,

  CharExploroRus    = false,
  CharRusExploro    = false,

  -- Liter\Graf:
  GrafLatinRus      = false,
  GrafRusLatin      = false,

} --- Actions
unit.Actions = Actions

do
  local function VarLenAction (Table) --> (function)

    --logShow(Table)

    return function (block) --> (block)

             --logShow(block)

             for k = Table[0], 1, -1 do
               local t = Table[k]
               --logShow(t)
               if t then
                 --logShow(block)
                 for i, v in pairs(t) do
                   block = farBlock.SubLines(block, i, v)

                 end
               end
             end

             --logShow(block)

             return block

           end -- function

  end -- VarLenAction

  for k, v in pairs(Actions) do
    if v == false then
      Actions[k] = VarLenAction

    end
  end
end -- do

local function Execute (Name) --> (function)

  local Table = CharChangeSets[Name]
  if type(Table) ~= 'table' then return end

  local function _Change ()

    local DoChange = (Actions[Name] or Actions.default)(Table)
    --logShow({Name, DoChange})

    return farSelect.Process(false, DoChange)

  end ---- _Change

  return _Change

end -- Execute
unit.Execute = Execute

---------------------------------------- Menu
local Menus = {

  ChangeSign = true,
  ChangeChar = true,

} --- Menus
unit.Menus = Menus

local sSectionFmt = " %s "

Menus.ChangeSign = {

  text = L.ChangeSign,
  --Title = "Change Sign",

  Props = {
    RectMenu = {
      MenuAlign = "CM",

    }, -- RectMenu

  }, -- Props

  Items = {
    { text = L.SignFixer,
      Function = Execute"SignFixer", },
    { text = L.SignTyper,
      Function = Execute"SignTyper", },
    { text = L.SignMaths,
      Function = Execute"SignMaths", },

    { text = "",
      separator = true, },
    { text = L.SignSuper,
      Function = Execute"SignSuper", },
    { text = L.SignSuber,
      Function = Execute"SignSuber", },
    { text = L.SignRefer,
      Function = Execute"SignRefer", },

  }, -- Items

} --- ChangeSign

--Menus.ChangeChar = nil

--logShow({ L.CharChar, L.CharLatinRus, L.CharRusLatin }, "Transcript.lua")

Menus.ChangeChar = {
  text = L.ChangeChar,
  --Title = "Change Char",
  --Title = "Change Char (long caption tested)",

  Props = {
    RectMenu = {
      MenuAlign = "CM",

    }, -- RectMenu

  }, -- Props

  Items = {
    { text = sSectionFmt:format(L.CharChar),
      separator = true, },
    { text = L.CharLatinRus,
      Function = Execute"CharLatinRus", },
    { text = L.CharRusLatin,
      Function = Execute"CharRusLatin", },
    { text = L.CharLatinGreek,
      Function = Execute"CharLatinGreek", },
    { text = L.CharGreekLatin,
      Function = Execute"CharGreekLatin", },
    { text = L.CharExploroRus,
      Function = Execute"CharExploroRus", },
    { text = L.CharRusExploro,
      Function = Execute"CharRusExploro", },

    { text = sSectionFmt:format(L.CharGraf),
      separator = true, },
    { text = L.GrafLatinRus,
      Function = Execute"GrafLatinRus", },
    { text = L.GrafRusLatin,
      Function = Execute"GrafRusLatin", },

  }, -- Items

} --- ChangeChar

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
