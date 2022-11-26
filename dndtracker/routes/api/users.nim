import std / json
import jester

import ../../consts
import ../../models/user

proc postadduser*(request: Request, user: User): ResponseData {.gcsafe.} =
  block route:
    # Verify that the request came from an admin
    if not ord(UserRoleType.Admin) in getUserRolesInt(user):
      let data = $(%*{"status": "failed"})
      resp Http403, data, "application/json"

    # Add the user
    let bodyJson = parseJson(request.body)
    let username = bodyJson["username"].getStr()
    let password = bodyJson["password"].getStr()
    let email = ""
    addUser(username, password, email)

    # Return the status
    let data = $(%*{"status": "success"})
    resp data, "application/json"

proc postchangepassword*(request: Request, user: User): ResponseData {.gcsafe.} =
  block route:
    # Change the password
    let password = request.body
    let success = changePassword(user.name, password)
    if not success:
      let data = $(%*{"status": "error"})
      resp Http500, data, "application/json"
    else:
      let data = $(%*{"status": "success"})
      resp data, "application/json"

proc getuserinfo*(request: Request, user: User): ResponseData {.gcsafe.} =
  block route:
    # Return the user information
    let userRoles = getUserRolesInt(user)
    let data = $(%*{"username": user.name, "roles": userRoles})
    resp data, "application/json"

proc getusername*(request: Request, user: User): ResponseData {.gcsafe.} =
  block route:
    # Return the username
    let data = $(%*{"username": user.name})
    resp data, "application/json"

