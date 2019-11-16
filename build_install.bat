mt.exe -manifest "bfree.exe.manifest" -outputresource:"bfree.exe";#1
upx bfree.exe
cd install
copy ..\bfree.exe /y
md images
cd images
copy ..\..\images\*.*
cd ..
cd songs
md Article
md Chords
md Midi
md MP3
md Sheet
cd ..
cd ..


