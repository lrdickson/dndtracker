import std/[json, macros]

import models/user

macro checkViewSession*(request: untyped) = quote do:
  let sessionId = `request`.cookies.getOrDefault("session", "")
  let (sessionFound, session) = getSession(sessionId)
  if not sessionFound:
      redirect "/login"

macro getSessionUser*(request: untyped, user: User): untyped =
  result = quote do:
    # Get the session
    let sessionId = `request`.cookies.getOrDefault("session", "")
    let (sessionFound, session) = getSession(sessionId)
    if not sessionFound:
      let data = $(%*{"status": "failed"})
      resp Http401, data, "application/json"

    # Get the user information
    var user = session.user

