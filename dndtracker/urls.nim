import prologue

import routes/api


let urlPatterns* = @[
  pattern("/api/v1/adduser", postadduser, HttpPost)
]
