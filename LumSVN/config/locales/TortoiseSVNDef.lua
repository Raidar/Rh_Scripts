--[[ TortoiseSVN: English ]]--

--------------------------------------------------------------------------------
local Data = {
  tSVN              = "&T - TortoiseSVN",       --          j      q    v xyz
  TortoiseSVN       = "TortoiseSVN",            -- abcdefghi klmnop rstu w

  eError            = "Error",
  ePathNotFound     = "Path to TortoiseSVN not found",
  eStatusFailed     = "Getting SVN status is failed",

  -- Menu items
  tSVN_checkout     = "Chec&kout…",             -- k
  hSVN_checkout     = "Check out a working copy from a repository",
  tSVN_update       = "&Update",                -- u
  hSVN_update       = "Updates the working copy to the current revision",
  tSVN_commit       = "&Commit…",               -- c
  hSVN_commit       = "Commits your changes to the repository",

  tSVN_diff         = "&Diff w/previous",       -- d -- &Diff with previous
  hSVN_diff         = "Diffs the working copy file with the one before the last commit",
  tSVN_log          = "Show &log",              -- l
  hSVN_log          = "Shows the log for the selected file/folder",
  tSVN_browse       = "&Repo-browser",          -- r
  hSVN_browse       = "Opens the repository browser to tweak the repository online",
  tSVN_browseto     = "&Repo-browser…",         --(r)
  tSVN_change       = "&Find changes",          -- f -- Check for modi&fications
  hSVN_change       = "Shows all files which were changed since the last update, locally and in the repository",
  tSVN_revgraph     = "Revision &graph",        -- g
  hSVN_revgraph     = "Shows a graphical representation of copies/tags/branches",

  tSVN_conflict     = "Edit conflicts",         --   -- &Edit conflicts
  hSVN_conflict     = "Launches the external diff/merge program to solve the conflicts",
  tSVN_resolve      = "Res&olved…",             -- o
  hSVN_resolve      = "Resolves conflicted files",
  tSVN_uptorev      = "Update to rev… &8",      -- 8 -- &Update to revision…
  hSVN_uptorev      = "Updates the working copy to a specific revision",
  tSVN_rename       = "Re&name…",               -- n
  hSVN_rename       = "Renames files/folders inside version control",
  tSVN_remove       = "Delete",                 --   --
  hSVN_remove       = "Deletes files/folders from version control",
  tSVN_revert       = "Revert…",                --   --
  hSVN_revert       = "Reverts all changes you made since the last update",
  tSVN_cleanup      = "Cl&ean up",              -- e
  hSVN_cleanup      = "Cleanup interrupted operations, locked files…",
  tSVN_lock         = "Get lock…    &#",        -- # --
  hSVN_lock         = "Locks a file for other users and makes it editable by you",
  tSVN_unlock       = "Release lock &3",        -- 3 --
  hSVN_unlock       = "Releases locks on files so other users can edit them again",

  tSVN_copy         = "Branch / &tag…",         -- t
  hSVN_copy         = "Creates a 'cheap' copy inside the repository used for branches or tagging",
  tSVN_switch       = "S&witch…",               -- w
  hSVN_switch       = "Switch working copy to another branch/tag",
  tSVN_merge        = "&Merge…",                -- m
  hSVN_merge        = "Merges a branch into the main trunk",
  tSVN_export       = "Export…",                --   -- E&xport…
  hSVN_export       = "Exports a repository to a clean working copy without the svn administrative folders",
  tSVN_relocate     = "Relocate…",              --   -- Relo&cate…
  hSVN_relocate     = "Use this if the URL of the repository has changed",

  tSVN_create       = "Make repo here",         --   -- Create repositor&y here
  hSVN_create       = "Creates a repository database at the current location",
  tSVN_blame        = "&Blame…",                -- b
  hSVN_blame        = "Blames each line of a file on an author",
  tSVN_add          = "&Add…",                  -- a
  hSVN_add          = "Adds file(s) to Subversion control",
  tSVN_import       = "Import…",                --   -- &Import…
  hSVN_import       = "Imports the directory to a repository",
  tSVN_ignore       = "To &ignore list",        -- i -- Add to &ignore list
  hSVN_ignore       = "Adds the selected file(s) or the filemask to the 'ignore' list",

  tSVN_patch        = "Create &patch…",         -- p
  hSVN_patch        = "Creates a unified diff file with all changes you made",
  tSVN_patching     = "Apply patch…",           --   --
  hSVN_patching     = "Applies a unified diff file to the working copy",
  tSVN_props        = "Properties   &!",         -- ! --
  hSVN_props        = "Manage Subversion properties",

  tSVN_settings     = "&Settings",              -- s
  hSVN_settings     = "Tweak TortoiseSVN",
  tSVN_help         = "&Help",                  -- h
  hSVN_help         = "Read the 'Daily Use Guide' before you are stuck…",
  tSVN_about        = "About        &?",        -- ? -- A&bout
  hSVN_about        = "Shows information about TortoiseSVN",

  tSVN_status       = "Status       &1",        -- = --
  hSVN_status       = "Shows status returned by SubWCRev.exe",
  wSVN_status       = "SVN Status",

  ----------------------------------------
} --- Data

--Data.tSVN_browseto = Data.tSVN_browse
Data.hSVN_browseto = Data.hSVN_browse

return Data
--------------------------------------------------------------------------------
