import norm / sqlite

var db: DbConn
const DB_FILEPATH* = "dnd.db"

proc openDbConn* =
  db = open(DB_FILEPATH, "", "", "")

proc getDatabase*: DbConn =
  return db
