if exists('g:loaded_arduinolsp') 
    finish 
endif

command! -nargs=1 ArduinoSetFqbn lua require 'arduinolsp.api'.set_fqbn(<q-args>)
command! -nargs=0 ArduinoClean lua require 'arduinolsp.api'.clean_config()
command! -nargs=0 ArduinoDump lua require 'arduinolsp.api'.dump_config()

let g:loaded_arduinolsp = 1
