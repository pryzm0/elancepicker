
storage = require '../storage'

module.exports = (req, res) ->
  page = parseInt req.query.page
  page = 0 if (isNaN page) or page < 0

  pageSize = 10

  storage.getPage(page, pageSize)
    .then (data) -> res.json data
