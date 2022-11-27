# Standard library
from std / htmlgen import nil
import std / [
  asyncdispatch,
  asyncnet,
  json,
  os,
  times
  ]

# 3rd party
import jester

# Internal
import dndtracker / [ consts, databaseinitializer, utils ]
import dndtracker / models / [campaign, user]
import dndtracker / routes / api

# Setup the database
const DB_FILEPATH = "dnd.db"
putEnv("DB_HOST", DB_FILEPATH)
let dbNeedsInitialized = not fileExists(DB_FILEPATH)
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
      #htmlgen.script(type="text/javascript", src=viewJs),
      htmlgen.script(viewJs),
      "<script src=\"https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/js/bootstrap.bundle.min.js\" integrity=\"sha384-OERcA2EqjJCMA+/3y+gxIOqMEjwtxJY7qPCqsdltbNJuaOe923+mo//f6V8Qbsw3\" crossorigin=\"anonymous\"></script>"
      ))
  return "<!doctype html>\n" & page

proc createView(viewJs: string): string =
  return viewJs.createView("DND Tracker")

const MAIN_VIEW_JS = staticRead("js/mainview.js")
const LOGIN_VIEW_JS = staticRead("js/loginview.js")
const SETTINGS_VIEW_JS = staticRead("js/settingsview.js")


proc match(request: Request): Future[ResponseData] {.async.} =
    if request.pathInfo == "/login":
      block route:
        if request.reqMethod == HttpGet:
          resp createView(LOGIN_VIEW_JS, "Login")
        elif request.reqMethod == HttpPost:
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
        else:
          resp Http404

    let sessionId = request.cookies.getOrDefault("session", "")
    let (sessionFound, session) = getSession(sessionId)
    if not sessionFound:
      block route:
        if request.pathInfo in ["/", "/settings"]:
          redirect "/login"
        else:
          let data = $(%*{"status": "failed"})
          resp Http401, data, "application/json"

    # Get the user information
    var user = session.user

    case request.pathInfo
    of "/":
      block route:
        resp createView(MAIN_VIEW_JS)
    of "/settings":
      block route:
        resp createView(SETTINGS_VIEW_JS)
    of "/logout":
      block route:
        # End the session
        endSession(sessionId)

        # Clear the cookies
        setCookie("session", "", now().utc)
        setCookie("username", "", now().utc)
        redirect("/login")

    of "/api/v1/addcharacter":
      block route:
        addCharacter(user)

        # Return the status
        let data = $(%*{"status": "success"})
        resp data, "application/json"
    else:
      discard

    case request.pathInfo
    of "/adduser":
      return postadduser(request, user)
    of "/changepassword":
      return postchangepassword(request, user)
    of "/userinfo":
      return getuserinfo(request, user)
    of "/username":
      return getusername(request, user)
    else:
      block route:
        redirect "/login"

    block route:
      redirect "/login"


when isMainModule:
  let s = newSettings(
    Port(5000),
    bindAddr="127.0.0.1",
  )

  var server = initJester(match, s)
  server.serve()
