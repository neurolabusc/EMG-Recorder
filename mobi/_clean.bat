del /S *.~*
del /S *.ppu
del /S *.o
del /S *.dcu
del /S *.obj
del /S *.hpp
del /S *.ddp
del /S *.mps
del /S *.mpt
del /S *.dsm
C:\strip  /B  "C:\mobi\mobirecord.exe"
del emgrecsrc.zip
c:\Progra~1\7-Zip\7z a -tzip emgrecsrc.zip
del emgrec.zip
c:\Progra~1\7-Zip\7z a -tzip emgrec.zip *.exe *.dll


copy c:\mobi\emgrecsrc.zip Z:\html\nl\tools\elecro\emgrecsrc.zip
copy c:\mobi\emgrec.zip Z:\html\nl\tools\elecro\emgrec.zip