--[[ MaxIncInt ]]--

-- Original author: Shmuel Zeigerman

----------------------------------------
--[[ description:
  -- Get a maximum incremented integer for number type.
  -- Получение максимального 'ещё увеличиваемого на 1' целого для типа number.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Samples.
--]]
--------------------------------------------------------------------------------
local N
local step1 = 1e10
local step2 = 1e5

for k = 0, math.huge, step1 do
  if k == k + 1 then N = k; break; end
end
for k = N - step1, math.huge, step2 do
  if k == k + 1 then N = k; break; end
end
for k = N - step2, math.huge, 1 do
  if k == k + 1 then N = k - 1; break; end
end

local format = string.format

far.Message(format("%.f", N), "MaxIncInt")

N = format("%.f", N):reverse():gsub("...", "%0 "):reverse()

far.Message(N, "Maximum incremented integer")

--------------------------------------------------------------------------------
-- 9007199254740991
-- 9 007 199 254 740 991
--------------------------------------------------------------------------------
