if exists('g:loaded_arduinolsp') 
    finish 
endif

command! -nargs=1 ArduinoSetFqbn lua require 'arduinolsp'.set_fqbn(<q-args>)
command! -nargs=0 ArduinoClean lua require 'arduinolsp'.clean_config()
command! -nargs=0 ArguinoDump lua require 'arduinolsp'.dump_config()

let g:loaded_arduinolsp = 1
