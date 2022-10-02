import std / os

# compile the karax views
createDir "js"
for (kind, view) in walkDir("views"):
  let (dir, name, ext) = splitFile(view)
  let compileView = "js/" & name & ".js"
  if not fileExists(compileView) or fileNewer(view, compileView):
    discard execShellCmd "nim js --outdir:js " & view

# Compile the main server
createDir "bin"
discard execShellCmd "nim c --outdir:bin --dynlibOverride:sqlite3 --passL:\"sqlite3.c -lm -pthread\" dndtracker.nim"
