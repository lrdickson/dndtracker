import std / json

include karax / prelude
import karax / [kajax, kdom, vstyles]

#import std / [cookies, strtabs]
#let cookieJar = parseCookies($document.cookie)

var passwordChangeStatus: kstring = ""
const passwordInputId = "passwordInput"
var username: kstring = ""

proc passwordChangeField(labelText, inputId, inputType: kstring): VNode =
  let labelStyle = style(
          (StyleAttr.display, cstring"inline-block"),
          (StyleAttr.width, cstring"100px"),
          (StyleAttr.padding, cstring"5px")
        )
  result = buildHtml(tdiv):
    tdiv(style=labelStyle):
      label: text labelText & ":"
    input(id=inputId, type=inputType)

proc passwordChangeCb(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    passwordChangeStatus = "Successfully changed the password"
  else:
    passwordChangeStatus = "Failed to change the password"

proc passwordChangeSubmit(ev: Event; n: VNode) =
  let password = document.getElementById(passwordInputId).value
  ajaxPost("/api/v1/changepassword", @[], password, passwordChangeCb)

proc createDom(): VNode =
  result = buildHtml(tdiv):
    if username != "":
      tdiv:
        text "Welcome " & username
    a(href="/logout"):
      text "logout"
    h4:
      text "Change Password"
    passwordChangeField("Password", passwordInputId, "password")
    tdiv:
      button(onclick=passwordChangeSubmit): text "submit"
    tdiv: text passwordChangeStatus

# Render the page
setRenderer createDom

# Get the user info
proc userInfoUpdate(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    let responseJson = parseJson($response)
    username = kstring(responseJson["username"].getStr())
ajaxGet("/api/v1/userinfo", @[], userInfoUpdate)

