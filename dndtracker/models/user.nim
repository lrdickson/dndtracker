import std/base64
import std/locks
import std/times
import std/random
randomize()

import nimcrypto
import nimcrypto/pbkdf2
import std/[logging, options]
import norm/model

import ../db_backend

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
      # TODO: replace with a better random number generator
      characterIndex = rand(len(characters) - 1)
    let randomChar = $characters[characterIndex]
    str = str & randomChar
  return str

proc getPasswordHash(password, salt: string): string =
  var hctx: HMAC[sha256]
  # TODO: move this into a settings file
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

proc addUser*(username, password, email: string) =
  withDb:
    var user = newUser(username, password, email)
    db.insert(user)

proc checkPassword*(username, password: string): bool =
  # Get the user
  var user = newUser()
  withDb:
    if not db.exists(User, "name = ?", username): return false
    db.select(user, "User.name = ?", username)

  # Check if the password is correct
  let passwordHash = getPasswordHash(password, user.salt)
  return passwordHash == user.password

proc changePassword*(user:var User, password: string): bool =
  # Change the password
  let newSalt = randString(10)
  let passwordHash = getPasswordHash(password, newSalt)
  user.password = passwordHash
  user.salt = newSalt
  withDb:
    db.update(user)
  return true

proc changePassword*(username, password: string): bool =
  # Get the user
  var user = newUser()
  withDb:
    if not db.exists(User, "name = ?", username): return false
    db.select(user, "User.name = ?", username)

  # Change the password
  return changePassword(user, password)

# =================== Role ============================== #
type
  UserRole* = ref object of Model
    user*: User
    role*: int

proc newUserRole*(user: User, role: int): UserRole =
  return UserRole(user: user, role: role)

proc newUserRole*: UserRole =
  return UserRole(user: newUser(), role: 0)

proc getUserRoles*(user: User): seq[UserRole] =
  var roles = @[newUserRole()]
  withDb:
    db.selectOneToMany(user, roles)
  return roles

proc getUserRolesInt*(user: User): seq[int] =
  var userRoles: seq[int] = @[]
  for role in getUserRoles(user):
    userRoles.add(role.role)
  return userRoles

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

proc beginSession*(username, password: string): (string, DateTime)=
  # Get the user
  var user = newUser()
  var session: Session
  withDb:
    if not db.exists(User, "name = ?", username): return ("", now().utc)
    db.select(user, "User.name = ?", username)

    # Check if the password is correct
    let passwordHash = getPasswordHash(password, user.salt)
    if passwordHash != user.password:
      return ("", now().utc)

    # Add a session to the database
    session = newSession(user)
    db.insert(session)
  return (session.identifier, session.expire)

proc endSession*(sessionId: string) =
  # Check if the session is still in the database
  withDb:
    if not db.exists(Session, "identifier = ?", sessionId):
      return

    # Delete the session
    var session = newSession()
    db.select(session, "Session.identifier = ?", sessionId)
    db.delete(session)

proc getSession*(sessionId: string): (bool, Session) =
  # Check if the session is still in the database
  withDb:
    if not db.exists(Session, "identifier = ?", sessionId):
      return (false, newSession())

    # Delete the session
    var session = newSession()
    db.select(session, "Session.identifier = ?", sessionId)
    return (true, session)

