import std / json

include karax / prelude
import karax / [kajax, kdom]

const welcomeId = "welcome"

proc createViewHeader*(): VNode =
  result = buildHtml(tdiv):
    tdiv(id=welcomeId): text ""
    a(href="/logout"):
      text "logout"

proc initViewHeader*() =
  # Get the user info
  proc userInfoUpdate(httpStatus: int, response: cstring) =
    if httpStatus == 200:
      let responseJson = parseJson($response)
      let username = (cstring)responseJson["username"].getStr()
      document.getElementById(welcomeId).innerHTML = "Welcome " & username
  ajaxGet("/api/v1/userinfo", @[], userInfoUpdate)
