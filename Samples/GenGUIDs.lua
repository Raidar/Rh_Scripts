--[[ GUID ]]--

----------------------------------------
--[[ description:
  -- GUID generation and insert to current editor.
  -- Генерация и вставка GUID в текущий редактор.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Samples.
--]]
--------------------------------------------------------------------------------
local GenUUID = win.Uuid

local InsText = function (text)

  editor.InsertText(nil, text)

  return editor.InsertString(nil, true)

end -- InsText

local Count = far.InputBox("Generate GUIDs", "Enter GUID count", nil, "10", 5, nil, 0)
Count = tonumber(Count) or 10

local t = {}
for _ = 1, Count do
  t[#t + 1] = GenUUID(GenUUID())

end

table.sort(t)

for k = 1, Count do
  InsText(t[k])

end
--------------------------------------------------------------------------------

