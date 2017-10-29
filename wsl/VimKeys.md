# CONEMU workaround for vim, both local and remote

Make sure ctrl+v isn't bound to paste in conemu
use ctrl+shift+v or something.

### In *.bashrc*:
```
if [ -d /mnt/c/Windows ] || [ $LC_WINDOWS10 ]; then
  export WINDOWS10=0
fi
if [ $WINDOWS10 ]; then
  export LC_WINDOWS10=$WINDOWS10
fi
```
### In local *.vimrc*:
```
let windows10=$WINDOWS10
if windows10 == '0'
  set t_ku=(ctrl+v , UP arrow)
  set t_kd=(ctrl+v , DOWN arrow)
  set t_kr=(ctrl+v , RIGHT arrow)
  set t_kl=(ctrl+v , LEFT arrow)
endif
```
In vim, this will appear as **"set t_ku=^[[A"** or something like that.
With both the bashrc and vimrc changes in place, local and remote vim both have working arrow keys, 
without breaking arrow keys in non-windows10 shells.
