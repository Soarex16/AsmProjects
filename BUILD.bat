Echo Off
cls
If -%1== - GoTo Mess1
If not exist %1.Asm GoTo Mess2
Echo Compiling ...
TAsm %1.Asm /zi /l
If ErrorLevel 1 GoTo ContErr
Echo No errors ...
Echo Linking ...
TLink /v %1.Obj
Del %1.Lst
Del %1.Map
Del %1.Obj

GoTo Exit

:ContErr
Echo !!! There are errors ...
Echo Watch carefully *.Lst
Pause
Rem Type %1.Lst
Rem Pause
GoTo Exit

:Mess1
Echo Empty parameters ...
GoTo Exit
:Mess2
Echo %1.asm not found
:Exit