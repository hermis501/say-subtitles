#NoTrayIcon
if not fileExists (@scriptdir&"\ffmpeg.exe") then
MSGBox (16, "Error", "ffmpeg.exe is missing.")
exit
endif
global $IF=fileopendialog ("Choose file", "", "All (*.*)", 1+2)
if $IF="" then exit
global $OF=stringtrimright ($IF, stringlen ($IF)-stringinstr ($IF, ".", default, -1)+1)
$OF=$OF&".mp3"
global $cmd='-y -i "'&$IF&'" -acodec libmp3lame -vn -ab 128k "'&$OF&'"'
if msgbox (4, "Information", "Creating the mp3 could take several minutes. Are you sure you wish to continue?")=7 then exit
run (@scriptdir&'\ffmpeg.exe '&$cmd)
