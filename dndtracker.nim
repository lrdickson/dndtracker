import std / htmlgen

import jester

proc addTemplate(bodyHtml, pageTitle: string): string =
  let page = html(
    head(
      title(pageTitle),
      style("")),
    body(bodyHtml))
  return page

proc addTemplate(bodyHtml: string): string =
  return bodyHtml.addTemplate("DND Tracker")

proc home: string =
  let page = h1("DND Power").addTemplate
  return page

proc loginView: string =
  let page = form(action="/login", `method`="post", enctype="multipart/form-data",
    `div`(
      label("Username:"),
      br(),
      input(placeholder="Enter Username", name="username")),
    `div`(
      label("Password:"),
      br(),
      input(type="password", placeholder="Enter Password", name="password")),
    `div`(button(type="submit","Login"))
  ).addTemplate("Login")
  return page

proc loginPost(request: Request): Future[string] {.async.} =
  let username = request.formData.getOrDefault("username").body
  let password = request.formData.getOrDefault("password").body
  return "Username: " & username & "\nPassword: " & password

routes:
  get "/":
    resp home()
  get "/login":
    resp loginView()
  get "/login/":
    resp loginView()
  post "/login":
    resp await loginPost(request)
  post "/login/":
    resp await loginPost(request)
