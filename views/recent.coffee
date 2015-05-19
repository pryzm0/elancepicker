
nano = (require 'nano')('http://localhost:5984')
db = (nano.db.use 'scrapejobs')

module.exports = (req, res) ->
  page = parseInt req.query.page
  page = 0 if (isNaN page) or page < 0

  pageSize = 10

  param =
    skip: pageSize * page
    limit: pageSize
    descending: true

  console.log 'recent', param

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

      res.json { total: totalCount, list: entryList }
