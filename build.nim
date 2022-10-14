#import std / httpclient
import std / os

# make sure the nimble packages are installed
var result = execShellCmd "nimble install -d -y"
if result != 0:
  quit(result)

# compile the karax views
createDir "js"
for (kind, view) in walkDir("dndtracker/views"):
  let (dir, name, ext) = splitFile(view)
  let compileView = "js/" & name & ".js"
  if not fileExists(compileView) or fileNewer(view, compileView):
    result = execShellCmd "nim js --outdir:js " & view
    if result != 0:
      quit(result)

# Get sqlite3
#var client = newHttpClient()
#var sqliteZip = client.getContent("https://www.sqlite.org/2022/sqlite-amalgamation-3390400.zip")
#echo sqliteZip

# Compile the main server
createDir "bin"
discard execShellCmd "nim c --outdir:bin --dynlibOverride:sqlite3 --passL:\"sqlite3.c -lm -pthread\" dndtracker.nim"
