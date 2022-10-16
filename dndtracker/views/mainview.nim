import std / json

include karax / prelude
import karax / [kajax, kdom, vstyles]

import ../viewutils

#import std / [cookies, strtabs]
#let cookieJar = parseCookies($document.cookie)

let marginTopStyle = style((StyleAttr.marginTop, cstring"5px"))

var addCharacterStatus : kstring = ""

proc addCharacterCb(httpStatus: int, response: cstring) =
  if httpStatus == 200:
    addCharacterStatus = "Successfully added new character"
  else:
    addCharacterStatus = "Failed to add new character"

proc addCharacterSubmit(ev: Event; n: VNode) =
  addCharacterStatus = ""
  ajaxGet("/api/v1/addcharacter", @[], addCharacterCb)


proc createDom(): VNode =
  result = buildHtml(tdiv):
    createUserDisplay()
    a(class="btn btn-primary", style=marginTopStyle, href="/settings"):
      text "settings"
    tdiv:
      button(onclick=addCharacterSubmit): text "Add Character"
    tdiv: text addCharacterStatus

# Render the page
setRenderer createDom

initUserDisplay()
