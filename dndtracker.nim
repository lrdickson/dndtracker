import std/asynchttpserver
import std/asyncdispatch

proc main {.async.} =
  var httpServer = newAsyncHttpServer()
  proc callBack(request: Request) {.async.} =
    echo "Request Method: " & $request.reqMethod
    echo "Request URL: " & $request.url
    echo "Request Headers: " & $request.headers
    let headers = {"content-type": "text/plain; charset=utf-8"}
    await request.respond(Http200, "DND Power", headers.newHttpHeaders())

  httpServer.listen(Port(8080))
  let port = httpServer.getPort
  echo "server started on port " & $port.uint16
  while true:
    if httpServer.shouldAcceptRequest():
      await httpServer.acceptRequest(callBack)
    else:
      await sleepAsync(500)

if isMainModule:
  waitFor main()

