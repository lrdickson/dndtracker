import norm / sqlite

import database
import models / user

proc prepareDatabase*(dbNeedsInitialized: bool) =
  var db = getDatabase()

  # Initialize the database if it hasn't been
  echo("Database needs initialized: " & $dbNeedsInitialized)
  if dbNeedsInitialized:
      db.createTables(newUser())
      var admin = newUser("admin", "admin", "")
      db.insert(admin)
