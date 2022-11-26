import consts
import db_backend
import models / [ campaign, misc, user ]

proc prepareDatabase*(dbNeedsInitialized: bool) =
  # Initialize the database if it hasn't been
  echo("Database needs initialized: " & $dbNeedsInitialized)
  if dbNeedsInitialized:
    withDb:
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
      var adminRole = newUserRole(admin, ord(UserRoleType.Admin))
      db.insert(adminRole)
