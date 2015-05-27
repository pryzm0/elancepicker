Q = require 'q'

module.exports =
  checkEntry: (uri) -> Q.resolve(false)

  putEntry: (task, doc) -> Q.resolve()

  getPage: (page, pageSize) -> Q.reject()
