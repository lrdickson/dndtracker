include karax / prelude
import karax / vstyles

proc loginField(labelText, inputName, inputType: kstring): VNode =
  let labelStyle = style(
          (StyleAttr.display, cstring"inline-block"),
          (StyleAttr.width, cstring"100px"),
          (StyleAttr.padding, cstring"5px")
        )
  result = buildHtml(tdiv):
    tdiv(style=labelStyle):
      label: text labelText & ":"
    input(name=inputName, type=inputType)

proc createDom(): VNode =
  let formStyle = style((StyleAttr.textAlign, cstring"center"))
  result = buildHtml(tdiv):
    form(action="/login", `method`="post", enctype="multipart/form-data", style=formStyle):
      loginField("Username", "username", "input")
      loginField("Password", "password", "password")
      tdiv:
        button(type="submit"): text "Login"

setRenderer createDom
