import std/[json, macros]

import models/user

proc getSessionUser*(ctx: Context): (User, bool) =
  let username = ctx.session.getOrDefault("username", "")
  return getUser(username)

proc sessionActive*(ctx: Context): bool =
  let (user, userFound) = ctx.getSessionUser()
  return userFound


