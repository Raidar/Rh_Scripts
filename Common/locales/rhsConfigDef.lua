--[[ rhsConfig: English ]]--

--------------------------------------------------------------------------------
local Data = {
  -- Message titles.
  FileCreate = 'File create',
  Attention = "Attention",

  -- Error messages.
  FileExistsOverwrite = 'File exists. Overwrite?',
  FileNotOpenCreated  = 'File not open or created',
  FileNewContentError = 'Error creating file content',

  -- Other messages.
  FileCreatingCancel  = 'File creating is canceled',
  FileCreatingSuccess = 'File was created successfully',
  RequireReloadFAR = "Reload FAR Manager to apply all changes",

  ----------------------------------------
  -- Dialog items texts.
  --btn_Ok     = "Ok",
  --btn_Close  = "Close",
  btn_Cancel = "Cancel",
  btn_Apply  = "Apply",

  -- Settings dialogs titles.
  cap_Dialog  = "Rh_Scripts pack: Settings",

  -- Settings dialogs separators.
  sep_MenuItems = "Menu items",
  sep_Residents = "Resident modules", 

  -- Settings dialogs texts.
  lbl_Area = "Area",
  lbl_HotKey = "  HotKey",
  lbl_ItemDesc = "Description",
  lbl_ItemName = "   Item Name",
  lbl_ItemCfgName = "   Config Item Name",
  lbl_Separator = "——Separator——",

    -- Menu items:
  cfg_UserMenus = "User Menus:", -- LUMs:
  cfg_LuaEUM = "LUM for &Editor",
  cfg_LuaEUM_Insert = "├ Template Insert",
  cfg_LuaEUM_ChsKit = "└ Characters Kit",
  cfg_LuaPUM = "LUM for &Panels",
  cfg_LumSVN = "LUM for &SVN",
  cfg_LumFLS = "&fl scripts LUM",
  cfg_Scripts   = "Scripts:", -- Scripts:
  cfg_VoidTruncate  = "Void Truncater",
  cfg_WordComplete  = "Word &Completion",
  cfg_AutoComplete  = "&Auto Completion",
  cfg_TextTemplate  = "&Text Templates",
  cfg_AutoTemplate  = "A&uto Templates",
  cfg_TT_Update     = "Update Templates",
  cfg_Samples   = "Samples:", -- Samples:
  cfg_KeysInfo      = "&Keys information",

    -- Residents:
  cfg_Res_AutoActions  = "Auto Actions",
  cfg_Res_VoidTruncate = "Void Truncater",
  cfg_Res_Keys_AutoActions  = "Character keys",
  cfg_Res_Keys_VoidTruncate = "End w/modifiers",
  cfg_Res_Desc_AutoActions  = "Templates + Completion",
  cfg_Res_Desc_VoidTruncate = "Kill trailing spaces + empty lines",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
