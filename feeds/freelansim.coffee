
parseIndex = ($) ->
  (($ '.task__title a').map (k, elem) -> {
      entry: 'freelansim-entry'
      content:
        href: ($ elem).attr('href')
    }).get()

parseEntry = ($) -> [
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

crawlTask = require '../task'

crawlIndex = crawlTask 'freelansim-index', [parseIndex]
crawlEntry = crawlTask 'freelansim-content', [parseEntry]

module.exports = (robot, task, doc) ->
  if task == 'initial'
    return [
      'http://freelansim.ru/tasks?page=1'
      'http://freelansim.ru/tasks?page=2'
    ].map crawlIndex

  switch doc.entry
    when 'freelansim-entry'
      robot.processIndex(task, doc).then (url) -> [
        crawlEntry url
      ] if url

    when 'freelansim-entry-content'
      robot.processEntry(task, doc)
