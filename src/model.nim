import std/db_sqlite
import std/os

const dbFilepath = "dnd.db"

let dbInitialized = fileExists(dbFilepath)
let db = open(dbFilepath, "", "", "")

proc checkdb* =
  echo("Database already exists: " & $dbInitialized)

  if not dbInitialized:
    # Create the user table
    echo("Initializing database")
    db.exec(sql"""CREATE TABLE users (
                      id        INTEGER     PRIMARY KEY AUTOINCREMENT,
                      username  VARCHAR(50) NOT NULL,
                      password  VARCHAR(50) NOT NULL
                  )""")

    # add the admin user
    db.exec(sql"""INSERT INTO users (username, password)
                  VALUES ('admin', 'admin')
                  """)

proc checkPassword*(username, password: string): bool =
  let storedPassword = db.getValue(sql"SELECT password FROM users WHERE username=?",username)
  return password == storedPassword
