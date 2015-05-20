
parseIndex = ($) ->
  (($ 'h3.title a').map (k, elem) -> {
      entry: 'pph-entry'
      content:
        href: ($ elem).attr('href')
    }).get()

parseEntry = ($) -> [
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

crawlTask = require '../task'

crawlIndex = crawlTask 'pph-index', [parseIndex]
crawlEntry = crawlTask 'pph-content', [parseEntry]

module.exports = (robot, task, doc) ->
  if task == 'initial'
    return [
      'http://www.peopleperhour.com/freelance-scraping-jobs?sort=latest'
      'http://www.peopleperhour.com/freelance-crawl-jobs?sort=latest'
    ].map crawlIndex

  switch doc.entry
    when 'pph-entry'
      robot.processIndex(task, doc).then (url) -> [
        crawlEntry url
      ] if url

    when 'pph-entry-content'
      robot.processEntry(task, doc)
