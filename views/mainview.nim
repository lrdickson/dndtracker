import std / json

include karax / prelude
import karax / [kajax, vstyles]

#import std / [cookies, strtabs]
#import karax / kdom
#let cookieJar = parseCookies($document.cookie)

var passwordChangeStatus: kstring = ""
var username: kstring = ""

proc passwordChangeField(labelText, inputName, inputType: kstring): VNode =
  let labelStyle = style(
          (StyleAttr.display, cstring"inline-block"),
          (StyleAttr.width, cstring"100px"),
          (StyleAttr.padding, cstring"5px")
        )
  result = buildHtml(tdiv):
    tdiv(style=labelStyle):
      label: text labelText & ":"
    input(name=inputName, type=inputType)

proc passwordChangeCb(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    passwordChangeStatus = "Successfully changed the password"
  else:
    passwordChangeStatus = "Failed to change the password"

proc passwordChangeSubmit(ev: Event; n: VNode) =
  discard

proc createDom(): VNode =
  result = buildHtml(tdiv):
    if username != "":
      tdiv:
        text "Welcome " & username
    a(href="/logout"):
      text "logout"
    h3:
      text "Change Password"
    form:
      passwordChangeField("Password", "password", "password")
      tdiv:
        button(type="submit", id="passwordChangeSubmit"): text "submit"



setRenderer createDom

# Get the user info
proc userInfoUpdate(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    let responseJson = parseJson($response)
    username = kstring(responseJson["username"].getStr())
ajaxGet("/api/v1/userinfo", @[], userInfoUpdate)

