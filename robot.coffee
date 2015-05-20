#!/usr/bin/env coffee

_ = require 'lodash'
Q = require 'q'

baseurl = require './utils/baseurl'
adhocPrice = require './utils/adhoc/price'
adhocDate = require './utils/adhoc/date'

# ===========================================================================

log = (require 'bunyan').createLogger {
  name: 'scrapejobs'
  streams: [
    { level: 'trace', stream: process.stdout },
    { level: 'info', path: './log/robot.log' },
  ]
}

# ===========================================================================

nano = (require 'nano')('http://localhost:5984')
db = (nano.db.use 'scrapejobs')

checkEntry = (uri) ->
  Q.Promise (resolve) ->
    db.head uri, (err, _, headers) ->
      resolve(not err)

putEntry = (task, doc) ->
  Q.Promise (resolve) ->
    db.insert doc, task.target, (err, body) ->
      resolve()

# ===========================================================================

class Robot

  feeds = _.map [
    # './feeds/odesk'
    './feeds/elance'
    './feeds/people-per-hour'
    './feeds/freelansim'
  ], require

  induct: (task, doc) =>
    result = []

    ends = for feed in feeds
      Q.when(feed this, task, doc).then (next) ->
        result.push (_.toArray next)

    (Q.all ends).then -> [].concat result ...

  processIndex: (task, doc) ->
    uri = (baseurl doc.content.href, task.target)

    checkEntry(uri).then (exists) ->
      unless exists then log.info { uri: task.target }, "=> #{uri}"
      else log.info { uri: uri }, "entry crawled before"

      uri unless exists

  processEntry: (task, doc) ->
    doc.ts = Date.create()
    doc.adhoc = {
      published: (adhocDate doc.content.published)
      price: (adhocPrice doc.content.price)
    }

    putEntry(task, doc).then ->
      log.info { uri: task.target }, doc.content.title


robot = new Robot()

# ===========================================================================

schedule = (require 'wbt/schedule').TimeoutThrottle(5*1000)
# schedule = (require 'wbt/schedule').Direct

# ===========================================================================

log.info 'started'
start = new Date().getTime()

(require 'wbt/reactor')(robot.induct, schedule).then ->
  total = Math.ceil 1e-3 * ((new Date().getTime()) - start)

  log.info { totalTime: "#{total}s" }, 'finished'
