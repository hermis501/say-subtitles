#Include-Once
local $NDll=""
func _NVDAInit ($NVDADll=@scriptdir&"\nvdaControllerClient32.dll")
if fileexists ($NvdaDll)=0 then return 0
$NDll=DllOpen ($NVDADll)
if $ndll=-1 then return 0
return 1
endfunc

func _NVDAClose ()
DllClose ($NDll)
endfunc

func _nvdasay ($fraze)
DllCall($NDll, "long", "nvdaController_speakText", "wstr", $fraze)
DllCall($NDll, "long", "nvdaController_brailleMessage", "wstr", $fraze)
endfunc

func _nvdaTestIfRunning ()
if $ndll=-1 then return false
local $call=DllCall($NDll, "long", "nvdaController_testIfRunning")
if $call[0]=0 then
return true
else
return false
endif
endfunc

func _NVDAStop ()
DllCall($NDll, "long", "nvdaController_cancelSpeech")
endfunc

