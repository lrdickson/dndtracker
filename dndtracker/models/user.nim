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
proc genSalt: string =
  const saltLen = 10
  const characters = [ '0'..'9', 'a'..'z' ]
  var salt = ""
  for i in 1..saltLen:
    var characterIndex: int
    withLock(randLock):
      characterIndex = rand(len(characters) - 1)
    let randomChar = $characters[characterIndex]
    salt = salt & randomChar
  return salt

proc getPasswordHash(password, salt: string): string =
  var hctx: HMAC[sha256]
  let secretKey = "SuperSecretKey"
  hctx.init(secretKey)
  var passwordHash: array[32, byte]
  let iterations = 18000
  discard pbkdf2(hctx, password, salt, iterations, passwordHash)
  return encode(passwordHash)

proc newUser*(name, password, email: string): User =
  let salt = genSalt()
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

