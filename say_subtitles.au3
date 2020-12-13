#include "memory.au3"
#Include <file.au3>
#Include <misc.au3>
#Include <GuiConstantsEx.au3>
#include "nvda.au3"
#include "Bass.au3"
#NoTrayIcon
#pragma compile(ProductName, Say Subtitles)
#pragma compile(ProductVersion, 1.00)
#pragma compile(FileVersion, 1.0)
#pragma compile(FileDescription, SRT subtitle reader for blind)
#pragma compile(LegalCopyright, '© 2019 Hermis Kasperavièius')
#pragma compile(CompanyName, 'Hermis Kasperavièius')
#pragma compile(UPX, false)
if _Singleton (@scriptname, 1)=0 then
exit
endif
_BASS_STARTUP (@scriptdir&"\bass.dll")
_BASS_Init(0, -1, 44100, 0, "")
if @error then
MSGBox (16, "Error", "Unable to initialize bass library.")
exit
endif
if _NVDAInit ()=0 then
MSGBox (64, "Error", "Can't provide NVDA support. Use Jaws or Sapi instead.")
endif
global $volume=iniread (@scriptdir&"\konfig.ini", "settings", "volume", "0")
$volume=int ($volume)
global $AudioFile="", $SRTFile=""
global $index, $start_time, $end_time, $text ; array of subs information
global $indexNR=0
global $playing=false, $found_sub=false, $speak_sub=true
global $tekstai[5]
$tekstai[0]=ubound ($tekstai)-1
$tekstai[1]="Choose a movie to watch"
$tekstai[2]="Hotkeys"
$tekstai[3]="About the program"
$tekstai[4]="Exit"
global $sk=1
opt("GuiCloseOnEsc", 0)
opt ("GUICoordMode", 0)
global $windowTitle="Say subtitles"
global $window=true
global $versija="0.1"
global $form=GuiCreate ("Say Subtitles", @DesktopWidth, @DesktopHeight)
AdlibRegister ("memory", 1000)
global $dummyup=GuiCTRLCreateDummy ()
global $dummydown=GuiCTRLCreateDummy ()
global $dummyenter=GuiCTRLCreateDummy ()
global $dummyspace=GuiCTRLCreateDummy ()
global $dummyesc=GuiCTRLCreateDummy ()
global $dummyslash=GuiCTRLCreateDummy ()
global $dummyright=GuiCTRLCreateDummy ()
global $dummyleft=GuiCTRLCreateDummy ()
global $dummysettings=GuiCTRLCreateDummy ()
GuiSetState (@sw_show, $form)
sleep (50)
$klaida=ObjEvent("AutoIt.Error","Klaida")
global $oJawsApi= ObjCreate("FreedomSci.JawsApi")
global $OSapi = ObjCreate("sapi.SPVoice")
global $sapi_enabled=false
_stopme ()
_SpeakMe ("Say subtitles, main menu, "&$tekstai[1])
global $acelkeys[9][2]
$acelkeys[0][0]="{up}"
$acelkeys[0][1]=$dummyup
$acelkeys[1][0]="{down}"
$acelkeys[1][1]=$dummydown
$acelkeys[2][0]="{enter}"
$acelkeys[2][1]=$dummyenter
$acelkeys[3][0]="{space}"
$acelkeys[3][1]=$dummyspace
$acelkeys[4][0]="{esc}"
$acelkeys[4][1]=$dummyesc
$acelkeys[5][0]="/"
$acelkeys[5][1]=$dummyslash
$acelkeys[6][0]="{right}"
$acelkeys[6][1]=$dummyright
$acelkeys[7][0]="{left}"
$acelkeys[7][1]=$dummyleft
$acelkeys[8][0]="^{tab}"
$acelkeys[8][1]=$dummysettings
GUISetAccelerators ($acelkeys, $form)
global $length
global $old_text=""
global $stream
while 1
$window=WinGetProcess(wingettitle("{active}")) = @AutoItPID
$pos=get_position ($stream)
$pos=round ($pos, 3)
if $pos>=$length then
; do nothing, catch when file is finished
WinSetTitle ($form, "", "Say Subtitles")
endif

; subtitle items
if ($found_sub=true) and ($pos<$length) and ($playing=true) then
if $pos>$start_time[$indexnr] then
if $indexnr<>$index[0] then $indexnr=$indexnr+1
elseif $pos<$start_time[$indexnr] then
if $indexnr>1 then $indexnr=$indexnr-1
endif

if ($pos>=$start_time[$indexNR]) and ($pos<=$start_time[$indexNR]+0.5) then
if ($old_text<>$text[$indexNR]) and ($text[$indexNR]<>"") and ($speak_sub=true) and ($window=true) then
$old_text=$text[$IndexNR]
_SpeakMe ($text[$indexNR])
endif
endif
endif
; subtitle items end


switch guiGetMSG ()
case $gui_event_close
_quit ()
case $dummyup
dummy_up ()
case $dummydown
dummy_down ()
case $dummyenter
if $sk=1 then
_bass_streamFree ($stream)
choose_file ()
elseif $sk=2 then
_SpeakMe ("Up/down arrow - increase or decrease the volume, space - play or pause, escape - stop the movie and return to main menu, / - temporary disable or enable subtitles, right arrow - forward movie by 10 sec, left arrow - backward movie by 10 sec, control plus tab - enable or disable Sapi output. Sapi output is not required when using Jaws or NVDA. Main menu,")
_SpeakMe ($tekstai[$sk])
elseif $sk=3 then
_StopMe ()
_SpeakMe ("Say Subtitles, program for reading subtitles in srt format along with movies."&@crlf&"Program created by Hermis Kasperavièius in 2019")
; MSGBox (0, "Say subtitles", "Copyright (C) 2019, program created by Hermis Kasperavièius."&@crlf&"e-mail: hermis.kasperavicius@gmail.com", 0, $form)
elseif $sk=4 then
_quit ()
endif
case $dummyspace
play_pause ()
case $dummyesc
audio_stop ()
case $dummyslash
if $speak_sub=true then
$speak_sub=false
_SpeakMe ("Off")
else
$speak_sub=true
_SpeakMe ("On")
endif
case $dummyright
right (10)
case $dummyleft
left (10)
case $dummysettings
if $sapi_enabled=true then
$sapi_enabled=false
_speakme ("Sapi, disabled")
else
$sapi_enabled=true
_speakme ("Sapi, enabled")
endif

endSwitch

WEnd

func _quit ()
_bass_Free ()
iniwrite (@scriptdir&"\konfig.ini", "settings", "volume", $volume)
_nvdaClose ()
exit
endfunc

func choose_file ()
$audioFile=FileOpenDialog ("Choose mp3 file", "", "Mp3 file (*.mp3)", 3, "", $form)
if $audiofile="" then return
WinSetTitle ($form, "", "Say Subtitles - "&stringtrimleft ($AudioFile, stringinstr ($AudioFile, "\", default, -1)+0))
_bass_streamFree ($stream)
$stream=_Bass_StreamCreateFile (false, $audiofile, 0, 0, "")
_BASS_ChannelSetVolume ($stream, $volume)
_bass_Channelplay ($stream, 1)
$length=Get_Length ($stream)
$playing=true
$SRTFile=stringtrimright ($audioFile, stringlen ($AudioFile)-stringinstr ($AudioFile, ".", default, -1)+1)
$SRTFile=$SRTFile&".srt"
; if fileexists ($SRTFile) then $found_sub=true
$found_sub=_prepare_srt ($SRTFile, $index, $start_time, $end_time, $text)
if $found_sub=false then
_Stopme ()
_SpeakMe ("SRT file not found.")
return
endif
for $i=1 to $index[0]
$start_time[$i]=int_srt ($start_time[$i])
next
$speak_sub=true
$indexNR=1
endfunc

func audio_stop ($param="stop")
if $audiofile="" then
if $param="stop" then $sk=$tekstai[0]
if $param="stop" then _SpeakMe ($tekstai[$sk])
return
endif
_bass_streamFree ($stream)
$audiofile=""
WinSetTitle ($form, "", "Say Subtitles")
$found_sub=false
$speak_sub=false
$SRTFile=""
$index=""
$start_time=""
$end_time=""
$text=""
$indexNR=0
_SpeakMe ("Closed, main menu, "&$tekstai[$sk])
endfunc

func play_pause ()
if $playing then
_BASS_ChannelPause ($stream)
$playing=false
else
_BASS_ChannelPlay ($stream, 0)
sleep (100)
$playing=true
endif
endfunc

func dummy_up ()
if $audiofile<>"" then
if $volume<100 then $volume=$volume+1
_BASS_ChannelSetVolume ($stream, $volume)
return
endif
if $sk=1 then $sk=2
$sk=$sk-1
_stopme ()
_SpeakMe ($tekstai[$sk])
endfunc

func dummy_down ()
if $audiofile<>"" then
if $volume>0 then $volume=$volume-1
_BASS_ChannelSetVolume ($stream, $volume)
return
endif
if $sk=$tekstai[0] then $sk=$tekstai[0]-1
$sk=$sk+1
_stopme ()
_SpeakMe ($tekstai[$sk])
endfunc

func right ($param)
local $a=_BASS_ChannelGetPosition ($stream, $BASS_POS_BYTE)
$a=_BASS_ChannelBytes2Seconds ($stream, $a)
$a=$a+$param
$a=_BASS_ChannelSeconds2Bytes ($stream, $a)
_BASS_ChannelSetPosition ($stream, $a, $BASS_POS_BYTE)
endfunc

func left ($param)
local $a=_BASS_ChannelGetPosition ($stream, $BASS_POS_BYTE)
$a=_BASS_ChannelBytes2Seconds ($stream, $a)
if $a<$param then
$a=0
endif
$a=_BASS_ChannelSeconds2Bytes ($stream, $a)
_BASS_ChannelSetPosition ($stream, $a, $BASS_POS_BYTE)
endfunc

func say_duration ()
local $bytes=_BASS_ChannelGetLength ($stream, $BASS_POS_BYTE)
local $a=_BASS_ChannelBytes2Seconds ($stream, $bytes)
$a=floor ($a)
local $min, $sek
$min=$a/60
$min=floor ($min)
$sek=mod ($a, 60)
if $min=-1 then return
_SpeakMe ($min&" min, "&$sek&" sec")
endfunc

func _prepare_srt ($filename, byref $indeksai, byref $laikas_nuo, byref $laikas_iki, byref $tekstai)
if not fileexists ($filename) then return false
$FHandle=fileopen ($filename)
local $eilutes=_filecountlines ($filename)
if $eilutes=0 then return false
local $aarray[$eilutes+1]
$aarray[0]=$eilutes
local $aarray2[$eilutes+1]
$aarray2[0]=$eilutes
local $j=1
for $i=1 to $aarray[0]
$aarray[$i]=filereadline ($FHandle)
$aarray[$i]=StringStripWS ($aarray[$i], 1+2)
if $aarray[$i]=" " then $aarray[$i]=""
$aarray[$i]=stringreplace ($aarray[$i], " --> ", "|")
; pagr algoritmas
if $aarray[$i]<>"" then
if $aarray[$i-1]="" then
$j=$j+1
$aarray2[0]=$j
endif
$aarray2[$j]=$aarray2[$j]&"|"&$aarray[$i]
endif
; pagr algoritmo galas
next
fileclose ($FHandle)
local $kiekis=$aarray2[0]
dim $indeksai[$kiekis+1]
$indeksai[0]=$kiekis
dim $laikas_nuo[$kiekis+1]
$laikas_nuo[0]=$kiekis
dim $laikas_iki[$kiekis+1]
$laikas_iki[0]=$kiekis
dim $tekstai[$kiekis+1]
$tekstai[0]=$kiekis
local $stringas=""
for $i=1 to $aarray2[0]
$aarray2[$i]=stringtrimleft ($aarray2[$i], 1)
$stringas=stringsplit ($aarray2[$i], "|")
if ($stringas[0]=1) or ($stringas[0]=2) then $stringas=""
if isarray($stringas) then
if $stringas[0]<3 then
$indeksai[$i]=""
$laikas_nuo[$i]=""
$laikas_iki[$i]=""
$tekstai[$i]=""
else
$indeksai[$i]=$stringas[1]
$laikas_nuo[$i]=$stringas[2]
$laikas_iki[$i]=$stringas[3]
if $stringas[0]=3 then
$tekstai[$i]=""
else
for $j=4 to $stringas[0]
$tekstai[$i]=$tekstai[$i]&" "&$stringas[$j]
next
endif
endif
else
$indeksai[$i]=""
$laikas_nuo[$i]=""
$laikas_iki[$i]=""
$tekstai[$i]=""
endif
$stringas=""
next
return true
endfunc

; converts srt time value to sec leaving 3 digits for ms
func int_srt ($time)
if stringlen ($time)<>12 then return ""
local $hour=0, $min=0, $sec=0, $ms=0
$hour=stringmid ($time, 1, 2)
$min=stringmid ($time, 4, 2)
$sec=stringmid ($time, 7, 2)
$MS=stringmid ($time, 10, 3)
local $tmp=$sec&"."&$MS
$hour=int($hour)
$min=int ($min)
$sec=int ($sec)
local $temp=($hour*60*60)+($min*60)
$tmp=round ($tmp, 3)
$temp=$temp+$tmp
return $temp
endfunc

func klaida ()
; if OBJError
return
endfunc

; speaks and brailles text
func _SpeakMe ($fraze)
_NVDASay ($fraze)
if $sapi_enabled=true then $OSapi.speak ($fraze, 1)
$OJawsAPI.SayString ($fraze, false)
$fraze=stringreplace ($fraze, "'", '"')
; replacing from ' to " as jaws doesn't understand it in runFunction
$OJawsAPI.RunFunction ("BrailleString("&$fraze&")")
endfunc

; stop speaking
func _StopMe ()
_NVDAStop ()
$osapi.speak ("", 3)
$OJawsAPI.SayString ("", true)
; $OJawsAPI.StopSpeech
endfunc

func get_length ($param)
local $bytes=_BASS_ChannelGetLength ($param, $BASS_POS_BYTE)
return _BASS_ChannelBytes2Seconds ($param, $bytes)
endfunc

func get_position ($param)
if not _bass_ChannelIsActive ($stream) then return
local $bytes=_BASS_ChannelGetPosition ($param, $BASS_POS_BYTE)
$bytes=_BASS_ChannelBytes2Seconds ($param, $bytes)
return $bytes
endfunc

