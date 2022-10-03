import norm/[model, sqlite]

import ../database

type
  User* = ref object of Model
    name*: string
    password*: string
    email*: string

func newUser*(name, password, email: string): User =
  User(name: name, password: password, email: email)

func newUser*: User =
  newUser("", "", "")

proc checkPassword*(username, password: string): bool =
  var user = newUser()
  getDatabase().select(user, "User.name = ?", username)
  return password == user.password
