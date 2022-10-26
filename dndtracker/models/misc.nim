import norm/model

import ../database
import ../db_backend

type
  AppInfo* = ref object of Model
    key*: string
    value*: string

proc newAppInfo*(key, value: string): AppInfo =
  AppInfo(key: key, value: value)

proc newAppInfo*: AppInfo =
  AppInfo(key: "", value: "")

proc setAppInfo*(key, value: string) =
  let db = getDatabase()
  if db.exists(AppInfo, "key = ?", key):
    var appInfo: AppInfo
    db.select(appInfo, "AppInfo.key = ?", key)
    appInfo.value = value
    db.update(appInfo)
  else:
    var appInfo = newAppInfo(key, value)
    db.insert(appInfo)

proc getAppInfo*(key: string): string =
  # Check if the key exists in the AppInfo table
  let db = getDatabase()
  if not db.exists(AppInfo, "key = ?", key): return ""

  # Get the AppInfo value
  var appInfo: AppInfo
  db.select(appInfo, "key = ?", key)
  return appInfo.value

