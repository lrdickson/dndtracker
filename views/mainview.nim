include std / cookies

include karax / prelude
import karax / kdom

let cookieJar = parseCookies($document.cookie)

proc createDom(): VNode =
  result = buildHtml(tdiv):
    p:
      text "Welcome " & cookieJar["username"]
    a(href="/logout"):
      text "logout"
    h1: text "DND Power"

setRenderer createDom
