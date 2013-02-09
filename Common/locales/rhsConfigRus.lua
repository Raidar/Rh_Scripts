--[[ rhsConfig: Russian ]]--
--[[ rhsConfig: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  -- Message titles.
  FileCreate = 'Создание файла',
  Attention = "Внимание",

  -- Error messages.
  FileExistsOverwrite = 'Файл существует. Перезаписать?',
  FileNotOpenCreated  = 'Файл не удаётся открыть или создать',
  FileNewContentError = 'Ошибка создания содержимого файла',

  -- Other messages.
  FileCreatingCancel  = 'Создание файла отменено',
  FileCreatingSuccess = 'Файл успешно создан',
  RequireReloadFAR = "Для вступления изменений в силу перезагрузите FAR Manager",

  ----------------------------------------
  -- Dialog items texts.
  --btn_Ok     = "Ок",
  --btn_Close  = "Закрыть",
  btn_Cancel = "Отменить",
  btn_Apply  = "Использовать",

  -- Settings dialogs titles.
  cap_Dialog  = "Rh_Scripts pack: Параметры",

  -- Settings dialogs separators.
  sep_MenuItems = "Пункты меню",
  sep_Residents = "Резидентные модули", 

  -- Settings dialogs texts.
  lbl_Area = "Обл.",
  lbl_HotKey = "Горячая клавиша",
  lbl_ItemDesc = "Описание",
  lbl_ItemName = "   Имя пункта",
  lbl_ItemCfgName = "   Имя в конфиг-меню",
  lbl_Separator = "——Разделитель——",

    -- Menu items:
  cfg_UserMenus = "Меню UM:", -- LUMs:
  cfg_LuaEUM = "LUM для &Редактора",
  cfg_LuaEUM_Insert = "├ Вставка шаблона",
  cfg_LuaEUM_ChsKit = "└ Набор символов",
  cfg_LuaPUM = "LUM для  &Панелей",
  cfg_LumSVN = "LUM для  &SVN",
  cfg_LumFLS = "LUM дл&я fl scripts",
  cfg_Scripts   = "Скрипты:", -- Scripts:
  cfg_VoidTruncate  = "Усекатель пустоты",
  cfg_WordComplete  = "&Завершение слов",
  cfg_AutoComplete  = "&АвтоЗавершение",
  cfg_TextTemplate  = "&Текстовые шаблоны",
  cfg_AutoTemplate  = "А&втоШаблоны",
  cfg_TT_Update     = "Обновить шаблоны",
  cfg_Samples   = "Примеры:", -- Samples:
  cfg_KeysInfo      = "Инфо о &клавишах",

    -- Residents:
  cfg_Res_AutoActions  = "Авто-действия",
  cfg_Res_VoidTruncate = "Усекатель пустоты",
  cfg_Res_Keys_AutoActions  = "Клавиши-символы",
  cfg_Res_Keys_VoidTruncate = "End + модиф.-ры",
  cfg_Res_Desc_AutoActions  = "Шаблоны + Завершение",
  cfg_Res_Desc_VoidTruncate = "(конечных пробелов + пустых строк)",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
