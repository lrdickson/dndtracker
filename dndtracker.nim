# Standard library
from std / htmlgen import nil
import std / os

# 3rd party
import jester

# Internal
import dndtracker / [ database, databaseinitializer ]
import dndtracker / models / user

proc createView(viewJs, pageTitle: string): string =
  let page = htmlgen.html(
    htmlgen.head(
      htmlgen.meta(charset="utf-8"),
      htmlgen.meta(name="viewport", content="width=device-width, initial-scale=1"),
      htmlgen.title(pageTitle),
      "<link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-Zenh87qX5JnK2Jl0vWa8Ck2rdkQ2Bzep5IDxbcnCeuOxjzrPF/et3URy9Bv1WTRi\" crossorigin=\"anonymous\">"
      ),
    htmlgen.body(id="body",
      htmlgen.`div`(id="ROOT"),
      htmlgen.script(type="text/javascript", src=viewJs),
      "<script src=\"https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/js/bootstrap.bundle.min.js\" integrity=\"sha384-OERcA2EqjJCMA+/3y+gxIOqMEjwtxJY7qPCqsdltbNJuaOe923+mo//f6V8Qbsw3\" crossorigin=\"anonymous\"></script>"
      ))
  return "<!doctype html>\n" & page

proc createView(viewJs: string): string =
  return viewJs.createView("DND Tracker")

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

  return checkPassword(username, password)

# Setup the database
let dbNeedsInitialized = not fileExists(DB_FILEPATH)
openDbConn()
prepareDatabase(dbNeedsInitialized)

const MAIN_VIEW_JS = staticRead("js/mainview.js")
const LOGIN_VIEW_JS = staticRead("js/loginview.js")

routes:
  get "/":
    let session = request.cookies.getOrDefault("session")
    if session == "":
      redirect "/login"
    resp createView("/static/mainview.js")
  get "/login":
    resp createView("/static/loginview.js", "Login")
  post "/login":
    # Check the credentials
    let validCredentials = await loginPost(request)
    if not validCredentials:
      resp "incorrect username or password"

    # Set the cookie to mark the user as logged in
    setCookie("session", "1", daysForward(1))
    redirect("/")
  get "/logout":
    setCookie("session", "", daysForward(1))
    redirect("/login")
  get "/static/mainview.js":
    resp MAIN_VIEW_JS
  get "/static/loginview.js":
    resp LOGIN_VIEW_JS
