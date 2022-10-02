
exec "nim js --outdir:static views/mainview.nim"
exec "nim js --outdir:static views/loginview.nim"
exec "nim c --dynlibOverride:sqlite3 --passL:\"sqlite3.c -lm -pthread\" dndtracker.nim"
