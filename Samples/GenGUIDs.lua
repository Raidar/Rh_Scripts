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
end

local Count = far.InputBox("Generate GUIDs", "Enter GUID count", nil, "10", 5, nil, 0)
Count = tonumber(Count) or 10

for k = 1, Count do
  InsText(GenUUID("tostring", GenUUID()))
end
--------------------------------------------------------------------------------
