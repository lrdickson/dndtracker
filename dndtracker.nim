import std / htmlgen

import jester

proc addTemplate(bodyHtml, pageTitle: string): string =
  let page = html(
    head(
      title(pageTitle)),
    body(bodyHtml))
  return page

proc addTemplate(bodyHtml: string): string =
  return bodyHtml.addTemplate("DND Tracker")

proc home: string =
  let page = h1("DND Power").addTemplate
  return page

proc login: string =
  let page = `div`(
    `div`(
      label("Username:"),
      input(placeholder="Enter Username", name="username")),
    `div`(
      label("Password:"),
      input(type="password", placeholder="Enter Password", name="username")),
  ).addTemplate("Login")
  return page

routes:
  get "/":
    resp home()
  get "/login":
    resp login()
  get "/login/":
    resp login()
