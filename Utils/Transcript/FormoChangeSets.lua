--[[ FormoChangeSets ]]--

----------------------------------------
--[[ description:
  -- Наборы изменений формы символов.
  -- Change sets for forms of letters.
--]]
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Data

---------------------------------------- ---- SignSuper
unit.SignSuper = {

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

---------------------------------------- ---- SignSuber
unit.SignSuber = {

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

---------------------------------------- ---- SignRefer
unit.SignRefer = {

  ['1'] = '¹', ['2'] = '²', ['3'] = '³', ['4'] = '⁴', ['5'] = '⁵',
  ['6'] = '⁶', ['7'] = '⁷', ['8'] = '⁸', ['9'] = '⁹', ['0'] = '⁰',
  ['+'] = '⁺', ['-'] = '⁻', ['='] = '⁼', ['('] = '⁽', [')'] = '⁾',
  ['@'] = '˚', ['^'] = '†', ['#'] = '‡', --['<'] = 'ʿ', ['>'] = 'ʾ',

} -- SignRefer

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------