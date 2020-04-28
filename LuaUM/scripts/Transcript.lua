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
local TekstChangeSets = {

  SignFixer = true,
  SignTyper = true,
  SignMaths = true,

} -- TekstChangeSets
unit.TekstChangeSets = TekstChangeSets

TekstChangeSets.SignFixer = {
  -- [[DO]]

  -- Текст:
  ["'"]     = '`',   --["''"]   = 'ʻ', -- DEPRECATED
  --["'"]     = 'ʼ',   ["''"]   = 'ʻ', -- DEPRECATED
  ['...']   = '…',   [',..']  = ',…',
  ['!..']   = '!…',  ['?..']  = '?…',
  ['..!']   = '…!',  ['..?']  = '…?',

  -- [[END]]

} -- SignFixer

TekstChangeSets.SignTyper = {
  -- [[DO]]

  -- Математика:
  ['<>']    = '≠', ['=/']   = '≠', ['==']   = '≡', ['==/']  = '≢',
  ['~~']    = '≈', ['~~/']  = '≉', ['~=']   = '≅', ['~=/']  = '≆',
  ['=<']    = '≤', ['=</']  = '≰', ['>=']   = '≥', ['>=/']  = '≱',
  ['~<']    = '≲', ['~</']  = '≴', ['>~']   = '≳', ['>~/']  = '≵',
  ['+-']    = '±', ['-+']   = '∓',
  --['oo']    = '∞', ['o/']   = '∅',

  ['(=)']   = '⊜',
  ['(+)']   = '⊕', ['(-)']  = '⊖', ['(*)']  = '⊛', ['(/)']  = '⊘',
  ['(⋅)']   = '⊙', ['(×)']  = '⊗', ['(∕)']  = '⊘', ['(⁄)']  = '⊘',
  ['(·)']   = '⊙', ['(¤)']  = '⊚', ['(—)']  = '⊝', ['(–)']  = '⊝',
  ['[+]']   = '⊞', ['[-]']  = '⊟', ['[⋅]']  = '⊡', ['[×]']  = '⊠',

  -- Стрелки:
  ['->']    = '→', ['|->']  = '↦', ['<-']   = '←', ['<-|']  = '↤',
  ['|^']    = '↑', ['_|^']  = '↥', ['#|']   = '↓', ['#|‾']  = '↧',

  -- Химия:
  ['\\=\\'] = '⇌', ['/=/']  = '⇋',
  ['--\\']  = '⇀', ['--/']  = '⇁', ['|\\']  = '↾', ['/|']   = '↿',
  ['\\--']  = '↽', ['/--']  = '↼', ['\\|']  = '⇃', ['|/']   = '⇂',

  -- Текст:
  ["'"]     = '`',   --["''"]   = 'ʻ', -- DEPRECATED
  --["'"]     = 'ʼ',   ["''"]   = 'ʻ', -- DEPRECATED
  ['...']   = '…',   [',..']  = ',…',
  ['!..']   = '!…',  ['?..']  = '?…',
  ['..!']   = '…!',  ['..?']  = '…?',

  -- Греческие буквы:
  _a = 'α', _b = 'β', _c = 'χ', _d = 'δ', _e = 'ε',
  _f = 'φ', _g = 'γ', _h = 'η', _i = 'ι', _j = 'ϕ',
  _k = 'κ', _l = 'λ', _m = 'μ', _n = 'ν', _o = 'ο',
  _p = 'π', _q = 'θ', _r = 'ρ', _s = 'σ', _t = 'τ',
  _u = 'υ', _v = 'ϖ', _w = 'ω', _x = 'ξ', _y = 'ψ', _z = 'ζ',

  _A = 'Α', _B = 'Β', _C = 'Χ', _D = 'Δ', _E = 'Ε',
  _F = 'Φ', _G = 'Γ', _H = 'Η', _I = 'Ι', _J = 'ϑ',
  _K = 'Κ', _L = 'Λ', _M = 'Μ', _N = 'Ν', _O = 'Ο',
  _P = 'Π', _Q = 'Θ', _R = 'Ρ', _S = 'Σ', _T = 'Τ',
  _U = 'Υ', _V = 'ϐ', _W = 'Ω', _X = 'Ξ', _Y = 'Ψ', _Z = 'Ζ',

  ['_a~'] = ' ', ['_b~'] = ' ', ['_c~'] = ' ', ['_d~'] = 'ϯ',
  ['_e~'] = 'ϵ', ['_f~'] = 'ϥ', ['_g~'] = 'ϫ', ['_h~'] = 'ϩ',
  ['_i~'] = 'ϳ', ['_j~'] = 'ϰ', ['_k~'] = 'ϗ', ['_l~'] = 'ϡ',
  ['_m~'] = 'ϻ', ['_n~'] = 'ϟ', ['_o~'] = 'ϙ', ['_p~'] = 'ϸ',
  ['_q~'] = ' ', ['_r~'] = 'ϱ', ['_s~'] = 'ς', ['_t~'] = 'ϲ',
  ['_u~'] = 'ϒ', ['_v~'] = 'ϭ', ['_w~'] = 'ϣ', ['_x~'] = 'ϝ',
  ['_y~'] = ' ', ['_z~'] = 'ϛ',

  ['_A~'] = ' ', ['_B~'] = ' ', ['_C~'] = ' ', ['_D~'] = 'Ϯ',
  ['_E~'] = '϶', ['_F~'] = 'Ϥ', ['_G~'] = 'Ϫ', ['_H~'] = 'Ϩ',
  ['_I~'] = ' ', ['_J~'] = 'ϴ', ['_K~'] = 'Ϗ', ['_L~'] = 'Ϡ',
  ['_M~'] = 'Ϻ', ['_N~'] = 'Ϟ', ['_O~'] = 'Ϙ', ['_P~'] = 'Ϸ',
  ['_Q~'] = ' ', ['_R~'] = 'ϼ', ['_S~'] = 'Ͻ', ['_T~'] = 'Ϲ',
  ['_U~'] = ' ', ['_V~'] = 'Ϭ', ['_W~'] = 'Ϣ', ['_X~'] = 'Ϝ',
  ['_Y~'] = ' ', ['_Z~'] = 'Ϛ',

  ["_a'"] = 'ά', ["_e'"] = 'έ', ["_h'"] = 'ή',
  ["_i'"] = 'ί', ["_o'"] = 'ό', ["_u'"] = 'ύ', ["_w'"] = 'ώ',
  ['_i:'] = 'ϊ', ['_ϋ:'] = 'ϋ',

  ["_A'"] = 'Ά', ["_E'"] = 'Έ', ["_H'"] = 'Ή',
  ["_I'"] = 'Ί', ["_O'"] = 'Ό', ["_U'"] = 'Ύ', ["_W'"] = 'Ώ',
  ['_I:'] = 'Ϊ', ['_Ϋ:'] = 'Ϋ',

  -- [[END]]

} -- SignTyper

TekstChangeSets.SignMaths = {
  -- [[DO]]

  -- Буквы:
  ['|N'] = 'ℕ', ['|Z'] = 'ℤ', ['|C'] = 'ℂ',
  ['|P'] = 'ℙ', ['|Q'] = 'ℚ', ['|R'] = 'ℝ',

  ['‾A'] = 'Ā',  ['‾B'] = 'B̅', ['‾C'] = 'C̅', ['‾D'] = 'D̅',
  ['‾E'] = 'Ē',  ['‾F'] = 'F̅', ['‾G'] = 'G̅', ['‾H'] = 'H̅',
  ['‾I'] = 'Ī',  ['‾J'] = 'J̅', ['‾K'] = 'K̅', ['‾L'] = 'L̅',
  ['‾M'] = 'M̅', ['‾N'] = 'N̅', ['‾O'] = 'Ō',  ['‾P'] = 'P̅',
  ['‾Q'] = 'O̅', ['‾R'] = 'R̅', ['‾S'] = 'S̅', ['‾T'] = 'T̅',
  ['‾U'] = 'Ū',  ['‾V'] = 'V̅', ['‾W'] = 'W̅', ['‾X'] = 'X̅',
  ['‾Y'] = 'Ȳ',  ['‾Z'] = 'Z̅',

  ['‾a'] = 'ā',  ['‾b'] = 'b̅', ['‾c'] = 'c̅', ['‾d'] = 'd̅',
  ['‾e'] = 'ē',  ['‾f'] = 'f̅', ['‾g'] = 'g̅', ['‾h'] = 'h̅',
  ['‾i'] = 'ī',  ['‾j'] = 'j̅', ['‾k'] = 'k̅', ['‾l'] = 'l̅',
  ['‾m'] = 'm̅', ['‾n'] = 'n̅', ['‾o'] = 'ō',  ['‾p'] = 'p̅',
  ['‾q'] = 'o̅', ['‾r'] = 'r̅', ['‾s'] = 's̅', ['‾t'] = 't̅',
  ['‾u'] = 'ū',  ['‾v'] = 'v̅', ['‾w'] = 'w̅', ['‾x'] = 'x̅',
  ['‾y'] = 'ȳ',  ['‾z'] = 'z̅',

  ['/A'] = 'Ɐ',  ['/B'] = '/B', ['/C'] = '/C', ['/D'] = '/D',
  ['/E'] = 'Ǝ',  ['/F'] = '/F', ['/G'] = '/G', ['/H'] = '/H',
  ['/I'] = '/I', ['/J'] = '/J', ['/K'] = '/K', ['/L'] = '/L',
  ['/M'] = '/M', ['/N'] = '/N', ['/O'] = '/O', ['/P'] = '/P',
  ['/Q'] = '/O', ['/R'] = '/R', ['/S'] = '/S', ['/T'] = '/T',
  ['/U'] = '/U', ['/V'] = 'Ʌ',  ['/W'] = '/W', ['/X'] = '/X',
  ['/Y'] = '/Y', ['/Z'] = '/Z',

  ['/a'] = 'ɐ',  ['/b'] = '/b', ['/c'] = '/c', ['/d'] = '/d',
  ['/e'] = 'ǝ',  ['/f'] = '/f', ['/g'] = 'ᵷ',  ['/h'] = 'ɥ',
  ['/i'] = 'ᴉ',  ['/j'] = '/j', ['/k'] = 'ʞ',  ['/l'] = '/l',
  ['/m'] = 'ɯ',  ['/n'] = '/n', ['/o'] = '/o', ['/p'] = '/p',
  ['/q'] = '/o', ['/r'] = 'ɹ',  ['/s'] = '/s', ['/t'] = 'ʇ',
  ['/u'] = '/u', ['/v'] = 'ʌ',  ['/w'] = 'ʍ',  ['/x'] = '/x',
  ['/y'] = 'ʎ',  ['/z'] = '/z',

  -- Символы:
  ['-']     = '−',
  ['·']     = '⋅', ['¤']    = '×',

  ['<>']    = '≠', ['=/']   = '≠', ['==']   = '≡', ['==/']  = '≢',
  ['~~']    = '≈', ['~~/']  = '≉', ['~=']   = '≅', ['~=/']  = '≆',
  ['=<']    = '≤', ['=</']  = '≰', ['>=']   = '≥', ['>=/']  = '≱',
  ['~<']    = '≲', ['~</']  = '≴', ['>~']   = '≳', ['>~/']  = '≵',
  ['+-']    = '±', ['-+']   = '∓',
  --['oo']    = '∞', ['o/']   = '∅',

  -- Множества:
  ['(-']    = '∈', ['(-/']  = '∉',
  ['-)']    = '∋', ['-)/']  = '∌',
  ['(=']    = '⊂', ['(=/']  = '⊄',
  ['=)']    = '⊃', ['=)/']  = '⊅',
  ['(_']    = '⊆', ['(_/']  = '⊈',
  ['_)']    = '⊇', ['_)/']  = '⊉',

  ['(=)']   = '⊜',
  ['(+)']   = '⊕', ['(-)']  = '⊖', ['(*)']  = '⊛', ['(/)']  = '⊘',
  ['(⋅)']   = '⊙', ['(×)']  = '⊗', ['(∕)']  = '⊘', ['(⁄)']  = '⊘',
  ['(·)']   = '⊙', ['(¤)']  = '⊚', ['(—)']  = '⊝', ['(–)']  = '⊝',
  ['[+]']   = '⊞', ['[-]']  = '⊟', ['[⋅]']  = '⊡', ['[×]']  = '⊠',

  -- Стрелки:
  ['->']    = '→', ['|->']  = '↦', ['<-']   = '←', ['<-|']  = '↤',
  ['|^']    = '↑', ['_|^']  = '↥', ['#|']   = '↓', ['#|‾']  = '↧',

  -- Химия:
  ['\\=\\'] = '⇌', ['/=/']  = '⇋',
  ['--\\']  = '⇀', ['--/']  = '⇁', ['|\\']  = '↾', ['/|']   = '↿',
  ['\\--']  = '↽', ['/--']  = '↼', ['\\|']  = '⇃', ['|/']   = '⇂',

  -- Текст:
  ["'"]     = '`',   --["''"]   = 'ʻ', -- DEPRECATED
  --["'"]     = 'ʼ',   ["''"]   = 'ʻ', -- DEPRECATED
  ['...']   = '…',   [',..']  = ',…',
  ['!..']   = '!…',  ['?..']  = '?…',
  ['..!']   = '…!',  ['..?']  = '…?',

  -- Индексы:
    -- верхние:
  ['^a'] = 'ᵃ',
  ['^d'] = 'ᵈ',
  ['^h'] = 'ʰ',
  ['^i'] = 'ⁱ', ['^j'] = 'ʲ', ['^k'] = 'ᵏ',
  ['^l'] = 'ˡ', ['^m'] = 'ᵐ', ['^n'] = 'ⁿ',
  ['^o'] = 'ᵒ', ['^p'] = 'ᵖ', --['^q'] = 'q',
  ['^r'] = 'ʳ', ['^s'] = 'ˢ', ['^t'] = 'ᵗ',
  ['^u'] = 'ᵘ', ['^v'] = 'ᵛ', ['^w'] = 'ʷ',
  ['^x'] = 'ˣ', ['^y'] = 'ʸ', ['^z'] = 'ᶻ',
  ['^1'] = '¹', ['^2'] = '²', ['^3'] = '³', ['^4'] = '⁴', ['^5'] = '⁵',
  ['^6'] = '⁶', ['^7'] = '⁷', ['^8'] = '⁸', ['^9'] = '⁹', ['^0'] = '⁰',
  --['^+'] = '⁺', ['^-'] = '⁻', ['^='] = '⁼', ['^('] = '⁽', ['^)'] = '⁾',
  --['^−'] = '⁻',
    -- нижние:
  ['`a'] = 'ₐ',
  ['`h'] = 'ₕ',
  ['`i'] = 'ᵢ', ['`j'] = 'ⱼ', ['`k'] = 'ₖ',
  ['`l'] = 'ₗ', ['`m'] = 'ₘ', ['`n'] = 'ₙ',
  ['`o'] = 'ₒ', ['`p'] = 'ₚ', --['`q'] = 'q',
  ['`r'] = 'ᵣ', ['`s'] = 'ₛ', ['`t'] = 'ₜ',
  ['`u'] = 'ᵤ', ['`v'] = 'ᵥ', --['`w'] = 'w',
  ['`x'] = 'ₓ', --['`y'] = 'y', ['`z'] = 'z',
  ['`1'] = '₁', ['`2'] = '₂', ['`3'] = '₃', ['`4'] = '₄', ['`5'] = '₅',
  ['`6'] = '₆', ['`7'] = '₇', ['`8'] = '₈', ['`9'] = '₉', ['`0'] = '₀',
  --['`+'] = '₊', ['`-'] = '₋', ['`='] = '₌', ['`('] = '₍', ['`)'] = '₎',
  --['`−'] = '₋',

  -- Греческие буквы:
  _a = 'α', _b = 'β', _c = 'χ', _d = 'δ', _e = 'ε', _f = 'φ',
  _g = 'γ', _h = 'η', _i = 'ι', _j = 'ϕ', _k = 'κ', _l = 'λ',
  _m = 'μ', _n = 'ν', _o = 'ο', _p = 'π', _q = 'θ', _r = 'ρ', _s = 'σ',
  _t = 'τ', _u = 'υ', _v = 'ϖ', _w = 'ω', _x = 'ξ', _y = 'ψ', _z = 'ζ',

  _A = 'Α', _B = 'Β', _C = 'Χ', _D = 'Δ', _E = 'Ε', _F = 'Φ',
  _G = 'Γ', _H = 'Η', _I = 'Ι', _J = 'ϑ', _K = 'Κ', _L = 'Λ',
  _M = 'Μ', _N = 'Ν', _O = 'Ο', _P = 'Π', _Q = 'Θ', _R = 'Ρ', _S = 'Σ',
  _T = 'Τ', _U = 'Υ', _V = 'ϐ', _W = 'Ω', _X = 'Ξ', _Y = 'Ψ', _Z = 'Ζ',

  --['_a~'] = ' ', ['_b~'] = ' ', ['_c~'] = ' ', ['_d~'] = 'ϯ',
  --['_e~'] = 'ϵ', ['_f~'] = 'ϥ', ['_g~'] = 'ϫ', ['_h~'] = 'ϩ',
  --['_i~'] = 'ϳ', ['_j~'] = 'ϰ', ['_k~'] = 'ϗ', ['_l~'] = 'ϡ',
  --['_m~'] = 'ϻ', ['_n~'] = 'ϟ', ['_o~'] = 'ϙ', ['_p~'] = 'ϸ',
  --['_q~'] = ' ', ['_r~'] = 'ϱ', ['_s~'] = 'ς', ['_t~'] = 'ϲ',
  --['_u~'] = 'ϒ', ['_v~'] = 'ϭ', ['_w~'] = 'ϣ', ['_x~'] = 'ϝ',
  --['_y~'] = ' ', ['_z~'] = 'ϛ',

  --['_a~'] = ' ', ['_b~'] = ' ', ['_c~'] = ' ', ['_d~'] = 'Ϯ',
  --['_e~'] = '϶', ['_f~'] = 'Ϥ', ['_g~'] = 'Ϫ', ['_h~'] = 'Ϩ',
  --['_i~'] = ' ', ['_j~'] = 'ϴ', ['_k~'] = 'Ϗ', ['_l~'] = 'Ϡ',
  --['_m~'] = 'Ϻ', ['_n~'] = 'Ϟ', ['_o~'] = 'Ϙ', ['_p~'] = 'Ϸ',
  --['_q~'] = ' ', ['_r~'] = 'ϼ', ['_s~'] = 'Ͻ', ['_t~'] = 'Ϲ',
  --['_u~'] = ' ', ['_v~'] = 'Ϭ', ['_w~'] = 'Ϣ', ['_x~'] = 'Ϝ',
  --['_y~'] = ' ', ['_z~'] = 'Ϛ',

  ["_a'"] = 'ά', ["_e'"] = 'έ', ["_h'"] = 'ή',
  ["_i'"] = 'ί', ["_o'"] = 'ό', ["_u'"] = 'ύ', ["_w'"] = 'ώ',
  ['_i:'] = 'ϊ', ['_ϋ:'] = 'ϋ',

  ["_A'"] = 'Ά', ["_E'"] = 'Έ', ["_H'"] = 'Ή',
  ["_I'"] = 'Ί', ["_O'"] = 'Ό', ["_U'"] = 'Ύ', ["_W'"] = 'Ώ',
  ['_I:'] = 'Ϊ', ['_Ϋ:'] = 'Ϋ',

  -- [[END]]

} -- SignMaths

-- TekstChangeSets
----------------------------------------
local LiterChangeSets = {

  CharRusLatin      = true,
  CharLatinRus      = true,

  CharLatinGreek    = true,
  CharGreekLatin    = true,

  CharRusExploro     = true,
  CharExploroRus     = true,

  GrafRusLatin      = true,
  GrafLatinRus      = true,

} -- LiterChangeSets
unit.LiterChangeSets = LiterChangeSets

---------------------------------------- Latin
LiterChangeSets.CharLatinRus = {
  -- [[DO]]

  ["A"] = 'А',
  ["B"] = 'Б',
  ["C"] = 'Ц',
  ["D"] = 'Д',
  ["E"] = 'Э',
  ["F"] = 'Ф',
  ["G"] = 'Г',
  ["H"] = 'Х',
  ["I"] = 'И',
  ["J"] = 'Й',
  ["K"] = 'К',
  ["L"] = 'Л',
  ["M"] = 'М',
  ["N"] = 'Н',
  ["O"] = 'О',
  ["P"] = 'П',
  ["Q"] = 'Кв',
  ["R"] = 'Р',
  ["S"] = 'С',
  ["T"] = 'Т',
  ["U"] = 'У',
  ["V"] = 'В',
  ["W"] = 'В',
  ["X"] = 'Кс',
  ["Y"] = 'Ы',
  ["Z"] = 'З',

  ["KH"] = 'Х', ["Kh"] = 'Х',
  ["YA"] = 'Я', ["Ya"] = 'Я',
  ["YE"] = 'Е', ["Ye"] = 'Е',
  ["YI"] = 'И', ["Yi"] = 'И',
  ["YO"] = 'Ё', ["Yo"] = 'Ё',
  ["YU"] = 'Ю', ["Yu"] = 'Ю',

  -- [[END]]

} -- CharLatinRus

LiterChangeSets.CharRusLatin = {
  -- [[DO]]

  ["А"] = 'A',
  ["Б"] = 'B',
  ["В"] = 'V',
  ["Г"] = 'G',
  ["Д"] = 'D',
  ["Е"] = 'Ye',
  ["Ё"] = 'Yo',
  ["Ж"] = 'J',
  ["З"] = 'Z',
  ["И"] = 'I',
  ["Й"] = 'J',
  ["К"] = 'K',
  ["Л"] = 'L',
  ["М"] = 'M',
  ["Н"] = 'N',
  ["О"] = 'O',
  ["П"] = 'P',
  ["Р"] = 'R',
  ["С"] = 'S',
  ["Т"] = 'T',
  ["У"] = 'U',
  ["Ф"] = 'F',
  ["Х"] = 'H',
  ["Ц"] = 'C',
  ["Ч"] = 'Ch',
  ["Ш"] = 'Sh',
  ["Щ"] = 'Xh',
  ["Ъ"] = '\'',
  ["Ы"] = 'Y',
  ["Ь"] = '\'',
  ["Э"] = 'E',
  ["Ю"] = 'Yu',
  ["Я"] = 'Ya',

  -- [[END]]

} -- CharRusLatin

---------------------------------------- Greek
LiterChangeSets.CharLatinGreek = {
  -- [[DO]]

  ["A"] = 'Α',
  ["B"] = 'Β',
  ["C"] = 'Χ',
  ["D"] = 'Δ',
  ["E"] = 'Ε',
  ["F"] = 'Φ',
  ["G"] = 'Γ',
  ["H"] = 'Η',
  ["I"] = 'Ι',
  ["J"] = 'ϑ',
  ["K"] = 'Κ',
  ["L"] = 'Λ',
  ["M"] = 'Μ',
  ["N"] = 'Ν',
  ["O"] = 'Ο',
  ["P"] = 'Π',
  ["Q"] = 'Θ',
  ["R"] = 'Ρ',
  ["S"] = 'Σ',
  ["T"] = 'Τ',
  ["U"] = 'Υ',
  ["V"] = 'ϐ',
  ["W"] = 'Ω',
  ["X"] = 'Ξ',
  ["Y"] = 'Ψ',
  ["Z"] = 'Ζ',

  ["v"] = 'ϖ',

  -- [[END]]

} -- CharLatinGreek

LiterChangeSets.CharGreekLatin = {
  -- [[DO]]

  ["Α"] = 'A',
  ["Β"] = 'B',
  ["Χ"] = 'C',
  ["Δ"] = 'D',
  ["Ε"] = 'E',
  ["Φ"] = 'F',
  ["Γ"] = 'G',
  ["Η"] = 'H',
  ["Ι"] = 'I',
  ["ϑ"] = 'J',
  ["Κ"] = 'K',
  ["Λ"] = 'L',
  ["Μ"] = 'M',
  ["Ν"] = 'N',
  ["Ο"] = 'O',
  ["Π"] = 'P',
  ["Θ"] = 'Q',
  ["Ρ"] = 'R',
  ["Σ"] = 'S',
  ["Τ"] = 'T',
  ["Υ"] = 'U',
  ["ϐ"] = 'V',
  ["Ω"] = 'W',
  ["Ξ"] = 'X',
  ["Ψ"] = 'Y',
  ["Ζ"] = 'Z',

  ["ϖ"] = 'v',

  -- [[END]]

} -- CharGreekLatin

---------------------------------------- Explo
LiterChangeSets.CharExploroRus = {
  -- [[DO]]

  ["A"] = 'А',
  ["B"] = 'Б',
  ["C"] = 'Ц',
  ["D"] = 'Д',
  ["E"] = 'Э',
  ["F"] = 'Ф',
  ["G"] = 'Г',
  --["H"] = 'Һ',
  ["H"] = 'Х',
  --["I"] = 'И',
  ["I"] = 'Ы',
  ["J"] = 'Ь',
  ["K"] = 'К',
  ["L"] = 'Л',
  ["M"] = 'М',
  ["N"] = 'Н',
  ["O"] = 'О',
  ["P"] = 'П',
  ["Q"] = 'Ж',
  ["R"] = 'Р',
  ["S"] = 'С',
  ["T"] = 'Т',
  ["U"] = 'У',
  ["V"] = 'В',
  --["W"] = 'Ӡ',
  ["W"] = 'ДЗ',
  ["X"] = 'Ш',
  ["Y"] = 'Й',
  ["Z"] = 'З',

  --["KH"] = 'Х', ["Kh"] = 'Х',
  ["YA"] = 'Я', ["Ya"] = 'Я',
  ["YE"] = 'Е', ["Ye"] = 'Е',
  ["YI"] = 'И', ["Yi"] = 'И',
  ["YO"] = 'Ё', ["Yo"] = 'Ё',
  ["YU"] = 'Ю', ["Yu"] = 'Ю',

  ["CJ"] = 'Ч', ["Cj"] = 'Ч',
  ["IJ"] = 'И', ["Ij"] = 'И',
  ["XJ"] = 'Щ', ["Xj"] = 'Щ',

  -- [[END]]

} -- CharExploroRus

LiterChangeSets.CharRusExploro = {
  -- [[DO]]

  ["А"] = 'A',
  ["Б"] = 'B',
  ["В"] = 'V',
  ["Г"] = 'G',
  ["Д"] = 'D',
  ["Е"] = 'Ye',
  ["Ё"] = 'Yo',
  ["Ж"] = 'Q',
  ["З"] = 'Z',
  --["И"] = 'I',
  ["И"] = 'Ij',
  ["Й"] = 'Y',
  ["К"] = 'K',
  ["Л"] = 'L',
  ["М"] = 'M',
  ["Н"] = 'N',
  ["О"] = 'O',
  ["П"] = 'P',
  ["Р"] = 'R',
  ["С"] = 'S',
  ["Т"] = 'T',
  ["У"] = 'U',
  ["Ф"] = 'F',
  ["Х"] = 'H',
  --["Х"] = 'Kh',
  ["Ц"] = 'C',
  ["Ч"] = 'Cj',
  ["Ш"] = 'X',
  ["Щ"] = 'Xj',
  ["Ъ"] = '\'',
  ["Ы"] = 'I',
  ["Ь"] = '\'',
  ["Э"] = 'E',
  ["Ю"] = 'Yu',
  ["Я"] = 'Ya',

  -- [[END]]

} -- CharRusExploro

---------------------------------------- Graf
LiterChangeSets.GrafLatinRus = {
  -- [[DO]]

  ["1"] = 'Т',  ["2"] = '2',
  ["3"] = 'З',  ["4"] = 'Ч',
  ["5"] = 'Б',  ["6"] = 'б',
  ["7"] = 'Т',  ["8"] = 'В',
  ["9"] = 'Э',  ["0"] = 'О',
  ["A"] = 'А',  ["a"] = 'а',
  ["B"] = 'В',  ["b"] = 'ь',
  ["C"] = 'С',  ["c"] = 'с',
  ["D"] = 'О',  ["d"] = 'о',
  ["E"] = 'Е',  ["e"] = 'е',
  ["F"] = 'Т',  ["f"] = 'т',
  ["G"] = 'Б',  ["g"] = 'ф',
  ["H"] = 'Н',  ["h"] = 'н',
  ["I"] = '1',  ["i"] = '1',
  ["J"] = 'Э',  ["j"] = 'э',
  ["K"] = 'К',  ["k"] = 'к',
  ["L"] = 'Ц',  ["l"] = '1',
  ["M"] = 'М',  ["m"] = 'м',
  ["N"] = 'И',  ["n"] = 'п',
  ["O"] = 'О',  ["o"] = 'о',
  ["P"] = 'Р',  ["p"] = 'р',
  ["Q"] = 'О',  ["q"] = '9',
  ["R"] = 'Я',  ["r"] = 'г',
  ["S"] = 'В',  ["s"] = 'в',
  ["T"] = 'Т',  ["t"] = 'т',
  ["U"] = 'Ц',  ["u"] = 'ц',
  ["V"] = 'И',  ["v"] = 'и',
  ["W"] = 'Ж',  ["w"] = 'ж',
  ["X"] = 'Х',  ["x"] = 'х',
  ["Y"] = 'У',  ["y"] = 'у',
  ["Z"] = '2',  ["z"] = '2',

  -- [[END]]

} -- GrafLatinRus

LiterChangeSets.GrafRusLatin = {
  -- [[DO]]

  ["1"] = 'I',  ["2"] = 'Z',
  ["3"] = '3',  ["4"] = '4',
  ["5"] = 'S',  ["6"] = 'b',
  ["7"] = 'Z',  ["8"] = 'B',
  ["9"] = 'g',  ["0"] = 'O',
  ["А"] = 'A',  ["а"] = 'a',
  ["Б"] = 'G',  ["б"] = 'b',
  ["В"] = 'B',  ["в"] = 's',
  ["Г"] = 'r',  ["г"] = 'r',
  ["Д"] = 'U',  ["д"] = 'u',
  ["Е"] = 'E',  ["е"] = 'e',
  ["Ё"] = 'E',  ["ё"] = 'e',
  ["Ж"] = 'W',  ["ж"] = 'w',
  ["З"] = '3',  ["з"] = '3',
  ["И"] = 'N',  ["и"] = 'u',
  ["Й"] = 'N',  ["й"] = 'u',
  ["К"] = 'K',  ["к"] = 'k',
  ["Л"] = 'II', ["л"] = 'n',
  ["М"] = 'M',  ["м"] = 'm',
  ["Н"] = 'H',  ["н"] = 'h',
  ["О"] = 'O',  ["о"] = 'o',
  ["П"] = 'II', ["п"] = 'n',
  ["Р"] = 'P',  ["р"] = 'p',
  ["С"] = 'C',  ["с"] = 'c',
  ["Т"] = 'T',  ["т"] = 't',
  ["У"] = 'Y',  ["у"] = 'y',
  ["Ф"] = 'G',  ["ф"] = 'g',
  ["Х"] = 'X',  ["х"] = 'x',
  ["Ц"] = 'U',  ["ц"] = 'u',
  ["Ч"] = '4',  ["ч"] = '4',
  ["Ш"] = 'III',["ш"] = 'iii',
  ["Щ"] = 'III',["щ"] = 'iii',
  ["Ъ"] = 'b',  ["ъ"] = 'b',
  ["Ы"] = 'bi', ["ы"] = 'bi',
  ["Ь"] = 'b',  ["ь"] = 'b',
  ["Э"] = 'D',  ["э"] = 'o',
  ["Ю"] = 'IO', ["ю"] = 'io',
  ["Я"] = 'R',  ["я"] = 'R',

  -- [[END]]

} -- GrafRusLatin

-- LiterChangeSets
----------------------------------------
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

  CharExploroRus     = true,
  CharRusExploro     = true,

  -- Liter\Graf:
  GrafLatinRus      = true,
  GrafRusLatin      = true,

  -- -- --
  Tekst = TekstChangeSets,
  Liter = LiterChangeSets,

} --- CharChangeSets
unit.CharChangeSets = CharChangeSets

CharChangeSets.SignSuper = {

  a     = 'ᵃ', b     = 'ᵇ', c     = 'ᶜ',
  d     = 'ᵈ', e     = 'ᵉ',
  h     = 'ʰ',
  i     = 'ⁱ', j     = 'ʲ', k     = 'ᵏ',
  l     = 'ˡ', m     = 'ᵐ', n     = 'ⁿ',
  o     = 'ᵒ', p     = 'ᵖ', --q     = 'q',
  r     = 'ʳ', s     = 'ˢ', t     = 'ᵗ',
  u     = 'ᵘ', v     = 'ᵛ', w     = 'ʷ',
  x     = 'ˣ', y     = 'ʸ', z     = 'ᶻ',
  ['1'] = '¹', ['2'] = '²', ['3'] = '³', ['4'] = '⁴', ['5'] = '⁵',
  ['6'] = '⁶', ['7'] = '⁷', ['8'] = '⁸', ['9'] = '⁹', ['0'] = '⁰',
  ['+'] = '⁺', ['-'] = '⁻', ['='] = '⁼', ['('] = '⁽', [')'] = '⁾',
  ['−'] = '⁻',

  ['ₕ'] = 'ʰ',
  ['ᵢ'] = 'ⁱ', ['ⱼ'] = 'ʲ', ['ₖ'] = 'ᵏ',
  ['ₗ'] = 'ˡ', ['ₘ'] = 'ᵐ', ['ₙ'] = 'ⁿ',
  ['₁'] = '¹', ['₂'] = '²', ['₃'] = '³', ['₄'] = '⁴', ['₅'] = '⁵',
  ['₆'] = '⁶', ['₇'] = '⁷', ['₈'] = '⁸', ['₉'] = '⁹', ['₀'] = '⁰',
  ['₊'] = '⁺', ['₋'] = '⁻', ['₌'] = '⁼', ['₍'] = '⁽', ['₎'] = '⁾',

} -- SignSuper

CharChangeSets.SignSuber = {

  a     = 'ₐ', --b     = '', c     = '',
  e     = 'ₑ',
  h     = 'ₕ',
  i     = 'ᵢ', j     = 'ⱼ', k     = 'ₖ',
  l     = 'ₗ', m     = 'ₘ', n     = 'ₙ',
  o     = 'ₒ', p     = 'ₚ', --q     = 'q',
  r     = 'ᵣ', s     = 'ₛ', t     = 'ₜ',
  u     = 'ᵤ', v     = 'ᵥ', --w     = 'w',
  x     = 'ₓ', --y     = 'y', z     = 'z',
  ['1'] = '₁', ['2'] = '₂', ['3'] = '₃', ['4'] = '₄', ['5'] = '₅',
  ['6'] = '₆', ['7'] = '₇', ['8'] = '₈', ['9'] = '₉', ['0'] = '₀',
  ['+'] = '₊', ['-'] = '₋', ['='] = '₌', ['('] = '₍', [')'] = '₎',
  ['−'] = '₋',

  ['ʰ'] = 'ₕ',
  ['ⁱ'] = 'ᵢ', ['ʲ'] = 'ⱼ', ['ᵏ'] = 'ₖ',
  ['ˡ'] = 'ₗ', ['ᵐ'] = 'ₘ', ['ⁿ'] = 'ₙ',
  ['¹'] = '₁', ['²'] = '₂', ['³'] = '₃', ['⁴'] = '₄', ['⁵'] = '₅',
  ['⁶'] = '₆', ['⁷'] = '₇', ['⁸'] = '₈', ['⁹'] = '₉', ['⁰'] = '₀',
  ['⁺'] = '₊', ['⁻'] = '₋', ['⁼'] = '₌', ['⁽'] = '₍', ['⁾'] = '₎',

} -- SignSuber

CharChangeSets.SignRefer = {

  ['1'] = '¹', ['2'] = '²', ['3'] = '³', ['4'] = '⁴', ['5'] = '⁵',
  ['6'] = '⁶', ['7'] = '⁷', ['8'] = '⁸', ['9'] = '⁹', ['0'] = '⁰',
  ['+'] = '⁺', ['-'] = '⁻', ['='] = '⁼', ['('] = '⁽', [')'] = '⁾',
  ['@'] = '˚', ['^'] = '†', ['#'] = '‡', --['<'] = 'ʿ', ['>'] = 'ʾ',

} -- SignRefer

-- CharChangeSets
---------------------------------------- Fill
do

-- Widening set for specifed kind by character forms.
-- Расширение набора указанного вида с учётом формы символов.
local function WidenChangeSets (Base, Kind)

  local t = {}
  local u = CharChangeSets[Base][Kind]

  for k, v in pairs(u) do
    t[k] = v
    local l = k:lower()
    if not t[l] then
      t[l] = v:lower()

    end
  end -- for

  CharChangeSets[Base][Kind] = t

end -- WidenChangeSets
unit.WidenChangeSets = WidenChangeSets

  local makeplain = strings.makeplain

-- Grouping set for specifed kind by key length.
-- Группировка набора указанного вида по длине ключа.
local function GroupChangeSets (Base, Kind)

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

end -- GroupChangeSets
unit.GroupChangeSets = GroupChangeSets

-- Tekst:
GroupChangeSets("Tekst", "SignFixer")
GroupChangeSets("Tekst", "SignTyper")
GroupChangeSets("Tekst", "SignMaths")

-- Liter\Char:
WidenChangeSets("Liter", "CharLatinRus")
GroupChangeSets("Liter", "CharLatinRus")
WidenChangeSets("Liter", "CharRusLatin")
GroupChangeSets("Liter", "CharRusLatin")

WidenChangeSets("Liter", "CharLatinGreek")
GroupChangeSets("Liter", "CharLatinGreek")

WidenChangeSets("Liter", "CharExploroRus")
GroupChangeSets("Liter", "CharExploroRus")
WidenChangeSets("Liter", "CharRusExploro")
GroupChangeSets("Liter", "CharRusExploro")

-- Liter\Graf:
GroupChangeSets("Liter", "GrafLatinRus")
GroupChangeSets("Liter", "GrafRusLatin")

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
