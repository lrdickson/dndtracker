import norm / sqlite

import consts
import database
import models / [ campaign, misc, user ]

proc prepareDatabase*(dbNeedsInitialized: bool) =
  var db = getDatabase()

  # Initialize the database if it hasn't been
  echo("Database needs initialized: " & $dbNeedsInitialized)
  if dbNeedsInitialized:
      # Create the tables
      db.createTables(newAppInfo())
      db.createTables(newUser())
      db.createTables(newUserRole())
      db.createTables(newSession())
      db.createTables(newCharacter())

      # Set the database version
      setAppInfo("DB_VERSION", "1")

      # Add the admin user
      var admin = newUser("admin", "admin", "")
      db.insert(admin)
      var adminRole = newUserRole(admin, AdminRole)
      db.insert(adminRole)
