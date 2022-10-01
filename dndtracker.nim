import std / htmlgen

import jester

const MAIN_VIEW_HTML = staticRead("mainview.html")
const MAIN_VIEW_JS = staticRead("mainview.js")

proc addTemplate(bodyHtml, pageTitle: string): string =
  let page = html(
    head(
      title(pageTitle),
      style("")),
    body(bodyHtml))
  return page

proc addTemplate(bodyHtml: string): string =
  return bodyHtml.addTemplate("DND Tracker")

proc home(request: Request): Future[string] {.async.} =
  let session = request.cookies.getOrDefault("session")
  let page = `div`(
    p("Session: " & session),
    br(),
    a(href="/logout", "logout"),
    br(),
    h1("DND Power")).addTemplate
  return page

proc loginView: string =
  let page = form(action="/login", `method`="post", enctype="multipart/form-data",
    label("Username:"),br(),
    input(placeholder="Enter Username", name="username"),br(),
    label("Password:"),br(),
    input(type="password", placeholder="Enter Password", name="password"),br(),
    button(type="submit","Login")
  ).addTemplate("Login")
  return page

proc loginPost(request: Request): Future[bool] {.async.} =
  let username = request.formData.getOrDefault("username").body
  let password = request.formData.getOrDefault("password").body

  # Authenticate the user
  var validCredentials: bool
  case username
  of "a":
    validCredentials = password == "a"
  else:
    validCredentials = false

  return validCredentials

routes:
  get "/":
    let session = request.cookies.getOrDefault("session")
    if session == "":
      redirect "/login"
    resp MAIN_VIEW_HTML
  get "/login":
    resp loginView()
  post "/login":
    # Check the credentials
    let validCredentials = await loginPost(request)
    if not validCredentials:
      resp "incorrect username or password"

    setCookie("session", "1", daysForward(1))
    redirect("/")
  get "/logout":
    setCookie("session", "", daysForward(1))
    redirect("/login")
  get "/static/mainview.js":
    resp MAIN_VIEW_JS
