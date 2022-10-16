import std / json
import jsffi except `&`

include karax / prelude
import karax / [kajax, kdom, vstyles]

import ../consts
import ../viewutils

#import std / [cookies, strtabs]
#let cookieJar = parseCookies($document.cookie)

let marginTopStyle = style((StyleAttr.marginTop, cstring"5px"))

proc createInputField(labelText, inputId, inputType: kstring): VNode =
  let labelStyle = style(
          (StyleAttr.display, cstring"inline-block"),
          (StyleAttr.width, cstring"100px"),
          (StyleAttr.padding, cstring"5px")
        )
  result = buildHtml(tdiv):
    tdiv(style=labelStyle):
      label: text labelText & ":"
    input(id=inputId, type=inputType)

var passwordChangeStatus: kstring = ""
const passwordChangeInputId = "passwordInput"

proc passwordChangeCb(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    passwordChangeStatus = "Successfully changed the password"
  else:
    passwordChangeStatus = "Failed to change the password"

proc passwordChangeSubmit(ev: Event; n: VNode) =
  passwordChangeStatus = ""
  let password = document.getElementById(passwordChangeInputId).value
  ajaxPost("/api/v1/changepassword", @[], password, passwordChangeCb)

var addUserStatus : kstring = ""
const addUserUsernameId = "addUserUsername"
const addUserPasswordId = "addUserPassword"

proc addUserCb(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    addUserStatus = "Successfully added new user"
  else:
    addUserStatus = "Failed to add new user"

proc addUserSubmit(ev: Event; n: VNode) =
  let username = $document.getElementById(addUserUsernameId).value
  let password = $document.getElementById(addUserPasswordId).value
  let data = cstring($(%*{"username": username, "password": password}))
  let headers:seq[(cstring, cstring)] = @[(cstring("Content-Type"), cstring("application/json"))]
  ajaxPost("/api/v1/adduser", headers, data, addUserCb)

var userRoles: seq[int] = @[]

proc createDom(): VNode =
  result = buildHtml(tdiv):
    createUserDisplay()
    a(class="btn btn-primary", style=marginTopStyle, href="/"):
      text "Main"
    h4:
      text "Change Password"
    createInputField("Password", passwordChangeInputId, "password")
    tdiv:
      button(onclick=passwordChangeSubmit): text "submit"
    tdiv: text passwordChangeStatus
    if AdminRole in userRoles:
      h4:
        text "Add User"
      createInputField("username", addUserUsernameId, "input")
      createInputField("password", addUserPasswordId, "password")
      tdiv:
        button(onclick=addUserSubmit): text "submit"
      tdiv: text addUserStatus

# Render the page
setRenderer createDom

# Load the user display
initUserDisplay()

# Get the user info
proc userInfoUpdate(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    let responseJson = parseJson($response)
    userRoles = @[]
    for role in responseJson["roles"].getElems():
      userRoles.add(role.getInt())
ajaxGet("/api/v1/userinfo", @[], userInfoUpdate)
