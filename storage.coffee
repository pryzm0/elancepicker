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

  getPage: (page, pageSize) -> Q.Promise (resolve) ->
    param =
      skip: pageSize * page
      limit: pageSize
      descending: true

    db.view 'app', 'recentTotalCount', (err, data) ->
      totalCount = data.rows[0].value

      db.view 'app', 'recent', param, (err, data) ->
        unless data
          entryList = []
        else
          entryList = data.rows.map (row) ->
            target: row.id
            title: row.value.content.title
            description: row.value.content.description
            price: row.value.adhoc.price
            published: row.value.adhoc.published
            discovered: row.value.ts

        resolve { total: totalCount, list: entryList }
