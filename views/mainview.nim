import std / json

include karax / prelude
import karax / kajax

#import std / [cookies, strtabs]
#import karax / kdom
#let cookieJar = parseCookies($document.cookie)

var username: kstring = ""

proc createDom(): VNode =
  result = buildHtml(tdiv):
    if username != "":
      tdiv:
        text "Welcome " & username
    a(href="/logout"):
      text "logout"
    h1: text "DND Power"

setRenderer createDom

# Get the user info
proc userInfoUpdate(httpStatus: int, response: cstring) =
  let responseJson = parseJson($response)
  username = kstring(responseJson["username"].getStr())
ajaxGet("/api/v1/userinfo", @[], userInfoUpdate)

