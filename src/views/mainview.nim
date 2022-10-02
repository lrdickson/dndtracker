include karax / prelude

proc createDom(): VNode =
  result = buildHtml(tdiv):
    a(href="/logout"):
      text "logout"
    h1: text "DND Power"

setRenderer createDom
