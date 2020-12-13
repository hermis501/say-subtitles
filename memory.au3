#Include-once
func memory ()
_reduceMemory ()
endfunc

Func _ReduceMemory($i_PID = @autoitPid)
If $i_PID <> -1 Then
Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $i_PID)
$ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $ai_Handle[0])
DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $ai_Handle[0])
Else
$ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
EndIf
Return $ai_Return[0]
endfunc
