include karax / prelude

proc createDom(): VNode =
  result = buildHtml(tdiv):
    a(href="/logout"):
      text "logout"

setRenderer createDom
