# Standard library
from std / htmlgen import nil
import std / [
  json,
  macros,
  os,
  times
  ]

# 3rd party
import jester

# Internal
import dndtracker / [ database, databaseinitializer ]
import dndtracker / models / user

# Setup the database
let dbNeedsInitialized = not fileExists(DB_FILEPATH)
openDbConn()
prepareDatabase(dbNeedsInitialized)

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

const MAIN_VIEW_JS = staticRead("js/mainview.js")
const LOGIN_VIEW_JS = staticRead("js/loginview.js")

macro getSessionUser(request, user) = quote do:
    # Get the session
    let sessionId = `request`.cookies.getOrDefault("session", "")
    let (sessionFound, session) = getSession(sessionId)
    if not sessionFound:
      let data = $(%*{"status": "failed"})
      resp Http401, data, "application/json"

    # Get the user information
    var `user` = session.user

routes:
  get "/":
    let session = request.cookies.getOrDefault("session")
    if session == "":
      redirect "/login"
    resp createView("/static/mainview.js")

  get "/login":
    resp createView("/static/loginview.js", "Login")

  post "/login":
    # Login the user
    let username = request.formData.getOrDefault("username").body
    let password = request.formData.getOrDefault("password").body
    var (sessionId, expire) = beginSession(username, password)
    if sessionId == "":
      resp "incorrect username or password"

    # Set the cookie to mark the user as logged in
    setCookie("session", sessionId, expire)
    setCookie("username", username, expire)
    redirect("/")

  get "/logout":
    # End the session
    let session = request.cookies.getOrDefault("session")
    endSession(session)

    # Clear the cookies
    setCookie("session", "", now().utc)
    setCookie("username", "", now().utc)
    redirect("/login")

  get "/static/mainview.js":
    resp MAIN_VIEW_JS
  get "/static/loginview.js":
    resp LOGIN_VIEW_JS

  get "/api/v1/userinfo":
    getSessionUser(request, user)

    # Return the user information
    let data = $(%*{"username": user.name})
    resp data, "application/json"

  post "/api/v1/changepassword":
    getSessionUser(request, user)

    # Change the password
    let password = request.body
    let success = changePassword(user, password)
    if not success:
      let data = $(%*{"status": "error"})
      resp Http500, data, "application/json"
    else:
      let data = $(%*{"status": "success"})
      resp data, "application/json"

