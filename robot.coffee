#!/usr/bin/env coffee

_ = require 'lodash'
Q = require 'q'

nano = (require 'nano')('http://localhost:5984')
db = (nano.db.use 'scrapejobs')

log = (require 'bunyan').createLogger {
  name: 'scrapejobs'
  streams: [
    { level: 'trace', stream: process.stdout },
    { level: 'info', path: './log/robot.log' },
  ]
}

{ TimeoutThrottle } = require 'wbt/schedule'
{ DomCropper } = require 'wbt/cropper/dom'

baseurl = require './utils/baseurl'
adhocDate = require './utils/adhoc-date'
adhocPrice = require './utils/adhoc-price'


# ===========================================================================

SAFARI_IPAD = 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25'
ICEWEASEL = 'Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20121202 Firefox/17.0 Iceweasel/17.0.1'

class LocalAgent

  request = (require 'request').defaults
    headers:
      'User-Agent': ICEWEASEL

  fetch: (url) -> request url


# ===========================================================================

checkEntry = (uri) ->
  Q.Promise (resolve) ->
    db.head uri, (err, _, headers) ->
      resolve(not err)

putEntry = (task, doc) ->
  Q.Promise (resolve) ->
    db.insert doc, task.target, (err, body) ->
      resolve()

# ===========================================================================

extractFreelansimEntryIndex = ($) ->
  docs = ($ '.task__title a').map (k, elem) ->
    entry: 'freelansim-entry'
    content:
      href: ($ elem).attr('href')
  docs.get()

extractFreelansimEntryInfo = ($) -> [
  entry: 'freelansim-entry-content'
  content:
    title:
      ($ 'h2.task__title').text().trim()
    description:
      ($ 'div.task__description').text().trim()
    price:
      ($ 'div.task__price').text().trim()
    tags:
      (($ 'a.tags__item_link').map (k, elem) -> ($ elem).text()).get()
    published:
      ($ 'span.icon_task_publish_at').next().text().trim()
]

extractElanceEntryIndex = ($) ->
  docs = ($ '.jobCard a.title').map (k, elem) ->
    entry: 'elance-entry'
    content:
      href: ($ elem).attr('href')
  docs.get()

extractElanceEntryInfo = ($) -> [
  entry: 'elance-entry-content'
  content:
    title:
      ($ '#jobTitle div.left').text().trim()
    description:
      ($ '#jobDescText').text().trim()
    price:
      ($ 'li.spr-budget').text().trim()
    tags:
      (($ '#jobDetailSkills a').map (k, elem) -> ($ elem).text()).get()
    published:
      ($ 'li.spr-posted_date').text().trim().replace(/^\w+:\s*/, '')
]

extractPphEntryIndex = ($) ->
  docs = ($ 'h3.title a').map (k, elem) ->
    entry: 'pph-entry'
    content:
      href: ($ elem).attr('href')
  docs.get()

extractPphEntryInfo = ($) -> [
  entry: 'pph-entry-content'
  content:
    title:
      ($ 'header h1').text().trim()
    description:
      ($ 'div.project-description').text().trim()
    price:
      ($ 'small.price-approx').first().text().replace(/[^$0-9]/g, '')
    published:
      ($ 'i.fpph-clock-wall').parents('li').first().find('time').text().trim()
]

# ===========================================================================

jobAgent = new LocalAgent()

crawlFreelansimIndex = (url) ->
  task: 'freelansim-index'
  target: url
  agent: jobAgent
  buffer: 30
  croppers: [DomCropper]
  dom: [extractFreelansimEntryIndex]

crawlFreelansimEntry = (url) ->
  task: 'freelansim-content'
  target: url
  agent: jobAgent
  croppers: [DomCropper]
  dom: [extractFreelansimEntryInfo]

crawlElanceIndex = (url) ->
  task: 'elance-index'
  target: url
  agent: jobAgent
  buffer: 30
  croppers: [DomCropper]
  dom: [extractElanceEntryIndex]

crawlElanceEntry = (url) ->
  task: 'elance-content'
  target: url
  agent: jobAgent
  croppers: [DomCropper]
  dom: [extractElanceEntryInfo]

crawlPphIndex = (url) ->
  task: 'pph-index'
  target: url
  agent: jobAgent
  buffer: 30
  croppers: [DomCropper]
  dom: [extractPphEntryIndex]

crawlPphEntry = (url) ->
  task: 'pph-content'
  target: url
  agent: jobAgent
  croppers: [DomCropper]
  dom: [extractPphEntryInfo]

# ===========================================================================

processIndex = (task, doc, crawler) ->
  uri = (baseurl doc.content.href, task.target)

  checkEntry(uri).then (exists) ->
    unless exists
      log.info { uri: task.target }, "=> #{uri}"
      return [crawler uri]
    log.info { uri: uri }, "entry crawled before"


induct = (task, doc) ->
  return if task == 'initial'

    freelansim = [
      # 'http://freelansim.ru/tasks?q=%D0%BF%D0%B0%D1%80%D1%81'
      'http://freelansim.ru/tasks?page=1'
      'http://freelansim.ru/tasks?page=2'
    ].map (url) -> crawlFreelansimIndex url

    elance = [
      'https://www.elance.com/r/jobs/q-Web%20scraping'
      'https://www.elance.com/r/jobs/q-Crawling'
    ].map (url) -> crawlElanceIndex url

    pph = [
      'http://www.peopleperhour.com/freelance-scraping-jobs?sort=latest'
      'http://www.peopleperhour.com/freelance-crawl-jobs?sort=latest'
    ].map (url) -> crawlPphIndex url

    Q.resolve [].concat(freelansim, elance, pph)

  switch doc.entry
    when 'freelansim-entry'
      processIndex task, doc, crawlFreelansimEntry

    when 'elance-entry'
      processIndex task, doc, crawlElanceEntry

    when 'pph-entry'
      processIndex task, doc, crawlPphEntry

    when 'freelansim-entry-content', 'elance-entry-content', 'pph-entry-content'
      doc.ts = Date.create()
      doc.adhoc = {
        published: (adhocDate doc.content.published)
        price: (adhocPrice doc.content.price)
      }

      putEntry(task, doc).then ->
        log.info { uri: task.target }, doc.content.title

    else
      Q.resolve()


start = new Date().getTime()
(require 'wbt/reactor')(induct, TimeoutThrottle(5*1000)).then ->
  total = Math.ceil 1e-3 * ((new Date().getTime()) - start)

  log.info { totalTime: "#{total}s" }, 'done'
