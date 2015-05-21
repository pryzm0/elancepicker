#!/usr/bin/env coffee

_ = require 'lodash'
Q = require 'q'

log = require './logger'

class Robot

  filter = /scrap|crawl|pars|grab|extract|скрап|скрейп|карул|парсер|парси|граб|curl|wget/i
  checkScrape = (doc) ->
    (filter.test doc.content.title) or
    (filter.test doc.content.description)

  baseurl = require './utils/baseurl'
  adhocPrice = require './utils/adhoc/price'
  adhocDate = require './utils/adhoc/date'

  feeds = _.map [
    './feeds/odesk'
    './feeds/elance'
    './feeds/people-per-hour'
    './feeds/freelansim'
  ], require

  constructor: (@storage) ->

  induct: (task, doc) =>
    result = []

    ends = for feed in feeds when (value = feed this, task, doc)
      (Q.when value).then (next) -> result.push (_.toArray next)

    (Q.all ends).then -> [].concat result ...

  processIndex: (task, doc) ->
    uri = (baseurl doc.content.href, task.target)

    @storage.checkEntry(uri)
      .then (exists) ->
        unless exists then log.info { uri: task.target }, "=> #{uri}"
        else log.info { uri: uri }, "entry crawled before"

        uri unless exists
      .fail (err) ->
        log.error err

  processEntry: (task, doc) ->
    doc.ts = Date.create()
    doc.adhoc = {
      published: (adhocDate doc.content.published)
      price: (adhocPrice doc.content.price)
      isScrape: (checkScrape doc)
    }

    @storage.putEntry(task, doc)
      .then ->
        log.info { uri: task.target }, doc.content.title
      .fail (err) ->
        log.error err

    Q.resolve()


(require './storage').then (storage) ->
  robot = new Robot(storage)

  schedule = (require 'wbt/schedule').TimeoutThrottle(5*1000)
  # schedule = (require 'wbt/schedule').Direct

  log.trace 'started'
  start = Date.now()

  (require 'wbt/reactor')(robot.induct, schedule).then ->
    end = Date.now()

    log.trace { totalTime: (end - start) }, 'finished'

    storage.disconnect()
