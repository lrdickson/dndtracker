import std / json

include karax / prelude
import karax / [kajax, kdom, vstyles]

import ../viewutils

#import std / [cookies, strtabs]
#let cookieJar = parseCookies($document.cookie)

let marginTopStyle = style((StyleAttr.marginTop, cstring"5px"))

proc createDom(): VNode =
  result = buildHtml(tdiv):
    createViewHeader()
    a(class="btn btn-primary", style=marginTopStyle, href="/settings"):
      text "settings"

# Render the page
setRenderer createDom

initViewHeader()
