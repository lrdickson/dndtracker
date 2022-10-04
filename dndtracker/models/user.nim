import std/times

import norm/[model, sqlite]

import ../database

# =================== User ============================== #
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
  # Check if the user exists
  let db = getDatabase()
  if not db.exists(User, "name = ?", username): return false

  # Check if the password is correct
  var user = newUser()
  getDatabase().select(user, "User.name = ?", username)
  return password == user.password

# =================== Session ============================== #
type
  Session* = ref object of Model
    user*: User
    identifier*: string
    expire*: DateTime

