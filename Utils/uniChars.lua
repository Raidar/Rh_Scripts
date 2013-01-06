--[[ Unicode chars ]]--

----------------------------------------
--[[ description:
  -- Some Unicode characters.
  -- Некоторые Unicode-символы.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Box Drawings
--[[
  F - shade filler.
  1 - light/single, 2 - double, 3 - heavy.
  A - arc, L - diagonal,
  V - vertical, H - horizontal.
  U/D/L/R - up/down/left/right.
--]]
-- See: interf.[ch]pp (BoxSymbols & BOX_DEF_SYMBOLS enum).
local BoxDrawings = {
  --  UCS-16  code  -- Unicode Standard
  --   UTF-8  char  -- short description
  -- Arc (rounded)
  ArcUL = "╯", -- Light  Arc Up   & Left
  ArcUR = "╰", -- Light  Arc Up   & Right
  ArcDL = "╮", -- Light  Arc Down & Left
  ArcDR = "╭", -- Light  Arc Down & Right
  -- Diagonal
  Cross = "╳", -- Light Diagonal Cross
  Slash = "╱", -- Light Diagonal Upper Right To Lower Left
  Backs = "╲", -- Light Diagonal Upper Left  To Lower Right

  --  UCS-16  code  -- Unicode Standard		--  OEM  CP:  -- FAR source
  --   UTF-8  char  -- short description	-- Ascii code -- BOX_DEF_SYMBOLS
  -- Shade
  ShadeL = "░", -- Light  Shade					-- B0 -- BS_X_B0
  ShadeM = "▒", -- Medium Shade					-- B1 -- BS_X_B1
  ShadeD = "▓", -- Dark   Shade					-- B2 -- BS_X_B2
  -- Light
  H1   = "─", -- Light  Horz.					-- C4 -- BS_H1
  V1   = "│", -- Light  Vert.					-- B3 -- BS_V1
  U1   = "╵", -- Light  Up
  D1   = "╷", -- Light  Down
  L1   = "╴", -- Light  Left
  R1   = "╶", -- Light  Right
  X1   = "┼", -- Light  Vert. & Horz. == V1H1
  H1d2 = "╌", -- Light  Horz. (Double Dash)
  V1d2 = "╎", -- Light  Vert. (Double Dash)
  H1d3 = "┄", -- Light  Horz. (Triple Dash)
  V1d3 = "┆", -- Light  Vert. (Triple Dash)
  H1d4 = "┈", -- Light  Horz. (Quadruple Dash)
  V1d4 = "┊", -- Light  Vert. (Quadruple Dash)
  -- Double
  H2   = "═", -- Double Horz.					-- CD -- BS_H2
  V2   = "║", -- Double Vert.					-- BA -- BS_V2
  X2   = "╬", -- Double Vert. & Horz. == V2H2
  -- Light x Double
  V1H1 = "┼", -- Light  Vert. & Horz.			-- C5 -- BS_C_H1V1
  V1H2 = "╪", -- Vert. Single & Horz. Double	-- D8 -- BS_C_H2V1
  V2H1 = "╫", -- Vert. Double & Horz. Single	-- D7 -- BS_C_H1V2
  V2H2 = "╬", -- Double Vert. & Horz.			-- CE -- BS_C_H2V2
  V1L1 = "┤", -- Light  Vert. & Left			-- B4 -- BS_R_H1V1
  V1L2 = "╡", -- Light  Vert. & Left  Double	-- B5 -- BS_R_H2V1
  V2L1 = "╢", -- Vert. Double & Left  Single	-- B6 -- BS_R_H1V2
  V2L2 = "╣", -- Vert. Double & Left			-- B9 -- BS_R_H1V2
  V1R1 = "├", -- Light  Vert. & Right			-- C3 -- BS_L_H1V1
  V1R2 = "╞", -- Vert. Single & Right Double	-- C6 -- BS_L_H2V1
  V2R1 = "╟", -- Vert. Double & Right Single	-- C7 -- BS_L_H1V2
  V2R2 = "╠", -- Double Vert. & Right			-- CC -- BS_L_H2V2
  U1H1 = "┴", -- Light  Up    & Horz.			-- C1 -- BS_B_H1V1
  U1H2 = "╧", -- Up    Single & Horz. Double	-- CF -- BS_B_H2V1
  U2H1 = "╨", -- Up    Double & Horz. Single	-- D0 -- BS_B_H1V2
  U2H2 = "╩", -- Double Up    & Horz.			-- CA -- BS_B_H2V2
  U1L1 = "┘", -- Light  Up    & Left			-- D9 -- BS_RB_H1V1
  U1L2 = "╛", -- Up    Single & Left  Double	-- BE -- BS_RB_H2V1
  U2L1 = "╜", -- Up    Double & Left  Single	-- BD -- BS_RB_H1V2
  U2L2 = "╝", -- Double Up    & Left			-- BC -- BS_RB_H2V2
  U1R1 = "└", -- Light  Up    & Right			-- C0 -- BS_LB_H1V1
  U1R2 = "╘", -- Up    Single & Right Double	-- D4 -- BS_LB_H2V1
  U2R1 = "╙", -- Up    Double & Right Single	-- D3 -- BS_LB_H1V2
  U2R2 = "╚", -- Double Up    & Right			-- C8 -- BS_LB_H2V2
  D1H1 = "┬", -- Light  Down  & Horz.			-- C2 -- BS_T_H1V1
  D1H2 = "╤", -- Down  Single & Horz. Double	-- D1 -- BS_T_H2V1
  D2H1 = "╥", -- Down  Double & Horz. Single	-- D2 -- BS_T_H1V2
  D2H2 = "╦", -- Double Down  & Horz.			-- CB -- BS_T_H2V2
  D1L1 = "┐", -- Light  Down  & Left			-- BF -- BS_RT_H1V1
  D1L2 = "╕", -- Down  Single & Left  Double	-- B8 -- BS_RT_H2V1
  D2L1 = "╖", -- Down  Double & Left  Single	-- B7 -- BS_RT_H1V2
  D2L2 = "╗", -- Double Down  & Left			-- BB -- BS_RT_H2V2
  D1R1 = "┌", -- Light  Down  & Right			-- DA -- BS_LT_H1V1
  D1R2 = "╒", -- Down  Single & Right Double	-- D5 -- BS_LT_H2V1
  D2R1 = "╓", -- Down  Double & Right Single	-- D6 -- BS_LT_H1V2
  D2R2 = "╔", -- Double Down  & Right			-- C9 -- BS_LT_H2V2
  -- Heavy
  HY   = "━", -- Heavy Horz.
  VY   = "┃", -- Heavy Vert.
  UY   = "╹", -- Heavy Up
  DY   = "╻", -- Heavy Down
  LY   = "╸", -- Heavy Left
  RY   = "╺", -- Heavy Right
  XY   = "╋", -- Heavy Vert. & Horz. == VYHY
  HYd2 = "╍", -- Heavy Horz. (Double Dash)
  VYd2 = "╏", -- Heavy Vert. (Double Dash)
  HYd3 = "┅", -- Heavy Horz. (Triple Dash)
  VYd3 = "┇", -- Heavy Vert. (Triple Dash)
  HYd4 = "┉", -- Heavy Horz. (Quadruple Dash)
  VYd4 = "┋", -- Heavy Vert. (Quadruple Dash)
  -- Light < Heavy
  U1DY = "╽", -- Light Up    Heavy Down
  UYD1 = "╿", -- Heavy Up    Light Down
  L1RY = "╼", -- Light Left  Heavy Right
  LYR1 = "╾", -- Heavy Left  Light Right
  -- Light x Heavy
  V1HY = "┿", -- Vert. Light & Horz. Heavy
  VYH1 = "╂", -- Vert. Heavy & Horz. Light
  VYHY = "╋", -- Heavy Vert. & Horz.
  V1LY = "┥", -- Vert. Light & Left  Heavy
  VYL1 = "┨", -- Vert. Heavy & Left  Light
  VYLY = "┫", -- Heavy Vert. & Left
  V1RY = "┝", -- Vert. Light & Right Heavy
  VYR1 = "┠", -- Vert. Heavy & Right Light
  VYRY = "┣", -- Heavy Vert. & Right
  U1HY = "┷", -- Up    Light & Horz. Heavy
  UYH1 = "┸", -- Up    Heavy & Horz. Light
  UYHY = "┻", -- Heavy Up    & Horz.
  U1LY = "┙", -- Up    Light & Left  Heavy
  UYL1 = "┚", -- Up    Heavy & Left  Light
  UYLY = "┛", -- Heavy Up    & Left
  U1RY = "┕", -- Up    Light & Right Heavy
  UYR1 = "┖", -- Up    Heavy & Right Light
  UYRY = "┗", -- Heavy Up    & Right
  D1HY = "┯", -- Down  Light & Horz. Heavy
  DYH1 = "┰", -- Down  Heavy & Horz. Light
  DYHY = "┳", -- Heavy Down  & Horz.
  D1LY = "┑", -- Down  Light & Left  Heavy
  DYL1 = "┒", -- Down  Heavy & Left  Light
  DYLY = "┓", -- Heavy Down  & Left
  D1RY = "┍", -- Down  Light & Right Heavy
  DYR1 = "┎", -- Down  Heavy & Right Light
  DYRY = "┏", -- Heavy Down  & Right
  -- L x H: Crosses' X-names
  X1UY = "╀", -- == UYDH1
  X1DY = "╁", -- == DYUH1
  X1LY = "┽", -- == VR1LY
  X1RY = "┾", -- == VL1RY
  XYU1 = "╈", -- == U1DHY
  XYD1 = "╇", -- == D1UHY
  XYL1 = "╊", -- == VRYL1
  XYR1 = "╉", -- == VLYR1
  -- L x H: Crosses' changed
  VL1RY = "┾", -- Right Heavy & Left  Vert. Light
  VLYR1 = "╉", -- Right Light & Left  Vert. Heavy
  VR1LY = "┽", -- Left  Heavy & Right Vert. Light
  VRYL1 = "╊", -- Left  Light & Right Vert. Heavy
  U1DHY = "╋", -- Up    Light & Down  Horz. Heavy
  D1UHY = "╇", -- Down  Light & Up    Horz. Heavy
  UYDH1 = "╀", -- Up    Heavy & Down  Horz. Light
  DYUH1 = "╁", -- Down  Heavy & Up    Horz. Light
  -- L x H: Crosses' angles
  ULYDR1 = "╃", -- Left  Up    Heavy & Right Down Light
  URYDL1 = "╄", -- Right Up    Heavy & Left  Down Light
  DLYUR1 = "╅", -- Left  Down  Heavy & Right Up   Light
  DRYUL1 = "╆", -- Right Down  Heavy & Left  Up   Light
  -- L x H: Left & Right sides
  U1DLY = "┪", -- Up    Light & Left  Down Heavy
  U1DRY = "┢", -- Up    Light & Right Down Heavy
  UYDL1 = "┦", -- Up    Heavy & Left  Down Light
  UYDR1 = "┞", -- Up    Heavy & Right Down Light
  D1ULY = "┩", -- Down  Light & Left  Up   Heavy
  D1URY = "┡", -- Down  Light & Right Up   Heavy
  DYUL1 = "┧", -- Down  Heavy & Left  Up   Light
  DYUR1 = "┟", -- Down  Heavy & Right Up   Light
  -- L x H: Top & Bottom sides
  UL1RY = "┶", -- Right Heavy & Left  Up   Light
  UR1LY = "┵", -- Left  Heavy & Right Up   Light
  DL1RY = "┮", -- Right Heavy & Left  Down Light
  DR1LY = "┭", -- Left  Heavy & Right Down Light
  ULYR1 = "┹", -- Right Light & Left  Up   Heavy
  URYL1 = "┺", -- Left  Light & Right Up   Heavy
  DLYR1 = "┱", -- Right Light & Left  Down Heavy
  DRYL1 = "┲", -- Left  Light & Right Down Heavy
} --- BoxDrawings
unit.BoxDrawings = BoxDrawings

---------------------------------------- Block Elements
--[[
  U/D/L/R - up/down/left/right.
--]]
-- See: interf.[ch]pp (BoxSymbols & BOX_DEF_SYMBOLS enum).
local BlockElements = {
  Full   = "█", -- Full Block				-- DB -- BS_X_DB
  Half_D = "▄", -- Lower Half Block			-- DC -- BS_X_DC
  Half_L = "▌", -- Left  Half Block			-- DD -- BS_X_DD
  Half_R = "▐", -- Right Half Block			-- DE -- BS_X_DE
  Half_U = "▀", -- Upper Half Block			-- DF -- BS_X_DF
} --- BlockElements
unit.BlockElements = BlockElements

---------------------------------------- Geometric Shapes
--[[
  Circle -- круг.
  Lozenge -- косоугольник (ромбовидный).
  Ptr (pointer) -- указатель.
  Pagram (parallelogram) -- параллелограмм ( = ромбоид).
  Rect (rectangle) -- прямоугольник.
  Romb (rhombus, diamond) -- ромб.
  Square -- квадрат.
  Tri (triangle) -- треугольник.
  V - vertical, H - horizontal.
  S - small, G - large.
  N - nested (embedded).
  U/D/L/R - up/down/left/right.
--]]
local GeometricShapes = {
  Black = {
    Square  = "■", -- Black Square
    SquareS = "▪", -- Black Small Square
    SquareN = "▣", -- White Square Containing Black Small Square

    RectH = "▬", -- Black (Horiz.) Rectangle
    RectV = "▮", -- Black Vertical Rectangle

    Tri_U  = "▲", -- Black Up-pointing Triangle
    Tri_D  = "▼", -- Black Down-pointing Triangle
    Tri_L  = "◀", -- Black Left-pointing Triangle
    Tri_R  = "▶", -- Black Right-pointing Triangle
    Tri_UL = "◤", -- Black Upper Left Triangle
    Tri_UR = "◥", -- Black Upper Right Triangle
    Tri_DL = "◣", -- Black Lower Left Triangle
    Tri_DR = "◢", -- Black Lower Right Triangle

    Ptr_L = "◄", -- Black Left-pointing Pointer
    Ptr_R = "►", -- Black Right-pointing Pointer

    Circle = "●", -- Black Circle

    Pagram  = "▰", -- Black Parallelogram
    Romb    = "◆", -- Black Diamond
    RombN   = "◈", -- White Diamond Containing Black Small Diamond
    --Lozenge = "◊", -- (Black) Lozenge -- NONE
  }, -- Black
  White = {
    -- Squares:
    Square  = "□", -- White Square
    SquareS = "▫", -- White Small Square
    SquareR = "▢", -- White Square With Rounded Corners

    RectH = "▭", -- White (Horiz.) Rectangle
    RectV = "▯", -- White Vertical Rectangle

    Tri_U = "△", -- White Up-pointing Triangle
    Tri_D = "▽", -- White Down-pointing Triangle
    Tri_L = "◁", -- White Left-pointing Triangle
    Tri_R = "▷", -- White Right-pointing Triangle
    Tri_UL = "◸", -- White Upper Left Triangle ?
    Tri_UR = "◹", -- White Upper Right Triangle ?
    Tri_DL = "◺", -- White Lower Left Triangle ?
    Tri_DR = "◿", -- White Lower Right Triangle ?

    Ptr_L = "◅", -- White Left-pointing Pointer
    Ptr_R = "▻", -- White Right-pointing Pointer

    Circle  = "○", -- White Circle
    CircleI = "◙", -- Inverse White Circle
    CircleL = "◯", -- Large Circle
    CircleD = "◌", -- Dotted Circle

    Circle_U  = "◠", -- Upper Half Circle
    CircleI_U = "◚", -- Upper Half Inverse White Circle
    Circle_D  = "◡", -- Lower Half Circle
    CircleI_D = "◛", -- Lower Half Inverse White Circle

    Arc_UL = "◜", -- Upper Left  Quadrant Circular Arc
    Arc_UR = "◝", -- Upper Right Quadrant Circular Arc
    Arc_DL = "◟", -- Lower Left  Quadrant Circular Arc
    Arc_DR = "◞", -- Lower Right Quadrant Circular Arc

    Bullseye = "◎", -- Bullseye
    Bullet   = "◦", -- White Bullet
    BulletI  = "◘", -- (White) Inverse Bullet

    Pagram  = "▱", -- White Parallelogram
    Romb    = "◇", -- White Diamond
    Lozenge = "◊", -- (White) Lozenge
  }, -- White
} --- GeometricShapes
unit.GeometricShapes = GeometricShapes

---------------------------------------- BoxChars
do

-- Names for box kinds.
-- Названия для видов рамок.
unit.BoxKindNames = {
  S = "Single",
  D = "Double",
  H = "DoubleH",
  V = "DoubleV",
  R = "Rounded",
  L = "Light",
  Y = "Heavy",
  B = "Block",
} --- BoxKindNames

  local BlackShapes = GeometricShapes.Black

-- Characters for varied box kinds.
-- Символы для различных видов рамок.
local BoxChars = {
  Single = { -- Обычная рамка:
    H  = BoxDrawings.H1,
    V  = BoxDrawings.V1,
    X  = BoxDrawings.X1,
    T  = BoxDrawings.D1H1,
    B  = BoxDrawings.U1H1,
    L  = BoxDrawings.V1R1,
    R  = BoxDrawings.V1L1,
    TL = BoxDrawings.D1R1,
    TR = BoxDrawings.D1L1,
    BL = BoxDrawings.U1R1,
    BR = BoxDrawings.U1L1,
  }, -- Single
  Double = { -- Двойная рамка:
    H  = BoxDrawings.H2,
    V  = BoxDrawings.V2,
    X  = BoxDrawings.X2,
    T  = BoxDrawings.D2H2,
    B  = BoxDrawings.U2H2,
    L  = BoxDrawings.V2R2,
    R  = BoxDrawings.V2L2,
    TL = BoxDrawings.D2R2,
    TR = BoxDrawings.D2L2,
    BL = BoxDrawings.U2R2,
    BR = BoxDrawings.U2L2,
  }, -- Double
  DoubleV = { -- Дв. верт. рамка:
    H  = BoxDrawings.H1,
    V  = BoxDrawings.V2,
    X  = BoxDrawings.V2H1,
    T  = BoxDrawings.D2H1,
    B  = BoxDrawings.U2H1,
    L  = BoxDrawings.V2R1,
    R  = BoxDrawings.V2L1,
    TL = BoxDrawings.D2R1,
    TR = BoxDrawings.D2L1,
    BL = BoxDrawings.U2R1,
    BR = BoxDrawings.U2L1,
  }, -- DoubleV
  DoubleH = { -- Дв. гориз. рамка:
    H  = BoxDrawings.H2,
    V  = BoxDrawings.V1,
    X  = BoxDrawings.V1H2,
    T  = BoxDrawings.D1H2,
    B  = BoxDrawings.U1H2,
    L  = BoxDrawings.V1R2,
    R  = BoxDrawings.V1L2,
    TL = BoxDrawings.D1R2,
    TR = BoxDrawings.D1L2,
    BL = BoxDrawings.U1R2,
    BR = BoxDrawings.U1L2,
  }, -- DoubleH
  Rounded = { -- Закруглённая рамка:
    H  = BoxDrawings.H1,
    V  = BoxDrawings.V1,
    X  = BoxDrawings.X1,
    T  = BoxDrawings.D1H1,
    B  = BoxDrawings.U1H1,
    L  = BoxDrawings.V1R1,
    R  = BoxDrawings.V1L1,
    TL = BoxDrawings.ArcDR,
    TR = BoxDrawings.ArcDL,
    BL = BoxDrawings.ArcUR,
    BR = BoxDrawings.ArcUL,
  }, -- Rounded
  Light = 0, -- Тонкая рамка
  Heavy = { -- Толстая рамка:
    H  = BoxDrawings.HY,
    V  = BoxDrawings.VY,
    X  = BoxDrawings.XY,
    T  = BoxDrawings.DYHY,
    B  = BoxDrawings.UYHY,
    L  = BoxDrawings.VYRY,
    R  = BoxDrawings.VYLY,
    TL = BoxDrawings.DYRY,
    TR = BoxDrawings.DYLY,
    BL = BoxDrawings.UYRY,
    BR = BoxDrawings.UYLY,
  }, -- Double
  Block = { -- Блоковая рамка:
    H  = BlockElements.Full,
    V  = BlockElements.Full,
    X  = BlockElements.Full,
    T  = BlockElements.Full,
    B  = BlockElements.Full,
    L  = BlockElements.Full,
    R  = BlockElements.Full,
    TL = BlockElements.Full,
    TR = BlockElements.Full,
    BL = BlockElements.Full,
    BR = BlockElements.Full,
    -- Special parts:
    HM = BlackShapes.Square,
    VM = BlockElements.Full,
    HT = BlockElements.Half_U,
    HB = BlockElements.Half_D,
    VL = BlockElements.Half_L,
    VR = BlockElements.Half_R,
  }, -- Double
} --- BoxChars
unit.BoxChars = BoxChars
BoxChars.Light = BoxChars.Single

end -- do

-- Get character for box.
-- Получение символа рамки.
function unit.BoxSymbols (name)
  return BoxDrawings[name] or BlockElements[name]
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
