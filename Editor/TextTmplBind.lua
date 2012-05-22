--[[ TextTemplate bind ]]--

----------------------------------------
--[[ description:
  -- Binding types to templates.
  -- Привязка типов к шаблонам.
--]]
--------------------------------------------------------------------------------
local Data = {

text = true,
  plain = true,
    --(default)
      --txt --= true,
      --(rare)
    --(formed)
      --message
      --(others)
        --filedesc --= true,
        readme = true,
  --rich
    --config
      --ini --= true,
        --ini_cfg --= true,
      --(lua)
        --cfg_lua --= true,
      --(far)
        --lng_far --= true,
      --cfg_sys --= true,
        --inf --= true,
        --reg --= true,
    --define
      --(resource)
        --res_src --= true,
      --(far)
        --airbrush --= true,
      --(rare)
      --(subtitles)
        sub = true,
      --(network)
        --css --= true,
    --markup
      --rtf --= true,
      --tex --= true,
      --(rare)
      --far --= true,
        --far_hlf --= true,
        --farmenu --= true,
      --sgml --= true,
        --html --= true,
          --xhtml --= true,
        --xml --= true,
          --(main)
            --xml_doc --= true,
            --dtd --= true,
          --(book)
            --fb2 --= true,
          --(others)
          --(rare)
        --(others)
        --colorer --= true,
          --clr_hrc --= true,
          --clr_hrd --= true,
          --clr_ent --= true,
          --clr5cat --= true,

  source = true,
    --main
      --(freqs)
        --asm --= true,
        --basic --= true,
        --c --= true,
        --java --= true,
        --pascal --= true,
        --perl --= true,
        --python --= true,
        --ruby --= true,
        --(asm others)
        --hdl --= true,
        --ml --= true,
        --prolog --= true,
      --dbl
        --sql --= true,
        --(rare)
      --dotnet
      --codscript
        --tcl_tk --= true,
        --lex --= true,
        --lua --= true,
        --makefile
        --(java)
        --rare
          --ahk --= true,
      --net
        --php --= true,
        --netscript
          --ascript --= true,
          --jscript --= true,
          --vbscript --= true,
        --(server pages)
          --asp --= true,
          --jsp --= true,
      --(batch/shell)
        --batch
        --shell
        --apache --= true,
        --(rare)
        --install

} --- Data

return Data
--------------------------------------------------------------------------------
