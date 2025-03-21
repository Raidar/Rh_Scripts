--[[ LiterChangeSets ]]--

----------------------------------------
--[[ description:
  -- Наборы изменений для букв.
  -- Change sets for letters.
--]]
--------------------------------------------------------------------------------

----------------------------------------
--local context = context
--local logShow = context.ShowInfo

local strings = require 'context.utils.useStrings'

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Char: Hanyu Pinyin <-> Palladius
do
  local konal = { -- Общие инициали-согласные
    ['B']  = 'Б',   ['P']  = 'П',  ['M']  = 'М',  ['F'] = 'Ф',
    ['D']  = 'Д',   ['T']  = 'Т',  ['N']  = 'Н',  ['L'] = 'Л',
    ['G']  = 'Г',   ['K']  = 'К',  ['H']  = 'Х',
    ['Zh'] = 'Чж',  ['Ch'] = 'Ч',  ['Sh'] = 'Ш',  ['R'] = 'Ж',
  }

  local hard_konal = { -- Инициали-согласные с "твёрдыми" гласными
    ['Z']  = 'Цз',  ['C']  = 'Ц',  ['S']  = 'С',
  }
  for k, v in pairs(konal) do hard_konal[k] = v end

  local soft_konal = { -- Инициали-согласные с "мягкими" гласными
    ['J']  = 'Цз',  ['Q']  = 'Ц',  ['X']  = 'С',
  }

  local ali_final = { -- Общие финали
                    ['ou']  = 'оу',                                    ['ong']  = 'ун',
    ['a']   = 'а',  ['ai']  = 'ай',  ['ao']  = 'ао', ['an']  = 'ань',  ['ang']  = 'ан',
    ['e']   = 'э',  ['ei']  = 'эй',  ['er']  = 'эр', ['en']  = 'энь',  ['eng']  = 'эн',
  }

  local hard_kon_final = { -- Финали с "твёрдыми" гласными
    ['o']   = 'о',

    ['u']   = 'у',  ['ui']  = 'уй',                  ['un']  = 'унь',
    ['ua']  = 'уа', ['uai'] = 'уай',                 ['uan'] = 'уань', ['uang'] = 'уан',
                    ['uei'] = 'уэй',                 ['uen'] = 'уэнь', ['ueng'] = 'уэн',
    ['uo']  = 'уо',
  }
  for k, v in pairs(ali_final) do hard_kon_final[k] = v end

  local soft_kon_final = { -- Финали с "мягкими" гласными

    ['i']   = 'и',                                   ['in']  = 'инь',  ['ing']  = 'ин',
    ['ia']  = 'я',                   ['iao'] = 'яо', ['ian'] = 'янь',  ['iang'] = 'ян',
    ['ie']  = 'е',
    ['io']  = 'ё',                                                     ['iong'] = 'юн',
    ['iu']  = 'ю',  ['ü']   = 'юй',  ['üe']  = 'юэ', ['ün']  = 'юнь',  ['üan']  = 'юaнь',
  }

  local nul_final = { -- Финали без инициалей-согласных
    ['i']   = 'ы',
    ['wa']  = 'ва', ['wai'] = 'вай',                 ['wan'] = 'вань', ['wang'] = 'ван',
                    ['wei'] = 'вэй',                 ['wen'] = 'вэнь', ['weng'] = 'вэн',
    ['wo']  = 'во',
    ['wu']  = 'у',

    ['yi']  = 'и',                                   ['yin'] = 'инь',  ['ying'] = 'ин',
    ['ya']  = 'я',                   ['yao'] = 'яо', ['yan'] = 'янь',  ['yang'] = 'ян',
    ['ye']  = 'е',
    ['yo']  = 'ё',                                                     ['yong'] = 'юн',
    ['you'] = 'ю',  ['yu']  = 'юй',  ['yue'] = 'юэ', ['yun'] = 'юнь',  ['yuan'] = 'юaнь',
  }
  for k, v in pairs(ali_final) do nul_final[k] = v end
  local upfirst = strings.upfirst
  for k, v in pairs(nul_final) do nul_final[upfirst(k)] = upfirst(v) end

  do
    -- GlifPinyinPallad
    local t = {}
    for k, v in pairs(konal) do -- Согласные
      t[k] = v
    end

    for k, v in pairs(hard_konal) do -- Согласные инициали
      for f, w in pairs(hard_kon_final) do -- с финалями с "твёрдыми" гласными
        t[k..f] = v..w
      end
    end
    for k, v in pairs(soft_konal) do -- Согласные инициали
      for f, w in pairs(soft_kon_final) do -- с финалями с "мягкими" гласными
        t[k..f] = v..w
      end
    end

    for f, w in pairs(nul_final) do -- Финали без инициалей
      t[f] = w
    end

    --logShow(t)

    unit.GlifPinyinPallad = t

    -- GlifPalladPinyin
    local u = {}
    for k, v in pairs(t) do
      u[v] = k
    end

    --logShow(u)

    unit.GlifPalladPinyin = u
  end
end

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
