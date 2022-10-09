import norm / sqlite

import consts
import database
import models / user

proc prepareDatabase*(dbNeedsInitialized: bool) =
  var db = getDatabase()

  # Initialize the database if it hasn't been
  echo("Database needs initialized: " & $dbNeedsInitialized)
  if dbNeedsInitialized:
      # Create the user table
      db.createTables(newUser())
      var admin = newUser("admin", "admin", "")
      db.insert(admin)

      # Create the user role table
      db.createTables(newUserRole())
      var adminRole = newUserRole(admin, AdminRole)
      db.insert(adminRole)

      # Create the session table
      db.createTables(newSession())
