import std/base64
import std/locks
import std/times
import std/random
randomize()

import nimcrypto
import nimcrypto/pbkdf2
import norm/[model, sqlite]

import ../database

# =================== User ============================== #
type
  User* = ref object of Model
    name*: string
    password*: string
    salt*: string
    email*: string

var randLock: Lock
proc randString(length: int): string =
  const characters = [ '0'..'9', 'a'..'z', 'A'..'Z' ]
  var str = ""
  for i in 1..length:
    var characterIndex: int
    withLock(randLock):
      characterIndex = rand(len(characters) - 1)
    let randomChar = $characters[characterIndex]
    str = str & randomChar
  return str

proc getPasswordHash(password, salt: string): string =
  var hctx: HMAC[sha256]
  let secretKey = "SuperSecretKey"
  hctx.init(secretKey)
  var passwordHash: array[32, byte]
  let iterations = 18000
  discard pbkdf2(hctx, password, salt, iterations, passwordHash)
  return encode(passwordHash)

proc newUser*(name, password, email: string): User =
  let salt = randString(10)
  let passwordHash = getPasswordHash(password, salt)
  User(name: name, password: passwordHash, salt: salt, email: email)

proc newUser*: User =
  newUser("", "", "")

proc checkPassword*(username, password: string): bool =
  # Get the user
  let db = getDatabase()
  if not db.exists(User, "name = ?", username): return false
  var user = newUser()
  getDatabase().select(user, "User.name = ?", username)

  # Check if the password is correct
  let passwordHash = getPasswordHash(password, user.salt)
  return passwordHash == user.password

# =================== Session ============================== #
type
  Session* = ref object of Model
    user*: User
    identifier*: string
    expire*: DateTime

proc newSession*(user: User): Session =
  let identifier = randString(16)
  let expire = now().utc + initDuration(minutes = 30)
  return Session(user: user, identifier: identifier, expire: expire)

proc newSession*: Session =
  return Session(user: newUser(), identifier: "", expire: now().utc)

proc beginSession*(user: User): (string, DateTime) =
  # Add a session to the database
  var session = newSession(user)
  let db = getDatabase()
  db.insert(session)

  # Return the session identifier
  return (session.identifier, session.expire)
