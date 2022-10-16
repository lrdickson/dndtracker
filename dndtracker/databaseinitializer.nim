import norm / sqlite

import consts
import database
import models / [ character, user ]

proc prepareDatabase*(dbNeedsInitialized: bool) =
  var db = getDatabase()

  # Initialize the database if it hasn't been
  echo("Database needs initialized: " & $dbNeedsInitialized)
  if dbNeedsInitialized:
      # Create the tables
      db.createTables(newUser())
      db.createTables(newUserRole())
      db.createTables(newSession())
      db.createTables(newCharacter())

      # Add the admin user
      var admin = newUser("admin", "admin", "")
      db.insert(admin)
      var adminRole = newUserRole(admin, AdminRole)
      db.insert(adminRole)
