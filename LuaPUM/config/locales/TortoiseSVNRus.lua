--[[ TortoiseSVN: Russian ]]--
--[[ TortoiseSVN: русский ]]--

--------------------------------------------------------------------------------
local Data = {

  --tSVN              = "&T - TortoiseSVN",
  --TortoiseSVN       = "TortoiseSVN",

  ----------------------------------------
  eError            = "Ошибка",
  ePathNotFound     = "Путь к TortoiseSVN не найден",
  eStatusFailed     = "Не удалось получить состояние SVN",

  ----------------------------------------
  -- Menu items:
  tSVN_checkout     = "&K - Извлечь…",              -- Извлечь…
  hSVN_checkout     = "Извлечь рабочую копию из хранилища",
  tSVN_update       = "&U - Обновить",              -- &Обновить
  hSVN_update       = "Обновляет рабочую копию до текущей ревизии",
  tSVN_commit       = "&C - Фиксировать…",          -- &Фиксировать…
  hSVN_commit       = "Фиксирует ваши изменения в хранилище",

  -- &Различия
  tSVN_diff         = "&/ - Сравнить с текущей", -- С&равнить с текущей версией
  hSVN_diff         = "Сравнивает файл в рабочей копии с его же версией при последней фиксации",
  -- "Сравнивает файл с последней зафиксированной ревизией для показа сделанных вами изменений"
  tSVN_prevdiff     = "&D - Сравнить с предыдущей", -- С&равнить с предыдущей версией
  hSVN_prevdiff     = "Сравнивает файл в рабочей копии с его же версией перед последней фиксацией",
  tSVN_log          = "&L - Журнал",                -- &Журнал
  hSVN_log          = "Показывает журнал для выбранного файла/папки",
  tSVN_browse       = "&Q - Обзор хранилища",       -- Обозреватель &хранилища
  hSVN_browse       = "Открывает обозреватель хранилища для оперативной работы с хранилищем",
  tSVN_browseto     = "&Q - Обзор хранилища…",      -- ()
  tSVN_change       = "&F - Найти изменения",       -- Проверить на наличие изменени&й
  hSVN_change       = "Показывает все файлы, которые изменились после последнего обновления, локально и в хранилище",
  tSVN_revgraph     = "&G - Граф ревизий",          -- &Граф Ревизий
  hSVN_revgraph     = "Показывает копии/метки/ответвления в графическом виде",

  tSVN_conflict     = "    Править конфликты",      -- Редактировать конф&ликты
  hSVN_conflict     = "Запускает внешнюю программу различий/слияния для разрешения конфликтов",
  tSVN_resolve      = "&O - Уладить…",              -- У&ладить…
  hSVN_resolve      = "Улаживает файлы с конфликтами",
  tSVN_uptorev      = "&J - Обновить до ревизии…",  -- Обновить &до ревизии…
  hSVN_uptorev      = "Обновляет рабочую копию до указанной ревизии",
  tSVN_rename       = "&N - Переименовать…",        -- П&ереименовать…
  hSVN_rename       = "Переименовывает файлы/папки внутри управления версиями",
  tSVN_remove       = "    Удалить",                -- &Удалить
  hSVN_remove       = "Удаляет файлы/папки из-под управления версиями",
  tSVN_revert       = "&V - Вернуть",               -- Убрать и&зменения
  hSVN_revert       = "Убирает все изменения, которые вы сделали после последнего обновления",
  tSVN_cleanup      = "&E - Очистить",              -- &Очистить
  hSVN_cleanup      = "Очистка прерванных операций, блокированных файлов…",
  tSVN_lock         = "&# - Заблокировать…",        -- За&блокировать
  hSVN_lock         = "Блокирует файл для других пользователей и делает его для вас доступным для редактирования",
  tSVN_unlock       = "&3 - Снять блокировку",      -- Сн&ять блокировку
  hSVN_unlock       = "Снимает блокировки с файлов, и пользователи снова смогут их редактировать",

  tSVN_copy         = "&B - Ветка / тэг…",          -- О&тветвление/метка
  hSVN_copy         = "Создает 'дешёвую' копию внутри хранилища, используемую для ответвлений и меток",
  tSVN_switch       = "&W - Переключить…",          -- Перекл&ючить…
  hSVN_switch       = "Переключить рабочую копию на другое ответвление/метку",
  tSVN_merge        = "&M - Слить…",                -- &Слить…
  hSVN_merge        = "Сливает ответвление с главным стволом",
  tSVN_export       = "    Экспорт…",               -- &Экспорт…
  hSVN_export       = "Экспортирует хранилище в чистую рабочую копию без административных svn-папок",
  tSVN_relocate     = "    Перебазировать…",        -- Перебазироват&ь…
  hSVN_relocate     = "Используйте это, если URL хранилища изменился",

  tSVN_create       = "    Создать базу здесь",     -- Создать здесь &хранилище
  hSVN_create       = "Создает базу данных хранилища в этом месте",
  tSVN_blame        = "&8 - Авторство…",            -- &Авторство…
  hSVN_blame        = "Показывает для каждой строки файла её автора",
  tSVN_add          = "&A - Добавить…",             -- &Добавить…
  hSVN_add          = "Вносит файл(ы) под управление Subversion",
  tSVN_import       = "    Импорт…",                -- И&мпорт…
  hSVN_import       = "Импортирует папку в хранилище",
  tSVN_ignore       = "&I - В список игнорируемых", -- Добавить в список &игнорирования
  hSVN_ignore       = "Добавляет выбранные файлы или маску файлов в список игнорирования",

  tSVN_patch        = "&P - Создать патч…",         -- Создать за&платку…
  hSVN_patch        = "Создает файл объединённых различий со всеми изменениями, которые вы сделали",
  tSVN_patching     = "    Применить патч…",        -- Применить заплатку…
  hSVN_patching     = "Применяет файл объединённых различий к рабочей копии",
  tSVN_props        = "&! - Свойства",              -- Свойства
  hSVN_props        = "Управление свойствами Subversion",

  tSVN_settings     = "&$ - Настройки",             -- &Настройки
  hSVN_settings     = "Подстроить TortoiseSVN",
  tSVN_help         = "&H - Справка",               -- &Справка
  hSVN_help         = "Прочитайте 'Руководство по ежедневному использованию', пока не застряли…",
  tSVN_about        = "&? - О программе",           -- &О программе
  hSVN_about        = "Показывает информацию о TortoiseSVN",

  tSVN_status       = "&1 - Состояние",             --
  hSVN_status       = "Показывает статус, возвращаемый из SubWCRev.exe",
  wSVN_status       = "Состояние SVN",

  ----------------------------------------
} --- Data

--Data.tSVN_browseto = Data.tSVN_browse
Data.hSVN_browseto = Data.hSVN_browse

return Data
--------------------------------------------------------------------------------
