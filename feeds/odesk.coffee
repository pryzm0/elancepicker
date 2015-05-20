
parseIndex = ($) ->
  (($ '.jobs-list a[itemprop="url"]').map (k, elem) -> {
      entry: 'odesk-entry'
      content:
        href: ($ elem).attr('href')
    }).get()

parseEntry = ($) -> [
  entry: 'odesk-entry-content'
  content:
    title:
      ($ 'h1').text().trim()
    description:
      ($ '.air-card h2').filter((k, el) -> ($ el).text().toUpperCase() == 'DETAILS')
        .next('p').text().trim()
    price:
      ($ '.air-icon-payment-circle').parent().next('div').find('strong').text().trim()
    published:
      ($ 'span[itemprop="datePosted"]').text().trim()
]

crawlTask = require '../task'

crawlIndex = crawlTask 'odesk-index', [parseIndex]
crawlEntry = crawlTask 'odesk-content', [parseEntry]

module.exports = (robot, task, doc) ->
  if task == 'initial'
    return [
      'https://www.upwork.com/o/jobs/browse/?q=scraping'
      'https://www.upwork.com/o/jobs/browse/?q=scraping&page=2'
    ].map crawlIndex

  switch doc.entry
    when 'odesk-entry'
      robot.processIndex(task, doc).then (url) -> [
        crawlEntry url
      ] if url

    when 'odesk-entry-content'
      robot.processEntry(task, doc)
