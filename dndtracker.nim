from std / htmlgen import nil
import std / [
  os,
  ]

import prologue
import prologue/middlewares/sessions/signedcookiesession

# Internal
import dndtracker / [ consts, databaseinitializer, urls, utils ]
import dndtracker / models / [campaign, user]

const MAIN_VIEW_JS = staticRead("js/mainview.js")
const LOGIN_VIEW_JS = staticRead("js/loginview.js")
const SETTINGS_VIEW_JS = staticRead("js/settingsview.js")

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

proc homeView(ctx: Context) {.async.} =
  resp createView(MAIN_VIEW_JS)

proc loginView(ctx: Context) {.async.} =
  resp createView(LOGIN_VIEW_JS, "Login")

proc loginPost(ctx: Context) {.async, gcsafe.} =
  # Login the user
  let username = ctx.getFormParamsOption("username").get()
  let password = ctx.getFormParamsOption("password").get()
  var (sessionId, expire) = beginSession(username, password)
  if sessionId == "":
    resp "incorrect username or password"

  # Set the cookie to mark the user as logged in
  ctx.session["username"] = username
  resp redirect("/")

when isMainModule:
  # Setup the database
  const DB_FILEPATH = "dnd.db"
  putEnv("DB_HOST", DB_FILEPATH)
  let dbNeedsInitialized = not fileExists(DB_FILEPATH)
  prepareDatabase(dbNeedsInitialized)

  let
    env = loadPrologueEnv(".env")
    settings = newSettings(
      appName = env.getOrDefault("appName", "Prologue"),
      debug = env.getOrDefault("debug", true),
      port = Port(env.getOrDefault("port", 8080)),
      secretKey = env.getOrDefault("secretKey", "")
      )

  var app = newApp(settings = settings)
  app.use(sessionMiddleware(settings))

  # Be careful with the routes.
  app.addRoute("/", homeView)
  app.addRoute("/login", loginView)
  app.addRoute("/api/v1/login", loginPost)
  #app.addRoute(urls.urlPatterns, "")
  app.run()
