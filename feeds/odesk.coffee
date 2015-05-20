{ DomCropper } = require 'wbt/cropper/dom'
localAgent = require '../utils/local-agent'


parseIndex = ($) ->
  docs = ($ '.jobs-list a[itemprop="url"]').map (k, elem) ->
    entry: 'odesk-entry'
    content:
      href: ($ elem).attr('href')
  docs.get()

parseEntry = ($) -> [
  entry: 'odesk-entry-content'
  content:
    title:
      ($ 'h1').text().trim()
    # description:
    #   ($ '#jobDescText').text().trim()
    # price:
    #   ($ 'li.spr-budget').text().trim()
    # tags:
    #   (($ '#jobDetailSkills a').map (k, elem) -> ($ elem).text()).get()
    # published:
    #   ($ 'li.spr-posted_date').text().trim().replace(/^\w+:\s*/, '')
]

crawlIndex = (url) ->
  task: 'odesk-index'
  target: url
  agent: localAgent
  buffer: 20
  croppers: [DomCropper]
  dom: [parseIndex]

crawlEntry = (url) ->
  task: 'odesk-content'
  target: url
  agent: localAgent
  croppers: [DomCropper]
  dom: [parseEntry]


module.exports = (robot, task, doc) ->
  if task == 'initial'
    return [
      'https://www.upwork.com/o/jobs/browse/?q=scraping'
    ].map (url) -> crawlIndex url

  switch doc.entry
    when 'odesk-entry'

      robot.processIndex(task, doc).then (url) ->
        console.log 'ODESK', url
        [crawlEntry url] if url

    when 'elance-entry-content'
      console.log 'ODESK', doc.content
