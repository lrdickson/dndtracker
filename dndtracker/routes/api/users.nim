import std / json
import Prologue

import ../../consts
import ../../models/user
import ../../utils

proc postadduser*(ctx: Context) {.async, gcsafe.} =
  # Get the session
  let (user, userFound) = ctx.getSessionUser()
  if not userFound:
    resp abort()
    return

  # Verify that the request came from an admin
  if not ord(UserRoleType.Admin) in getUserRolesInt(user):
    respDefault Http404
    return

  # Add the user
  let bodyJson = parseJson(request.body)
  let username = bodyJson["username"].getStr()
  let password = bodyJson["password"].getStr()
  let email = ""
  addUser(username, password, email)

  # Return the status
  let data = $(%*{"status": "success"})
  resp data, "application/json"

proc postchangepassword*(ctx: Context) {.async, gcsafe.} =
  # Change the password
  let password = request.body
  let success = changePassword(user.name, password)
  if not success:
    let data = $(%*{"status": "error"})
    resp Http500, data, "application/json"
  else:
    let data = $(%*{"status": "success"})
    resp data, "application/json"

proc getuserinfo*(ctx: Context) {.async, gcsafe.} =
  # Return the user information
  let userRoles = getUserRolesInt(user)
  let data = $(%*{"username": user.name, "roles": userRoles})
  resp data, "application/json"

proc getusername*(ctx: Context) {.async, gcsafe.} =
  # Return the username
  let data = $(%*{"username": user.name})
  resp data, "application/json"

