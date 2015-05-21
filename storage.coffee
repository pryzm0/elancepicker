Q = require 'q'


Storage = (client) ->
  checkEntry: (uri) -> Q.Promise (resolve, reject) ->
    qs = '''
      SELECT COUNT(*) AS CNT
      FROM jobentry WHERE uri = $1
    '''

    client.query qs, [uri], (err, result) ->
      return if err
        reject(err)

      resolve((parseInt result.rows[0].cnt) > 0)

  putEntry: (task, doc) -> Q.Promise (resolve, reject) ->
    qs = '''
      INSERT INTO jobentry (uri, title, description, price,
        post_date, adhoc_price, adhoc_post_date, adhoc_is_scrape)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    '''

    params = []
    params.push(task.target)
    params.push(doc.content.title)
    params.push(doc.content.description)
    params.push(doc.content.price)
    params.push(doc.content.published)
    params.push(doc.adhoc.price)
    params.push(doc.adhoc.published.toISOString())
    params.push(doc.adhoc.isScrape)

    client.query qs, params, (err, result) ->
      return if err
        reject(err)

      resolve(result)

  getPage: (page, pageSize) -> Q.Promise (resolve, reject) ->
    qsCount = 'SELECT COUNT(*) AS CNT FROM jobentry WHERE adhoc_is_scrape'

    qs = '''
      SELECT * FROM jobentry
      WHERE adhoc_is_scrape
      ORDER BY crawl_date DESC
      LIMIT $1 OFFSET $2
    '''

    params = [pageSize, pageSize*page]

    client.query qsCount, [], (err, result) ->
      return if err
        reject(err)

      totalCount = result.rows[0].cnt

      client.query qs, params, (err, result) ->
        return if err
          reject(err)

        entryList = result.rows.map (row) ->
          target: row.uri
          title: row.title
          description: row.description
          price: row.adhoc_price
          published: row.adhoc_post_date
          discovered: row.crawl_date

        resolve {
          total: totalCount
          list: entryList
        }

  disconnect: ->
    client.end()


module.exports = Q.Promise (resolve, reject) ->
  (require 'pg').connect process.env.DATABASE_URL, (err, client) ->
    return if err
      reject(err)

    resolve(Storage client)
