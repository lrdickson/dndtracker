include karax / prelude

proc createDom(): VNode =
  result = buildHtml(tdiv):
    form(action="/login", `method`="post", enctype="multipart/form-data"):
      tdiv:
        label: text "Username:"
      tdiv:
        input(placeholder="Enter Username", name="username")
      tdiv:
        label: text "Password:"
      tdiv:
        input(type="password", placeholder="Enter Password", name="password")
      tdiv:
        button(type="submit"): text "Login"


setRenderer createDom
