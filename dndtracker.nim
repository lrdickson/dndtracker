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

proc loginView(ctx: Context) {.async.} =
  resp createView(LOGIN_VIEW_JS, "Login")

proc loginPost(ctx: Context) {.async, gcsafe.} =
  # Get the user
  let username = ctx.getFormParamsOption("username").get()
  let (user, userFound) = getUser(username)
  if not userFound:
    resp "incorrect username or password"

  # Check the password
  let password = ctx.getFormParamsOption("password").get()
  if not user.passwordValid(password):
    resp "incorrect username or password"

  # Set the session
  ctx.session["username"] = user.name
  resp redirect("/")

proc logout(ctx: Context) {.async, gcsafe.} =
  # Clear the session
  ctx.session["username"] = ""
  resp redirect("/login")

proc getSessionUser(ctx: Context): (User, bool) =
  let username = ctx.session.getOrDefault("username", "")
  return getUser(username)

proc sessionActive(ctx: Context): bool =
  let (user, userFound) = ctx.getSessionUser()
  return userFound

proc homeView(ctx: Context) {.async.} =
  if not sessionActive(ctx):
    resp redirect("/login")
    return
  resp createView(MAIN_VIEW_JS)

proc settingsView(ctx: Context) {.async.} =
  if not sessionActive(ctx):
    resp redirect("/login")
    return
  resp createView(SETTINGS_VIEW_JS)

proc addCharacterApi(ctx: Context) {.async, gcsafe.} =
  # Get the session
  let (user, userFound) = ctx.getSessionUser()
  if not userFound:
    resp abort()
    return

  # Add a new character to the user
  addCharacter(user)

  # Return the status
  let data = %*{"status": "success"}
  resp jsonResponse(data)

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
  let sessionName = "dndtracker"
  app.use(sessionMiddleware(settings, sessionName))

  # Be careful with the routes.
  app.addRoute("/login", loginView, HttpGet)
  app.addRoute("/login", loginPost, HttpPost)
  app.addRoute("/logout", logout)
  app.addRoute("/", homeView)
  app.addRoute("/settings", settingsView)
  app.addRoute("/api/v1/addcharacter", addCharacterApi)
  #app.addRoute(urls.urlPatterns, "")
  app.run()
