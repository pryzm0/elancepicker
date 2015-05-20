
parseIndex = ($) ->
  (($ '.jobCard a.title').map (k, elem) -> {
      entry: 'elance-entry'
      content:
        href: ($ elem).attr('href')
    }).get()

parseEntry = ($) -> [
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

crawlTask = require '../task'

crawlIndex = crawlTask 'elance-index', [parseIndex]
crawlEntry = crawlTask 'elance-content', [parseEntry]

module.exports = (robot, task, doc) ->
  if task == 'initial'
    return [
      'https://www.elance.com/r/jobs/q-Web%20scraping'
      'https://www.elance.com/r/jobs/q-Crawling'
    ].map crawlIndex

  switch doc.entry
    when 'elance-entry'
      robot.processIndex(task, doc).then (url) -> [
        crawlEntry url
      ] if url

    when 'elance-entry-content'
      robot.processEntry(task, doc)
