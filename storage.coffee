nano = (require 'nano')('http://localhost:5984')
db = (nano.db.use 'scrapejobs')

Q = require 'q'

module.exports =
  checkEntry: (uri) -> Q.Promise (resolve) ->
    db.head uri, (err, _, headers) ->
      resolve(not err)

  putEntry: (task, doc) -> Q.Promise (resolve) ->
    db.insert doc, task.target, (err, body) ->
      resolve()
